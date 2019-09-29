#!/usr/bin/env python3

import os
import sys
import json

if __name__ == "__main__":
    event_path = os.environ["GITHUB_EVENT_PATH"]
    event_data = json.load(open(event_path))

    check_run = event_data["check_run"]

    print(check_run["status"])
    print(check_run["name"])
    sys.exit(78)
