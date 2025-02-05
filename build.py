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

ARCHITECTURES = {"arm64": "aarch64"}

_jinja_env = jinja2.Environment(undefined=jinja2.StrictUndefined)


class BuildContext(object):
    def __init__(self, name, version):
        self.name = name
        self.version = version

    def get_architecture(self):
        return ARCHITECTURES[platform.machine()]

    def render_template(self, template):
        tpl = _jinja_env.from_string(template)
        return tpl.render(context=self, arch=self.get_architecture())

    def execute_condition(self, condition):
        result = self.render_template("{{" + condition + "}}")
        return result == "True"

    def execute_template(self, obj):
        if type(obj) == str:
            return self.render_template(obj)
        elif type(obj) == list:
            return [self.execute_template(o) for o in obj]
        elif type(obj) == dict:
            if "try" in obj:
                for value in obj["try"]:
                    if self.execute_condition(value["condition"]):
                        return self.execute_template(value["value"])

                raise NotImplementedError("Try not implemented.")
        else:
            raise ValueError("Template object not supported.")

    def build_neurodocker(self, build_directive, deploy):
        args = ["neurodocker", "generate", "docker"]

        base = self.execute_template(build_directive.get("base-image") or "")
        pkg_manager = self.execute_template(build_directive.get("pkg-manager") or "")

        if base == "" or pkg_manager == "":
            raise ValueError("Base image or package manager cannot be empty.")

        args += ["--base-image", base, "--pkg-manager", pkg_manager]

        args += [
            "--run=printf '#!/bin/bash\\nls -la' > /usr/bin/ll",
            "--run=chmod +x /usr/bin/ll",
            f"--run=mkdir -p {" ".join(GLOBAL_MOUNT_POINT_LIST)}",
        ]

        def add_directive(directive):
            if "condition" in directive:
                if not self.execute_condition(directive["condition"]):
                    return []

            if "install" in directive:
                if type(directive["install"]) == str:
                    return ["--install"] + self.execute_template(
                        [
                            f
                            for f in directive["install"].replace("\n", " ").split(" ")
                            if f != ""
                        ]
                    )
                elif type(directive["install"]) == list:
                    return ["--install"] + self.execute_template(directive["install"])
                else:
                    raise ValueError("Install directive must be a string or list.")
            elif "run" in directive:
                return [
                    "--run=" + " \\\n && ".join(self.execute_template(directive["run"]))
                ]
            elif "workdir" in directive:
                return ["--workdir", self.execute_template(directive["workdir"])]
            elif "environment" in directive:
                ret = []
                for key, value in directive["environment"].items():
                    ret += [
                        "--env",
                        f"{self.execute_template(key)}={self.execute_template(value)}",
                    ]
                return ret
            elif "template" in directive:
                name = self.execute_template(directive["template"].get("name") or "")
                if name == "":
                    raise ValueError("Template name cannot be empty.")

                items = [
                    f"{k}={self.execute_template(v)}"
                    for k, v in directive["template"].items()
                    if k != "name"
                ]

                return ["--" + name] + items
            elif "copy" in directive:
                return ["--copy"] + self.execute_template(directive["copy"].split(" "))
            else:
                raise ValueError(f"Directive {directive} not supported.")

        for directive in build_directive["directives"]:
            args += add_directive(directive)

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

        return subprocess.check_output(args).decode("utf-8")


def http_get(url):
    with urllib.request.urlopen(url) as response:
        return response.read().decode("utf-8")


def main(args):
    parser = argparse.ArgumentParser(
        description="Build a Docker image from a description file."
    )
    parser.add_argument("description_file", help="Path to the description YAML file")
    parser.add_argument("output_directory", help="Directory to output the build files")
    parser.add_argument(
        "--recreate", action="store_true", help="Recreate the build directory"
    )
    parser.add_argument(
        "--build", action="store_true", help="Build the Docker image after creating it"
    )

    args = parser.parse_args()

    # Load description file
    description_file = yaml.safe_load(open(args.description_file, "r"))

    if description_file == None:
        raise ValueError("Description file is empty.")

    # Get basic information
    name = description_file.get("name") or ""
    version = description_file.get("version") or ""

    readme = description_file.get("readme") or ""

    ctx = BuildContext(name, version)

    if "variables" in description_file:
        for key, value in description_file["variables"].items():
            ctx.__dict__[key] = ctx.execute_template(value)

    ctx.readme = ctx.execute_template(readme)

    # If readme is not found, try to get it from a URL
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
        raise ValueError("No build tag found in description file.")

    ctx.build_kind = ctx.build_info.get("kind") or ""
    if ctx.build_kind == "":
        raise ValueError("Build kind cannot be empty.")

    ctx.deploy = description_file.get("deploy") or None

    # Create build directory
    ctx.build_directory = os.path.join(args.output_directory, name + "-" + version)

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
    ctx.files = description_file.get("files") or []
    for file in ctx.files:
        name = file["name"]

        if name == "":
            raise ValueError("File name cannot be empty.")

        output_filename = os.path.join(ctx.build_directory, name)

        if "contents" in file:
            contents = ctx.execute_template(file["contents"])
            with open(output_filename, "w") as f:
                f.write(contents)
        elif "filename" in file:
            base = os.path.abspath(os.path.dirname(args.description_file))
            filename = os.path.join(base, file["filename"])
            with open(output_filename, "wb") as f:
                with open(filename, "rb") as f2:
                    f.write(f2.read())
        else:
            raise ValueError("File contents not found.")

        if "executable" in file and file["executable"]:
            os.chmod(output_filename, 0o755)

    # Write Dockerfile
    if ctx.build_kind == "neurodocker":
        dockerfile = ctx.build_neurodocker(ctx.build_info, ctx.deploy)

        with open(os.path.join(ctx.build_directory, "Dockerfile"), "w") as f:
            f.write(dockerfile)
    else:
        raise ValueError("Build kind not supported.")

    if args.build:
        print("Building Docker image...")
        # Shell out to Docker
        # docker-py does not support using BuildKit
        subprocess.check_call(
            ["docker", "build", "-t", ctx.tag, "."],
            cwd=ctx.build_directory,
        )
        print("Docker image built successfully at", ctx.tag)


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
