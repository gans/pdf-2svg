import base64, os, re

BASE = './'
fonts = [i for i in os.listdir(BASE) if i.endswith('.woff')]


svg_style = '<svg:style type="text/css">\n'

for i in fonts:
    fontb = open(BASE + i, 'r').read()
    fontb = base64.encodestring(fontb).replace('\n', '')
    the_font = '@font-face { font-family: "'+ i.split('.')[0]  +'"; src: url(data:font/woff;base64,'+ fontb +'); }\n'
    svg_style += the_font

svg_style += '</svg:style>\n'

src = open(BASE + 'output.svg', 'r').read()

sub = re.compile('(<defs.*?">)', re.S).findall(src)[0]
src = src.replace(sub, '{0}\n{1}'.format(svg_style, sub))
open(BASE+'output.svg', 'w').write(src)

