import os
import logging
import argparse
import logging
from konnect import Konnect
import json
import re


# Set up logging
COLORS = {
    'WARNING': '\033[93m',
    'INFO': '\033[94m',
    'ERROR': '\033[91m',
    'END': '\033[0m'
}
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Define custom log levels with colors
logging.addLevelName(logging.INFO, "\033[94mINFO\033[0m")
logging.addLevelName(logging.WARNING, "\033[93mWARNING\033[0m")
logging.addLevelName(logging.ERROR, "\033[91mERROR\033[0m")

logging.info = lambda msg: logging.log(logging.INFO, f"{COLORS['INFO']}{msg}{COLORS['END']}")
logging.warning = lambda msg: logging.log(logging.WARNING, f"{COLORS['WARNING']}{msg}{COLORS['END']}")
logging.error = lambda msg: logging.log(logging.ERROR, f"{COLORS['ERROR']}{msg}{COLORS['END']}")

def parse_args(parser):
    parser.add_argument("--konnect-access-token", help="Access token", required=not os.getenv("KONNECT_ACCESS_TOKEN"), default=os.getenv("KONNECT_ACCESS_TOKEN"))
    parser.add_argument("--konnect-address", help="Konnect address", required=not os.getenv("KONNECT_ADDRESS"), default=os.getenv("KONNECT_ADDRESS") or "https://global.api.konghq.com")
    parser.add_argument("--config-file", help="Teams config file", required=True, default="../../resources/teams.json")
    parser.add_argument("--wipe", help="Delete all teams", default=False, type=bool)
    args = parser.parse_args()

    return args

def get_workspaces_from_dumps_dir(dumps_dir):
    workspaces = []
    for filename in os.listdir(dumps_dir):
        if filename.endswith(".yaml"):
            workspace_name = os.path.splitext(filename)[0]
            if workspace_name != "default": # Exclude default workspace
                workspaces.append(workspace_name)
    return workspaces

def validate_config(config):
    if "teams" not in config or "control_plane_groups" not in config or "_format_version" not in config:
        logging.error("Config file should have 'teams', 'control_plane_groups', and '_format_version' keys.")
        exit(1)
    team_names = set()
    for team in config["teams"]:
        if "name" not in team or "description" not in team:
            logging.error("Every team should have a 'name' and a 'description' key.")
            exit(1)
        if not isinstance(team["name"], str) or not isinstance(team["description"], str):
            logging.error("Every team name and description should be a string.")
            exit(1)
        if not team["name"].replace('_', ' ').replace(' ', '').isalnum():
            logging.error("Team names should only contain alphanumeric characters, spaces, or underscores.")
            exit(1)
        if team["name"] in team_names:
            logging.error("Team names should be unique.")
            exit(1)
        team_names.add(team["name"])
    
    if not isinstance(config["control_plane_groups"], list):
        logging.error("'control_plane_groups' should be an array.")
        exit(1)
    
    for group in config["control_plane_groups"]:
        if not isinstance(group, dict):
            logging.error("Each group in 'control_plane_groups' should be an object.")
            exit(1)
        if "name" not in group or "members" not in group:
            logging.error("Each group in 'control_plane_groups' should have 'name' and 'members' keys.")
            exit(1)
        if not isinstance(group["name"], str) or not group["name"].replace('_', ' ').replace(' ', '').isalnum():
            logging.error("Group name should be a string with alphanumeric characters, spaces, or underscores.")
            exit(1)
        if not isinstance(group["members"], list) or not all(isinstance(members, str) for members in group["members"]):
            logging.error("Group members should be a list of strings.")
            exit(1)
    
    if not isinstance(config["_format_version"], str) or not is_valid_semver(config["_format_version"]):
        logging.error("_format_version should be a valid semver string.")
        exit(1)

def is_valid_semver(version):
    pattern = r'^\d+\.\d+\.\d+$'
    return bool(re.match(pattern, version))

def provision_teams(args):
    logging.info("Provisioning teams in Konnect...")
    logging.info(args)
    logging.info(f"Reading team data from '{args.config_file}'")
    config = {}
    with open(args.config_file, "r") as file:
        config = json.load(file)

    # ToDO: Uncomment this line
    # validate_config(config)

    # Get all the teams in Konnect
    existing_teams = Konnect.get_all_teams(args)

    # Delete teams that are not in the config
    for team in existing_teams:
        if team["name"] not in [team["name"] for team in config["teams"]]:
            logging.info(f"Deleting team '{team['name']}'")
            Konnect.delete_team(args, team["id"])

    
    for team in config["teams"]:
        if args.wipe:
            existing_team = next((t for t in existing_teams if t["name"] == team["name"]), None)
            if existing_team:
                logging.info(f"Deleting team '{team['name']}'")
                Konnect.delete_team(args, existing_team["id"])
            else:
                logging.info(f"Team '{team['name']}' does not exist. Skipping...")
        else:
            Konnect.create_team(args, team, existing_teams)

    # Get all the teams again and print them in stdout
    existing_teams = Konnect.get_all_teams(args)


    merged_teams = merge_arrays(config["teams"], existing_teams)
    config["teams"] = merged_teams
  
    print(json.dumps(config, indent=2))

def merge_arrays(arr1, arr2):
    dict1 = {item['name']: item for item in arr1}
    dict2 = {item['name']: item for item in arr2}
    
    merged_dict = {**dict1, **dict2}
    
    for key in dict1.keys() & dict2.keys():
        merged_dict[key] = {**dict1[key], **dict2[key]}
    
    merged_list = list(merged_dict.values())
    
    return merged_list

def main():
    parser = argparse.ArgumentParser(description="Utility to provision teams in Konnect.")
    args = parse_args(parser)

    provision_teams(args)

if __name__ == "__main__":
    main()
