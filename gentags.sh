ls *.cpp    > files1
ls *.h      >> files1

function find_cpph ()
{
    find $1 -name "*.cpp"   >> files1
    find $1 -name "*.h"     >> files1
}

alldirs="jit shell vm"
for dir in $alldirs; do {
    find_cpph $dir
}; done

grep -Ev "arm|mips" files1 > files2
ctags -L files2
rm -rf files1 files2
