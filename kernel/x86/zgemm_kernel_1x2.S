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

#define STACK	16
#define ARGS	16
	
#define J	 0 + STACK(%esp)
#define I	 4 + STACK(%esp)
#define KK	 8 + STACK(%esp)
#define KKK	12 + STACK(%esp)

#define M	 4 + STACK + ARGS(%esp)
#define N	 8 + STACK + ARGS(%esp)
#define K	12 + STACK + ARGS(%esp)
#ifdef DOUBLE
#define ALPHA_R	16 + STACK + ARGS(%esp)
#define ALPHA_I	24 + STACK + ARGS(%esp)
#define STACK_A	32 + STACK + ARGS(%esp)
#define STACK_B	36 + STACK + ARGS(%esp)
#define C	40 + STACK + ARGS(%esp)
#define STACK_LDC	44 + STACK + ARGS(%esp)
#define OFFSET	48 + STACK + ARGS(%esp)
#else
#define ALPHA_R	16 + STACK + ARGS(%esp)
#define ALPHA_I	20 + STACK + ARGS(%esp)
#define STACK_A	24 + STACK + ARGS(%esp)
#define STACK_B	28 + STACK + ARGS(%esp)
#define C	32 + STACK + ARGS(%esp)
#define STACK_LDC	36 + STACK + ARGS(%esp)
#define OFFSET	40 + STACK + ARGS(%esp)
#endif

#define A	%edx
#define B	%ecx
#define BB	%ebx
#define LDC	%ebp
#define BX	%esi

#define ADD1	faddp

#if defined(NN) || defined(CN)
#define ADD2	faddp
#else
#define ADD2	fsubrp
#endif

#if defined(NN) || defined(CC)
#define ADD3	fsubrp
#else
#define ADD3	faddp
#endif

#if defined(NN) || defined(NC)
#define ADD4	faddp
#else
#define ADD4	fsubrp
#endif

#define PREFETCHSIZE (8 * 5 + 4)

#define AOFFSET   1
#define BOFFSET   1

#ifdef HAVE_3DNOW
#define PREFETCH	prefetch
#else
#define PREFETCH	prefetcht0
#endif

