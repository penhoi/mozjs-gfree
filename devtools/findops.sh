#!/bin/bash

#test case
#[Codegen] # Emitting profiler exit frame tail stub
#[Codegen] xorl       $0x6b8b4567, 0x0(%rsp)
#[Codegen] movabsq    $0x7ffff6938228, %r11
#[Codegen] movq       0x0(%r11), %r11
#[Codegen] movq       0x100(%r11), %r8
#[Codegen] testq      %r8, %r8
#[Codegen] je         .Lfrom36
#[Codegen] cmpq       %r8, %rsp
#OPS="xor mov mov"


LOG=$1
OPSTR=$2

#checking parameters
if (($# != 2)); then {
    echo "Usage: $0 logfile opcodes"
    echo "Eg: $0 spidermonkeylog \"xor push mov\""
    exit
} fi

#the length of opcode sequence is: 2 <$N
OPS=($OPSTR)
N=$(( ${#OPS[@]} ))
if (($N < 2)); then {
    echo "The length of opcode sequence is $N, too short!"
    exit
} fi 

#Generate the command
cmd="grep \"Codegen\" $LOG -n | grep -Ev \"Emitting|\.set|\.balign|\.quad|ud2|wrapper\""
for ((i=0; i<$N; i++)); do
	k=$(($N - 1 - $i))
    cmd="$cmd | grep ${OPS[$i]} -B$i -A$k"
done

#Execute the command
eval $cmd
