digraph html {
    abc [shape=none, margin=0, label=<
    <TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4">
        <TR><TD ROWSPAN="1" COLSPAN="14"><FONT COLOR="red">{{ ptype }}</FONT><BR/>Profiling</TD></TR>
        <TR><TD COLSPAN="1" ROWSPAN="3"></TD><TD>CPU</TD><TD>Mem</TD><TD COLSPAN="5">IO-Disk</TD><TD COLSPAN="6">Network</TD></TR>
        <TR>
            <TD ROWSPAN="2" BGCOLOR="lightgrey">util(cores)</TD>
            <TD ROWSPAN="2" BGCOLOR="lightgrey">throughput(GB/s)</TD>
            <TD ROWSPAN="1" COLSPAN="2" BGCOLOR="lightgrey">write</TD>
            <TD ROWSPAN="1" COLSPAN="2" BGCOLOR="lightgrey">read</TD>
            <TD ROWSPAN="2" COLSPAN="1" BGCOLOR="lightgrey">util</TD>
            <TD ROWSPAN="1" COLSPAN="3" BGCOLOR="lightgrey">ingress</TD>
            <TD ROWSPAN="1" COLSPAN="3" BGCOLOR="lightgrey">egress</TD>
        </TR>
        <TR>
            <TD>throughput(MB/s)</TD>
            <TD>request(/s)</TD>
            <TD>throughput(MB/s)</TD>
            <TD>request(/s)</TD>
            <TD>throughput(Mb/s)</TD>
            <TD>packetNum(/s)</TD>
            <TD>packetSize(Mb)</TD>
            <TD>throughput(Mb/s)</TD>
            <TD>packetNum(/s)</TD>
            <TD>packetSize(Mb)</TD>
        </TR>
        <TR>
            <TD BGCOLOR="lightgreen">Avg</TD>
            {% for metric in metrics -%}
                <TD>{{ metric.avg }}</TD>
            {% endfor %}
        </TR>
        <TR>
            <TD BGCOLOR="lightgreen">Max</TD>
            {% for metric in metrics -%}
                <TD>{{ metric.max }}</TD>
            {% endfor %}
        </TR>
    </TABLE>>];
}