#define KERNEL \
	PREFETCH	PREFETCHSIZE * SIZE + AOFFSET(A, %eax, 2);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(4);\
	FLD	-15 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD2	%st, %st(5);\
	FLD	-14 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(6);\
	FMUL	-13 * SIZE + BOFFSET(B, %eax, 4);\
	ADD2	%st, %st(6);\
	FLD	-15 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	-15 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(4);\
	FLD	-16 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD4	%st, %st(5);\
	FLD	-13 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(6);\
	FMUL	-14 * SIZE + BOFFSET(B, %eax, 4);\
	ADD4	%st, %st(6);\
	FLD	-14 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	-12 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(4);\
	FLD	-11 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD2	%st, %st(5);\
	FLD	-10 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(6);\
	FMUL	 -9 * SIZE + BOFFSET(B, %eax, 4);\
	ADD2	%st, %st(6);\
	FLD	-13 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	-11 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(4);\
	FLD	-12 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD4	%st, %st(5);\
	FLD	 -9 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(6);\
	FMUL	-10 * SIZE + BOFFSET(B, %eax, 4);\
	ADD4	%st, %st(6);\
	FLD	-12 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	 -8 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(4);\
	FLD	 -7 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD2	%st, %st(5);\
	FLD	 -6 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(6);\
	FMUL	 -5 * SIZE + BOFFSET(B, %eax, 4);\
	ADD2	%st, %st(6);\
	FLD	-11 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	 -7 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(4);\
	FLD	 -8 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD4	%st, %st(5);\
	FLD	 -5 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(6);\
	FMUL	 -6 * SIZE + BOFFSET(B, %eax, 4);\
	ADD4	%st, %st(6);\
	FLD	-10 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	 -4 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(4);\
	FLD	 -3 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD2	%st, %st(5);\
	FLD	 -2 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(6);\
	FMUL	 -1 * SIZE + BOFFSET(B, %eax, 4);\
	ADD2	%st, %st(6);\
	FLD	 -9 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	 -3 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(4);\
	FLD	 -4 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD4	%st, %st(5);\
	FLD	 -1 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(6);\
	FMUL	 -2 * SIZE + BOFFSET(B, %eax, 4);\
	ADD4	%st, %st(6);\
	FLD	  8 * SIZE + AOFFSET(A, %eax, 2);\
	fxch	%st(1);\
	FLD	  0 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(4);\
	FLD	  1 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	PREFETCH	(PREFETCHSIZE + 8) * SIZE + AOFFSET(A, %eax, 2);\
	ADD2	%st, %st(5);\
	FLD	  2 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(6);\
	FMUL	  3 * SIZE + BOFFSET(B, %eax, 4);\
	ADD2	%st, %st(6);\
	FLD	 -7 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	  1 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(4);\
	FLD	  0 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD4	%st, %st(5);\
	FLD	  3 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(6);\
	FMUL	  2 * SIZE + BOFFSET(B, %eax, 4);\
	ADD4	%st, %st(6);\
	FLD	 -6 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	  4 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(4);\
	FLD	  5 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD2	%st, %st(5);\
	FLD	  6 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(6);\
	FMUL	  7 * SIZE + BOFFSET(B, %eax, 4);\
	ADD2	%st, %st(6);\
	FLD	 -5 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	  5 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(4);\
	FLD	  4 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD4	%st, %st(5);\
	FLD	  7 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(6);\
	FMUL	  6 * SIZE + BOFFSET(B, %eax, 4);\
	ADD4	%st, %st(6);\
	FLD	 -4 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	  8 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(4);\
	FLD	  9 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD2	%st, %st(5);\
	FLD	 10 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(6);\
	FMUL	 11 * SIZE + BOFFSET(B, %eax, 4);\
	ADD2	%st, %st(6);\
	FLD	 -3 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	  9 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(4);\
	FLD	  8 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD4	%st, %st(5);\
	FLD	 11 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(6);\
	FMUL	 10 * SIZE + BOFFSET(B, %eax, 4);\
	ADD4	%st, %st(6);\
	FLD	 -2 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	 12 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(4);\
	FLD	 13 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD2	%st, %st(5);\
	FLD	 14 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD1	%st, %st(6);\
	FMUL	 15 * SIZE + BOFFSET(B, %eax, 4);\
	ADD2	%st, %st(6);\
	FLD	 -1 * SIZE + AOFFSET(A, %eax, 2);\
	FLD	 13 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(4);\
	FLD	 12 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD4	%st, %st(5);\
	FLD	 15 * SIZE + BOFFSET(B, %eax, 4);\
	fmul	%st(1), %st;\
	ADD3	%st, %st(6);\
	FMUL	 14 * SIZE + BOFFSET(B, %eax, 4);\
	ADD4	%st, %st(6);\
	FLD	 16 * SIZE + AOFFSET(A, %eax, 2);\
	fxch	%st(2);\
	FLD	  0 * SIZE + BOFFSET(BB, %eax, 4);\
	subl	 $-8 * SIZE, %eax

/*

  A hint of scheduling is received from following URL

  http://www.netlib.org/atlas/atlas-comm/msg00260.html

*/

	PROLOGUE

	subl	$ARGS, %esp	# Generate Stack Frame

	pushl	%ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx

	PROFCODE

#if defined(TRMMKERNEL) && !defined(LEFT)
	movl	OFFSET, %eax
	negl	%eax
	movl	%eax, KK
#endif

	movl	STACK_LDC, LDC
	sall	$ZBASE_SHIFT, LDC
	
	subl	$(AOFFSET - 16 * SIZE), STACK_A
	subl	$(BOFFSET - 16 * SIZE), STACK_B

	movl	M, %eax
	testl	%eax, %eax
	jle	.L999

	movl	N, %eax
	testl	%eax, %eax
	jle	.L999

	movl	K, %eax
	testl	%eax, %eax
	jle	.L999
	
	movl	N,   %eax
	sarl	$1,  %eax
	movl	%eax, J
	je	.L20
	ALIGN_3

.L11:
#if defined(TRMMKERNEL) && defined(LEFT)
	movl	OFFSET, %eax
	movl	%eax, KK
#endif	

	movl	STACK_A, A
	movl	STACK_B, B
	movl	C, %edi

	movl	K, BX
	sall	$ZBASE_SHIFT + 1, BX
	addl	B, BX

	movl	M, %eax
	movl	%eax, I
	ALIGN_3

