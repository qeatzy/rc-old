#!/usr/bin/bash
echo "${BASH_SOURCE[0]}" '$0'"=[$0]"
case $0 in */*) t0="$0";; *) t0="./$0";; esac
t2="${t0%/*}"
echo "current script is $t0"
echo "copy used config files"
mkdir -p ~/.ssh && cp "$t2/authorized_keys" ~/.ssh  &&
    cp "$t2/shadowsocks.json" /etc
# /root/xd/setup_vps.sh
# /root/xd/authorized_keys
# /root/xd/shadowsocks.json

apt-get update
yes | apt-get install g++ tmux zsh wget curl git
yes | apt-get install python3-pip python-pip silversearcher-ag
git clone https://github.com/qeatzy/rc ~/rc
bash ~/rc/rc/install/rc_setup.sh
# make below file in place
# /root/.ssh/authorized_keys
# /etc/shadowsocks.json
python -m pip install shadowsocks

fix_shadowsocks() {
# "/lib/x86_64-linux-gnu/libcrypto.so.1.1: undefined symbol: EVP_CIPHER_CTX_cleanup"解决方案
# https://www.iteye.com/blog/haohetao-2423078
# https://floperry.github.io/2019/02/24/2018-06-25-Ubuntu-18.04-%E4%B8%8B%E8%A7%A3%E5%86%B3-shadowsocks-%E6%9C%8D%E5%8A%A1%E6%8A%A5%E9%94%99%E9%97%AE%E9%A2%98/
# https://blog.csdn.net/alex_bean/article/details/86500662
tmp=$(yes n |python -m pip uninstall shadowsocks)
t1="${tmp%shadowsocks/*}"
t2="${t1##* }"
# EVP_CIPHER_CTX_cleanup -> EVP_CIPHER_CTX_reset
from="EVP_CIPHER_CTX_cleanup"
to="EVP_CIPHER_CTX_reset"
# cd "${t2}shadowsocks" && ag -l EVP_CIPHER_CTX_reset
files=$(ag -l "$from" "${t2}shadowsocks"); exit_code=$?
# bug: $files empty, 
echo "$files" "$exit_code"
if [ $exit_code -eq 0 ]; then
    pwd
    echo "sed -i 's/$from/$to/' $files"
    # sed -i "s/$from/$to/" "$files"
    sed -i "s/$from/$to/" "${t2}shadowsocks/crypto/openssl.py"
fi
}

# ssserver -c /etc/shadowsocks.json -d start
output=$(ssserver -c /etc/shadowsocks.json -d start 2>&1); exit_code=$?
sleep 1
# echo "\$? = $?"
set -x
if [ $exit_code -gt 0 ]; then
    case $output in
        *AttributeError*EVP_CIPHER_CTX_cleanup*)
            echo shadowsocks start fail
            fix_shadowsocks
            ssserver -c /etc/shadowsocks.json -d start
            # ;;*)
            # echo not found
            ;;*)
            echo shadowsocks start succeeded;;
    esac
fi
echo Done.
