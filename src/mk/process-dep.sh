#!/bin/sh

mk_dir=`dirname $0`
mk_obj_dir=$1
shift

c_file=`dirname $0`/process-dep.c
exe_file=$mk_obj_dir/process-dep

if [ ! -x $exe_file -o $exe_file -ot $c_file ]; then
    mkdir -p $mk_obj_dir
    gcc -Wall -O3 $c_file -o $exe_file
fi

exec $exe_file "$@"
