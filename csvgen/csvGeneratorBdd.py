#!/usr/bin/python3

import irmaDBCredentials
import MySQLdb
import os
import re

def genCsv(allyesconfig):
    properties = {"KERNEL_SIZE":[]}

    pattern = re.compile("^([^#][^=]*)=(.*)$")

    # Extract all property names
    allyes = open(allyesconfig, "r")
    for line in allyes:
        m=re.match(pattern, line)
        if m:
            name = m.group(1)
            properties[name] = []

    # Get all .configs that successfully compiled
    try:
        conn = MySQLdb.connect(**irmaDBCredentials.info)

        # Request
        entry_sql = ("SELECT (config_file, com) TuxML"
            "(compilation_time, config_file, core_size, error)"
            "VALUES (%(compilation_time)s, %(config_file)s, %(core_size)s, %(error)s)")

    # To complete

if __name__ == "__main__":
    genCsv("allyes.config")
