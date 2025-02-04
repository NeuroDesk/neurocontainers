#!/usr/bin/env python3
import yaml
import subprocess
import os
import sys
import urllib.request
import argparse
import shutil
import jinja2

GLOBAL_MOUNT_POINT_LIST = (
    "/afm01 /afm02 /cvmfs /90days /30days "
    + "/QRISdata /RDS /data /short /proc_temp "
    + "/TMPDIR /nvme /neurodesktop-storage /local "
    + "/gpfs1 /working /winmounts /state /tmp "
    + "/autofs /cluster /local_mount /scratch "
    + "/clusterdata /nvmescratch"
).split(" ")

_jinja_env = jinja2.Environment(undefined=jinja2.StrictUndefined)


class BuildContext(object):
    def __init__(self, name, version):
        self.name = name
        self.version = version

    def execute_template(self, obj):
        if type(obj) == str:
            tpl = _jinja_env.from_string(obj)
            return tpl.render(context=self)
        elif type(obj) == list:
            return [self.execute_template(o) for o in obj]
        else:
            raise ValueError("Template object not supported.")


def build_neurodocker(ctx: BuildContext, build_directive, deploy):
    args = ["neurodocker", "generate", "docker"]

    base = build_directive.get("base-image") or ""
    pkg_manager = build_directive.get("pkg-manager") or ""

    if base == "" or pkg_manager == "":
        raise ValueError("Base image or package manager cannot be empty.")

    args += ["--base-image", base, "--pkg-manager", pkg_manager]

    args += [
        "--run=printf '#!/bin/bash\\nls -la' > /usr/bin/ll",
        "--run=chmod +x /usr/bin/ll",
        f"--run=mkdir -p {" ".join(GLOBAL_MOUNT_POINT_LIST)}",
    ]

    for directive in build_directive["directives"]:
        if "install" in directive:
            if type(directive["install"]) == str:
                args += ["--install"] + [
                    f
                    for f in directive["install"].replace("\n", " ").split(" ")
                    if f != ""
                ]
            elif type(directive["install"]) == list:
                args += ["--install"] + directive["install"]
            else:
                raise ValueError("Install directive must be a string or list.")
        elif "run" in directive:
            args += [
                "--run=" + " \\\n && ".join(ctx.execute_template(directive["run"]))
            ]
        elif "workdir" in directive:
            args += ["--workdir", directive["workdir"]]
        elif "environment" in directive:
            for key, value in directive["environment"].items():
                args += ["--env", f"{key}={value}"]
        elif "template" in directive:
            name = directive["template"]["name"]
            if name == "":
                raise ValueError("Template name cannot be empty.")
            items = [
                f"{k}={v}" for k, v in directive["template"].items() if k != "name"
            ]
            args += ["--" + name] + items
        elif "copy" in directive:
            args += ["--copy"] + directive["copy"].split(" ")
        else:
            raise ValueError(f"Directive {directive} not supported.")

    if deploy is not None:
        if "path" in deploy:
            args += ["--env", "DEPLOY_PATH=" + ":".join(deploy["path"])]
        if "bins" in deploy:
            args += ["--env", "DEPLOY_BINS=" + ":".join(deploy["bins"])]

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

    args = parser.parse_args()

    # Load description file
    description_file = yaml.safe_load(open(args.description_file, "r"))

    if description_file == None:
        raise ValueError("Description file is empty.")

    # Get basic information
    name = description_file.get("name") or ""
    version = description_file.get("version") or ""

    readme = description_file.get("readme") or ""

    # If readme is not found, try to get it from a URL
    if "readme_url" in description_file:
        readme_url = description_file["readme_url"]
        if readme_url != "":
            readme = http_get(readme_url)

    # Check if name, version, or readme is empty
    if name == "" or version == "" or readme == "":
        raise ValueError("Name, version, or readme cannot be empty.")

    # Get build information
    build_info = description_file.get("build") or None

    if build_info is None:
        raise ValueError("No build tag found in description file.")

    build_kind = build_info.get("kind") or ""
    if build_kind == "":
        raise ValueError("Build kind cannot be empty.")

    deploy = description_file.get("deploy") or None

    # Create build directory
    build_directory = os.path.join(args.output_directory, name + "-" + version)

    if os.path.exists(build_directory):
        if args.recreate:
            shutil.rmtree(build_directory)
        else:
            raise ValueError("Build directory already exists.")

    os.makedirs(build_directory)

    # Write README.md
    with open(os.path.join(build_directory, "README.md"), "w") as f:
        f.write(readme)

    ctx = BuildContext(name, version)

    # Write Dockerfile
    if build_kind == "neurodocker":
        dockerfile = build_neurodocker(ctx, build_info, deploy)

        with open(os.path.join(build_directory, "Dockerfile"), "w") as f:
            f.write(dockerfile)
    else:
        raise ValueError("Build kind not supported.")

    files = description_file.get("files") or []
    for file in files:
        name = file["name"]

        if name == "":
            raise ValueError("File name cannot be empty.")

        if "contents" in file:
            contents = file["contents"]
            with open(os.path.join(build_directory, name), "w") as f:
                f.write(contents)
        elif "filename" in file:
            base = os.path.abspath(os.path.dirname(args.description_file))
            filename = os.path.join(base, file["filename"])
            with open(os.path.join(build_directory, name), "wb") as f:
                with open(filename, "rb") as f2:
                    f.write(f2.read())
        else:
            raise ValueError("File contents not found.")


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
