import requests
import logging
import sys

class Konnect:
    @staticmethod
    def get_all_teams(args):
        try:
            teams = []
            page_number = 1
            while True:
                # Get a list of teams from Konnect
                filter_labels = '{"genby":"provutils"}'
                url = f"{args.konnect_address}/v3/teams?page[size]=100&page[number]={page_number}&filter[labels]={filter_labels}"
                headers = {
                    "Authorization": f"Bearer {args.konnect_access_token}"
                }
                response = requests.get(url, headers=headers)
                response.raise_for_status()  # Raise an exception if the request was not successful
                data = response.json()

                # Filter out system teams
                filtered_data = [record for record in data["data"] if not record.get("system_team")]

                teams.extend(filtered_data)
                if len(data["data"]) == 0:
                    break
                page_number += 1
            return teams
        except requests.exceptions.RequestException as e:
            logging.error(f"An error occurred while retrieving teams: {e}")
            sys.exit(1)

    @staticmethod
    def get_team_by_name(args, team_name):
        try:
            filter_labels = '{"genby":"provutils"}'
            url = f"{args.konnect_address}/v3/teams?filter[name]={team_name}&filter[labels]={filter_labels}"
            headers = {
                "Authorization": f"Bearer {args.konnect_access_token}"
            }
            response = requests.get(url, headers=headers)
            response.raise_for_status()  # Raise an exception if the request was not successful
            data = response.json()
            return data["data"][0] if data["data"] else None
        except requests.exceptions.RequestException as e:
            logging.error(f"An error occurred while retrieving team '{team_name}': {e}")
            sys.exit(1)

    @staticmethod
    def create_team(args, team, existing_teams):

        # if team name already exists in existing_teams, return the team
        for existing_team in existing_teams:
            if existing_team["name"] == team["name"]:
                logging.info(f"Team '{team["name"]}' already exists.")
                return existing_team

        try:
            url = f"{args.konnect_address}/v3/teams"
            headers = {
                "Authorization": f"Bearer {args.konnect_access_token}",
                "Content-Type": "application/json"
            }
            payload = {
                "name": team["name"],
                "description": team["description"],
                "labels": {
                    "genby":"provutils"
                }
            }
            response = requests.post(url, headers=headers, json=payload)
            response.raise_for_status()  # Raise an exception if the request was not successful
            logging.info(f"Team '{team["name"]}' created successfully.")
            return response.json()
        except requests.exceptions.RequestException as e:
            logging.error(f"An error occurred while creating team '{team["name"]}': {e}")
            sys.exit(1)

    @staticmethod
    def delete_team(args, team_id):
        try:
            url = f"{args.konnect_address}/v3/teams/{team_id}"
            headers = {
                "Authorization": f"Bearer {args.konnect_access_token}",
                "Content-Type": "application/json"
            }
            response = requests.delete(url, headers=headers)
            response.raise_for_status()  # Raise an exception if the request was not successful
            logging.info(f"Team '{team_id}' deleted successfully.")
        except requests.exceptions.RequestException as e:
            logging.error(f"An error occurred while deleting team '{team_id}': {e}")
            sys.exit(1)

    @staticmethod
    def assign_role_to_team(args, team_id, role):

        try:
            url = f"{args.konnect_address}/v3/teams/{team_id}/assigned-roles"
            headers = {
                "Authorization": f"Bearer {args.konnect_access_token}",
                "Content-Type": "application/json"
            }
            payload = role
            response = requests.post(url, headers=headers, json=payload)
            response.raise_for_status()  # Raise an exception if the request was not successful
            logging.info(f"Role '{role["role_name"]}' assigned to team '{team_id}' and region '{role["entity_region"]}' successfully.")
            return response.json()
        except requests.exceptions.RequestException as e:
            
            # if status code is 409, it means the role is already assigned to the team
            if response.status_code == 409:
                logging.info(f"Role '{role["role_name"]}' is already assigned to team '{team_id}' and region '{role["entity_region"]}'")
                return response.json()
            
            logging.error(f"An error occurred while assigning role '{role["role_name"]}' to team '{team_id}' and region '{role["entity_region"]}': {e}")
            sys.exit(1)