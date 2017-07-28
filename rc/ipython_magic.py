# mirror this file to profile_name/startup/magic_qeatzy.py
# !ln -s %:p  ~/.ipython/profile_default/startup/
# exec '!cp '.expand('%:p').' $(ipython profile locate)/startup'
# "notation, mirror of notes/.ipython_magic.py  ~/.ipython/profile_default/startup/
from IPython.core.magic import register_line_magic
@register_line_magic
def fj(line):
    get_ipython().run_line_magic('edit', ' -x ' + line)
del fj
@register_line_magic
def jf(line):
    get_ipython().run_line_magic('edit', ' -x ' + line)
del jf

