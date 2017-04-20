//
//  Operators.swift
//  Z80
//
//  Created by Harsh Mistry on 2017-04-17.
//  Copyright © 2017 Harsh Mistry  Inc. All rights reserved.
//

import Foundation

// Generated INC/DEC functions for 8bit registers

func incA() {
	z80.A += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.A == 0x80, FLAG_V, 0)) | (ternOpB((z80.A&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.A]
}

func decA() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.A&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.A -= 1
	z80.F |= (ternOpB(z80.A == 0x7f, FLAG_V, 0)) | sz53Table[z80.A]
}

func incB() {
	z80.B += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.B == 0x80, FLAG_V, 0)) | (ternOpB((z80.B&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.B]
}

func decB() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.B&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.B -= 1
	z80.F |= (ternOpB(z80.B == 0x7f, FLAG_V, 0)) | sz53Table[z80.B]
}

func incC() {
	z80.C += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.C == 0x80, FLAG_V, 0)) | (ternOpB((z80.C&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.C]
}

func decC() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.C&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.C -= 1
	z80.F |= (ternOpB(z80.C == 0x7f, FLAG_V, 0)) | sz53Table[z80.C]
}

func incD() {
	z80.D += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.D == 0x80, FLAG_V, 0)) | (ternOpB((z80.D&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.D]
}

func decD() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.D&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.D -= 1
	z80.F |= (ternOpB(z80.D == 0x7f, FLAG_V, 0)) | sz53Table[z80.D]
}

func incE() {
	z80.E += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.E == 0x80, FLAG_V, 0)) | (ternOpB((z80.E&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.E]
}

func decE() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.E&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.E -= 1
	z80.F |= (ternOpB(z80.E == 0x7f, FLAG_V, 0)) | sz53Table[z80.E]
}

func incF() {
	z80.F += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.F == 0x80, FLAG_V, 0)) | (ternOpB((z80.F&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.F]
}

func decF() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.F&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.F -= 1
	z80.F |= (ternOpB(z80.F == 0x7f, FLAG_V, 0)) | sz53Table[z80.F]
}

func incH() {
	z80.H += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.H == 0x80, FLAG_V, 0)) | (ternOpB((z80.H&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.H]
}

func decH() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.H&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.H -= 1
	z80.F |= (ternOpB(z80.H == 0x7f, FLAG_V, 0)) | sz53Table[z80.H]
}

func incI() {
	z80.I += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.I == 0x80, FLAG_V, 0)) | (ternOpB((z80.I&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.I]
}

func decI() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.I&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.I -= 1
	z80.F |= (ternOpB(z80.I == 0x7f, FLAG_V, 0)) | sz53Table[z80.I]
}

func incL() {
	z80.L += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.L == 0x80, FLAG_V, 0)) | (ternOpB((z80.L&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.L]
}

func decL() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.L&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.L -= 1
	z80.F |= (ternOpB(z80.L == 0x7f, FLAG_V, 0)) | sz53Table[z80.L]
}

func incR7() {
	z80.R7 += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.R7 == 0x80, FLAG_V, 0)) | (ternOpB((z80.R7&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.R7]
}

func decR7() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.R7&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.R7 -= 1
	z80.F |= (ternOpB(z80.R7 == 0x7f, FLAG_V, 0)) | sz53Table[z80.R7]
}

func incA_() {
	z80.A_ += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.A_ == 0x80, FLAG_V, 0)) | (ternOpB((z80.A_&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.A_]
}

func decA_() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.A_&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.A_ -= 1
	z80.F |= (ternOpB(z80.A_ == 0x7f, FLAG_V, 0)) | sz53Table[z80.A_]
}

func incB_() {
	z80.B_ += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.B_ == 0x80, FLAG_V, 0)) | (ternOpB((z80.B_&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.B_]
}

func decB_() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.B_&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.B_ -= 1
	z80.F |= (ternOpB(z80.B_ == 0x7f, FLAG_V, 0)) | sz53Table[z80.B_]
}

func incC_() {
	z80.C_ += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.C_ == 0x80, FLAG_V, 0)) | (ternOpB((z80.C_&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.C_]
}

func decC_() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.C_&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.C_ -= 1
	z80.F |= (ternOpB(z80.C_ == 0x7f, FLAG_V, 0)) | sz53Table[z80.C_]
}

func incD_() {
	z80.D_ += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.D_ == 0x80, FLAG_V, 0)) | (ternOpB((z80.D_&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.D_]
}

func decD_() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.D_&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.D_ -= 1
	z80.F |= (ternOpB(z80.D_ == 0x7f, FLAG_V, 0)) | sz53Table[z80.D_]
}

func incE_() {
	z80.E_ += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.E_ == 0x80, FLAG_V, 0)) | (ternOpB((z80.E_&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.E_]
}

func decE_() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.E_&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.E_ -= 1
	z80.F |= (ternOpB(z80.E_ == 0x7f, FLAG_V, 0)) | sz53Table[z80.E_]
}

