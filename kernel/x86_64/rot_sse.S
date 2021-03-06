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

#define N	ARG1	/* rdi */
#define X	ARG2	/* rsi */
#define INCX	ARG3	/* rdx */
#define Y	ARG4	/* rcx */
#ifndef WINDOWS_ABI
#define INCY	ARG5	/* r8  */
#else
#define INCY	%r10
#endif

#define C	%xmm14
#define S	%xmm15

#include "l1param.h"

	PROLOGUE
	PROFCODE

#ifdef WINDOWS_ABI
	movq	40(%rsp), INCY
	movss	48(%rsp), %xmm0
	movss	56(%rsp), %xmm1
#endif

	SAVEREGISTERS

	leaq	(, INCX, SIZE), INCX	
	leaq	(, INCY, SIZE), INCY	

	pshufd	$0x0, %xmm0, C
	pshufd	$0x0, %xmm1, S

	cmpq	$0, N
	jle	.L999

	cmpq	$SIZE, INCX
	jne	.L50
	cmpq	$SIZE, INCY
	jne	.L50

	testq	$SIZE, X
	je	.L05

	movss	0 * SIZE(Y), %xmm1
	movss	0 * SIZE(X), %xmm0

	movaps	%xmm1, %xmm2
	movaps	%xmm0, %xmm3

	mulss	C, %xmm0
	mulss	S, %xmm1

	mulss	C, %xmm2
	mulss	S, %xmm3

	addss	%xmm1, %xmm0
	subss	%xmm3, %xmm2

	movss	%xmm0, 0 * SIZE(X)
	movss	%xmm2, 0 * SIZE(Y)

	addq	$1 * SIZE, X
	addq	$1 * SIZE, Y
	decq	N
	jle	.L999

.L05:
	testq	$2 * SIZE, X
	je	.L10

	cmpq	$1, N
	je	.L17

	movsd	0 * SIZE(Y), %xmm1
	movsd	0 * SIZE(X), %xmm0

	movaps	%xmm1, %xmm2
	movaps	%xmm0, %xmm3

	mulps	C, %xmm0
	mulps	S, %xmm1

	mulps	C, %xmm2
	mulps	S, %xmm3

	addps	%xmm1, %xmm0
	subps	%xmm3, %xmm2

	movlps	%xmm0, 0 * SIZE(X)
	movlps	%xmm2, 0 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	subq	$2, N
	jle	.L999
	ALIGN_2

.L10:
	testq	$3 * SIZE, Y
	jne	.L20

	movq	N,  %rax
	sarq	$5, %rax
	jle	.L14

	movaps	 0 * SIZE(Y), %xmm1
	movaps	 4 * SIZE(Y), %xmm3
	movaps	 8 * SIZE(Y), %xmm9
	movaps	12 * SIZE(Y), %xmm11

	movaps	 0 * SIZE(X), %xmm0
	movaps	 4 * SIZE(X), %xmm2
	movaps	 8 * SIZE(X), %xmm8
	movaps	12 * SIZE(X), %xmm10
	
	decq	%rax
	jle	.L12
	ALIGN_3

.L11:
#ifdef PREFETCHW
	PREFETCHW (PREFETCHSIZE +  0) - PREOFFSET(X)
#endif

	movaps	%xmm1, %xmm4
	mulps	S, %xmm1
	movaps	%xmm3, %xmm6
	mulps	S, %xmm3
	movaps	%xmm0, %xmm5
	mulps	C, %xmm0
	movaps	%xmm2, %xmm7
	mulps	C, %xmm2

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	movaps	16 * SIZE(Y), %xmm1
	addps	%xmm3, %xmm2
	movaps	20 * SIZE(Y), %xmm3
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

#ifdef PREFETCHW
	PREFETCHW (PREFETCHSIZE +  0) - PREOFFSET(Y)
