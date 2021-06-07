#!/usr/bin/env python3
from jinja2 import Environment, FileSystemLoader

# generate jinja template
file_loader = FileSystemLoader('templates')
env = Environment(loader=file_loader)

template = env.get_template('treeDirectory.tpl')

cluster1 = {}
cluster1['name'] = "Layer1"
cluster1['id'] = "0"
cluster1['nodes'] = "a;b;"

cluster2 = {}
cluster2['name'] = "Layer2"
cluster2['id'] = "1"
cluster2['nodes'] = "c;d;"

clusters = [cluster1, cluster2]

lines = [{"from":"a","to":"c"},{"from":"b","to":"d"}]

output = template.render(clusters=clusters, lines=lines)
open('treeDirectory.graph','w').write(output)
