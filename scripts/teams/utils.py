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
    if "_format_version" not in config or "_type" not in config or "name" not in config or "region" not in config or "description" not in config or "resources" not in config or "plan" not in config:
        logging.error("Config file should have '_format_version', '_type', 'name', 'region', 'description', 'resources', and 'plan' keys.")
        exit(1)
    if not isinstance(config["_format_version"], str) or not is_valid_semver(config["_format_version"]):
        logging.error("_format_version should be a valid semver string.")
        exit(1)
    
    return True