#endif

	movaps	%xmm0, 0 * SIZE(X)
	movaps	16 * SIZE(X), %xmm0
	movaps	%xmm2, 4 * SIZE(X)
	movaps	20 * SIZE(X), %xmm2
	movaps	%xmm4, 0 * SIZE(Y)
	movaps	%xmm6, 4 * SIZE(Y)

	movaps	%xmm9, %xmm4
	mulps	S, %xmm9
	movaps	%xmm8, %xmm5
	mulps	C, %xmm8
	movaps	%xmm11, %xmm6
	mulps	S, %xmm11
	movaps	%xmm10, %xmm7
	mulps	C, %xmm10

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm9,  %xmm8
	movaps	24 * SIZE(Y), %xmm9
	addps	%xmm11, %xmm10
	movaps	28 * SIZE(Y), %xmm11
	subps	%xmm5,  %xmm4
	subps	%xmm7,  %xmm6

	movaps	%xmm8,  8 * SIZE(X)
	movaps	24 * SIZE(X), %xmm8
	movaps	%xmm10,12 * SIZE(X)
	movaps	28 * SIZE(X), %xmm10
	movaps	%xmm4,  8 * SIZE(Y)
	movaps	%xmm6, 12 * SIZE(Y)

#ifdef PREFETCHW
	PREFETCHW (PREFETCHSIZE + 64) - PREOFFSET(X)
#endif

	movaps	%xmm1, %xmm4
	mulps	S, %xmm1
	movaps	%xmm3, %xmm6
	mulps	S, %xmm3
	movaps	%xmm0, %xmm5
	mulps	C, %xmm0
	movaps	%xmm2, %xmm7
	mulps	C, %xmm2

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	movaps	32 * SIZE(Y), %xmm1
	addps	%xmm3, %xmm2
	movaps	36 * SIZE(Y), %xmm3
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

	movaps	%xmm0, 16 * SIZE(X)
	movaps	32 * SIZE(X), %xmm0
	movaps	%xmm2, 20 * SIZE(X)
	movaps	36 * SIZE(X), %xmm2
	movaps	%xmm4, 16 * SIZE(Y)
	movaps	%xmm6, 20 * SIZE(Y)

#ifdef PREFETCHW
	PREFETCHW (PREFETCHSIZE + 64) - PREOFFSET(Y)
#endif

	movaps	%xmm9, %xmm4
	mulps	S, %xmm9
	movaps	%xmm8, %xmm5
	mulps	C, %xmm8
	movaps	%xmm11, %xmm6
	mulps	S, %xmm11
	movaps	%xmm10, %xmm7
	mulps	C, %xmm10

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm9,  %xmm8
	movaps	40 * SIZE(Y), %xmm9
	addps	%xmm11, %xmm10
	movaps	44 * SIZE(Y), %xmm11
	subps	%xmm5,  %xmm4
	subps	%xmm7,  %xmm6

	movaps	%xmm8,  24 * SIZE(X)
	movaps	40 * SIZE(X), %xmm8
	movaps	%xmm10, 28 * SIZE(X)
	movaps	44 * SIZE(X), %xmm10
	movaps	%xmm4,  24 * SIZE(Y)
	movaps	%xmm6,  28 * SIZE(Y)

	addq	$32 * SIZE, X
	addq	$32 * SIZE, Y

	decq	%rax
	jg	.L11
	ALIGN_3

