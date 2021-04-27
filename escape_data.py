from jinja2 import Template, escape

data = '<a>Today is a sunny day</a>'

tm1 = Template("{{ data | e }}")
msg1 = tm1.render(data=data)
tm2 = Template("{{ data }}")
msg2 = tm2.render(data=data)

print(msg1)
print(msg2)
print(escape(data))
