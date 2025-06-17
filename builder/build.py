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
import typing
import json

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


def get_repo_path() -> str:
    return os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def get_cache_dir() -> str:
    # Get the cache directory
    cache_dir = os.path.join(os.path.expanduser("~"), ".cache", "neurocontainers")
    if not os.path.exists(cache_dir):
        os.makedirs(cache_dir)

    return cache_dir


def load_description_file(recipe_dir: str) -> typing.Any:
    # Load the description file
    description_file = os.path.join(recipe_dir, "build.yaml")
    if not os.path.exists(description_file):
        raise ValueError(f"Description file {description_file} does not exist.")

    with open(description_file, "r") as f:
        return yaml.safe_load(f)


_jinja_env = jinja2.Environment(undefined=jinja2.StrictUndefined)


class NeuroDockerBuilder:
    def __init__(
        self, base_image: str, pkg_manager: str = "apt", add_default: bool = True
    ):
        self.renderer_dict = {
            "pkg_manager": pkg_manager,
            "instructions": [],
        }

        self.add_directive("from_", base_image=base_image)

        # Always set the root user for the neurocontainer installation.
        self.set_user("root")

        if add_default:
            self.add_directive("_default")

    def add_directive(self, directive: typing.Any, **kwargs: typing.Any):
        """
        Low level function to add a directive to the renderer_dict.
        Can also be used to add templates.
        :param directive: The name of the directive.
        :param kwargs: The keyword arguments for the directive.
        """
        self.renderer_dict["instructions"].append({"name": directive, "kwds": kwargs})

    def install_packages(self, packages: typing.List[str]):
        """
        Install packages using the specified package manager.
        :param packages: List of packages to install.
        """
        self.add_directive("install", pkgs=packages, opts=None)

    def run_command(self, command: str):
        """
        Run a command in the container.
        :param args: The command to run.
        """
        self.add_directive("run", command=command)

    def set_user(self, user: str):
        """
        Set the user for the container.
        :param user: The user to set.
        """
        self.add_directive("user", user=user)

    def set_workdir(self, path: str):
        """
        Set the working directory for the container.
        :param path: The path to set as the working directory.
        """
        self.add_directive("workdir", path=path)

    def set_entrypoint(self, entrypoint: str):
        """
        Set the entrypoint for the container.
        :param entrypoint: The entrypoint to set.
        """
        self.add_directive("entrypoint", args=[entrypoint])

    def set_environment(self, key: str, value: str):
        """
        Set an environment variable for the container.
        :param key: The name of the environment variable.
        :param value: The value of the environment variable.
        """
        self.add_directive("env", **{key: value})

    def copy(self, *args: str):
        """
        Copy files into the container.
        :param args: The files to copy.
        """
        source, destination = list(args[:-1]), args[-1]
        self.add_directive("copy", source=source, destination=destination)

    def generate(self) -> str:
        """
        Generate the NeuroDocker Dockerfile.
        :return: The generated Dockerfile as a string.
        """

        from neurodocker.reproenv.renderers import DockerRenderer

        if (
            len(
                [
                    i
                    for i in self.renderer_dict["instructions"]
                    if i["name"] == "entrypoint"
                ]
            )
            == 0
            and len(
                [
                    i
                    for i in self.renderer_dict["instructions"]
                    if i["name"] == "_default"
                ]
            )
            > 0
        ):
            self.set_entrypoint("/neurodocker/startup.sh")

        r = DockerRenderer.from_dict(self.renderer_dict)

        return str(r)


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
    build_directory: str | None = None
    readme: str | None = None
    tag: str | None = None
    build_info: typing.Any | None = None
    build_kind: str | None = None
    dockerfile_name: str | None = None

    def __init__(self, base_path, recipe_path, name, version, arch):
        self.base_path = base_path
        self.recipe_path = recipe_path
        self.name = name
        self.version = version
        self.original_version = version
        self.arch = arch
        self.max_parallel_jobs = os.cpu_count()
        self.options = {}
        self.option_info = {}
        self.files = {}
        self.lint_error = False
        self.deploy_bins = []
        self.deploy_path = []

    def lint_fail(self, message):
        if self.lint_error:
            raise ValueError("lint failed: " + message)
        print("lint failed: " + message)

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
        if self.build_directory is None:
            raise ValueError("Build directory not set.")

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

    def execute_template(self, obj, locals, methods=None):
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
                    if self.execute_condition(value["condition"], locals=locals):
                        return self.execute_template(value["value"], locals=locals)

                raise NotImplementedError("Try not implemented.")
        else:
            raise ValueError("Template object not supported.")

    def execute_template_string(self, obj: str, locals, methods=None) -> str:
        try:
            return self.render_template(obj, locals=locals, methods=methods)
        except jinja2.exceptions.TemplateSyntaxError as e:
            raise ValueError(f"Template syntax error: {e} in {obj}")

    def add_file(self, file, recipe_path, locals, check_only=False):
        if self.build_directory is None:
            raise ValueError("Build directory not set.")

        name = self.execute_template_string(file["name"], locals=locals)

        if name == "":
            raise ValueError("File name cannot be empty.")

        output_filename = os.path.join(self.build_directory, name)

        if "url" in file:
            # download and cache the file
            url = self.execute_template(file["url"], locals=locals)
            cached_file = download_with_cache(
                url,
                check_only=check_only,
                insecure=file.get("insecure", False),
            )

            if "executable" in file and file["executable"]:
                os.chmod(output_filename, 0o755)

            self.files[name] = {
                "cached_path": cached_file,
            }
        else:
            if "contents" in file:
                contents = self.execute_template_string(file["contents"], locals=locals)
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
                "cached_path": output_filename,
            }

    def file_exists(self, filename: str) -> bool:
        if self.build_directory is None:
            raise ValueError("Build directory not set.")

        return os.path.exists(os.path.join(self.build_directory, filename))

    def generate_cache_id(self, directive: str) -> str:
        return "h" + directive[:8]

    def load_include_file(self, filename: str) -> typing.Any:
        filename = os.path.join(self.base_path, filename)

        if not os.path.exists(filename):
            raise ValueError(f"Include file {filename} not found.")

        with open(filename, "r") as f:
            return yaml.safe_load(f)

    def check_docker_image(self, image: str) -> str:
        if image == "":
            raise ValueError("Docker image cannot be empty.")

        if ":" not in image:
            self.lint_fail("Docker image must have a tag. Use <image>:<tag> format.")
            return image + ":latest"

        name, tag = image.split(":", 1)

        if name == "ubuntu":
            if tag not in ["16.04", "18.04", "20.04", "22.04", "24.04", "26.04"]:
                self.lint_fail(
                    "Ubuntu version not supported. Use 16.04, 18.04, 20.04, 22.04, 24.04 or 26.04."
                )

        return image

    def build_neurodocker(self, build_directive, locals):
        base_raw = self.execute_template(
            build_directive.get("base-image") or "", locals=locals
        )
        if not isinstance(base_raw, str):
            raise ValueError("Base image must be a string.")

        base = self.check_docker_image(base_raw)

        pkg_manager = self.execute_template(
            build_directive.get("pkg-manager") or "", locals=locals
        )
        if not isinstance(pkg_manager, str):
            raise ValueError("Package manager must be a string.")

        if base == "" or pkg_manager == "":
            raise ValueError("Base image or package manager cannot be empty.")

        builder = NeuroDockerBuilder(
            base, pkg_manager, build_directive.get("add-default-template", True)
        )

        builder.run_command("printf '#!/bin/bash\\nls -la' > /usr/bin/ll")
        builder.run_command("chmod +x /usr/bin/ll")
        builder.run_command("mkdir -p " + " ".join(GLOBAL_MOUNT_POINT_LIST))

        def add_directive(directive, locals):
            if "condition" in directive:
                if not self.execute_condition(directive["condition"], locals=locals):
                    return []

            if "install" in directive:
                if type(directive["install"]) == str:
                    pkg_list = self.execute_template(
                        [
                            f
                            for f in directive["install"].replace("\n", " ").split(" ")
                            if f != ""
                        ],
                        locals=locals,
                    )
                    if not isinstance(pkg_list, list):
                        raise ValueError(
                            "Install directive must be a list of packages."
                        )
                    builder.install_packages(pkg_list)  # type: ignore
                elif type(directive["install"]) == list:
                    pkg_list = self.execute_template(
                        directive["install"], locals=locals
                    )
                    if not isinstance(pkg_list, list):
                        raise ValueError(
                            "Install directive must be a list of packages."
                        )
                    builder.install_packages(pkg_list)  # type: ignore
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
                if not isinstance(args, list):
                    raise ValueError("Run directive must be a list of commands.")
                builder.run_command(
                    " ".join(local.run_args) + " " + " \\\n && ".join(args)  # type: ignore
                )
            elif "workdir" in directive:
                workdir = self.execute_template(directive["workdir"], locals=locals)
                if not isinstance(workdir, str):
                    raise ValueError("Workdir must be a string.")

                builder.set_workdir(workdir)
            elif "user" in directive:
                user = self.execute_template(directive["user"], locals=locals)
                if not isinstance(user, str):
                    raise ValueError("User must be a string.")

                builder.set_user(user)
            elif "entrypoint" in directive:
                entrypoint = self.execute_template(
                    directive["entrypoint"], locals=locals
                )
                if not isinstance(entrypoint, str):
                    raise ValueError("Entrypoint must be a string.")

                builder.set_entrypoint(entrypoint)
            elif "environment" in directive:
                if directive["environment"] == None:
                    raise ValueError("Environment must be a map of keys and values.")

                for key, value in directive["environment"].items():
                    key = self.execute_template(key, locals=locals)
                    if not isinstance(key, str):
                        raise ValueError("Environment key must be a string.")

                    value = self.execute_template(value, locals=locals)
                    if not isinstance(value, str):
                        raise ValueError("Environment value must be a string.")

                    builder.set_environment(key, value)  # type: ignore
            elif "template" in directive:
                name = self.execute_template(
                    directive["template"].get("name") or "", locals=locals
                )
                if name == "":
                    raise ValueError("Template name cannot be empty.")

                builder.add_directive(
                    name,
                    **{
                        k: self.execute_template(v, locals=locals)
                        for k, v in directive["template"].items()
                        if k != "name"
                    },
                )
            elif "copy" in directive:
                args = []
                if type(directive["copy"]) == str:
                    args = self.execute_template(
                        directive["copy"].split(" "), locals=locals
                    )
                elif type(directive["copy"]) == list:
                    args = self.execute_template(directive["copy"], locals=locals)

                if not isinstance(args, list):
                    raise ValueError("Copy directive must be a list of files.")

                if len(args) == 2:
                    arg = args[0]
                    if not isinstance(arg, str):
                        raise ValueError("Copy directive must be a list of files.")

                    # check to make sure the first reference is a file and it exists.
                    if not self.file_exists(arg):
                        filename = args[0]
                        raise ValueError(f"File {filename} does not exist.")

                builder.copy(*args)  # type: ignore
            elif "group" in directive:
                variables = {**locals}

                if "with" in directive:
                    for key, value in directive["with"].items():
                        variables[key] = self.execute_template(value, locals=variables)

                for item in directive["group"]:
                    add_directive(item, locals=variables)
            elif "include" in directive:
                filename = self.execute_template(
                    directive["include"] or "", locals=locals
                )

                if not isinstance(filename, str):
                    raise ValueError("Include filename must be a string.")

                include_file = self.load_include_file(filename)

                if include_file.get("builder") != "neurodocker":
                    raise ValueError("Include file must be a neurodocker file.")

                variables = {**locals}

                if "with" in directive:
                    for key, value in directive["with"].items():
                        variables[key] = self.execute_template(value, locals=variables)

                for directive in include_file["directives"]:
                    add_directive(directive, locals=variables)
            elif "file" in directive:
                self.add_file(directive["file"], self.recipe_path, locals=locals)
            elif "variables" in directive:
                for key, value in directive["variables"].items():
                    locals[key] = self.execute_template(value, locals=locals)
            elif "test" in directive:
                # TODO: implement test directive
                pass
            elif "deploy" in directive:
                if "bins" in directive["deploy"]:
                    bins = self.execute_template(
                        directive["deploy"]["bins"], locals=locals
                    )
                    if not isinstance(bins, list):
                        raise ValueError("Deploy bins must be a list.")
                    self.deploy_bins.extend(bins)

                if "path" in directive["deploy"]:
                    path = self.execute_template(
                        directive["deploy"]["path"], locals=locals
                    )
                    if not isinstance(path, list):
                        raise ValueError("Deploy path must be a list.")
                    self.deploy_path.extend(path)
            else:
                raise ValueError(f"Directive {directive} not supported.")

        for directive in build_directive["directives"]:
            add_directive(directive, locals=locals)

        if len(self.deploy_path) > 0:
            path = self.execute_template(self.deploy_path, locals=locals)
            if not isinstance(path, list):
                raise ValueError("Deploy path must be a list.")
            builder.set_environment("DEPLOY_PATH", ":".join(path))  # type: ignore
        if len(self.deploy_bins) > 0:
            bins = self.execute_template(self.deploy_bins, locals=locals)
            if not isinstance(bins, list):
                raise ValueError("Deploy bins must be a list.")
            builder.set_environment("DEPLOY_BINS", ":".join(bins))  # type: ignore

        builder.copy("README.md", "/README.md")

        output = builder.generate()

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


