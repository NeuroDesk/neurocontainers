#!/usr/bin/env python3
import yaml
import subprocess
import os
import sys
import urllib.request
import argparse
import shutil
import jinja2
import platform
import hashlib

GLOBAL_MOUNT_POINT_LIST = [
    "/afm01",
    "/afm02",
    "/cvmfs",
    "/90days",
    "/30days",
    "/QRISdata",
    "/RDS",
    "/data",
    "/short",
    "/proc_temp",
    "/TMPDIR",
    "/nvme",
    "/neurodesktop-storage",
    "/local",
    "/gpfs1",
    "/working",
    "/winmounts",
    "/state",
    "/tmp",
    "/autofs",
    "/cluster",
    "/local_mount",
    "/scratch",
    "/clusterdata",
    "/nvmescratch",
]

ARCHITECTURES = {
    "x86_64": "x86_64",
    "arm64": "aarch64",
    "aarch64": "aarch64",
}


def get_cache_dir():
    # Get the cache directory
    cache_dir = os.path.join(os.path.expanduser("~"), ".cache", "neurocontainers")
    if not os.path.exists(cache_dir):
        os.makedirs(cache_dir)

    return cache_dir


_jinja_env = jinja2.Environment(undefined=jinja2.StrictUndefined)


class LocalBuildContext(object):
    def __init__(self, context, cache_id):
        self.context = context
        self.run_args = []
        self.mounted_cache = False
        self.cache_id = cache_id

    def try_mount_cache(self):
        target = "/.neurocontainer-cache/" + self.cache_id

        if self.mounted_cache:
            return target

        cache_dir = self.context.get_context_cache_dir(self.cache_id)

        cache_relpath = os.path.relpath(cache_dir, self.context.build_directory)

        self.run_args.append(
            f"--mount=type=bind,source={cache_relpath},target={target},readonly"
        )
        self.mounted_cache = True

        return target

    def ensure_context_cached(self, cache_filename, guest_filename):
        # Check if the file is already cached
        context_cache_dir = self.context.get_context_cache_dir(self.cache_id)

        cached_file = os.path.join(context_cache_dir, guest_filename)
        if os.path.exists(cached_file):
            return guest_filename

        # if not then link it from the cache
        os.link(cache_filename, cached_file)

        # return the filename
        return guest_filename

    def get_file(self, filename):
        file_info = self.context.files.get(filename)
        if file_info is None:
            raise ValueError(f"File {filename} not found.")

        if "cached_path" in file_info:
            cache_dir = self.try_mount_cache()
            cache_filename = self.ensure_context_cached(
                file_info["cached_path"],
                filename,
            )
            return cache_dir + "/" + cache_filename
        elif "context_path" in file_info:
            return file_info["context_path"]
        else:
            raise ValueError("File has no cached path or context path.")

    def methods(self):
        return {
            "get_file": self.get_file,
        }


def hash_obj(obj):
    # Hash the object using SHA256
    if isinstance(obj, str):
        obj = obj.encode("utf-8")
    elif isinstance(obj, dict):
        obj = yaml.dump(obj).encode("utf-8")
    elif isinstance(obj, list):
        obj = yaml.dump(obj).encode("utf-8")
    else:
        raise ValueError("Object type not supported.")

    return hashlib.sha256(obj).hexdigest()


