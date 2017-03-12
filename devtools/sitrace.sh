JSSCRIPT=$1
GDBSCRIPT=tmpscript

echo "" > $GDBSCRIPT
echo '
#jit::EnterBaselineAtBranch(JSContext* cx, InterpreterFrame* fp, jsbytecode* pc), start-end
break project/protect-jit/exp/mozjs-45.0.2/js/src/jit/BaselineJIT.cpp:195 

def startlog
    set $i = 1
    display/2i $pc
    while ($i < 20000000)
        si 2
        set $i = $i+1
    end      
end

command 1
    startlog
end

run
' >> $GDBSCRIPT

#echo "break project/protect-jit/exp/mozjs-45.0.2/js/src/jit/BaselineIC.cpp:54" > $GDBSCRIPT
#echo "run"  >> $GDBSCRIPT

#osr iter 120 times
gdb --nx -x $GDBSCRIPT  --args ./js --ion-warmup-threshold=12 --ion-offthread-compile=on $JSSCRIPT
