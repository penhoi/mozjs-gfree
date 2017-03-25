/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "vm/String.h"
#include "gc/Marking.h"
#include "jsatom.h"
#include "jsgc.h"
#include "jscntxt.h"
#include "jscompartment.h"

#include "jit/ExecutableAllocator.h"
#include "jit/IonCode.h"
#include "jit/JitCompartment.h"
#include "jit/MacroAssembler.h"

#include "tests.h"
#include "jit/MacroAssembler.h"
#include "jit/IonCode.h"
#include "jit/Linker.h"
#include "jit/VMFunctions.h"
#include "jit/x64/SharedICHelpers-x64.h"
#include "jit/MacroAssembler-inl.h"
#include "jit/MoveResolver.h"

static const int LIFO_ALLOC_PRIMARY_CHUNK_SIZE = 4*1024;

using namespace js;
using namespace js::jit;

static js::jit::JitCode*
linkAndAllocate(JSContext* cx, js::jit::MacroAssembler* masm)
{
    AutoFlushICache afc("test");

    Linker l(*masm);
    return l.newCode<CanGC>(cx, ION_CODE);
}

BEGIN_TEST(test_XorRet)
{
    //Please check me carefully with with gdb...
    LifoAlloc lifo(LIFO_ALLOC_PRIMARY_CHUNK_SIZE);
    TempAllocator alloc(&lifo);
    JitContext jc(cx, &alloc);
    rt->getJitRuntime(cx);
    MacroAssembler masm;

    masm.initRetCookie();
    masm.encryptReturnAddress();
    masm.ret();

    JitCode* code = linkAndAllocate(cx, &masm); 
    typedef void (*FunTy)(void);
    FunTy f = (FunTy)(code->raw());

    //May crash!
    f();
    return true;
}
END_TEST(test_XorRet)

BEGIN_TEST(test_XorRet2)
{
    //Please check me carefully with with gdb...
    CommonFrameLayout *frame = new CommonFrameLayout;
    size_t *retPtr = (size_t*)frame;
    uint8_t *addr;

    addr = (uint8_t*)0x11223344;
    frame->setReturnAddress(addr);
    CHECK(*retPtr == 0x0000000011223344);

    //__asm__ __volatile__ ("" ::: "memory");
    frame->encryptReturnAddress();
    CHECK(*retPtr == 0x8000000011223344);

    frame->decryptReturnAddress();
    CHECK(*retPtr == 0x0000000011223344);

    return true;
}
END_TEST(test_XorRet2)



