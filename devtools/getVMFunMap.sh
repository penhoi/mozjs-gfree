JITDIR="/home/hack/project/protect-jit/exp/mozjs-45.0.2/js/src/jit"
SCRIPT=tmpscript

echo 'set height 0'  > $SCRIPT
echo '# js::RunScript(JSContext* cx, RunState& state)'  >> $SCRIPT
echo 'break project/protect-jit/exp/mozjs-45.0.2/js/src/jit/BaselineIC.cpp:54' >> $SCRIPT

echo 'command 1' >> $SCRIPT
#eg. static const VMFunction CheckOverRecursedWithExtraInfo =
grep  "static const VMFunction" $JITDIR/*.cpp | awk -F"static const VMFunction" '{print $2}' | 
awk -F"=" '{print "p \""$1"\"\n" "set $jc = cx->runtime()->jitRuntime()->getVMWrapper("$1")\n" "p/x ((JitCode*)$jc)->code_\n" }' >> $SCRIPT
#echo 'quit' >> $SCRIPT
echo 'end' >> $SCRIPT
echo 'set confirm off' >> $SCRIPT
echo 'run' >> $SCRIPT

echo 'function foo() {
    var a = 0x11223344 ^ 0x44332200;
    return a;
}

var sum = 0;
for (var i =0; i< 20000; i++)
    sum += foo();
print(sum);' > del.js


gdb --nx --quiet -x $SCRIPT --args ./js --ion-offthread-compile=off del.js #> vmf_address.txt 2>&1