.L14:
	prefetchnta	-16 * SIZE + BOFFSET(BX)
	prefetchnta	 -8 * SIZE + BOFFSET(BX)
	subl	$-16 * SIZE, BX

	movl	STACK_B, B

#if !defined(TRMMKERNEL) || \
	(defined(TRMMKERNEL) &&  defined(LEFT) &&  defined(TRANSA)) || \
	(defined(TRMMKERNEL) && !defined(LEFT) && !defined(TRANSA))
#else
	movl	KK,   %eax
	leal	(, %eax, SIZE), %eax
	leal	(A, %eax, 2), A
	leal	(B, %eax, 4), B
#endif

	fldz
	fldz
	fldz
	fldz

	FLD	   0 * SIZE + AOFFSET(A)
	FLD	  -8 * SIZE + AOFFSET(A)
	FLD	 -16 * SIZE + AOFFSET(A)
	FLD	 -16 * SIZE + BOFFSET(B)

#ifdef HAVE_3DNOW
	prefetchw	1 * SIZE(%edi)
	prefetchw	2 * SIZE(%edi, LDC)
#elif defined(HAVE_SSE)
	prefetcht0	1 * SIZE(%edi)
	prefetcht0	2 * SIZE(%edi, LDC)
#endif

#ifndef TRMMKERNEL
	movl	K,  %eax
#elif (defined(LEFT) && !defined(TRANSA)) || (!defined(LEFT) && defined(TRANSA))
	movl	K, %eax
	subl	KK, %eax
	movl	%eax, KKK	
#else
	movl	KK, %eax
#ifdef LEFT
	addl	$1, %eax
#else
	addl	$2, %eax
#endif
	movl	%eax, KKK
#endif

	andl	$-8, %eax

	leal	(, %eax, SIZE), %eax
	leal	(A, %eax, 2), A
	leal	16 * SIZE(B, %eax, 4), BB
	leal	(B, %eax, 4), B
	negl	%eax
	NOBRANCH
 	je	.L16
	ALIGN_4

.L15:
	KERNEL
	jge	.L16
	KERNEL
	jge	.L16
	KERNEL
	jge	.L16
	KERNEL
	jl	.L15
	ALIGN_4

.L16:
#ifndef TRMMKERNEL
	movl	K, %eax
#else
	movl	KKK, %eax
#endif
	and	$7, %eax
	je	.L19
	ALIGN_4


.L17:
	fmul	%st(1), %st
	ADD1	%st, %st(4)
	FLD	-15 * SIZE + BOFFSET(B)

	fmul	%st(1), %st
	ADD2	%st, %st(5)
	FLD	-14 * SIZE + BOFFSET(B)

	fmul	%st(1), %st
	ADD1	%st, %st(6)
	FMUL	-13 * SIZE + BOFFSET(B)

	ADD2	%st, %st(6)
	FLD	-15 * SIZE + AOFFSET(A)
	FLD	-15 * SIZE + BOFFSET(B)

	fmul	%st(1), %st
	ADD3	%st, %st(4)
	FLD	-16 * SIZE + BOFFSET(B)

	fmul	%st(1), %st
	ADD4	%st, %st(5)
	FLD	-13 * SIZE + BOFFSET(B)

	fmul	%st(1), %st
	ADD3	%st, %st(6)
	FMUL	-14 * SIZE + BOFFSET(B)

	ADD4	%st, %st(6)
	FLD	-14 * SIZE + AOFFSET(A)
	FLD	-12 * SIZE + BOFFSET(B)

	addl	$2 * SIZE,A
	addl	$4 * SIZE,B

	decl	%eax
	jne	 .L17
	ALIGN_4

.L19:
	ffreep	%st(0)
	ffreep	%st(0)
	ffreep	%st(0)
	ffreep	%st(0)

	FLD	ALPHA_R
	fmul	%st(1), %st
	FLD	ALPHA_I
	fmul	%st(3), %st
	fsubrp	%st, %st(1)
	fxch	%st(2)
	FMUL	ALPHA_R
	fxch	%st(1)
	FMUL	ALPHA_I
	faddp	%st, %st(1)	

#ifndef TRMMKERNEL
	FADD	1 * SIZE(%edi)
	FST	1 * SIZE(%edi)
	FADD	0 * SIZE(%edi)
	FST	0 * SIZE(%edi)