.L12:
	movaps	%xmm1, %xmm4
	mulps	S, %xmm1
	movaps	%xmm3, %xmm6
	mulps	S, %xmm3
	movaps	%xmm0, %xmm5
	mulps	C, %xmm0
	movaps	%xmm2, %xmm7
	mulps	C, %xmm2

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	movaps	16 * SIZE(Y), %xmm1
	addps	%xmm3, %xmm2
	movaps	20 * SIZE(Y), %xmm3
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

	movaps	%xmm0, 0 * SIZE(X)
	movaps	16 * SIZE(X), %xmm0
	movaps	%xmm2, 4 * SIZE(X)
	movaps	20 * SIZE(X), %xmm2

	movaps	%xmm4, 0 * SIZE(Y)
	movaps	%xmm6, 4 * SIZE(Y)

	movaps	%xmm9, %xmm4
	mulps	S, %xmm9
	movaps	%xmm8, %xmm5
	mulps	C, %xmm8
	movaps	%xmm11, %xmm6
	mulps	S, %xmm11
	movaps	%xmm10, %xmm7
	mulps	C, %xmm10

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm9,  %xmm8
	movaps	24 * SIZE(Y), %xmm9
	addps	%xmm11, %xmm10
	movaps	28 * SIZE(Y), %xmm11
	subps	%xmm5,  %xmm4
	subps	%xmm7,  %xmm6

	movaps	%xmm8,  8 * SIZE(X)
	movaps	24 * SIZE(X), %xmm8
	movaps	%xmm10,12 * SIZE(X)
	movaps	28 * SIZE(X), %xmm10
	movaps	%xmm4,  8 * SIZE(Y)
	movaps	%xmm6, 12 * SIZE(Y)

	movaps	%xmm1, %xmm4
	mulps	S, %xmm1
	movaps	%xmm3, %xmm6
	mulps	S, %xmm3
	movaps	%xmm0, %xmm5
	mulps	C, %xmm0
	movaps	%xmm2, %xmm7
	mulps	C, %xmm2

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	addps	%xmm3, %xmm2
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

	movaps	%xmm0, 16 * SIZE(X)
	movaps	%xmm2, 20 * SIZE(X)
	movaps	%xmm4, 16 * SIZE(Y)
	movaps	%xmm6, 20 * SIZE(Y)

	movaps	%xmm9, %xmm4
	mulps	S, %xmm9
	movaps	%xmm8, %xmm5
	mulps	C, %xmm8
	movaps	%xmm11, %xmm6
	mulps	S, %xmm11
	movaps	%xmm10, %xmm7
	mulps	C, %xmm10

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm9,  %xmm8
	addps	%xmm11, %xmm10
	subps	%xmm5,  %xmm4
	subps	%xmm7,  %xmm6

	movaps	%xmm8,  24 * SIZE(X)
	movaps	%xmm10, 28 * SIZE(X)
	movaps	%xmm4,  24 * SIZE(Y)
	movaps	%xmm6,  28 * SIZE(Y)

	addq	$32 * SIZE, X
	addq	$32 * SIZE, Y
	ALIGN_3

.L14:
	testq	$31, N
	jle	.L999

	testq	$16, N
	jle	.L15

	movaps	0 * SIZE(Y), %xmm1
	movaps	0 * SIZE(X), %xmm0
	movaps	4 * SIZE(Y), %xmm3
	movaps	4 * SIZE(X), %xmm2

	movaps	%xmm1, %xmm4
	movaps	%xmm0, %xmm5
	movaps	%xmm3, %xmm6
	movaps	%xmm2, %xmm7

	mulps	C, %xmm0
	mulps	S, %xmm1
	mulps	C, %xmm2
	mulps	S, %xmm3

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	addps	%xmm3, %xmm2
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

	movaps	%xmm0, 0 * SIZE(X)
	movaps	%xmm2, 4 * SIZE(X)
	movaps	%xmm4, 0 * SIZE(Y)
	movaps	%xmm6, 4 * SIZE(Y)

	movaps	 8 * SIZE(Y), %xmm1
	movaps	 8 * SIZE(X), %xmm0
	movaps	12 * SIZE(Y), %xmm3
	movaps	12 * SIZE(X), %xmm2

	movaps	%xmm1, %xmm4
	movaps	%xmm0, %xmm5
	movaps	%xmm3, %xmm6
	movaps	%xmm2, %xmm7

	mulps	C, %xmm0
	mulps	S, %xmm1
	mulps	C, %xmm2
	mulps	S, %xmm3

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	addps	%xmm3, %xmm2
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

	movaps	%xmm0,  8 * SIZE(X)
	movaps	%xmm2, 12 * SIZE(X)
	movaps	%xmm4,  8 * SIZE(Y)
	movaps	%xmm6, 12 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L15:
	testq	$8, N
	jle	.L16

	movaps	0 * SIZE(Y), %xmm1
	movaps	0 * SIZE(X), %xmm0
	movaps	4 * SIZE(Y), %xmm3
	movaps	4 * SIZE(X), %xmm2

	movaps	%xmm1, %xmm4
	movaps	%xmm0, %xmm5
	movaps	%xmm3, %xmm6
	movaps	%xmm2, %xmm7

	mulps	C, %xmm0
	mulps	S, %xmm1
	mulps	C, %xmm2
	mulps	S, %xmm3

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	addps	%xmm3, %xmm2
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

	movaps	%xmm0, 0 * SIZE(X)
	movaps	%xmm2, 4 * SIZE(X)
	movaps	%xmm4, 0 * SIZE(Y)
	movaps	%xmm6, 4 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3