class BuildContext(object):
    def __init__(self, name, version, arch):
        self.name = name
        self.version = version
        self.original_version = version
        self.arch = arch
        self.max_parallel_jobs = os.cpu_count()
        self.options = {}
        self.option_info = {}
        self.files = {}

    def add_option(self, key, description="", default=False, version_suffix=""):
        self.options[key] = default
        self.option_info[key] = {
            "description": description,
            "default": default,
            "version_suffix": version_suffix,
        }

    def set_option(self, key, value):
        if key not in self.options:
            raise ValueError(f"Option {key} not found.")

        if value == "true":
            self.options[key] = True
            self.calculate_version()
        elif value == "false":
            self.options[key] = False
        else:
            raise ValueError(f"Value {value} not supported.")

    def calculate_version(self):
        version = self.original_version
        for key, value in self.options.items():
            version_suffix = self.option_info[key]["version_suffix"]
            if value and version_suffix != "":
                version += version_suffix

        self.version = version

    def set_max_parallel_jobs(self, max_parallel_jobs):
        self.max_parallel_jobs = max_parallel_jobs

    def get_context_cache_dir(self, cache_id):
        cache_dir = os.path.join(self.build_directory, "cache", cache_id)
        if not os.path.exists(cache_dir):
            os.makedirs(cache_dir)

        return cache_dir

    def render_template(self, template, locals=None, methods=None):
        tpl = _jinja_env.from_string(template)
        return tpl.render(
            context=self,
            arch=self.arch,
            parallel_jobs=self.max_parallel_jobs,
            local=locals,
            **(methods or {}),
        )

    def execute_condition(self, condition, locals=None):
        result = self.render_template("{{" + condition + "}}", locals=locals)
        return result == "True"

    def execute_template(self, obj, locals=None, methods=None):
        if type(obj) == str:
            try:
                return self.render_template(obj, locals=locals, methods=methods)
            except jinja2.exceptions.TemplateSyntaxError as e:
                raise ValueError(f"Template syntax error: {e} in {obj}")
        elif type(obj) == list:
            return [
                self.execute_template(o, locals=locals, methods=methods) for o in obj
            ]
        elif type(obj) == dict:
            if "try" in obj:
                for value in obj["try"]:
                    if self.execute_condition(
                        value["condition"], locals=locals, methods=methods
                    ):
                        return self.execute_template(value["value"])

                raise NotImplementedError("Try not implemented.")
        else:
            raise ValueError("Template object not supported.")

    def add_file(self, file, recipe_path, check_only=False):
        name = file["name"]

        if name == "":
            raise ValueError("File name cannot be empty.")

        output_filename = os.path.join(self.build_directory, name)

        if "url" in file:
            # download and cache the file
            url = self.execute_template(file["url"])
            cached_file = download_with_cache(url, check_only=check_only)

            if "executable" in file and file["executable"]:
                os.chmod(output_filename, 0o755)

            self.files[name] = {
                "cached_path": cached_file,
            }
        else:
            if "contents" in file:
                contents = self.execute_template(file["contents"])
                with open(output_filename, "w") as f:
                    f.write(contents)
            elif "filename" in file:
                base = os.path.abspath(recipe_path)
                filename = os.path.join(base, file["filename"])
                with open(output_filename, "wb") as f:
                    with open(filename, "rb") as f2:
                        f.write(f2.read())
            else:
                raise ValueError("File contents not found.")

            if "executable" in file and file["executable"]:
                os.chmod(output_filename, 0o755)

            self.files[name] = {
                "context_path": file["filename"],
            }

    def file_exists(self, filename):
        return os.path.exists(os.path.join(self.build_directory, filename))

    def generate_cache_id(self, directive):
        return "h" + directive[:8]

    def build_neurodocker(self, build_directive, deploy):
        args = ["neurodocker", "generate", "docker"]

        base = self.execute_template(build_directive.get("base-image") or "")
        pkg_manager = self.execute_template(build_directive.get("pkg-manager") or "")

        if base == "" or pkg_manager == "":
            raise ValueError("Base image or package manager cannot be empty.")

        args += ["--base-image", base, "--pkg-manager", pkg_manager]

        mount_point_list = " ".join(GLOBAL_MOUNT_POINT_LIST)

        args += [
            "--run=printf '#!/bin/bash\\nls -la' > /usr/bin/ll",
            "--run=chmod +x /usr/bin/ll",
            f"--run=mkdir -p {mount_point_list}",
        ]

        def add_directive(directive, locals):
            if "condition" in directive:
                if not self.execute_condition(directive["condition"], locals=locals):
                    return []

            if "install" in directive:
                if type(directive["install"]) == str:
                    return ["--install"] + self.execute_template(
                        [
                            f
                            for f in directive["install"].replace("\n", " ").split(" ")
                            if f != ""
                        ],
                        locals=locals,
                    )
                elif type(directive["install"]) == list:
                    return ["--install"] + self.execute_template(
                        directive["install"], locals=locals
                    )
                else:
                    raise ValueError("Install directive must be a string or list.")
            elif "run" in directive:
                local = LocalBuildContext(
                    self, self.generate_cache_id(hash_obj(directive))
                )
                args = self.execute_template(
                    directive["run"],
                    locals=locals,
                    methods=local.methods(),
                )
                run_param = (
                    "--run=" + " ".join(local.run_args) + " " + " \\\n && ".join(args)
                )
                return [run_param]
            elif "workdir" in directive:
                return [
                    "--workdir",
                    self.execute_template(directive["workdir"], locals=locals),
                ]
            elif "user" in directive:
                return [
                    "--user",
                    self.execute_template(directive["user"], locals=locals),
                ]
            elif "entrypoint" in directive:
                return [
                    "--entrypoint",
                    self.execute_template(directive["entrypoint"], locals=locals),
                ]
            elif "environment" in directive:
                if directive["environment"] == None:
                    raise ValueError("Environment must be a map of keys and values.")

                ret = []
                for key, value in directive["environment"].items():
                    ret += [
                        "--env",
                        f"{self.execute_template(key, locals=locals)}={self.execute_template(value, locals=locals)}",
                    ]
                return ret
            elif "template" in directive:
                name = self.execute_template(
                    directive["template"].get("name") or "", locals=locals
                )
                if name == "":
                    raise ValueError("Template name cannot be empty.")

                items = [
                    f"{k}={self.execute_template(v, locals=locals)}"
                    for k, v in directive["template"].items()
                    if k != "name"
                ]

                return ["--" + name] + items
            elif "copy" in directive:
                args = []
                if type(directive["copy"]) == str:
                    args = self.execute_template(
                        directive["copy"].split(" "), locals=locals
                    )
                elif type(directive["copy"]) == list:
                    args = self.execute_template(directive["copy"], locals=locals)

                if len(args) == 2:
                    # check to make sure the first reference is a file and it exists.
                    if not self.file_exists(args[0]):
                        raise ValueError(f"File {args[0]} does not exist.")

                return ["--copy"] + args
            elif "group" in directive:
                variables = {**locals}

                if "with" in directive:
                    for key, value in directive["with"].items():
                        variables[key] = self.execute_template(value, locals=variables)

                ret = []

                for item in directive["group"]:
                    ret += add_directive(item, locals=variables)

                return ret
            else:
                raise ValueError(f"Directive {directive} not supported.")

        locals = {}

        for directive in build_directive["directives"]:
            args += add_directive(directive, locals=locals)

        if deploy is not None:
            if "path" in deploy:
                args += [
                    "--env",
                    "DEPLOY_PATH=" + ":".join(self.execute_template(deploy["path"])),
                ]
            if "bins" in deploy:
                args += [
                    "--env",
                    "DEPLOY_BINS=" + ":".join(self.execute_template(deploy["bins"])),
                ]

        args += ["--copy", "README.md", "/README.md"]

        p = subprocess.Popen(args, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        output, _ = p.communicate(input=b"y\n")

        output = output.decode("utf-8")

        # Hack to remove the localedef installation since neurodocker adds it.
        if build_directive.get("fix-locale-def"):
            # go though the output looking for the first line containing localedef and remove it.
            lines = output.split("\n")
            for i, line in enumerate(lines):
                if "localedef" in line:
                    lines[i] = ""
                    break
            output = "\n".join(lines)

        return output


def http_get(url):
    with urllib.request.urlopen(url) as response:
        return response.read().decode("utf-8")


def build_tinyrange(tinyrange_path, description_file, output_dir, name, version):
    tinyrange_config = None
    try:
        with open("tinyrange.yaml", "r") as f:
            tinyrange_config = yaml.safe_load(f)
    except FileNotFoundError:
        print("WARN: TinyRange configuration file not found.")
        tinyrange_config = {
            "cpu_cores": 4,
            "memory_size_gb": 8,
            "root_size_gb": 8,
            "docker_persist_size_gb": 16,
        }

    # ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)

    build_dir = subprocess.check_output([tinyrange_path, "env", "build-dir"]).decode(
        "utf-8"
    )

    # Remove the persist docker image each time.
    try:
        os.remove(os.path.join(build_dir, "persist", "docker_persist.img"))
    except:
        pass

    description_filename = os.path.basename(description_file)

    persist_size = str(tinyrange_config["docker_persist_size"] * 1024)

    login_file = {
        "version": 1,
        "builder": "alpine@3.21",
        "service_commands": [
            "dockerd",
        ],
        "commands": [
            "%verbose,exit_on_failure",
            "cd /root;python3 -m venv env;source env/bin/activate;pip install -r requirements.txt",
            f"cd /root;source env/bin/activate;python build.py --build {description_filename} build",
            "killall dockerd",
        ],
        "files": ["../build.py", "../requirements.txt", "../" + description_file],
        "packages": ["py3-pip", "docker"],
        "macros": ["//lib/alpine_kernel:kernel,3.21"],
        "volumes": [f"docker,{persist_size},/var/lib/docker,persist"],
        "min_spec": {
            "cpu": tinyrange_config["cpu_cores"],
            "memory": tinyrange_config["memory_size"] * 1024,
            "disk": tinyrange_config["root_size"] * 1024,
        },
    }

    with open(os.path.join(output_dir, f"{name}_{version}.yaml"), "w") as f:
        yaml.dump(login_file, f)

    subprocess.check_call(
        [
            tinyrange_path,
            "login",
            "--verbose",
            "-c",
            os.path.join(output_dir, f"{name}_{version}.yaml"),
        ]
    )


def get_recipe_directory(name):
    return os.path.join("recipes", name)


def main_init(args):
    name = args.name
    version = args.version

    if name == "" or version == "":
        raise ValueError("Name and version cannot be empty.")

    recipe_path = get_recipe_directory(name)
    if not os.path.exists(recipe_path):
        os.makedirs(recipe_path)

    # Create description file
    description_file = os.path.join(recipe_path, "build.yaml")
    if os.path.exists(description_file):
        raise ValueError("Description file {} already exists.".format(description_file))

    with open(description_file, "w") as f:
        yaml.safe_dump(
            {
                "name": name,
                "version": version,
                "architectures": ["x86_64"],
                "build": {
                    "kind": "neurodocker",
                    "base-image": "ubuntu:24.04",
                    "pkg-manager": "apt",
                    "directives": [
                        {"run": ["echo 'Hello World'"]},
                    ],
                },
                "readme": "TODO",
            },
            f,
            sort_keys=False,
            default_flow_style=False,
            width=10000,
        )


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def get_cache_dir():
    # Get the cache directory
    cache_dir = os.path.join(os.path.expanduser("~"), ".cache", "neurocontainers")
    if not os.path.exists(cache_dir):
        os.makedirs(cache_dir)

    return cache_dir


def download_with_cache(url, check_only=False):
    # download with curl to a temporary file
    if shutil.which("curl") is None:
        raise ValueError("curl not found in PATH.")

    cache_dir = get_cache_dir()
    os.makedirs(cache_dir, exist_ok=True)

    filename = sha256(url.encode("utf-8"))

    # Make the output filename and check if it exists
    output_filename = os.path.join(cache_dir, filename)
    if os.path.exists(output_filename):
        return output_filename

    # Skip download if check_only is True
    if check_only:
        with open(output_filename, "w") as f:
            f.write("")
        print("Check only mode: skipping file download.")
        return output_filename

    # download the file
    print(f"Downloading {url} to {output_filename}")
    subprocess.check_call(
        ["curl", "-L", "-o", output_filename, url],
        stdout=subprocess.DEVNULL,
    )

    return output_filename


def main_generate(args):
    recipe_path = get_recipe_directory(args.name)

    # Load description file
    description_file = yaml.safe_load(
        open(os.path.join(recipe_path, "build.yaml"), "r")
    )

    if description_file == None:
        raise ValueError("Description file is empty.")

    # Get basic information
    name = description_file.get("name") or ""
    version = description_file.get("version") or ""

    if args.build_tinyrange:
        build_tinyrange(
            args.tinyrange_path,
            args.description_file,
            args.output_directory,
            name,
            version,
        )
        return

    readme = description_file.get("readme") or ""

    draft = description_file.get("draft") or False
    if draft:
        print("WARN: This is a draft recipe.")

    arch = ARCHITECTURES[platform.machine()]

    allowed_architectures = description_file.get("architectures") or []
    if allowed_architectures == []:
        raise ValueError("No architectures specified in description file.")

    if arch not in allowed_architectures and not args.ignore_architectures:
        raise ValueError(f"Architecture {arch} not supported by this recipe.")

    ctx = BuildContext(name, version, arch)
    ctx.set_max_parallel_jobs(args.max_parallel_jobs)

    if "variables" in description_file:
        for key, value in description_file["variables"].items():
            ctx.__dict__[key] = ctx.execute_template(value)

    options = description_file.get("options") or {}
    for key, value in options.items():
        ctx.add_option(
            key,
            description=value.get("description") or "",
            default=value.get("default") or False,
            version_suffix=value.get("version_suffix") or "",
        )

    # Set options from command line
    if args.option is not None:
        for option in args.option:
            key, value = option.split("=")
            ctx.set_option(key, value)

    # Set options from description file
    ctx.calculate_version()

    if (readme == "") and ("readme_url" not in description_file):
        # If readme is not found, try to get it from a file
        readme_file = os.path.join(recipe_path, "README.md")
        if os.path.exists(readme_file):
            with open(readme_file, "r") as f:
                readme = f.read()
        else:
            raise ValueError("README.md not found and readme is empty")

    ctx.readme = ctx.execute_template(readme)

    # If readme is not found, try to get it from a URL
    # This is done after so we don't execute the template
    if "readme_url" in description_file:
        readme_url = ctx.execute_template(description_file["readme_url"])
        if readme_url != "":
            ctx.readme = http_get(readme_url)

    # Check if name, version, or readme is empty
    if ctx.name == "" or ctx.version == "" or ctx.readme == "":
        raise ValueError("Name, version, or readme cannot be empty.")

    ctx.tag = f"{name}:{version}"

    # Get build information
    ctx.build_info = description_file.get("build") or None

    if ctx.build_info is None:
        raise ValueError("No build info found in description file.")

    ctx.build_kind = ctx.build_info.get("kind") or ""
    if ctx.build_kind == "":
        raise ValueError("Build kind cannot be empty.")

    ctx.deploy = description_file.get("deploy") or None

    # Create build directory
    ctx.build_directory = os.path.join(args.output_directory, name)

    if os.path.exists(ctx.build_directory):
        if args.recreate:
            shutil.rmtree(ctx.build_directory)
        else:
            raise ValueError("Build directory already exists.")

    os.makedirs(ctx.build_directory)

    # Write README.md
    with open(os.path.join(ctx.build_directory, "README.md"), "w") as f:
        f.write(ctx.readme)

    # Write all files
    for file in description_file.get("files", []):
        ctx.add_file(file, recipe_path, check_only=args.check_only)

    dockerfile_name = "{}_{}.Dockerfile".format(ctx.name, ctx.version.replace(":", "_"))

    # Write Dockerfile
    if ctx.build_kind == "neurodocker":
        dockerfile = ctx.build_neurodocker(ctx.build_info, ctx.deploy)

        with open(os.path.join(ctx.build_directory, dockerfile_name), "w") as f:
            f.write(dockerfile)
    else:
        raise ValueError("Build kind not supported.")

    if args.check_only:
        print("Dockerfile generated successfully at", dockerfile_name)
        return

    if args.build:
        print("Building Docker image...")

        if not shutil.which("docker"):
            raise ValueError("Docker not found in PATH.")

        # Shell out to Docker
        # docker-py does not support using BuildKit
        subprocess.check_call(
            ["docker", "build", "-f", dockerfile_name, "-t", ctx.tag, "."],
            cwd=ctx.build_directory,
        )
        print("Docker image built successfully at", ctx.tag)

        if args.login:
            subprocess.check_call(
                ["docker", "run", "--rm", "-it", ctx.tag],
                cwd=ctx.build_directory,
            )
            return

        if args.build_sif:
            print("Building Singularity image...")

            if not shutil.which("singularity"):
                raise ValueError("Singularity not found in PATH.")

            output_filename = os.path.join("sifs", f"{ctx.name}_{ctx.version}.sif")
            if not os.path.exists("sifs"):
                os.makedirs("sifs")

            subprocess.check_call(
                [
                    "singularity",
                    "build",
                    "--force",
                    output_filename,
                    "docker-daemon://" + ctx.tag,
                ],
            )

            print("Singularity image built successfully as", ctx.tag + ".sif")
    else:
        if args.build_sif:
            raise ValueError(
                "Building Singularity image requires building the Docker image first."
            )


def main(args):
    root = argparse.ArgumentParser(
        description="NeuroContainer Builder",
    )

    command = root.add_subparsers(dest="command")

    build_parser = command.add_parser(
        "generate",
        help="Generate a Docker image from a description file",
    )
    build_parser.add_argument("name", help="Name of the recipe to generate")
    build_parser.add_argument(
        "--output-directory",
        help="Output directory for the build",
        default=os.path.join(os.getcwd(), "build"),
    )
    build_parser.add_argument(
        "--recreate", action="store_true", help="Recreate the build directory"
    )
    build_parser.add_argument(
        "--build", action="store_true", help="Build the Docker image after creating it"
    )
    build_parser.add_argument(
        "--build-sif",
        action="store_true",
        help="Build a Singularity image after building the Docker image",
    )
    build_parser.add_argument(
        "--build-tinyrange",
        action="store_true",
        help="Build the Docker image after creating it using TinyRange",
    )
    build_parser.add_argument(
        "--tinyrange-path",
        help="Path to the TinyRange binary",
        default="tinyrange",
    )
    build_parser.add_argument(
        "--max-parallel-jobs",
        type=int,
        help="Maximum number of parallel jobs to run during the build",
        default=os.cpu_count(),
    )
    build_parser.add_argument(
        "--ignore-architectures", action="store_true", help="Ignore architecture checks"
    )
    build_parser.add_argument(
        "--option",
        action="append",
        help="Set an option in the description file. Use --option key=value",
    )
    build_parser.add_argument(
        "--login",
        action="store_true",
        help="Run a interactive docker container with the generated image",
    )
    build_parser.add_argument(
        "--check-only",
        action="store_true",
        help="Check the recipe and exit without building",
    )

    init_parser = command.add_parser(
        "init",
        help="Initialize a new recipe",
    )
    init_parser.add_argument("name", help="Name of the recipe to create")
    init_parser.add_argument("version", help="Version of the recipe to create")

    args = root.parse_args()

    if args.command == "init":
        main_init(args)
    elif args.command == "generate":
        main_generate(args)
    else:
        root.print_help()
        sys.exit(1)


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
