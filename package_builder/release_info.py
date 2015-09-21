#!/usr/bin/env python

import json
import sys

with open(sys.argv[3]) as f: change_log = f.read()

hash =  {
  'date': sys.argv[1],
  'commit-id': sys.argv[2],
  'change-log': change_log,
}

print json.dumps(hash, indent=2)