.L16:
	testq	$4, N
	jle	.L17

	movaps	0 * SIZE(Y), %xmm1
	movaps	0 * SIZE(X), %xmm0

	movaps	%xmm1, %xmm2
	movaps	%xmm0, %xmm3

	mulps	C, %xmm0
	mulps	S, %xmm1

	mulps	C, %xmm2
	mulps	S, %xmm3

	addps	%xmm1, %xmm0
	subps	%xmm3, %xmm2

	movaps	%xmm0, 0 * SIZE(X)
	movaps	%xmm2, 0 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L17:
	testq	$2, N
	jle	.L18

	movsd	0 * SIZE(Y), %xmm1
	movsd	0 * SIZE(X), %xmm0

	movaps	%xmm1, %xmm2
	movaps	%xmm0, %xmm3

	mulps	C, %xmm0
	mulps	S, %xmm1

	mulps	C, %xmm2
	mulps	S, %xmm3

	addps	%xmm1, %xmm0
	subps	%xmm3, %xmm2

	movlps	%xmm0, 0 * SIZE(X)
	movlps	%xmm2, 0 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L18:
	testq	$1, N
	jle	.L999

	movss	0 * SIZE(Y), %xmm1
	movss	0 * SIZE(X), %xmm0

	movaps	%xmm1, %xmm2
	movaps	%xmm0, %xmm3

	mulss	C, %xmm0
	mulss	S, %xmm1

	mulss	C, %xmm2
	mulss	S, %xmm3

	addss	%xmm1, %xmm0
	subss	%xmm3, %xmm2

	movss	%xmm0, 0 * SIZE(X)
	movss	%xmm2, 0 * SIZE(Y)
	jmp	.L999
	ALIGN_3

.L20:
	movq	N,  %rax
	sarq	$5, %rax
	jle	.L24
	ALIGN_3

.L21:
#ifdef PREFETCHW
	PREFETCHW (PREFETCHSIZE +  0) - PREOFFSET(X)
#endif

	movsd	0 * SIZE(Y), %xmm1
	movhps	2 * SIZE(Y), %xmm1
	movsd	4 * SIZE(Y), %xmm3
	movhps	6 * SIZE(Y), %xmm3
	movaps	0 * SIZE(X), %xmm0
	movaps	4 * SIZE(X), %xmm2

	movaps	%xmm1, %xmm4
	movaps	%xmm0, %xmm5
	movaps	%xmm3, %xmm6
	movaps	%xmm2, %xmm7

	mulps	C, %xmm0
	mulps	S, %xmm1
	mulps	C, %xmm2
	mulps	S, %xmm3

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	addps	%xmm3, %xmm2
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

	movaps	%xmm0, 0 * SIZE(X)
	movaps	%xmm2, 4 * SIZE(X)
	movlps	%xmm4, 0 * SIZE(Y)
	movhps	%xmm4, 2 * SIZE(Y)
	movlps	%xmm6, 4 * SIZE(Y)
	movhps	%xmm6, 6 * SIZE(Y)

#ifdef PREFETCHW
	PREFETCHW (PREFETCHSIZE +  0) - PREOFFSET(Y)
