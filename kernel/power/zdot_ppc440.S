/*********************************************************************/
/* Copyright 2009, 2010 The University of Texas at Austin.           */
/* All rights reserved.                                              */
/*                                                                   */
/* Redistribution and use in source and binary forms, with or        */
/* without modification, are permitted provided that the following   */
/* conditions are met:                                               */
/*                                                                   */
/*   1. Redistributions of source code must retain the above         */
/*      copyright notice, this list of conditions and the following  */
/*      disclaimer.                                                  */
/*                                                                   */
/*   2. Redistributions in binary form must reproduce the above      */
/*      copyright notice, this list of conditions and the following  */
/*      disclaimer in the documentation and/or other materials       */
/*      provided with the distribution.                              */
/*                                                                   */
/*    THIS  SOFTWARE IS PROVIDED  BY THE  UNIVERSITY OF  TEXAS AT    */
/*    AUSTIN  ``AS IS''  AND ANY  EXPRESS OR  IMPLIED WARRANTIES,    */
/*    INCLUDING, BUT  NOT LIMITED  TO, THE IMPLIED  WARRANTIES OF    */
/*    MERCHANTABILITY  AND FITNESS FOR  A PARTICULAR  PURPOSE ARE    */
/*    DISCLAIMED.  IN  NO EVENT SHALL THE UNIVERSITY  OF TEXAS AT    */
/*    AUSTIN OR CONTRIBUTORS BE  LIABLE FOR ANY DIRECT, INDIRECT,    */
/*    INCIDENTAL,  SPECIAL, EXEMPLARY,  OR  CONSEQUENTIAL DAMAGES    */
/*    (INCLUDING, BUT  NOT LIMITED TO,  PROCUREMENT OF SUBSTITUTE    */
/*    GOODS  OR  SERVICES; LOSS  OF  USE,  DATA,  OR PROFITS;  OR    */
/*    BUSINESS INTERRUPTION) HOWEVER CAUSED  AND ON ANY THEORY OF    */
/*    LIABILITY, WHETHER  IN CONTRACT, STRICT  LIABILITY, OR TORT    */
/*    (INCLUDING NEGLIGENCE OR OTHERWISE)  ARISING IN ANY WAY OUT    */
/*    OF  THE  USE OF  THIS  SOFTWARE,  EVEN  IF ADVISED  OF  THE    */
/*    POSSIBILITY OF SUCH DAMAGE.                                    */
/*                                                                   */
/* The views and conclusions contained in the software and           */
/* documentation are those of the authors and should not be          */
/* interpreted as representing official policies, either expressed   */
/* or implied, of The University of Texas at Austin.                 */
/*********************************************************************/

#define ASSEMBLER
#include "common.h"
	
#if defined(F_INTERFACE) && defined(F_INTERFACE_F2C)
#define RESULT	r3
#define N	r4
#define X	r5
#define INCX	r6	
#define Y	r7
#define INCY	r8
#define PRE	r9
#else
#define N	r3
#define X	r4
#define INCX	r5	
#define Y	r6
#define INCY	r7
#define PRE	r8
#endif

#define INCXM1	r10
#define INCYM1	r11

#define FZERO	f0

#define STACKSIZE 160

	PROLOGUE
	PROFCODE

	addi	SP, SP, -STACKSIZE
	li	r0,   0

	stw	r0,   144(SP)
	stfd	f14,    0(SP)
	stfd	f15,    8(SP)
	stfd	f16,   16(SP)
	stfd	f17,   24(SP)

	stfd	f18,   32(SP)
	stfd	f19,   40(SP)
	stfd	f20,   48(SP)
	stfd	f21,   56(SP)

	stfd	f22,   64(SP)
	stfd	f23,   72(SP)
	stfd	f24,   80(SP)
	stfd	f25,   88(SP)

	stfd	f26,   96(SP)
	stfd	f27,  104(SP)
	stfd	f28,  112(SP)
	stfd	f29,  120(SP)

	stfd	f30,  128(SP)
	stfd	f31,  136(SP)

	lfs	FZERO,144(SP)

