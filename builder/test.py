#!/usr/bin/env python3
import argparse
import yaml
import os
import shutil
import subprocess


def get_recipe_test(recipe):
    return os.path.join("recipes", recipe, "test.yaml")


def get_recipe_description(recipe):
    return os.path.join("recipes", recipe, "build.yaml")


def get_recipe_metadata(recipe):
    description_file = get_recipe_description(recipe)
    description_file = yaml.safe_load(open(description_file))

    return description_file["name"], description_file["version"]


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
    volume_name = f"neurocontainer-test-{tag.replace(':', '-')}"
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
    return run_docker_test(tag, test)


def check_docker(tag):
    # use docker image inspect
    subprocess.check_call(
        ["docker", "image", "inspect", tag],
        stdout=subprocess.DEVNULL,
    )


def run_tests(recipe):
    test_file = get_recipe_test(recipe)

    test_file = yaml.safe_load(open(test_file))
    if not test_file:
        print(f"No tests found for recipe {recipe}")
        return

    name, version = get_recipe_metadata(recipe)

    tag = f"{name}:{version}"

    check_docker(tag)

    for test in test_file["tests"]:
        run_test(tag, test)


def main(args):
    root = argparse.ArgumentParser(
        description="NeuroContainer Tester",
    )

    root.add_argument("recipe", help="The name of the recipe to test")

    args = root.parse_args(args)

    if shutil.which("docker") is None:
        print("Docker is not installed or not in PATH")
        return

    # Check that the user has permission to run docker

    run_tests(args.recipe)


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