#else
	FST	1 * SIZE(%edi)
	FST	0 * SIZE(%edi)
#endif

	FLD	ALPHA_R
	fmul	%st(1), %st
	FLD	ALPHA_I
	fmul	%st(3), %st
	fsubrp	%st, %st(1)
	fxch	%st(2)
	FMUL	ALPHA_R
	fxch	%st(1)
	FMUL	ALPHA_I
	faddp	%st, %st(1)	

#ifndef TRMMKERNEL
	FADD	1 * SIZE(%edi,LDC)
	FST	1 * SIZE(%edi,LDC)
	FADD	0 * SIZE(%edi,LDC)
	FST	0 * SIZE(%edi,LDC)
#else
	FST	1 * SIZE(%edi,LDC)
	FST	0 * SIZE(%edi,LDC)
#endif

#if (defined(TRMMKERNEL) &&  defined(LEFT) &&  defined(TRANSA)) || \
    (defined(TRMMKERNEL) && !defined(LEFT) && !defined(TRANSA))
	movl	K, %eax
	subl	KKK, %eax
	leal	(,%eax, SIZE), %eax
	leal	(A, %eax, 2), A
	leal	(B, %eax, 4), B
#endif

#if defined(TRMMKERNEL) && defined(LEFT)
	addl	$1, KK
#endif

	addl	$2 * SIZE, %edi
	decl	I
	jne	.L14

#if defined(TRMMKERNEL) && !defined(LEFT)
	addl	$2, KK
#endif

	leal	(, LDC, 2), %eax
	addl	%eax, C
	movl	B, STACK_B
	decl	J
	jne	.L11
	ALIGN_4

.L20:
	movl	N,   %eax
	andl	$1,  %eax
	je	.L999
	ALIGN_3

#if defined(TRMMKERNEL) && defined(LEFT)
	movl	OFFSET, %eax
	movl	%eax, KK
#endif	

	movl	STACK_A, A
	movl	STACK_B, B
	movl	C, %edi

	movl	M, %eax
	movl	%eax, I
	ALIGN_3

.L24:
	movl	STACK_B, B
#if !defined(TRMMKERNEL) || \
	(defined(TRMMKERNEL) &&  defined(LEFT) &&  defined(TRANSA)) || \
	(defined(TRMMKERNEL) && !defined(LEFT) && !defined(TRANSA))
#else
	movl	KK,   %eax
	leal	(, %eax, SIZE), %eax
	leal	(A,      %eax, 2), A
	leal	(B, %eax, 2), B
#endif

	fldz
	fldz
	fldz
	fldz

	FLD	-16 * SIZE + AOFFSET(A)
	FLD	-16 * SIZE + BOFFSET(B)

	prefetchw	1 * SIZE(%edi)

#ifndef TRMMKERNEL
	movl	K,  %eax
#elif (defined(LEFT) && !defined(TRANSA)) || (!defined(LEFT) && defined(TRANSA))
	movl	K, %eax
	subl	KK, %eax
	movl	%eax, KKK	
#else
	movl	KK, %eax
#ifdef LEFT
	addl	$1, %eax
#else
	addl	$1, %eax
#endif
	movl	%eax, KKK
#endif
	sarl	$2, %eax
 	je	.L26
	ALIGN_3