#ifdef F_INTERFACE
	LDINT	N,    0(N)
	LDINT	INCX, 0(INCX)
	LDINT	INCY, 0(INCY)
#endif

	slwi	INCX, INCX, ZBASE_SHIFT
	slwi	INCY, INCY, ZBASE_SHIFT

	subi	INCXM1, INCX, SIZE
	subi	INCYM1, INCY, SIZE

	fmr	f1,  FZERO
	fmr	f2,  FZERO
	fmr	f3,  FZERO
	fmr	f4,  FZERO
	fmr	f5,  FZERO
	fmr	f6,  FZERO
	fmr	f7,  FZERO

	fmr	f24,  FZERO
	fmr	f25,  FZERO
	fmr	f26,  FZERO
	fmr	f27,  FZERO
	fmr	f28,  FZERO
	fmr	f29,  FZERO
	fmr	f30,  FZERO
	fmr	f31,  FZERO

	li	PRE, 3 * 16 * SIZE

	cmpwi	cr0, N, 0
	ble-	LL(999)

#ifdef F_INTERFACE
	cmpwi	cr0, INCX, 0
	bge+	LL(102)

	subi	r0, N, 1
	mullw	r0, r0, INCX
	sub	X, X, r0
	.align 4

LL(102):
	cmpwi	cr0, INCY, 0
	bge+	LL(104)

	subi	r0, N, 1
	mullw	r0, r0, INCY
	sub	Y, Y, r0
	.align 4

LL(104):
#endif
	sub	X, X, INCXM1
	sub	Y, Y, INCYM1

	srawi.	r0, N, 3
	mtspr	CTR,  r0
	beq-	LL(150)

	LFDX	f8,   X, INCXM1
	LFDX	f16,  Y, INCYM1
	LFDUX	f9,   X, INCX
	LFDUX	f17,  Y, INCY

	LFDX	f10,  X, INCXM1
	LFDX	f18,  Y, INCYM1
	LFDUX	f11,  X, INCX
	LFDUX	f19,  Y, INCY

	LFDX	f12,   X, INCXM1
	LFDX	f20,   Y, INCYM1
	LFDUX	f13,   X, INCX
	LFDUX	f21,   Y, INCY

	LFDX	f14,   X, INCXM1
	LFDUX	f15,   X, INCX
	bdz	LL(120)
	.align 4

LL(110):
	FMADD	f0, f8,  f16,  f0
	LFDX	f22,   Y, INCYM1
#ifdef PPCG4
	dcbt	X, PRE
#endif
	FMADD	f3, f8,  f17,  f3
	LFDX	f8,   X, INCXM1
	FMADD	f1, f9,  f17,  f1
	LFDUX	f23,   Y, INCY
	FMADD	f2, f9,  f16,  f2
	LFDUX	f9,   X, INCX

	FMADD	f4, f10, f18,  f4
	LFDX	f16,  Y, INCYM1
#ifdef PPCG4
	dcbt	Y, PRE
#endif
	FMADD	f7, f10, f19,  f7
	LFDX	f10,  X, INCXM1
	FMADD	f5, f11, f19,  f5
	LFDUX	f17,  Y, INCY
	FMADD	f6, f11, f18,  f6
	LFDUX	f11,  X, INCX

	FMADD	f24, f12, f20,  f24
	LFDX	f18,  Y, INCYM1
#if defined(PPCG4) && defined(DOUBLE)
	dcbt	X, PRE
#endif
	FMADD	f27, f12, f21,  f27
	LFDX	f12,   X, INCXM1
	FMADD	f25, f13, f21,  f25
	LFDUX	f19,  Y, INCY
	FMADD	f26, f13, f20,  f26
	LFDUX	f13,   X, INCX

	FMADD	f28, f14, f22,  f28
	LFDX	f20,   Y, INCYM1
