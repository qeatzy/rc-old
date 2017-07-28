# import lxml
import os, sys
import re
def log(*args, **kwargs):
    # print(":{}".format(sys._getframe().f_back.f_code.co_name), *args, **kwargs)
    print("{}:{}".format(__name__, sys._getframe().f_back.f_code.co_name), *args, **kwargs)
    # print("{}:{}".format(__file__, sys._getframe().f_back.f_code.co_name), *args, **kwargs)
from lxml import html
from lxml import etree
from urllib.parse import urlparse  # python 3
def _add_parent_to_path(fn, level=1, abs=True):
    """ level=1 to add current directory, level=0 to add fn itself, """
    import os, sys
    if abs:
        fn = os.path.abspath(fn)
    while level > 0:
        fn = os.path.dirname(fn)
        level -= 1
    sys.path.append(fn)
_add_parent_to_path(__file__,3)
from data import fetch_url, set_theme, parse_mintty_theme
warning=print

def url_base(url):
    return '{uri.scheme}://{uri.netloc}'.format(uri=urlparse(url))

url_meta = 'https://github.com/iamthad/base16-mintty/tree/master/mintty'
url_meta_base = url_base(url_meta)

text = fetch_url(url_meta)
d=html.fromstring(text)
x=d.xpath("//*[contains(@title,'minttyrc') and contains(@href,'minttyrc')]")
print(len(x), set(i.tag for i in x))
fns = [url_meta_base + i.get('href') for i in x]

def url_github_raw(loc):
    x = loc.split('/')
    assert(x[3] == 'raw')
    # print('https://raw.githubusercontent.com' + '/'.join(x[:3]+ x[4:]))
    return 'https://raw.githubusercontent.com' + '/'.join(x[:3]+ x[4:])
    # return '/'.join(x[:3]+ x[4:])
# groud='/iamthad/base16-mintty/master/mintty/base16-zenburn.minttyrc'
# example='/iamthad/base16-mintty/raw/master/mintty/base16-zenburn.minttyrc'
# x=url_github_raw(example)

# text = fetch_url(fns[0], url_raw_base='https://raw.githubusercontent.com')
def fetch_url_raw(url, url_raw_base='https://raw.githubusercontent.com'):
    # print(url)
    text = fetch_url(url)
    d=html.fromstring(text)
    x=d.xpath('//*[@id="raw-url"]')
    # print(x)
    if len(x) == 0:
        warning('no [@id="raw-url"] tag found. \nurl={}'.format(url))
    elif len(x) > 1:
        raise ValueError('expected 1 [@id="raw-url"] tag, {} found'.format(len(x)))
    else:
        h=x[0].get('href')
        # print(h)
        url_raw = url_github_raw(h)
        text = fetch_url(url_raw)
    return url_raw
    return text
# x=fetch_url_raw(fns[-1])
# xs=[fetch_url_raw(url) for url in fns]
# print(x)
# text=x

# href = '/iamthad/base16-mintty/raw/master/mintty/base16-3024-256.minttyrc' # from link a[@id='raw-url']
def url_github_raw(url_or_net_loc):
    uri = urlparse(url_or_net_loc)
    x = uri.path.split('/')
    assert(uri.path.startswith('/') and uri.netloc in ('','github.com') and x[3] in ('raw', 'blob'))
    return 'https://raw.githubusercontent.com' + '/'.join(x[:3]+ x[4:])

url_meta = 'https://github.com/iamthad/base16-mintty/tree/master/mintty'
def get_file_list(url_meta):
    text = fetch_url(url_meta)
    d = html.fromstring(text)
    x=d.xpath("//*[contains(@title,'minttyrc') and contains(@href,'minttyrc')]")
    log(len(x), set(i.tag for i in x))
    fns = [url_meta_base + i.get('href') for i in x]
    return fns
# x = get_file_list(url_meta)
def get_name_from_url(url):
    m = re.search(r'.*/([-_a-zA-Z0-9]+).minttyrc', url)
    return m[1]

# prefix = 33
class ThemeList(object):
    prefix = os.path.expanduser('~/.colors/{}persist'.format('tmux' if os.environ.get('TMUX') else ''))
# os.makedirs(path, exist_ok=True)    # 3.2
    os.makedirs(prefix, exist_ok=True)
    to_ansi = set_theme # TODO assign function to class attribute, make it a bound method?
    def __init__(self, start, f_fn_transfer=None, f_get_name=None, f_reader=None,
            f_parser=None):
        try:
            arg, get_file_list = start
        except ValueError:
            raise NotImplementedError('')
        fns = get_file_list(arg)
        if f_fn_transfer is not None:
            fns_final = [f_fn_transfer(fn) for fn in fns]
        else:
            fns_final = fns
        self.fns = fns
        self.fns_final = fns_final
        if f_get_name:
            self.names = [f_get_name(fn) for fn in fns]
        if f_reader:
            # x = self.fns_final
            self.themes = [f_reader(fn) for fn in self.fns_final]
        if f_parser:
            self.themes = [f_parser(th) for th in self.themes]
        # self.to_ansi = self.to_ansi
        self.to_ansi = set_theme
    def save(self, f, arg='name', overrite=False):
        assert(arg in ('name', 'url'))
        def do_save(path, theme):
            if not path.startswith('/'):
                path = os.path.join(self.prefix, path)
            if not overrite and os.path.exists(path):
                return
            with open(path,'w') as f:
                f.write(self.to_ansi(theme))
        for arg, theme in zip((self.names if arg == 'name' else self.fns), self.themes):
            path = f(arg)
            do_save(path, theme)

base16_mintty = ThemeList((url_meta, get_file_list), f_fn_transfer=url_github_raw, f_get_name=get_name_from_url,
        f_reader=fetch_url, f_parser=parse_mintty_theme)
x=base16_mintty
x.save(lambda x:x)

# import data
# from data import parse_mintty_theme
# ts = [parse_mintty_theme(text) for text in xs]
# f=lambda th: print(data.set_theme(th))
