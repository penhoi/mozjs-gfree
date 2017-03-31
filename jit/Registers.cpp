/* -*- Mode: C++; tab-width: 8; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 * vim: set ts=8 sts=4 et sw=4 tw=99:
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "jit/Registers.h"
#include "shared/Assembler-shared.h"
#include "MacroAssembler.h"

using namespace js;
using namespace jit;

Register::Encoding
Register::encoding(const AssemblerShared *asmer) const
{
    Register r = *this;
    if (asmer) {
        const MacroAssembler* masm;
        masm = static_cast<const MacroAssembler*>(asmer);
        r = masm->getRandomizedRegister(r);
    }

    MOZ_ASSERT(Code(r.reg_) < Registers::Total);
    return (X86Encoding::RegisterID)r.reg_;
}

const char* 
Register::name(const AssemblerShared *asmer) const
{
    Register r = *this;
    if (asmer) {
        const MacroAssembler* masm;
        masm = static_cast<const MacroAssembler*>(asmer);
        r = masm->getRandomizedRegister(r);
    }
    return Registers::GetName(r.code());
}

