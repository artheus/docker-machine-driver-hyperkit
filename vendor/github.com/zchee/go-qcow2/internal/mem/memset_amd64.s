// Copyright 2016 The go-qcow2 Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// +build !plan9

#include "textflag.h"

// NOTE: Windows externalthreadhandler expects memclr to preserve DX.

// void set(dst []byte, value byte)
TEXT ·set(SB), NOSPLIT, $0-25
	XORQ       AX, AX                  // clear upper bytes
	MOVQ       $0x0101010101010101, R8 // Multiply input by this to spread to all values
	MOVQ       dst+0(FP), DI
	MOVQ       dst_len+8(FP), BX
	MOVB       value+24(FP), AX
	IMULQ      R8, AX
	MOVQ       AX, X0                  // Move to XMM0
	PUNPCKLQDQ X0, X0                  // Unpack to upper bits (copy lower 64 bit to high)

	// MOVOU seems always faster than REP STOSQ.

clr_tail:
	TESTQ BX, BX
	JEQ   clr_0
	CMPQ  BX, $2
	JBE   clr_1or2
	CMPQ  BX, $4
	JBE   clr_3or4
	CMPQ  BX, $8
	JBE   clr_5through8
	CMPQ  BX, $16
	JBE   clr_9through16
	CMPQ  BX, $32
	JBE   clr_17through32
	CMPQ  BX, $64
	JBE   clr_33through64
	CMPQ  BX, $128
	JBE   clr_65through128
	CMPQ  BX, $256
	JBE   clr_129through256

	// TODO: use branch table and BSR to make this just a single dispatch
	// TODO: for really big clears, use MOVNTDQ.

clr_loop:
	MOVOU X0, 0(DI)
	MOVOU X0, 16(DI)
	MOVOU X0, 32(DI)
	MOVOU X0, 48(DI)
	MOVOU X0, 64(DI)
	MOVOU X0, 80(DI)
	MOVOU X0, 96(DI)
	MOVOU X0, 112(DI)
	MOVOU X0, 128(DI)
	MOVOU X0, 144(DI)
	MOVOU X0, 160(DI)
	MOVOU X0, 176(DI)
	MOVOU X0, 192(DI)
	MOVOU X0, 208(DI)
	MOVOU X0, 224(DI)
	MOVOU X0, 240(DI)
	SUBQ  $256, BX
	ADDQ  $256, DI
	CMPQ  BX, $256
	JAE   clr_loop
	JMP   clr_tail

clr_1or2:
	MOVB AX, (DI)
	MOVB AX, -1(DI)(BX*1)
	RET

clr_0:
	RET

clr_3or4:
	MOVW AX, (DI)
	MOVW AX, -2(DI)(BX*1)
	RET

clr_5through8:
	MOVL AX, (DI)
	MOVL AX, -4(DI)(BX*1)
	RET

clr_9through16:
	MOVQ AX, (DI)
	MOVQ AX, -8(DI)(BX*1)
	RET

clr_17through32:
	MOVOU X0, (DI)
	MOVOU X0, -16(DI)(BX*1)
	RET

clr_33through64:
	MOVOU X0, (DI)
	MOVOU X0, 16(DI)
	MOVOU X0, -32(DI)(BX*1)
	MOVOU X0, -16(DI)(BX*1)
	RET

clr_65through128:
	MOVOU X0, (DI)
	MOVOU X0, 16(DI)
	MOVOU X0, 32(DI)
	MOVOU X0, 48(DI)
	MOVOU X0, -64(DI)(BX*1)
	MOVOU X0, -48(DI)(BX*1)
	MOVOU X0, -32(DI)(BX*1)
	MOVOU X0, -16(DI)(BX*1)
	RET

clr_129through256:
	MOVOU X0, (DI)
	MOVOU X0, 16(DI)
	MOVOU X0, 32(DI)
	MOVOU X0, 48(DI)
	MOVOU X0, 64(DI)
	MOVOU X0, 80(DI)
	MOVOU X0, 96(DI)
	MOVOU X0, 112(DI)
	MOVOU X0, -128(DI)(BX*1)
	MOVOU X0, -112(DI)(BX*1)
	MOVOU X0, -96(DI)(BX*1)
	MOVOU X0, -80(DI)(BX*1)
	MOVOU X0, -64(DI)(BX*1)
	MOVOU X0, -48(DI)(BX*1)
	MOVOU X0, -32(DI)(BX*1)
	MOVOU X0, -16(DI)(BX*1)
	RET