#endif

	movsd	 8 * SIZE(Y), %xmm1
	movhps	10 * SIZE(Y), %xmm1
	movsd	12 * SIZE(Y), %xmm3
	movhps	14 * SIZE(Y), %xmm3
	movaps	 8 * SIZE(X), %xmm0
	movaps	12 * SIZE(X), %xmm2

	movaps	%xmm1, %xmm4
	movaps	%xmm0, %xmm5
	movaps	%xmm3, %xmm6
	movaps	%xmm2, %xmm7

	mulps	C, %xmm0
	mulps	S, %xmm1
	mulps	C, %xmm2
	mulps	S, %xmm3

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	addps	%xmm3, %xmm2
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

	movaps	%xmm0,  8 * SIZE(X)
	movaps	%xmm2, 12 * SIZE(X)
	movlps	%xmm4,  8 * SIZE(Y)
	movhps	%xmm4, 10 * SIZE(Y)
	movlps	%xmm6, 12 * SIZE(Y)
	movhps	%xmm6, 14 * SIZE(Y)

#ifdef PREFETCHW
	PREFETCHW (PREFETCHSIZE + 64) - PREOFFSET(X)
#endif

	movsd	16 * SIZE(Y), %xmm1
	movhps	18 * SIZE(Y), %xmm1
	movsd	20 * SIZE(Y), %xmm3
	movhps	22 * SIZE(Y), %xmm3
	movaps	16 * SIZE(X), %xmm0
	movaps	20 * SIZE(X), %xmm2

	movaps	%xmm1, %xmm4
	movaps	%xmm0, %xmm5
	movaps	%xmm3, %xmm6
	movaps	%xmm2, %xmm7

	mulps	C, %xmm0
	mulps	S, %xmm1
	mulps	C, %xmm2
	mulps	S, %xmm3

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	addps	%xmm3, %xmm2
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

	movaps	%xmm0, 16 * SIZE(X)
	movaps	%xmm2, 20 * SIZE(X)
	movlps	%xmm4, 16 * SIZE(Y)
	movhps	%xmm4, 18 * SIZE(Y)
	movlps	%xmm6, 20 * SIZE(Y)
	movhps	%xmm6, 22 * SIZE(Y)

#ifdef PREFETCHW
	PREFETCHW (PREFETCHSIZE + 64) - PREOFFSET(Y)
#endif

	movsd	24 * SIZE(Y), %xmm1
	movhps	26 * SIZE(Y), %xmm1
	movsd	28 * SIZE(Y), %xmm3
	movhps	30 * SIZE(Y), %xmm3
	movaps	24 * SIZE(X), %xmm0
	movaps	28 * SIZE(X), %xmm2

	movaps	%xmm1, %xmm4
	movaps	%xmm0, %xmm5
	movaps	%xmm3, %xmm6
	movaps	%xmm2, %xmm7

	mulps	C, %xmm0
	mulps	S, %xmm1
	mulps	C, %xmm2
	mulps	S, %xmm3

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	addps	%xmm3, %xmm2
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

	movaps	%xmm0, 24 * SIZE(X)
	movaps	%xmm2, 28 * SIZE(X)
	movlps	%xmm4, 24 * SIZE(Y)
	movhps	%xmm4, 26 * SIZE(Y)
	movlps	%xmm6, 28 * SIZE(Y)
	movhps	%xmm6, 30 * SIZE(Y)

	addq	$32 * SIZE, X
	addq	$32 * SIZE, Y
	decq	%rax
	jg	.L21
	ALIGN_3