.L25:
	fmul	%st(1), %st
	PADDING
	ADD1	%st, %st(2)
	FMUL	-15 * SIZE + BOFFSET(B)

	ADD2	%st, %st(2)
	FLD	-15 * SIZE + AOFFSET(A)
	FLD	-16 * SIZE + BOFFSET(B)

	fmul	%st(1), %st
	PADDING
	ADD4	%st, %st(4)
	FMUL	-15 * SIZE + BOFFSET(B)

	ADD3	%st, %st(4)
	FLD	-14 * SIZE + AOFFSET(A)
	FLD	-14 * SIZE + BOFFSET(B)

	fmul	%st(1), %st
	PADDING
	ADD1	%st, %st(2)
	FMUL	-13 * SIZE + BOFFSET(B)

	ADD2	%st, %st(2)
	FLD	-13 * SIZE + AOFFSET(A)
	FLD	-14 * SIZE + BOFFSET(B)

	fmul	%st(1), %st
	PADDING
	ADD4	%st, %st(4)
	FMUL	-13 * SIZE + BOFFSET(B)

	ADD3	%st, %st(4)
	FLD	-12 * SIZE + AOFFSET(A)
	FLD	-12 * SIZE + BOFFSET(B)

	fmul	%st(1), %st
	PADDING
	ADD1	%st, %st(2)
	FMUL	-11 * SIZE + BOFFSET(B)

	ADD2	%st, %st(2)
	FLD	-11 * SIZE + AOFFSET(A)
	FLD	-12 * SIZE + BOFFSET(B)

	fmul	%st(1), %st
	PADDING
	ADD4	%st, %st(4)
	FMUL	-11 * SIZE + BOFFSET(B)

	ADD3	%st, %st(4)
	FLD	-10 * SIZE + AOFFSET(A)
	FLD	-10 * SIZE + BOFFSET(B)

	fmul	%st(1), %st
	PADDING
	ADD1	%st, %st(2)
	FMUL	 -9 * SIZE + BOFFSET(B)

	ADD2	%st, %st(2)
	FLD	 -9 * SIZE + AOFFSET(A)
	FLD	-10 * SIZE + BOFFSET(B)

	fmul	%st(1), %st
	PADDING
	ADD4	%st, %st(4)
	FMUL	 -9 * SIZE + BOFFSET(B)

	ADD3	%st, %st(4)
	FLD	 -8 * SIZE + AOFFSET(A)
	FLD	 -8 * SIZE + BOFFSET(B)

	addl	$8 * SIZE,A
	addl	$8 * SIZE,B

	decl	%eax
	jne	.L25
	ALIGN_4

.L26:
#ifndef TRMMKERNEL
	movl	K, %eax
#else
	movl	KKK, %eax
#endif
	and	$3, %eax
	je	.L29
	ALIGN_4

.L27:
	fmul	%st(1), %st
	PADDING
	ADD1	%st, %st(2)
	FMUL	-15 * SIZE + BOFFSET(B)

	ADD2	%st, %st(2)
	FLD	-15 * SIZE + AOFFSET(A)
	FLD	-16 * SIZE + BOFFSET(B)

	fmul	%st(1), %st
	PADDING
	ADD4	%st, %st(4)
	FMUL	-15 * SIZE + BOFFSET(B)

	ADD3	%st, %st(4)
	FLD	-14 * SIZE + AOFFSET(A)
	FLD	-14 * SIZE + BOFFSET(B)

	addl	$2 * SIZE,A
	addl	$2 * SIZE,B

	decl	%eax
	jne	 .L27
	ALIGN_4

.L29:
	ffreep	%st(0)
	ffreep	%st(0)

	faddp	%st, %st(3)
	faddp	%st, %st(1)

	fxch	%st(1)

	FLD	ALPHA_R
	fmul	%st(1), %st
	FLD	ALPHA_I
	fmul	%st(3), %st
	fsubrp	%st, %st(1)
	fxch	%st(2)
	FMUL	ALPHA_R
	fxch	%st(1)
	FMUL	ALPHA_I
	faddp	%st, %st(1)	

#ifndef TRMMKERNEL
	FADD	1 * SIZE(%edi)
	FST	1 * SIZE(%edi)
	FADD	0 * SIZE(%edi)
	FST	0 * SIZE(%edi)
#else
	FST	1 * SIZE(%edi)
	FST	0 * SIZE(%edi)
#endif

#if (defined(TRMMKERNEL) &&  defined(LEFT) &&  defined(TRANSA)) || \
    (defined(TRMMKERNEL) && !defined(LEFT) && !defined(TRANSA))
	movl	K, %eax
	subl	KKK, %eax
	leal	(,%eax, SIZE), %eax
	leal	(A, %eax, 2), A
	leal	(B, %eax, 2), B
#endif

#if defined(TRMMKERNEL) && defined(LEFT)
	addl	$1, KK
#endif

	addl	$2 * SIZE, %edi
	decl	I
	jne	.L24

#if defined(TRMMKERNEL) && !defined(LEFT)
	addl	$1, KK
#endif

	addl	LDC, C
	movl	B, STACK_B
	ALIGN_4

.L999:
	popl	%ebx
	popl	%esi
	popl	%edi
	popl	%ebp
	addl	$ARGS, %esp
	ret

	EPILOGUE

#if defined(__ELF__)
        .section .note.GNU-stack,"",%progbits
#endif
