#!/usr/bin/env python3

import os
import sys
import json


with open(sys.argv[1]) as f:
  data = json.load(f)

blocks = []
for block in data:
    blocks.append(block)
    

lineLength = 5
index = 0
for block in sorted(blocks):
    print ('%-25s' % block, end = " ")
    index = index + 1
    if not index % lineLength:
        print()    

print ()