#if defined(PPCG4) && defined(DOUBLE)
	dcbt	Y, PRE
#endif
	FMADD	f31, f14, f23,  f31
	LFDX	f14,   X, INCXM1
	FMADD	f29, f15, f23,  f29
	LFDUX	f21,   Y, INCY
	FMADD	f30, f15, f22,  f30
	LFDUX	f15,   X, INCX

	FMADD	f0, f8,  f16,  f0
	LFDX	f22,   Y, INCYM1
#ifdef PPCG4
	dcbt	X, PRE
#endif
	FMADD	f3, f8,  f17,  f3
	LFDX	f8,   X, INCXM1
	FMADD	f1, f9,  f17,  f1
	LFDUX	f23,   Y, INCY
	FMADD	f2, f9,  f16,  f2
	LFDUX	f9,   X, INCX

	FMADD	f4, f10, f18,  f4
	LFDX	f16,  Y, INCYM1
#ifdef PPCG4
	dcbt	Y, PRE
#endif
	FMADD	f7, f10, f19,  f7
	LFDX	f10,  X, INCXM1
	FMADD	f5, f11, f19,  f5
	LFDUX	f17,  Y, INCY
	FMADD	f6, f11, f18,  f6
	LFDUX	f11,  X, INCX

	FMADD	f24, f12, f20,  f24
	LFDX	f18,  Y, INCYM1
#if defined(PPCG4) && defined(DOUBLE)
	dcbt	X, PRE
#endif
	FMADD	f27, f12, f21,  f27
	LFDX	f12,   X, INCXM1
	FMADD	f25, f13, f21,  f25
	LFDUX	f19,  Y, INCY
	FMADD	f26, f13, f20,  f26
	LFDUX	f13,   X, INCX

	FMADD	f28, f14, f22,  f28
	LFDX	f20,   Y, INCYM1
#if defined(PPCG4) && defined(DOUBLE)
	dcbt	Y, PRE
#endif
	FMADD	f31, f14, f23,  f31
	LFDX	f14,   X, INCXM1
	FMADD	f29, f15, f23,  f29
	LFDUX	f21,   Y, INCY
	FMADD	f30, f15, f22,  f30
	LFDUX	f15,   X, INCX
	bdnz	LL(110)
	.align 4

LL(120):
	FMADD	f0, f8,  f16,  f0
	LFDX	f22,   Y, INCYM1
	FMADD	f3, f8,  f17,  f3
	LFDX	f8,   X, INCXM1
	FMADD	f1, f9,  f17,  f1
	LFDUX	f23,   Y, INCY
	FMADD	f2, f9,  f16,  f2
	LFDUX	f9,   X, INCX

	FMADD	f4, f10, f18,  f4
	LFDX	f16,  Y, INCYM1
	FMADD	f7, f10, f19,  f7
	LFDX	f10,  X, INCXM1
	FMADD	f5, f11, f19,  f5
	LFDUX	f17,  Y, INCY
	FMADD	f6, f11, f18,  f6
	LFDUX	f11,  X, INCX

	FMADD	f24, f12, f20,  f24
	LFDX	f18,  Y, INCYM1
	FMADD	f27, f12, f21,  f27
	LFDX	f12,   X, INCXM1
	FMADD	f25, f13, f21,  f25
	LFDUX	f19,  Y, INCY
	FMADD	f26, f13, f20,  f26
	LFDUX	f13,   X, INCX

	FMADD	f28, f14, f22,  f28
	LFDX	f20,   Y, INCYM1
	FMADD	f31, f14, f23,  f31
	LFDX	f14,   X, INCXM1
	FMADD	f29, f15, f23,  f29
	LFDUX	f21,   Y, INCY
	FMADD	f30, f15, f22,  f30
	LFDUX	f15,   X, INCX

	LFDX	f22,   Y, INCYM1
	FMADD	f0, f8,  f16,  f0
	LFDUX	f23,   Y, INCY
	FMADD	f3, f8,  f17,  f3
	FMADD	f1, f9,  f17,  f1
	FMADD	f2, f9,  f16,  f2

	FMADD	f4, f10, f18,  f4
	FMADD	f7, f10, f19,  f7
	FMADD	f5, f11, f19,  f5
	FMADD	f6, f11, f18,  f6

	FMADD	f24, f12, f20,  f24
	FMADD	f27, f12, f21,  f27
	FMADD	f25, f13, f21,  f25
	FMADD	f26, f13, f20,  f26

	FMADD	f28, f14, f22,  f28
	FMADD	f31, f14, f23,  f31
	FMADD	f29, f15, f23,  f29
	FMADD	f30, f15, f22,  f30
	.align 4

