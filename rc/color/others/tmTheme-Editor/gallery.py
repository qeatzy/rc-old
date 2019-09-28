import os, sys
import requests
import json
import lxml
from lxml import html
from lxml import etree
import ipdb; st=ipdb.set_trace

_dir = os.path.expanduser('~/tmp/color/tmTheme-Editor')
fn = os.path.join(_dir, 'app/front/public/gallery.json')
# download from urls to ~/.colors/tmTheme_gallery
_dir_out = os.path.expanduser('~/.colors/tmTheme_gallery')

# info about gallery.json
with open(fn,'r') as f:
    gallery = json.load(f)
# #   x = gallery
# # print(len(x))
# # print(set([len(i) for i in x]))
# # print(set([tuple(i.keys()) for i in x]))
# # print(set([i.get('light') or i.get('Light') for i in x]))
# # print(len([i for i in x if i.get('light') or i.get('Light')]))
# # # print(len([i for i in x if (i.get('light') or i.get('Light')) == True]))
#
#
# # download & write
# # _s = requests.Session()
# # try:
# #     failed
# # except NameError:
# #     failed = []
# # for th in x:
# #     url = th['url']
# #     print(th['name'])
# #     r = _s.get(url)
# #     # assert(r.status_code == 200)
# #     if r.status_code != 200:
# #         failed.append(th)
# #         print('{} failed'.format(th['name']))
# #     fn_out = os.path.join(_dir_out, th['name'].replace(' ','-') + '.tmTheme')
# #     # print(fn_out)
# #     with open(fn_out
# #         ,'wb') as f:
# #         f.write(r.content)

# def parse_tmTheme(fn):
#     d = etree.parse(os.path.join(_dir_out, fn)).getroot()
#     assert(d.tag == 'plist' and len(d) == 1)
#     d = d[0]
#     def parse_dict(d):
#         assert(d.tag == 'dict' and len(d) % 2 == 0)
#         ret = []
#         for i,e in enumerate(d):
#             if i % 2 == 0:
#                 assert(e.tag == 'key')
#                 ret.append(e.text)
#         return tuple(ret)
#     parse_dict(d)
#
# # read & parse
# x = []
# failed = []
# as_failed = []
# for fn in os.listdir(_dir_out):
#     try:
#         x.append(parse_tmTheme(fn))
#     # except Exception as e:
#     except etree.Error as e:
#         # st()
#         failed.append(fn)
#     except AssertionError as e:
#         as_failed.append(fn)
#         # raise
#         # st()
#
# # d_gallery = {i['name']: i['url'] for i in gallery}
# # dl_failed = []
# # _s = requests.Session()
# # name_mismatch = []
# # for name in (i.partition('.')[0] for i in failed):
# #     print(name)
# #     try:
# #         url = d_gallery[name.replace('-',' ')]
# #     except KeyError:
# #         name_mismatch.append(name)
# #     out_fn = os.path.join(_dir_out, name + '.tmTheme')
# #     r = _s.get(url)
# #     if r:
# #         with open(out_fn, 'wb') as f:
# #             f.write(r.content)
# #     else:
# #         dl_failed.append(name)

def parse_tmTheme(fn):
    d = html.parse(fn)
    return d.xpath('//plist')

dl_failed = []
def download(url, dir=_dir_out):
    try:
        download.s
    except AttributeError:
        download.s = requests.Session()
    fn = url.rpartition('/')[-1]
    r = download.s.get(url)
    if r.status_code == 200:
        with open(os.path.join(dir, fn),'wb') as f:
            f.write(r.content)
    else:
        dl_failed.append((fn, r.status_code, url))

# def bot(message, phones=phones, token=token):
import json, time
def ding(message=__file__):
    token = "7ada5f7f4126f07f81aa47ebd55bf2a9fef6f0bc78b7b123ce24e559be0d4696"
    phones = [13270888966]
    url = 'https://oapi.dingtalk.com/robot/send'
    params = { 'access_token': token }
    headers = { 'Content-Type': 'application/json' }
    data = json.dumps({
        "msgtype": "text",
        "text": {
            "content": message + ": " + 
                       time.strftime('%Y/%m/%d %H:%M:%S')
                       },
        "at": {"atMobiles": phones},
    })
    return requests.post(url, headers=headers, params=params, data=data)

for i in gallery:
    download(i['url'])
ding()
