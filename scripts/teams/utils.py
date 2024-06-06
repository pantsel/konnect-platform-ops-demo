import re

def is_valid_semver(version):
    pattern = r'^\d+\.\d+\.\d+$'
    return bool(re.match(pattern, version))

def merge_arrays(arr1, arr2):
    dict1 = {item['name']: item for item in arr1}
    dict2 = {item['name']: item for item in arr2}
    
    merged_dict = {**dict1, **dict2}
    
    for key in dict1.keys() & dict2.keys():
        merged_dict[key] = {**dict1[key], **dict2[key]}
    
    merged_list = list(merged_dict.values())
    
    return merged_list

def validate_config(config, logging):
    if "_format_version" not in config or "_type" not in config or "name" not in config or "region" not in config or "description" not in config or "resources" not in config:
        logging.error("Config file should have '_format_version', '_type', 'name', 'region', 'description', and 'resources' keys.")
        exit(1)
    if not isinstance(config["_format_version"], str) or not is_valid_semver(config["_format_version"]):
        logging.error("_format_version should be a valid semver string.")
        exit(1)
    if not isinstance(config["_type"], str) or config["_type"] not in ["federated", "central"]:
        logging.error("_type should be a string with value 'federated' or 'central'.")
        exit(1)
    if not isinstance(config["name"], str):
        logging.error("name should be a string.")
        exit(1)
    if not isinstance(config["region"], str):
        logging.error("region should be a string.")
        exit(1)
    if config["region"] not in ["eu", "au", "us"]:
        logging.error("region should be one of 'eu', 'au', or 'us'.")
        exit(1)
    if not isinstance(config["description"], str):
        logging.error("description should be a string.")
        exit(1)
    if not isinstance(config["resources"], list):
        logging.error("resources should be a list.")
        exit(1)
    for resource in config["resources"]:
        if not isinstance(resource, dict):
            logging.error("Each resource in resources should be an object.")
            exit(1)
        if "type" not in resource or "name" not in resource or "description" not in resource or "labels" not in resource:
            logging.error("Each resource should have 'type', 'name', 'description', and 'labels' keys.")
            exit(1)
        if not isinstance(resource["type"], str):
            logging.error("resource type should be a string.")
            exit(1)
        if not isinstance(resource["name"], str):
            logging.error("resource name should be a string.")
            exit(1)
        if not isinstance(resource["description"], str):
            logging.error("resource description should be a string.")
            exit(1)
        if not isinstance(resource["labels"], dict):
            logging.error("resource labels should be a dictionary.")
            exit(1)
    return True