LL(150):
	andi.	r0,  N, 7
	mtspr	CTR, r0
	beq	LL(999)
	.align 4

LL(160):
	LFDX	f8,    X, INCXM1
	LFDUX	f9,    X, INCX
	LFDX	f16,   Y, INCYM1
	LFDUX	f17,   Y, INCY

	FMADD	f0, f8,  f16,  f0
	FMADD	f1, f9,  f17,  f1
	FMADD	f2, f9,  f16,  f2
	FMADD	f3, f8,  f17,  f3
	bdnz	LL(160)
	.align 4

LL(999):
	FADD	f0, f0, f4
	FADD	f1, f1, f5
	FADD	f2, f2, f6
	FADD	f3, f3, f7

	FADD	f24, f28, f24
	FADD	f25, f29, f25
	FADD	f26, f30, f26
	FADD	f27, f31, f27

	FADD	f0, f0, f24
	FADD	f1, f1, f25
	FADD	f2, f2, f26
	FADD	f3, f3, f27

#ifndef CONJ
	FSUB	f1,  f0,  f1
	FADD	f2,  f2,  f3
#else
	FADD	f1,  f0,  f1
	FSUB	f2,  f3,  f2
#endif

#if defined(F_INTERFACE) && defined(F_INTERFACE_F2C)
	STFD	f1,    0 * SIZE(RESULT)
	STFD	f2,    1 * SIZE(RESULT)
#endif

#if defined(F_INTERFACE) && defined(F_INTERFACE_GFORT)
#ifndef __64BIT__
#ifndef DOUBLE
	stfs	f1,   144(SP)
	stfs	f2,   148(SP)
	lwz	r3,   144(SP)
	lwz	r4,   148(SP)
#else
	stfd	f1,   144(SP)
	stfd	f2,   152(SP)
	lwz	r3,   144(SP)
	lwz	r4,   148(SP)
	lwz	r5,   152(SP)
	lwz	r6,   156(SP)
#endif
#else
#ifndef DOUBLE
	stfs	f1,   144(SP)
	stfs	f2,   148(SP)
	ld	r3,   144(SP)
#else
	stfd	f1,   144(SP)
	stfd	f2,   152(SP)
	ld	r3,   144(SP)
	ld	r4,   152(SP)
#endif
#endif
#endif

	lfd	f14,    0(SP)
	lfd	f15,    8(SP)
	lfd	f16,   16(SP)
	lfd	f17,   24(SP)

	lfd	f18,   32(SP)
	lfd	f19,   40(SP)
	lfd	f20,   48(SP)
	lfd	f21,   56(SP)

	lfd	f22,   64(SP)
	lfd	f23,   72(SP)
	lfd	f24,   80(SP)
	lfd	f25,   88(SP)

	lfd	f26,   96(SP)
	lfd	f27,  104(SP)
	lfd	f28,  112(SP)
	lfd	f29,  120(SP)

	lfd	f30,  128(SP)
	lfd	f31,  136(SP)

	addi	SP, SP, STACKSIZE
	blr

	EPILOGUE

#if defined(__ELF__)
        .section .note.GNU-stack,"",%progbits
#endif
