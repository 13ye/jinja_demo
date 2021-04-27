import yaml
import time
import os
import numpy as np
import matplotlib.pyplot as plt
from jinja2 import Environment, FileSystemLoader

os.system('mkdir pictures')

def draw_4(figName, ylabel,dict1,dict2,dict3,dict4):
    #figName = 'Write_DiskIO'
    #ylabel = 'Write/Read Throughput (MB/s)'
    x = np.arange(len(dict1['value']))

    fig, ax = plt.subplots()
    line, = ax.plot(x, dict1['value'], 'g:',marker='.',label=dict1['key'])
    line, = ax.plot(x, dict2['value'], 'r:',marker='+',label=dict2['key'])
    line, = ax.plot(x, dict3['value'], 'b-.',marker='*',label=dict3['key'])
    line, = ax.plot(x, dict4['value'], 'y--',marker='.',label=dict4['key'])
    
    ymax = -2e10
    for xxx in dict1['value']+dict2['value']+dict3['value']+dict4['value']:
        if xxx > ymax:
            ymax = xxx

    ax.set_xticks(x)
    ax.set_xticklabels(x)
    plt.ylim((0,ymax*1.05))
    #ax.legend(loc='lower right')
    ax.legend(loc='upper right')
    plt.ylabel(ylabel)
    plt.xlabel(figName+' case index')
    plt.show()
    plt.savefig("./pictures/"+figName+'.png')
    print("generate picture: "+figName+'.png')

def draw_2(figName, ylabel,dict1,dict2):
    #figName = 'Write_DiskIO'
    #ylabel = 'Write/Read Throughput (MB/s)'
    x = np.arange(len(dict1['value']))

    fig, ax = plt.subplots()
    line, = ax.plot(x, dict1['value'], 'r:',marker='+',label=dict1['key'])
    line, = ax.plot(x, dict2['value'], 'b-.',marker='*',label=dict2['key'])

    ymax = -2e10
    for xxx in dict1['value']+dict2['value']:
        if xxx > ymax:
            ymax = xxx

    ax.set_xticks(x)
    ax.set_xticklabels(x)
    plt.ylim((0,ymax*1.05))
    #ax.legend(loc='lower right')
    ax.legend(loc='upper right')
    plt.ylabel(ylabel)
    plt.xlabel(figName+' case index')
    plt.show()
    #plt.savefig(figName+'.png')
    plt.savefig("./pictures/"+figName+'.png')
    print("generate picture: "+figName+'.png')

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

    # This part is to generate Pictures
    for d in data:
        typeRWs = ['write','read']
        for typeRW in typeRWs:
            
            # iostat
            iostat = extract(d[typeRW]['Iostat'])
            draw_4(typeRW+'_DiskIO_Throuput','Write/Read Throughput (MB/s)',{'key':'wMB_max','value':iostat['wmb_max']},{'key':'wMB_avg','value':iostat['wmb_avg']},{'key':'rMB_max','value':iostat['rmb_max']},{'key':'rMB_avg','value':iostat['rmb_avg']})
            draw_4(typeRW+'_DiskIO_Request','Write/Read Request (/s)',{'key':'wRq_max','value':iostat['wrq_max']},{'key':'wRq_avg','value':iostat['wrq_avg']},{'key':'rRq_max','value':iostat['rrq_max']},{'key':'rRq_avg','value':iostat['rrq_avg']})
            draw_2(typeRW+'_DiskIO_Util','Write/Read Util Percentage (%)',{'key':'util_max','value':iostat['util_max']},{'key':'util_avg','value':iostat['util_avg']})

            # memstat
            memstat = extract(d[typeRW]['Memstat'])
            draw_2(typeRW+'_MEM_Throughput','Memory Throughput (GB/s)',{'key':'mem_max','value':memstat['mem_max']},{'key':'mem_avg','value':memstat['mem_avg']})
            draw_2(typeRW+'_MEM_Request','Memory Loads/Stores (/s)',{'key':'loads','value':memstat['loads']},{'key':'stores','value':memstat['stores']})

            # netstat
            netstat = extract(d[typeRW]['Netstat'])
            draw_4(typeRW+'_NET_Throuput','Network Throughput (Mbit/s)',{'key':'rxmb_max','value':netstat['rxmb_max']},{'key':'rxmb_avg','value':netstat['rxmb_avg']},{'key':'txmb_max','value':netstat['txmb_max']},{'key':'txmb_avg','value':netstat['txmb_avg']})
            draw_4(typeRW+'_NET_Packets','Network Packets (/s)',{'key':'rxpac_max','value':netstat['rxpac_max']},{'key':'rxpac_avg','value':netstat['rxpac_avg']},{'key':'txpac_max','value':netstat['txpac_max']},{'key':'txpac_avg','value':netstat['txpac_avg']})
            draw_4(typeRW+'_NET_PacketSize','Network PacketSize (Kbit/s)',{'key':'rxpackb_max','value':netstat['rxpackb_max']},{'key':'rxpackb_avg','value':netstat['rxpackb_avg']},{'key':'txpackb_max','value':netstat['txpackb_max']},{'key':'txpackb_avg','value':netstat['txpackb_avg']})

            # cpustat
            cpustat = extract(d[typeRW]['Cpustat'])
            draw_2(typeRW+'_CPU_Util','Cpu Util Percentage (cores)',{'key':'cpu_max','value':cpustat['cpu_max']},{'key':'cpu_avg','value':cpustat['cpu_avg']})

            # @@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            # This part is to generate table
            statList = ['Cpustat','Memstat','Iostat','Netstat']
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
    os.system('dot -Tsvg write.table.digraph -o pictures/write.table.svg && rm write.table.digraph')
    os.system('dot -Tsvg read.table.digraph -o pictures/read.table.svg && rm read.table.digraph')
                
