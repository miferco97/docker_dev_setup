#!/bin/env/python3

import argparse
import os

import yaml


def load_yaml(file_path):
    with open(file_path, "r") as file:
        return yaml.safe_load(file)


def save_yaml(data, file_path):
    with open(file_path, "w") as file:
        yaml.safe_dump(data, file)


def merge_dicts(base, override):
    for key, value in override.items():
        if isinstance(value, dict) and key in base and isinstance(base[key], dict):
            merge_dicts(base[key], value)
        elif isinstance(value, list) and key in base and isinstance(base[key], list):
            # Merge lists by extending the base list with unique items from the override list
            for item in value:
                if item not in base[key]:
                    base[key].append(item)
        else:
            base[key] = value
    return base


def find_full_context_path(build_context, file_route):
    """Given a build context, return the absolute path."""
    # also handle the ~ case for home directory
    if os.path.isabs(build_context) or build_context.startswith("$"):
        return build_context
    elif build_context.startswith("~"):
        # return os.path.expanduser(build_context)
        return build_context
    else:
        base_dir = os.path.dirname(os.path.abspath(file_route))
        return os.path.abspath(os.path.join(base_dir, build_context))


def divide_docker_compose(docker_compose_file):
    """Divides a docker-compose with a single service into
    build-part: image name and all the build related variables
    run-part: all the other variables related to running the container
    """
    docker_compose_content = load_yaml(docker_compose_file)

    services = docker_compose_content.get("services", {})
    if len(services) != 1:
        raise ValueError("The docker-compose content must contain exactly one service.")

    service_name, service_config = next(iter(services.items()))

    build_part = {}
    run_part = {}

    for key, value in service_config.items():
        if key in ["build", "image"]:
            build_part[key] = value
        else:
            run_part[key] = value

    # check the context path
    if build_part.get("build") and isinstance(build_part["build"], dict):
        context = build_part["build"].get("context", ".")
        full_context_path = find_full_context_path(context, docker_compose_file)
        build_part["build"]["context"] = full_context_path

    # do the same for the volumes in the run_part, to make them absolute paths in the left side of the colcon
    # if it has 3 parts, like /host/path:/container/path:ro only make the host path absolute
    if "volumes" in run_part:
        absolute_volumes = []
        for vol in run_part["volumes"]:
            parts = vol.split(":")
            if len(parts) >= 2:
                host_path = parts[0]
                if not os.path.isabs(host_path):
                    host_path = find_full_context_path(host_path, docker_compose_file)
                parts[0] = host_path
                absolute_volumes.append(":".join(parts))
            else:
                absolute_volumes.append(
                    vol
                )  # leave it as is if it doesn't match expected format
        run_part["volumes"] = absolute_volumes

    return {
        "service_name": service_name,
        "build_part": build_part,
        "run_part": run_part,
    }


def resolve_project_variables(run_part, project_dir):
    """Replace $PROJECT_DIR and $PROJECT_NAME in volume paths and environment values."""
    project_name = os.path.basename(project_dir)
    if "volumes" in run_part:
        resolved = []
        for vol in run_part["volumes"]:
            vol = vol.replace("$PROJECT_DIR", project_dir)
            vol = vol.replace("$PROJECT_NAME", project_name)
            resolved.append(vol)
        run_part["volumes"] = resolved
    if "environment" in run_part:
        for key, value in run_part["environment"].items():
            if isinstance(value, str):
                run_part["environment"][key] = value.replace(
                    "$PROJECT_DIR", project_dir
                ).replace("$PROJECT_NAME", project_name)


def extend_docker_compose(base_file, extension_file, output_file):
    base_divided = divide_docker_compose(base_file)
    # print(f"Base divided: {base_divided}")
    dev_divided = divide_docker_compose(extension_file)

    # Resolve $PROJECT_DIR and $PROJECT_NAME in devenv volumes
    project_dir = os.path.dirname(os.path.abspath(base_file))
    resolve_project_variables(dev_divided["run_part"], project_dir)

    # if there is no build part in base_service, then use the service name as BASE_IMAGE without an additional service
    print(f"Base divided build part: {base_divided['build_part']}")

    base_service_name = base_divided["service_name"]
    base_image_name = base_divided["build_part"].get("image", None)

    if not base_divided["build_part"].get("build", None):
        dev_divided["service_name"] = base_service_name + "_dev"
        dev_divided["build_part"]["image"] = (
            base_image_name + ":dev"
            if base_image_name.find(":") == -1
            else f"{base_image_name.split(':')[0]}-dev:{base_image_name.split(':')[1]}"
        )
        dev_divided["build_part"]["build"]["args"]["BASE_IMAGE"] = base_image_name
        run_part_merged = merge_dicts(base_divided["run_part"], dev_divided["run_part"])
        new_config = {
            "services": {
                dev_divided["service_name"]: merge_dicts(
                    dev_divided["build_part"], run_part_merged
                ),
            }
        }

        save_yaml(new_config, output_file)
        return

    base_divided["build_part"]["image"] = base_image_name + ":base"
    base_divided["build_part"]["command"] = (
        "true"  # Dummy command to keep the container running if needed
    )

    base_divided["service_name"] = base_service_name + "_build"
    dev_divided["service_name"] = base_service_name + "_dev"
    dev_divided["build_part"]["image"] = base_image_name + ":dev"
    dev_divided["build_part"]["build"]["args"]["BASE_IMAGE"] = base_image_name + ":base"
    dev_divided["build_part"]["depends_on"] = [base_divided["service_name"]]

    run_part_merged = merge_dicts(base_divided["run_part"], dev_divided["run_part"])
    # print(f"Run part merged: {run_part_merged}")
    # print(f"Dev divided: {dev_divided}")

    new_config = {
        "services": {
            base_divided["service_name"]: base_divided["build_part"],
            dev_divided["service_name"]: merge_dicts(
                dev_divided["build_part"], run_part_merged
            ),
        }
    }
    save_yaml(new_config, output_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Extend a docker-compose.yml file with a dev configuration."
    )
    parser.add_argument("base_file", help="Path to the base docker-compose.yml file")
    parser.add_argument(
        "-d",
        "--dev",
        dest="extension_files",
        required=True,
        help="Path to the extension docker-compose.dev.yml file(s). Can be specified multiple times.",
    )
    parser.add_argument(
        "-o",
        "--output",
        default="docker-compose.extended.yml",
        help="Path to save the extended docker-compose.yml file (default: docker-compose.extended.yml)",
    )
    args = parser.parse_args()

    base_file = args.base_file
    extension_files = args.extension_files
    output_file = args.output

    extend_docker_compose(base_file, extension_files, output_file)
