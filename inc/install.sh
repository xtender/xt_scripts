#!/bin/sh

#functions:
f_br(){
    echo "---------------------------------------------"
}

f_init(){
    current_dir=`pwd`
    default_dir="$current_dir/xt_scripts"
    read -p "Please enter the path to install[$default_dir]: " -e install_path
    install_path=${install_path:-$default_dir}
    echo "Installing into $install_path"
}

f_fetch(){
    # fetch scripts:
    if  hash fgit 2>/dev/null; then
        #git clone https://github.com/xtender/xt_scripts.git $install_path
        echo "git exists"
    elif hash wget unzip 2>/dev/null; then
        echo "wget and unzip found."
        wget http://src.orasql.org/arc/xt_scripts.tar.gz -P $install_path
        #unzip $install_path/xt_scripts.tar.gz $install_path
        tar -xvf -C $install_path xt_scripts.tar.gz
    else
        echo "ERROR: You need to install git or wget+unzip!"
        exit 1;
    fi
}

#
echo "--------------------------------------------"
echo "***    Welcome to xt_scripts install!    ***"
echo "--------------------------------------------"

f_init
f_fetch
#cat ${ORACLE_HOME}/sqlplus/admin/glogin.sql
#cd xt_scripts && sqlplus /nolog
