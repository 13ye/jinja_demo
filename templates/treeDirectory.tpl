digraph G {
    label="Tree Directory Graph";
    K=0.6;
    pad=1.0;

    {% for cluster in clusters %} 
    subgraph cluster_{{ cluster.id }} {
        label="{{ cluster.name }}";
        {{ cluster.nodes }}
    }[pad=0.1]
    {% endfor %}
    {% for line in lines %} 
    {{ line.from }} -> {{ line.to }}[penwidth=0.2,color="green"];
    {% endfor %}
}