.L24:
	testq	$31, N
	jle	.L999

	testq	$16, N
	jle	.L25

	movsd	0 * SIZE(Y), %xmm1
	movhps	2 * SIZE(Y), %xmm1
	movsd	4 * SIZE(Y), %xmm3
	movhps	6 * SIZE(Y), %xmm3
	movaps	0 * SIZE(X), %xmm0
	movaps	4 * SIZE(X), %xmm2

	movaps	%xmm1, %xmm4
	movaps	%xmm0, %xmm5
	movaps	%xmm3, %xmm6
	movaps	%xmm2, %xmm7

	mulps	C, %xmm0
	mulps	S, %xmm1
	mulps	C, %xmm2
	mulps	S, %xmm3

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	addps	%xmm3, %xmm2
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

	movaps	%xmm0, 0 * SIZE(X)
	movaps	%xmm2, 4 * SIZE(X)
	movlps	%xmm4, 0 * SIZE(Y)
	movhps	%xmm4, 2 * SIZE(Y)
	movlps	%xmm6, 4 * SIZE(Y)
	movhps	%xmm6, 6 * SIZE(Y)

	movsd	 8 * SIZE(Y), %xmm1
	movhps	10 * SIZE(Y), %xmm1
	movsd	12 * SIZE(Y), %xmm3
	movhps	14 * SIZE(Y), %xmm3
	movaps	 8 * SIZE(X), %xmm0
	movaps	12 * SIZE(X), %xmm2

	movaps	%xmm1, %xmm4
	movaps	%xmm0, %xmm5
	movaps	%xmm3, %xmm6
	movaps	%xmm2, %xmm7

	mulps	C, %xmm0
	mulps	S, %xmm1
	mulps	C, %xmm2
	mulps	S, %xmm3

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	addps	%xmm3, %xmm2
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

	movaps	%xmm0,  8 * SIZE(X)
	movaps	%xmm2, 12 * SIZE(X)
	movlps	%xmm4,  8 * SIZE(Y)
	movhps	%xmm4, 10 * SIZE(Y)
	movlps	%xmm6, 12 * SIZE(Y)
	movhps	%xmm6, 14 * SIZE(Y)

	addq	$16 * SIZE, X
	addq	$16 * SIZE, Y
	ALIGN_3

.L25:
	testq	$8, N
	jle	.L26

	movsd	0 * SIZE(Y), %xmm1
	movhps	2 * SIZE(Y), %xmm1
	movsd	4 * SIZE(Y), %xmm3
	movhps	6 * SIZE(Y), %xmm3
	movaps	0 * SIZE(X), %xmm0
	movaps	4 * SIZE(X), %xmm2

	movaps	%xmm1, %xmm4
	movaps	%xmm0, %xmm5
	movaps	%xmm3, %xmm6
	movaps	%xmm2, %xmm7

	mulps	C, %xmm0
	mulps	S, %xmm1
	mulps	C, %xmm2
	mulps	S, %xmm3

	mulps	C, %xmm4
	mulps	S, %xmm5
	mulps	C, %xmm6
	mulps	S, %xmm7

	addps	%xmm1, %xmm0
	addps	%xmm3, %xmm2
	subps	%xmm5, %xmm4
	subps	%xmm7, %xmm6

	movaps	%xmm0, 0 * SIZE(X)
	movaps	%xmm2, 4 * SIZE(X)
	movlps	%xmm4, 0 * SIZE(Y)
	movhps	%xmm4, 2 * SIZE(Y)
	movlps	%xmm6, 4 * SIZE(Y)
	movhps	%xmm6, 6 * SIZE(Y)

	addq	$8 * SIZE, X
	addq	$8 * SIZE, Y
	ALIGN_3


.L26:
	testq	$4, N
	jle	.L27

	movsd	0 * SIZE(Y), %xmm1
	movhps	2 * SIZE(Y), %xmm1
	movaps	0 * SIZE(X), %xmm0

	movaps	%xmm1, %xmm2
	movaps	%xmm0, %xmm3

	mulps	C, %xmm0
	mulps	S, %xmm1

	mulps	C, %xmm2
	mulps	S, %xmm3

	addps	%xmm1, %xmm0
	subps	%xmm3, %xmm2

	movaps	%xmm0, 0 * SIZE(X)
	movlps	%xmm2, 0 * SIZE(Y)
	movhps	%xmm2, 2 * SIZE(Y)

	addq	$4 * SIZE, X
	addq	$4 * SIZE, Y
	ALIGN_3

