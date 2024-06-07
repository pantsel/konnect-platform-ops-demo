import os
import logging
import argparse
import logging
from konnect import Konnect
import json
from utils import is_valid_semver, merge_arrays, validate_config


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

def parse_label(label):
    try:
        key, value = label.split('=')
        return key, value
    except ValueError:
        raise argparse.ArgumentTypeError(f"Invalid label: {label}. Must be in the format key=value.")

def parse_args(parser):
    parser.add_argument("--konnect-access-token", help="Access token", required=not os.getenv("KONNECT_ACCESS_TOKEN"), default=os.getenv("KONNECT_ACCESS_TOKEN"))
    parser.add_argument("--konnect-address", help="Konnect address", required=not os.getenv("KONNECT_ADDRESS"), default=os.getenv("KONNECT_ADDRESS") or "https://global.api.konghq.com")
    parser.add_argument("--config-file", help="Teams config file", required=True, default="../../resources/teams.json")
    parser.add_argument("--extra-labels", type=parse_label, help="Extra labels to add to the team", nargs="+")
    parser.add_argument("--wipe", help="Delete all teams", default=False, type=bool)
    args = parser.parse_args()

    return args

def read_config_file(config_file):
    with open(config_file, "r") as file:
        config = json.load(file)
    return config

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

    logging.info(f"Existing teams: {existing_teams}")

    # Delete teams that are not in the config
    for team in existing_teams:
        if team["name"] not in [team["name"] for team in config["resources"]["teams"]]:
            logging.info(f"Deleting team '{team['name']}'")
            Konnect.delete_team(args, team["id"])

    
    for team in config["resources"]["teams"]:
        if args.wipe:
            logging.info(f"Deleting team '{team['name']}'")
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


    merged_teams = merge_arrays(config["resources"]["teams"], existing_teams)
    config["resources"]["teams"] = merged_teams
  
    print(json.dumps(config, indent=2))


def provision_team(args, config):
    logging.info("Provisioning team in Konnect...")
    logging.info(args)
    logging.info(f"Reading team data from '{args.config_file}'")

    validate_config(config, logging)

    team_name = config["metadata"]["name"]

    existing_team = Konnect.get_team_by_name(args, team_name)

    if existing_team:
        logging.info(f"Team '{team_name}' already exists.")
        if args.wipe:
            logging.info(f"Deleting team '{team_name}'")
            Konnect.delete_team(args, existing_team["id"])
        else:
            logging.info("Skipping...")
    else:
        existing_team = Konnect.create_team(args, config["metadata"], [])

    config["metadata"] = {**config["metadata"], **existing_team}

    print(json.dumps(config, indent=2))


def main():
    parser = argparse.ArgumentParser(description="Utility to provision teams in Konnect.")
    args = parse_args(parser)
    config = read_config_file(args.config_file)

    if config["metadata"]["type"] == "konnect::team":
        provision_team(args,config)
    elif config["metadata"]["type"] == "konnect::resources":
        provision_teams(args)
    else:
        logging.error("Invalid config file. '.metadata.type' should be 'konnect::team' or 'konnect::resources'.")

if __name__ == "__main__":
    main()
