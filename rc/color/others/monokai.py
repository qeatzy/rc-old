import os, sys, time
from lxml import etree
def self():
    x = sys._getframe().f_back.f_code.co_name
    return x

# Monokai.tmTheme from http://tmtheme-editor.herokuapp.com/#!/editor/theme/Monokai
fn = os.path.join(os.path.dirname(__file__), 'Monokai.tmTheme')
with open(fn,'r') as f:
    text = f.read()
def parseXMLTheme_tmTheme(fn_or_text):
    if os.path.isfile(fn_or_text):
        d = etree.parse(fn)
    else:
        raise NotImplementedError(self())
    x=d.xpath('//array')
    x=x[0] if len(x) == 1 else x
    assert(len(x) > 10)
    print(len(x), [(i.tag,len(i)) for i in x])
    for e in x:
        # print(len(e), [(i.tag,len(i)) for i in e])
        print(etree.tostring(e).decode('utf8'))
        time.sleep(1)
    # print(len(x[0]), [(i.tag,len(i)) for i in x[0]])
    # print(len(x[1]), [(i.tag,len(i)) for i in x[1]])
    # print(len(x[-1]), [(i.tag,len(i)) for i in x[-1]])
    return x
x=parseXMLTheme_tmTheme(fn)
x=x[0]
# t=etree.tostring(x)
# print(t[:1])
# print(t.decode('utf8'))