def build_tinyrange(
    tinyrange_path: str, description_file: str, output_dir: str, name: str, version: str
):
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


def get_recipe_directory(repo_path, name):
    return os.path.join(repo_path, "recipes", name)


def init_new_recipe(repo_path: str, name: str, version: str):
    if name == "" or version == "":
        raise ValueError("Name and version cannot be empty.")

    recipe_path = get_recipe_directory(repo_path, name)
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
                "copyright": [
                    {"license": "TODO", "url": "TODO"},
                ],
                "build": {
                    "kind": "neurodocker",
                    "base-image": "ubuntu:24.04",
                    "pkg-manager": "apt",
                    "directives": [
                        {
                            "file": {
                                "name": "hello.txt",  # Example file
                                "contents": "Hello, world!",  # Example content
                            }
                        },
                        {"run": ['cat {{ get_file("hello.txt") }}']},
                        {
                            "deploy": {
                                "bins": ["TODO"],
                            }
                        },
                        {
                            "test": {
                                "name": "Simple Deploy Bins/Path Test",
                                "builtin": "test_deploy.sh",
                            },
                        },
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


def download_with_cache(url, check_only=False, insecure=False):
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
    # Use full argument names for curl for clarity
    curl_args = ["curl", "--location", "--output", output_filename, url]
    if insecure:
        curl_args.append("--insecure")

    subprocess.check_call(
        curl_args,
        stdout=subprocess.DEVNULL,
    )

    return output_filename


def get_build_platform(arch: str) -> str:
    if arch == "x86_64":
        return "linux/amd64"
    elif arch == "aarch64":
        return "linux/arm64"
    else:
        raise ValueError(f"Architecture {arch} not supported.")


def load_spdx_licenses():
    # the JSON file is next to the script
    spdx_licenses_file = os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "licenses.json"
    )

    if not os.path.exists(spdx_licenses_file):
        raise ValueError("SPDX licenses file not found.")

    with open(spdx_licenses_file, "r") as f:
        spdx_licenses = json.load(f)

        ret = {}

        for license in spdx_licenses["licenses"]:
            if "licenseId" in license:
                ret[license["licenseId"]] = license

        return ret


def validate_license(description_file):
    # don't try to validate if the license is not present
    if "copyright" not in description_file:
        return

    valid_licenses = load_spdx_licenses()

    copyright_list = description_file["copyright"]
    if not isinstance(copyright_list, list):
        raise ValueError("Copyright must be a list of dicts.")

    for copyright in copyright_list:
        if "license" in copyright:
            license = copyright["license"]
            if license not in valid_licenses:
                raise ValueError(f"License {license} not found in SPDX licenses.")
        elif "name" in copyright:
            # ignore custom licenses
            pass

        if "url" not in copyright:
            raise ValueError("License URL not found in copyright.")


def generate_from_description(
    repo_path: str,
    recipe_path: str,
    description_file: typing.Any,
    output_directory: str,
    architecture: str | None = None,
    ignore_architecture: bool | None = False,
    auto_build: bool = False,
    max_parallel_jobs: int | None = None,
    options: list[str] | None = None,
    recreate_output_dir: bool = False,
    check_only: bool = False,
) -> BuildContext | None:
    if max_parallel_jobs is None:
        max_parallel_jobs = os.cpu_count()

    # Get basic information
    name = description_file.get("name") or ""
    version = description_file.get("version") or ""

    readme = description_file.get("readme") or ""

    draft = description_file.get("draft") or False
    if draft:
        print("WARN: This is a draft recipe.")
        if auto_build:
            print("WARN: Auto build is enabled. Skipping build.")
            return None

    arch = ARCHITECTURES[architecture or platform.machine()]

    allowed_architectures = description_file.get("architectures") or []
    if allowed_architectures == []:
        raise ValueError("No architectures specified in description file.")

    if arch not in allowed_architectures and not ignore_architecture:
        raise ValueError(f"Architecture {arch} not supported by this recipe.")

    validate_license(description_file)

    ctx = BuildContext(repo_path, recipe_path, name, version, arch)
    ctx.set_max_parallel_jobs(max_parallel_jobs)

    locals = {}

    if "variables" in description_file:
        for key, value in description_file["variables"].items():
            ctx.__dict__[key] = ctx.execute_template(value, locals=locals)

    description_options = description_file.get("options") or {}
    for key, value in description_options.items():
        ctx.add_option(
            key,
            description=value.get("description") or "",
            default=value.get("default") or False,
            version_suffix=value.get("version_suffix") or "",
        )

    # Set options from command line
    if options is not None:
        for option in options:
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

    ctx.readme = ctx.execute_template_string(readme, locals=locals)

    # If readme is not found, try to get it from a URL
    # This is done after so we don't execute the template
    if "readme_url" in description_file:
        readme_url = ctx.execute_template(description_file["readme_url"], locals=locals)
        if readme_url != "":
            ctx.readme = http_get(readme_url)

    # Check if name, version, or readme is empty
    if ctx.name == "" or ctx.version == "" or ctx.readme == "":
        raise ValueError("Name, version, or readme cannot be empty.")

    # Get hardcoded deploy info
    if "deploy" in description_file:
        if "bins" in description_file["deploy"]:
            ctx.deploy_bins = ctx.execute_template(description_file["deploy"]["bins"], locals=locals)  # type: ignore
        if "path" in description_file["deploy"]:
            ctx.deploy_path = ctx.execute_template(description_file["deploy"]["path"], locals=locals)  # type: ignore

    ctx.tag = f"{name}:{version}"

    # Get build information
    ctx.build_info = description_file.get("build") or None

    if ctx.build_info is None:
        raise ValueError("No build info found in description file.")

    ctx.build_kind = ctx.build_info.get("kind") or ""
    if ctx.build_kind == "":
        raise ValueError("Build kind cannot be empty.")

    # Create build directory
    ctx.build_directory = os.path.join(output_directory, name)

    if os.path.exists(ctx.build_directory):
        if recreate_output_dir:
            shutil.rmtree(ctx.build_directory)
        else:
            raise ValueError(
                "Build directory already exists. Pass --recreate to overwrite it."
            )

    os.makedirs(ctx.build_directory)

    # Write README.md
    with open(os.path.join(ctx.build_directory, "README.md"), "w") as f:
        if ctx.readme == None:
            raise ValueError("README.md is empty.")

        f.write(ctx.readme)
        # add empty line at the end so that promt in a container is on the new line:
        f.write("\n")

    # Write all files
    for file in description_file.get("files", []):
        ctx.add_file(file, recipe_path, check_only=check_only, locals=locals)

    ctx.dockerfile_name = "{}_{}.Dockerfile".format(
        ctx.name, ctx.version.replace(":", "_")
    )

    # Write Dockerfile
    if ctx.build_kind == "neurodocker":
        dockerfile = ctx.build_neurodocker(ctx.build_info, locals=locals)

        with open(os.path.join(ctx.build_directory, ctx.dockerfile_name), "w") as f:
            f.write(dockerfile)
    else:
        raise ValueError("Build kind not supported.")

    if check_only:
        print("Dockerfile generated successfully at", ctx.dockerfile_name)
        return ctx

    return ctx


def build_and_run_container(
    dockerfile_name: str,
    name: str,
    version: str,
    tag: str,
    architecture: str,
    recipe_path: str,
    build_directory: str,
    login=False,
    build_sif=False,
):
    if not shutil.which("docker"):
        raise ValueError("Docker not found in PATH.")

    # Shell out to Docker
    # docker-py does not support using BuildKit
    subprocess.check_call(
        [
            "docker",
            "build",
            "--platform",
            get_build_platform(architecture),
            "-f",
            dockerfile_name,
            "-t",
            tag,
            ".",
        ],
        cwd=build_directory,
    )
    print("Docker image built successfully at", tag)

    if login:
        abs_path = os.path.abspath(recipe_path)

        subprocess.check_call(
            [
                "docker",
                "run",
                "--platform",
                get_build_platform(architecture),
                "--rm",
                "-it",
                "-v",
                abs_path + ":/buildhostdirectory",
                tag,
            ],
            cwd=build_directory,
        )
        return

    if build_sif:
        print("Building Singularity image...")

        if not shutil.which("singularity"):
            raise ValueError("Singularity not found in PATH.")

        output_filename = os.path.join("sifs", f"{name}_{version}.sif")
        if not os.path.exists("sifs"):
            os.makedirs("sifs")

        subprocess.check_call(
            [
                "singularity",
                "build",
                "--force",
                output_filename,
                "docker-daemon://" + tag,
            ],
        )

        print("Singularity image built successfully as", tag + ".sif")


def run_docker_prep(prep, volume_name):
    name = prep.get("name")
    image = prep.get("image")
    script = prep.get("script")
    if name is None or image is None or script is None:
        raise ValueError("Prep step must have a name, image and script")

    # Docker run the script in the container mounting the volume as /test
    subprocess.check_call(
        [
            "docker",
            "run",
            "--rm",
            "-v",
            f"{volume_name}:/test",
            image,
            "bash",
            "-c",
            f"""set -ex
                cd /test
                {script}""",
        ],
    )


def run_builtin_test(tag, test):
    # built-in tests are found next to this file
    builtin_test = os.path.join(os.path.dirname(__file__), test)
    if not os.path.exists(builtin_test):
        raise ValueError(f"Builtin test {test} does not exist")

    test_content = open(builtin_test).read()

    # Docker run the test script in the container mounting the volume as /test
    subprocess.check_call(
        [
            "docker",
            "run",
            "--rm",
            tag,
            "bash",
            "-c",
            test_content,
        ],
    )


def run_docker_test(tag, test):
    if test.get("builtin") == "test_deploy.sh":
        return run_builtin_test(tag, test.get("builtin"))

    script = test.get("script")
    if script is None:
        raise ValueError("Test step must have a script")

    # Create a docker volume for the test, if it exists remove it first
    cleaned_tag = tag.replace(":", "-")
    volume_name = f"neurocontainer-test-{cleaned_tag}"
    try:
        subprocess.check_call(
            ["docker", "volume", "rm", volume_name],
            stdout=subprocess.DEVNULL,
        )
    except subprocess.CalledProcessError as e:
        # check to make sure the volume is not in use
        if "is in use" in str(e):
            raise ValueError(
                f"Volume {volume_name} is in use, please remove it manually"
            )

        # If the volume does not exist, ignore the error
        pass
    subprocess.check_call(
        ["docker", "volume", "create", volume_name],
        stdout=subprocess.DEVNULL,
    )

    # For each prep step in the test, run it in a docker container
    if "prep" in test:
        for prep in test["prep"]:
            run_docker_prep(prep, volume_name)

    # Docker run the test script in the container mounting the volume as /test
    subprocess.check_call(
        [
            "docker",
            "run",
            "--rm",
            "-v",
            f"{volume_name}:/test",
            tag,
            "bash",
            "-c",
            f"""set -ex
                cd /test
                {script}""",
        ],
    )


def run_test(tag, test):
    test_name = test["name"]
    print(f"Running test {test_name} on image {tag}")
    return run_docker_test(tag, test)


def check_docker(tag):
    # use docker image inspect
    subprocess.check_call(
        ["docker", "image", "inspect", tag],
        stdout=subprocess.DEVNULL,
    )


def get_directives(description_file: dict) -> list[dict]:
    # Get directives from the description file
    if "build" not in description_file:
        raise ValueError("Description file must have a build key")

    if "directives" not in description_file["build"]:
        raise ValueError("Description file must have a build.directives key")

    return description_file["build"]["directives"]


def get_all_tests(description_file: typing.Any, recipe_path: str) -> list[dict]:
    # tests can come from two locations. Either in the description file or in a separate test.yaml file.

    tests = []

    if os.path.exists(os.path.join(recipe_path, "test.yaml")):
        with open(os.path.join(recipe_path, "test.yaml"), "r") as f:
            test_file = yaml.safe_load(f)
            if "tests" not in test_file:
                raise ValueError("Test file must have a tests key")
            tests.extend(test_file["tests"])

    directives = get_directives(description_file)

    def walk_directives(directives):
        for directive in directives:
            if "group" in directive:
                walk_directives(directive["group"])
            elif "test" in directive:
                tests.append(directive["test"])

    walk_directives(directives)

    return tests


def get_tag_from_description_file(description_file: dict) -> str:
    # Get the tag from the description file
    if "name" not in description_file:
        raise ValueError("Description file must have a name key")

    if "version" not in description_file:
        raise ValueError("Description file must have a version key")

    name = description_file["name"]
    version = description_file["version"]

    return f"{name}:{version}"


def run_tests(recipe_path: str):
    description_file = load_description_file(recipe_path)

    tag = get_tag_from_description_file(description_file)

    for test in get_all_tests(description_file, recipe_path):
        run_test(tag, test)


def autodetect_recipe_path(repo_path: str, path: str) -> str | None:
    # look for build.yaml in path and keep going up until we find it or reach the repo path

    # if path is not a descendant of the repo path, raise an error
    if not os.path.commonpath([repo_path, path]) == repo_path:
        raise ValueError("Path is not a descendant of the repo path.")

    while path != repo_path:
        if os.path.exists(os.path.join(path, "build.yaml")):
            return path

        path = os.path.dirname(path)

    return None


def generate_dockerfile(repo_path, recipe_path):
    build_directory = os.path.join(repo_path, "build")

    print(f"Generate Dockerfile from {recipe_path}...")

    return generate_from_description(
        repo_path,
        recipe_path,
        load_description_file(recipe_path),
        build_directory,
        architecture=platform.machine(),
        recreate_output_dir=True,
    )


def generate_main():
    root = argparse.ArgumentParser(
        description="NeuroContainer Builder - Generate Docker images from description files",
    )

    # add a optional name positional argument
    root.add_argument(
        "name",
        help="Name of the recipe to generate",
        type=str,
        nargs="?",
    )

    args = root.parse_args()

    repo_path = get_repo_path()

    recipe_path = ""
    if args.name == None:
        recipe_path = autodetect_recipe_path(repo_path, os.getcwd())
        if recipe_path is None:
            print("No recipe found in current directory.")
            sys.exit(1)
    else:
        recipe_path = get_recipe_directory(repo_path, args.name)

    generate_dockerfile(repo_path, recipe_path)


def generate_and_build(repo_path, recipe_path, login=False):
    ctx = generate_dockerfile(repo_path, recipe_path)
    if ctx is None:
        print("Recipe generation failed.")
        sys.exit(1)

    if ctx.dockerfile_name is None:
        raise ValueError("Dockerfile name not set.")
    if ctx.build_directory is None:
        raise ValueError("Build directory not set.")
    if ctx.tag is None:
        raise ValueError("Tag not set.")

    tag = ctx.tag

    if login:
        print(f"Building and Running Docker image {tag}...")
    else:
        print(f"Building Docker image {tag}...")

    build_and_run_container(
        ctx.dockerfile_name,
        ctx.name,
        ctx.version,
        ctx.tag,
        ctx.arch,
        recipe_path,
        ctx.build_directory,
        login=login,
    )


def build_main(login=False):
    root = argparse.ArgumentParser(
        description="NeuroContainer Builder - Build Docker images from description files",
    )

    # add a optional name positional argument
    root.add_argument(
        "name",
        help="Name of the recipe to generate",
        type=str,
        nargs="?",
    )

    args = root.parse_args()

    repo_path = get_repo_path()

    recipe_path = ""
    if args.name == None:
        recipe_path = autodetect_recipe_path(repo_path, os.getcwd())
        if recipe_path is None:
            print("No recipe found in current directory.")
            sys.exit(1)
    else:
        recipe_path = get_recipe_directory(repo_path, args.name)

    generate_and_build(repo_path, recipe_path, login=login)


def login_main():
    build_main(login=True)


def test_main():
    root = argparse.ArgumentParser(
        description="NeuroContainer Builder - Run tests on Docker images",
    )

    # add a optional name positional argument
    root.add_argument(
        "name",
        help="Name of the recipe to generate",
        type=str,
        nargs="?",
    )

    args = root.parse_args()

    repo_path = get_repo_path()

    recipe_path = ""
    if args.name == None:
        recipe_path = autodetect_recipe_path(repo_path, os.getcwd())
        if recipe_path is None:
            print("No recipe found in current directory.")
            sys.exit(1)
    else:
        recipe_path = get_recipe_directory(repo_path, args.name)

    generate_and_build(repo_path, recipe_path, login=False)

    run_tests(recipe_path)


def init_main():
    root = argparse.ArgumentParser(
        description="NeuroContainer Builder - Initialize a new recipe",
    )

    root.add_argument("name", help="Name of the recipe to create")
    root.add_argument("version", help="Version of the recipe to create")

    args = root.parse_args()

    repo_path = get_repo_path()

    init_new_recipe(
        repo_path,
        args.name,
        args.version,
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
        "--test", action="store_true", help="Run tests after building"
    )
    build_parser.add_argument(
        "--architecture",
        help="Architecture to build for",
        default=platform.machine(),
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
    build_parser.add_argument(
        "--auto-build",
        action="store_true",
        help="Set if the recipe is being built in CI",
    )

    init_parser = command.add_parser(
        "init",
        help="Initialize a new recipe",
    )
    init_parser.add_argument("name", help="Name of the recipe to create")
    init_parser.add_argument("version", help="Version of the recipe to create")

    args = root.parse_args()

    repo_path = get_repo_path()

    if args.command == "init":
        init_new_recipe(
            repo_path,
            args.name,
            args.version,
        )
    elif args.command == "generate":
        recipe_path = get_recipe_directory(repo_path, args.name)

        if args.build_tinyrange:
            build_tinyrange(
                args.tinyrange_path,
                os.path.join(recipe_path, "build.yaml"),
                args.output_directory,
                args.name,
                args.version,
            )
            return

        ctx = generate_from_description(
            repo_path,
            recipe_path,
            load_description_file(recipe_path),
            args.output_directory,
            architecture=args.architecture,
            ignore_architecture=args.ignore_architectures,
            auto_build=args.auto_build,
            max_parallel_jobs=args.max_parallel_jobs,
            options=args.option,
            recreate_output_dir=args.recreate,
        )

        if args.build:
            if ctx is None:
                print("Recipe generation failed.")
                sys.exit(1)
            if ctx.dockerfile_name is None:
                raise ValueError("Dockerfile name not set.")
            if ctx.build_directory is None:
                raise ValueError("Build directory not set.")
            if ctx.tag is None:
                raise ValueError("Tag not set.")

            build_and_run_container(
                ctx.dockerfile_name,
                ctx.name,
                ctx.version,
                ctx.tag,
                ctx.arch,
                recipe_path,
                ctx.build_directory,
                login=args.login,
                build_sif=args.build_sif,
            )
    else:
        root.print_help()
        sys.exit(1)


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
