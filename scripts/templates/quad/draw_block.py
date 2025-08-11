#!/usr/bin/env python3

import sys
import matplotlib.pyplot as plt
import gzip
import numpy as np
import re

def chunks(lst, n):
    """Yield successive n-sized chunks from lst."""
    for i in range(0, len(lst), n):
        yield lst[i:i + n]

def convert_rect2poly(rect):
    flat = [x for l in rect for x in l]
    return [[flat[0], flat[1]], [flat[0], flat[3]], [flat[2], flat[3]], [flat[2], flat[1]]]


def plot_poly(coord):
    coord.append(coord[0]) #repeat the first point to create a 'closed loop'
    xs, ys = zip(*coord) #create lists of x and y values
    plt.figure()
    plt.plot(xs,ys)
    plt.axis('equal')
    plt.grid()
    plt.show()
        

mydef = sys.argv[1]        
is_da = False
da = []

with gzip.open(mydef,'rt') as f:
    for line in f:
        if 'DIEAREA' in line or is_da:            
            is_da = True
            new_line = re.sub("^ | $", "", re.sub("\s\s+" , " ", "".join(i for i in line if i in "0123456789 ")))
            print(new_line)            
            da.append(new_line)
            if ';' in line and is_da:
                is_da = False
                break

da = " ".join(da)
da_list = da.split()
da_norm = [int(item) / 2000 for item in da_list]
coor_list = list(chunks(da_norm,2))
if coor_list.__len__() == 2:
    coor_list = convert_rect2poly(coor_list)

plot_poly(coor_list)















