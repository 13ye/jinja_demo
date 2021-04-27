#!/usr/bin/env python3
from jinja2 import Environment, FileSystemLoader
import yaml
import numpy as np

def extract(obj):
    obj_keyset = [j.keys() for j in obj][0]
    obj_format = {}
    for key in obj_keyset:
        obj_format[key] = [value for value in (j[key] for j in obj)]
    return obj_format

with open('./output.yaml') as f:
    data = yaml.load_all(f, Loader=yaml.FullLoader)

    metrics_write = [
        #{'avg': 99.99, 'max': 404.404}
    ]
    metrics_read = [
        #{'avg': 99.99, 'max': 404.404}
    ]

    for d in data:
        typeRWs = ['write','read']
        statList = ['Cpustat','Memstat','Iostat','Netstat']
        for typeRW in typeRWs:
            for stat in statList:
                # stat
                statDict = extract(d[typeRW][stat])
                for key in statDict.keys():
                    if key.endswith("avg"):
                        if typeRW == 'write':
                            metrics_write.append({'avg':np.round(np.average(np.array(statDict[key])),6),'max':np.round(np.average(np.array(statDict[key.replace('avg','max')])),6)})
                        elif typeRW == 'read':
                            metrics_read.append({'avg':np.round(np.average(np.array(statDict[key])),6),'max':np.round(np.average(np.array(statDict[key.replace('avg','max')])),6)})

    # generate jinja template
    file_loader = FileSystemLoader('templates')
    env = Environment(loader=file_loader)

    template = env.get_template('profiling.tpl')

    output = template.render(ptype='Write', metrics=metrics_write)
    open('write.table.digraph','w').write(output)
    output = template.render(ptype='Read',metrics=metrics_read)
    open('read.table.digraph','w').write(output)