.L27:
	testq	$2, N
	jle	.L28

	movsd	0 * SIZE(Y), %xmm1
	movsd	0 * SIZE(X), %xmm0

	movaps	%xmm1, %xmm2
	movaps	%xmm0, %xmm3

	mulps	C, %xmm0
	mulps	S, %xmm1

	mulps	C, %xmm2
	mulps	S, %xmm3

	addps	%xmm1, %xmm0
	subps	%xmm3, %xmm2

	movlps	%xmm0, 0 * SIZE(X)
	movlps	%xmm2, 0 * SIZE(Y)

	addq	$2 * SIZE, X
	addq	$2 * SIZE, Y
	ALIGN_3

.L28:
	testq	$1, N
	jle	.L999

	movss	0 * SIZE(Y), %xmm1
	movss	0 * SIZE(X), %xmm0

	movaps	%xmm1, %xmm2
	movaps	%xmm0, %xmm3

	mulss	C, %xmm0
	mulss	S, %xmm1

	mulss	C, %xmm2
	mulss	S, %xmm3

	addss	%xmm1, %xmm0
	subss	%xmm3, %xmm2

	movss	%xmm0, 0 * SIZE(X)
	movss	%xmm2, 0 * SIZE(Y)
	jmp	.L999
	ALIGN_3


.L50:
	movq	N,  %rax
	sarq	$2, %rax
	jle	.L55
	ALIGN_3

.L53:
	movss	(Y), %xmm1
	movss	(X), %xmm0

	movaps	%xmm1, %xmm2
	movaps	%xmm0, %xmm3

	mulss	C, %xmm0
	mulss	S, %xmm1

	mulss	C, %xmm2
	mulss	S, %xmm3

	addss	%xmm1, %xmm0
	subss	%xmm3, %xmm2

	movss	%xmm0, (X)
	movss	%xmm2, (Y)

	addq	INCX, X
	addq	INCY, Y

	movss	(Y), %xmm1
	movss	(X), %xmm0

	movaps	%xmm1, %xmm2
	movaps	%xmm0, %xmm3

	mulss	C, %xmm0
	mulss	S, %xmm1

	mulss	C, %xmm2
	mulss	S, %xmm3

	addss	%xmm1, %xmm0
	subss	%xmm3, %xmm2

	movss	%xmm0, (X)
	movss	%xmm2, (Y)

	addq	INCX, X
	addq	INCY, Y

	movss	(Y), %xmm1
	movss	(X), %xmm0

	movaps	%xmm1, %xmm2
	movaps	%xmm0, %xmm3

	mulss	C, %xmm0
	mulss	S, %xmm1

	mulss	C, %xmm2
	mulss	S, %xmm3

	addss	%xmm1, %xmm0
	subss	%xmm3, %xmm2

	movss	%xmm0, (X)
	movss	%xmm2, (Y)

	addq	INCX, X
	addq	INCY, Y

	movss	(Y), %xmm1
	movss	(X), %xmm0

	movaps	%xmm1, %xmm2
	movaps	%xmm0, %xmm3

	mulss	C, %xmm0
	mulss	S, %xmm1

	mulss	C, %xmm2
	mulss	S, %xmm3

	addss	%xmm1, %xmm0
	subss	%xmm3, %xmm2

	movss	%xmm0, (X)
	movss	%xmm2, (Y)

	addq	INCX, X
	addq	INCY, Y

	decq	%rax
	jg	.L53
	ALIGN_3

.L55:
	movq	N,  %rax
	andq	$3, %rax
	jle	.L999
	ALIGN_3

.L56:
	movss	(Y), %xmm1
	movss	(X), %xmm0

	movaps	%xmm1, %xmm2
	movaps	%xmm0, %xmm3

	mulss	C, %xmm0
	mulss	S, %xmm1

	mulss	C, %xmm2
	mulss	S, %xmm3

	addss	%xmm1, %xmm0
	subss	%xmm3, %xmm2

	movss	%xmm0, (X)
	movss	%xmm2, (Y)

	addq	INCX, X
	addq	INCY, Y

	decq	%rax
	jg	.L56
	ALIGN_3

.L999:
	RESTOREREGISTERS

	ret

	EPILOGUE

#if defined(__ELF__)
        .section .note.GNU-stack,"",%progbits
#endif
