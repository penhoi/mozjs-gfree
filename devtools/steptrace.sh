#!/bin/bash
JSDIR="/home/hack/project/protect-jit/exp/mozjs-45.0.2/js/src/debug-build/dist/bin/js"
JSSCRIPT=$1
GDBSCRIPT="tmpscript"

function gather_skpped_funcs()
{
    #Get function names.
echo '
b main
run
info functions
set confirm off
quit
' > $GDBSCRIPT

    INFO="infofun.txt"
    #gdb --nx -x $GDBSCRIPT --args $JSDIR > $INFO 2>&1


    #Extract all of the functions
    LS=(`wc -l $INFO`)
    N=$((${LS[0]} - 35))
    tail -n $N $INFO | grep -E "\);$" | sed -e '/2/{N; s=,\n=,=}' | sed -e "s/^const //; s/^static //;" | sed -e "s/^const //; s/^static //; s/^unsigned //;" | awk '{first = $1; $1 = ""; print $0; }' | sed -e "s/^ //; s/^*//; s/^&//;" | sed -e "s/^*//; s/^&//; s/;$//;" > delme2
 

    #awk -F'(' '{print $1}' funcs.lst | awk -F' ' '{print $NF"("}' > fname 
    #awk -F'(' '{print $2}' funcs.lst | awk -F";" '{print $1}' > param
    #paste -d" " fname param > funcs

    #Gather functions that should be skipped.
    grep -v "js::jit::" delme2 | awk -F" " '{if (0 == index($1, ">") and 1<$NF) print $0}' > skipedfuncs
    rm delme*
}

function generate_trace_script()
{
gather_skpped_funcs

echo "" > $GDBSCRIPT

echo '
#jit::EnterBaselineAtBranch(JSContext* cx, InterpreterFrame* fp, jsbytecode* pc), start-end
break project/protect-jit/exp/mozjs-45.0.2/js/src/jit/BaselineJIT.cpp:195 
#break project/protect-jit/exp/mozjs-45.0.2/js/src/jit/BaselineJIT.cpp:264

#jit::EnterBaselineMethod(JSContext* cx, RunState& state), start-end
#break project/protect-jit/exp/mozjs-45.0.2/js/src/jit/BaselineJIT.cpp:175 
#break project/protect-jit/exp/mozjs-45.0.2/js/src/jit/BaselineJIT.cpp:192

#EnterIon(JSContext* cx, EnterJitData& data), start-end
#break project/protect-jit/exp/mozjs-45.0.2/js/src/jit/Ion.cpp:2683
#break project/protect-jit/exp/mozjs-45.0.2/js/src/jit/Ion.cpp:2729

#jit::FastInvoke(JSContext* cx, HandleFunction fun, CallArgs& args), start-end
#break project/protect-jit/exp/mozjs-45.0.2/js/src/jit/Ion.cpp:2824 
#break project/protect-jit/exp/mozjs-45.0.2/js/src/jit/Ion.cpp:2863


def dosteplog
    set $i=0
    while ($i < 2000000)
        step 1
        set $i = $i+1
    end
end

command 1
	dosteplog
end
' >> $GDBSCRIPT

awk '{print "skip " $0}' skipedfuncs >> $GDBSCRIPT

echo '
run
' >> $GDBSCRIPT
}

generate_trace_script
#run gdb for tracing
gdb --nx -x $GDBSCRIPT  --args ./js --ion-offthread-compile=off $JSSCRIPT


