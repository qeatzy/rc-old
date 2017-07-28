
" .+s/ /\hi /g
let commands =<< trim END
hi pythonAsync
hi pythonAttribute
hi pythonBuiltin
hi pythonComment
hi pythonConditional
hi pythonDecorator
hi pythonDecoratorName
hi pythonDoctest
hi pythonDoctestValue
hi pythonEscape
hi pythonException
hi pythonExceptions
hi pythonFunction
hi pythonInclude
hi pythonMatrixMultiply
hi pythonNumber
hi pythonOperator
hi pythonQuotes
hi pythonRawString
hi pythonRepeat
hi pythonSpaceError
hi pythonStatement
hi pythonString
hi pythonSync
hi pythonTodo
hi pythonTripleQuotes
END
" let res = execute(commands)
" echo type(res)
" put=res
py import vim, re
" py import pdb; st=pdb.set_trace
py <<EOF
# print(res)
cmd = vim.eval('commands')
def f():
    d = {}
    global cmd
    while cmd:
        vim.command("let yv = pyeval('cmd')")
        # st()
        # vim.command('echo yv')
        # return
        xin = vim.eval("execute(yv)")
        # print(xin)
        # print("+"*55)
        lines = xin.strip().splitlines()
        # print(cmd)
        for l in lines:
            m = re.search('^(\w+)\s+xxx\s+(links to)?\s*(.*)',l)
            if m is None: raise ValueError("not hi output")
            k,v = m.group(1), m.group(2)
            if k in d:
                print(sorted(d.keys()))
                print("-"*55)
                print(l)
                print(lines)
                print("+"*55)
                return d
            assert(k not in d)
            d[k] = (False, m.group(3)) if v is None else (True, m.group(3))
        cmd = ['hi {}'.format(i) for i in 
            set(v[1] for k,v in d.items() if (v[0] and (v[1] not in d)))]
        e = [v[1] for k,v in d.items() if (v[0] and (v[1] not in d))]
        # print(any([i in d for i in e]))
        # print(cmd)
        # print('pythonQuotes' in d)
        # print("="*55)
        # break
    return d
# x = f(vim.eval('commands'))
x = f()
# print('\n'.join('{} {}'.format(k,v[1]) for k,v in x.items() if not v[0]))
print('\n'.join('{} {}'.format(k,v[1]) for k,v in x.items()))
res = '\n'.join('{} {}'.format(k,v[1]) for k,v in x.items())
EOF
put=pyeval('res')
