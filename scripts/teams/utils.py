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
    # ToDo: Add more validation
    
    return True