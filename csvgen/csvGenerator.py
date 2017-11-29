#!/usr/bin/python3

import irmaDBCredentials
import os
import re

config_folder = "configs/"

config_files = os.listdir(config_folder)

file_count = len(config_files)

properties = {"KERNEL_SIZE":[0]*file_count}

pattern = re.compile("^([^#][^=]*)=(.*)$")

for file_number, config_file in enumerate(config_files):
    config_content = open(config_folder + config_file, "r")
    # Config properties
    for line in config_content:
        m = re.match(pattern, line)
        if m:
            key = m.group(1)
            value = m.group(2)
            if key not in properties:
                properties[key] = ["n"]*file_count
            properties[key][file_number] = value
    # File size
    properties["KERNEL_SIZE"][file_number] = str(os.path.getsize(config_folder + config_file))

for (k,v) in properties.items():
    values = k
    for va in v:
        values += "," + va

    print(values)


