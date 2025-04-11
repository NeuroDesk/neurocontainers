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


def run_docker_test(tag, test):
    print(tag, test)

    raise NotImplementedError("Docker test execution is not implemented yet")


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
