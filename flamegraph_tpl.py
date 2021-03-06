#!/usr/bin/env python3
from jinja2 import Environment, FileSystemLoader
import yaml
import numpy as np
import os

def extract(obj):
    obj_keyset = [j.keys() for j in obj][0]
    obj_format = {}
    for key in obj_keyset:
        obj_format[key] = [value for value in (j[key] for j in obj)]
    return obj_format

# read data from *.flametrace
height = 0
time_min = 9999999999999999
time_max = 0
colors = ["rgb(200,200,0)","rgb(250,150,0)","rgb(220,170,0)","rgb(160,240,30)","rgb(210,80,30)"]
color_index = 0
items = []
flametrace_dir = "./flametrace/"
return_value = os.popen('ls -l '+flametrace_dir).read()
fileNames = [i.split(" ")[-1] for i in return_value.split("\n")[1:-1]]

for fileName in fileNames:
    # trash code: to get global timeMultiple
    with open(flametrace_dir+fileName,"r") as filein:
        for line in filein.readlines():
            x = line.split(";")
            mintime = int(x[len(x)-2])
            maxtime = int(x[-1])
            if mintime < time_min:
                time_min = mintime
            if maxtime > time_max:
                time_max = maxtime

# actual svg width is 1180
timeMultiple = (time_max - time_min)/1180
print(time_min, time_max, timeMultiple)

for fileName in fileNames:
    with open(flametrace_dir+fileName,"r") as filein:
        file_item_batch = []
        depth = 1
        for line in filein.readlines():
            x = line.split(";")
            mintime = int(x[len(x)-2])
            maxtime = int(x[-1])
            if (maxtime - mintime)/(time_max-time_min)>0.001:
                has_item = True
                item = {}
                title = ""
                #print(x)
                item["title"] = x[len(x)-5].replace("<","[").replace(">","]")
                item["x_t"] = str((mintime - time_min) / timeMultiple + 13 )
                item["x"] = str( (mintime - time_min) / timeMultiple + 10 )
                #item["y"] = str(100+height)
                #item["y_t"] = item["y"]+10
                item["y"] = len(x)-5+1
                if depth < item["y"]:
                    depth = item["y"]
                item["width"] = (maxtime - mintime) / timeMultiple
                if item["width"] > 30:
                    if len(item["title"]) < int(item["width"]/7):
                        item["text"] = item["title"]
                    else:
                        item["text"] = item["title"][:min(len(item["title"])-1,int(item["width"]/7.1))] + ".."
                    print(len(item["title"])-1, int(item["width"]/7.1), item["title"])
                item["color"] = colors[color_index%len(colors)]
                file_item_batch.append(item)
                #items.append(item)
                color_index += 1
        for item in file_item_batch:
            item["y"] = (depth - item["y"])*15 + 100 + height
            item["y_t"] = item["y"]+10
            items.append(item)
        # add separation line
        if len(file_item_batch)>0:
            height += 15*depth
            print(height,depth)
            item = {"title":"separation","text":"separation","x":str(10),"x_t":str(13),"y":str(100+height),"y_t":str(110+height),"width":(time_max-time_min)/timeMultiple,"color":"rgb(0,250,250)"}
            items.append(item)
            height += 30
item = {"title":"all","text":"all","x":str(10),"x_t":str(13),"y":str(100+height),"y_t":str(110+height),"width":(time_max-time_min)/timeMultiple,"color":"rgb(255,0,0)"}
items.append(item)
height += 150

# generate jinja template
file_loader = FileSystemLoader('templates')
env = Environment(loader=file_loader)

template = env.get_template('flamegraph.tpl')

output = template.render(items = items,height=str(height+50),height_time_axis=str(height),height_time_axis_plus=str(height + 2),timeMultiple=str(timeMultiple))
open('svgs/flamegraph.temp.svg','w').write(output)
