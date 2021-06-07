# created by 13ye
#!/usr/bin/env python3
from jinja2 import Environment, FileSystemLoader
import os
import sys
import time

rootPath = "MMM"
global_cluster_id = 0
clusters_temp = []
clusters = []
lines = []

clusterRoot = {"id":global_cluster_id,"name":"root","nodes":""}
clusters_temp.append(clusterRoot)

def DFS(path, parent, depth, clusterMyLayer):
    global global_cluster_id
    #print(path, parent, depth)
    res = os.popen("cd "+path+" && ls -l").read().split("\n")[1:-1]
    for r in res:
        name = r.split(" ")[-1]
        if r.startswith("d"):
            global_cluster_id += 1
            nodeName = name.replace("-","_")+"_"+str(depth)+"_"+str(global_cluster_id)
            clusterMyLayer["nodes"] += nodeName+";"
            lines.append({"from":parent,"to":nodeName})
            clusterNext = {"id":global_cluster_id,"name":name,"nodes":""}
            clusters_temp.append(clusterNext)
            DFS(path+"/"+name, nodeName, depth+1, clusterNext)
        

DFS(rootPath, "root", 0, clusterRoot)
for cluster in clusters_temp:
    if len(cluster["nodes"]) > 0:
        clusters.append(cluster)

#print(clusters)
#print(lines)

# generate jinja template
file_loader = FileSystemLoader('templates')
env = Environment(loader=file_loader)

template = env.get_template('treeDirectory.tpl')

output = template.render(clusters=clusters, lines=lines)
open('treeDirectory.graph','w').write(output)