func incF_() {
	z80.F_ += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.F_ == 0x80, FLAG_V, 0)) | (ternOpB((z80.F_&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.F_]
}

func decF_() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.F_&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.F_ -= 1
	z80.F |= (ternOpB(z80.F_ == 0x7f, FLAG_V, 0)) | sz53Table[z80.F_]
}

func incH_() {
	z80.H_ += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.H_ == 0x80, FLAG_V, 0)) | (ternOpB((z80.H_&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.H_]
}

func decH_() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.H_&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.H_ -= 1
	z80.F |= (ternOpB(z80.H_ == 0x7f, FLAG_V, 0)) | sz53Table[z80.H_]
}

func incL_() {
	z80.L_ += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.L_ == 0x80, FLAG_V, 0)) | (ternOpB((z80.L_&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.L_]
}

func decL_() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.L_&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.L_ -= 1
	z80.F |= (ternOpB(z80.L_ == 0x7f, FLAG_V, 0)) | sz53Table[z80.L_]
}

func incIXL() {
	z80.IXL += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.IXL == 0x80, FLAG_V, 0)) | (ternOpB((z80.IXL&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.IXL]
}

func decIXL() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.IXL&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.IXL -= 1
	z80.F |= (ternOpB(z80.IXL == 0x7f, FLAG_V, 0)) | sz53Table[z80.IXL]
}

func incIXH() {
	z80.IXH += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.IXH == 0x80, FLAG_V, 0)) | (ternOpB((z80.IXH&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.IXH]
}

func decIXH() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.IXH&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.IXH -= 1
	z80.F |= (ternOpB(z80.IXH == 0x7f, FLAG_V, 0)) | sz53Table[z80.IXH]
}

func incIYL() {
	z80.IYL += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.IYL == 0x80, FLAG_V, 0)) | (ternOpB((z80.IYL&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.IYL]
}

func decIYL() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.IYL&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.IYL -= 1
	z80.F |= (ternOpB(z80.IYL == 0x7f, FLAG_V, 0)) | sz53Table[z80.IYL]
}

func incIYH() {
	z80.IYH += 1
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.IYH == 0x80, FLAG_V, 0)) | (ternOpB((z80.IYH&0x0f) != 0, 0, FLAG_H)) | sz53Table[z80.IYH]
}

func decIYH() {
	z80.F = (z80.F & FLAG_C) | (ternOpB(z80.IYH&0x0f != 0, 0, FLAG_H)) | FLAG_N
	z80.IYH -= 1
	z80.F |= (ternOpB(z80.IYH == 0x7f, FLAG_V, 0)) | sz53Table[z80.IYH]
}

// Generated getters/setters and INC/DEC functions for 16bit registers

func BC() -> UInt16 {
	return z80.bc.get()
}

func SetBC(value : UInt16) {
	z80.bc.set(value)
}

func DecBC() {
	z80.bc.dec()
}

func IncBC() {
	z80.bc.inc()
}

func DE() -> UInt16 {
	return z80.de.get()
}

func SetDE(value : UInt16) {
	z80.de.set(value)
}

func DecDE() {
	z80.de.dec()
}

func IncDE() {
	z80.de.inc()
}

func HL() -> UInt16 {
	return z80.hl.get()
}

func SetHL(value : UInt16) {
	z80.hl.set(value)
}

func DecHL() {
	z80.hl.dec()
}

func IncHL() {
	z80.hl.inc()
}

func BC_() -> UInt16 {
	return z80.bc_.get()
}

func SetBC_(value : UInt16) {
	z80.bc_.set(value)
}

func DecBC_() {
	z80.bc_.dec()
}

func IncBC_() {
	z80.bc_.inc()
}

func DE_() -> UInt16 {
	return z80.de_.get()
}

func SetDE_(value : UInt16) {
	z80.de_.set(value)
}

func DecDE_() {
	z80.de_.dec()
}

func IncDE_() {
	z80.de_.inc()
}

func HL_() -> UInt16 {
	return z80.hl_.get()
}

func SetHL_(value : UInt16) {
	z80.hl_.set(value)
}

func DecHL_() {
	z80.hl_.dec()
}

func IncHL_() {
	z80.hl_.inc()
}

func IX() -> UInt16 {
	return z80.ix.get()
}

func SetIX(value : UInt16) {
	z80.ix.set(value)
}

func DecIX() {
	z80.ix.dec()
}

func IncIX() {
	z80.ix.inc()
}

func Ioperators() -> UInt16 {
	return z80.iy.get()
}

func SetIY(value : UInt16) {
	z80.iy.set(value)
}

func DecIY() {
	z80.iy.dec()
}

func IncIY() {
	z80.iy.inc()
}
