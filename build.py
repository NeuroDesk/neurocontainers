#!/usr/bin/env python3
import yaml
import subprocess
import os

GLOBAL_MOUNT_POINT_LIST = (
    "/afm01 /afm02 /cvmfs /90days /30days "
    + "/QRISdata /RDS /data /short /proc_temp "
    + "/TMPDIR /nvme /neurodesktop-storage /local "
    + "/gpfs1 /working /winmounts /state /tmp "
    + "/autofs /cluster /local_mount /scratch "
    + "/clusterdata /nvmescratch"
).split(" ")


def build_neurodocker(build_directive, deploy):
    args = ["neurodocker", "generate", "docker"]

    base = build_directive["base-image"]
    pkg_manager = build_directive["pkg-manager"]

    if base == "" or pkg_manager == "":
        raise ValueError("Base image or package manager cannot be empty.")

    args += ["--base-image", base, "--pkg-manager", pkg_manager]

    args += [
        "--run=\"printf '#!/bin/bash\\nls -la' > /usr/bin/ll\"",
        '--run="chmod +x /usr/bin/ll"',
        f'--run="mkdir -p {" ".join(GLOBAL_MOUNT_POINT_LIST)}"',
    ]

    for directive in build_directive["directives"]:
        if "install" in directive:
            args += ["--install"] + directive["install"]
        elif "run" in directive:
            args += ["--run=" + " && ".join(directive["run"])]
        elif "workdir" in directive:
            args += ["--workdir", directive["workdir"]]
        elif "environment" in directive:
            for key, value in directive.items():
                if key == "environment":
                    continue
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

    args += ["--copy", "README.md", "/README.md"]

    return subprocess.check_output(args).decode("utf-8")


def main(args):
    if len(args) != 2:
        print("Usage: build.py <description_file> <output_directory>")
        os.exit(1)
    description_filename = args[0]
    output_directory = args[1]

    description_file = yaml.safe_load(open(description_filename, "r"))

    name = description_file["name"]
    version = description_file["version"]

    readme = description_file["readme"]

    if name == "" or version == "" or readme == "":
        raise ValueError("Name, version, or readme cannot be empty.")

    build_kind = description_file["build"]["kind"]

    deploy = None
    if "deploy" in description_file:
        deploy = description_file["deploy"]

    build_directory = os.path.join(output_directory, name + "-" + version)

    if os.path.exists(build_directory):
        raise ValueError("Build directory already exists.")

    os.makedirs(build_directory)

    with open(os.path.join(build_directory, "README.md"), "w") as f:
        f.write(readme)

    if build_kind == "neurodocker":
        dockerfile = build_neurodocker(description_file["build"], deploy)

        with open(os.path.join(build_directory, "Dockerfile"), "w") as f:
            f.write(dockerfile)
    else:
        raise ValueError("Build kind not supported.")

    if "files" in description_file:
        files = description_file["files"]
        for file in files:
            name = file["name"]

            if name == "":
                raise ValueError("File name cannot be empty.")

            if "contents" in file:
                contents = file["contents"]
                with open(os.path.join(build_directory, name), "w") as f:
                    f.write(contents)
            elif "filename" in file:
                base = os.path.abspath(os.path.dirname(description_filename))
                filename = os.path.join(base, file["filename"])
                with open(os.path.join(build_directory, name), "wb") as f:
                    with open(filename, "rb") as f2:
                        f.write(f2.read())
            else:
                raise ValueError("File contents not found.")


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
