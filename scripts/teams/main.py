import subprocess
import os
import logging
import argparse
import logging
from konnect import Konnect
import json


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
    if "teams" not in config:
        logging.error("Config file should have a 'teams' key.")
        exit(1)
    team_names = set()
    for team in config["teams"]:
        if "name" not in team or "description" not in team:
            logging.error("Every team should have a 'name' and a 'description' key.")
            exit(1)
        if not isinstance(team["name"], str) or not isinstance(team["description"], str):
            logging.error("Every team name and description should be a string.")
            exit(1)
        if team["name"] in team_names:
            logging.error("Team names should be unique.")
            exit(1)
        team_names.add(team["name"])

def provision_teams(args):
    logging.info("Provisioning teams in Konnect...")
    logging.info(args)
    logging.info(f"Reading team data from '{args.config_file}'")
    config = {}
    with open(args.config_file, "r") as file:
        config = json.load(file)

    validate_config(config)

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
    logging.info("Existing teams:")
    print(json.dumps(existing_teams, indent=2))

def main():
    parser = argparse.ArgumentParser(description="Utility to provision teams in Konnect.")
    args = parse_args(parser)

    provision_teams(args)

if __name__ == "__main__":
    main()