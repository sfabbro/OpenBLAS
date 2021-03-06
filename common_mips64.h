/*****************************************************************************
Copyright (c) 2011, Lab of Parallel Software and Computational Science,ICSAS
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

   1. Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the
      distribution.
   3. Neither the name of the ISCAS nor the names of its contributors may 
      be used to endorse or promote products derived from this software 
      without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

**********************************************************************************/

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

#ifndef COMMON_MIPS64
#define COMMON_MIPS64

#define MB
#define WMB

#define INLINE inline

#ifndef ASSEMBLER

static void INLINE blas_lock(volatile unsigned long *address){

  long int ret, val = 1;

  do {
    while (*address) {YIELDING;};

    __asm__ __volatile__(
			 "1:	ll	%0, %3\n"
			 "	ori	%2, %0, 1\n"
			 "	sc	%2, %1\n"
			 "	beqz	%2, 1b\n"
			 "	 andi	%2, %0, 1\n"
			 "	sync\n"
			 : "=&r" (val), "=m" (address), "=&r" (ret)
			 : "m" (address)
			 : "memory");

  } while (ret);
}

static inline unsigned int rpcc(void){
  unsigned long ret;
#if defined(LOONGSON3A) || defined(LOONGSON3B)
  //  unsigned long long tmp;
  //__asm__ __volatile__("dmfc0 %0, $25, 1": "=r"(tmp):: "memory");
  //ret=tmp;
  __asm__ __volatile__(".set push \n"
                       ".set mips32r2\n"
                       "rdhwr %0, $2\n"
                       ".set pop": "=r"(ret):: "memory");

#else
  __asm__ __volatile__(".set   push    \n"                                     
          ".set   mips32r2\n"                                                  
          "rdhwr %0, $30  \n"                                                  
          ".set pop" : "=r"(ret) : : "memory");
#endif
  return ret;
}

#if defined(LOONGSON3A) || defined(LOONGSON3B)
#ifndef NO_AFFINITY
#define WHEREAMI
static inline int WhereAmI(void){
  int ret=0;
  __asm__ __volatile__(".set push \n"
                       ".set mips32r2\n"
                       "rdhwr %0, $0\n"
                       ".set pop": "=r"(ret):: "memory");
  return ret;

}
#endif
#endif

static inline int blas_quickdivide(blasint x, blasint y){
  return x / y;
}

#ifdef DOUBLE
#define GET_IMAGE(res)  __asm__ __volatile__("mov.d %0, $f2" : "=f"(res)  : : "memory")
#else
#define GET_IMAGE(res)  __asm__ __volatile__("mov.s %0, $f2" : "=f"(res)  : : "memory")
#endif

#define GET_IMAGE_CANCEL

#endif


#ifdef ASSEMBLER

#define HALT	teq	$0, $0
#define NOP	move	$0, $0

#ifdef DOUBLE
#define LD	ldc1
#define ST	sdc1
#define MADD	madd.d
#define NMADD	nmadd.d
#define MSUB	msub.d
#define NMSUB	nmsub.d
#define ADD	add.d
#define SUB	sub.d
#define MUL	mul.d
#define MOV	mov.d
#define CMOVF	movf.d
#define CMOVT	movt.d
#define MTC	dmtc1
#define FABS	abs.d
#define CMPEQ	c.eq.d
#define CMPLE	c.le.d
#define CMPLT	c.lt.d
#define	NEG	neg.d
#else
#define LD	lwc1
#define ST	swc1
#define MADD	madd.s
#define NMADD	nmadd.s
#define MSUB	msub.s
#define NMSUB	nmsub.s
#define ADD	add.s
#define SUB	sub.s
#define MUL	mul.s
#define MOV	mov.s
#define CMOVF	movf.s
#define CMOVT	movt.s
#define MTC	mtc1
#define FABS	abs.s
#define CMPEQ	c.eq.s
#define CMPLE	c.le.s
#define CMPLT	c.lt.s
#define PLU     plu.ps                                                    
#define PLL     pll.ps   
#define PUU     puu.ps    
#define PUL     pul.ps   
#define MADPS   madd.ps   
#define CVTU    cvt.s.pu    
#define CVTL    cvt.s.pl 
#define	NEG	neg.s
#endif

#if   defined(__64BIT__) &&  defined(USE64BITINT)
#define LDINT	ld
#define LDARG	ld
#define SDARG	sd
#elif defined(__64BIT__) && !defined(USE64BITINT)
#define LDINT	lw
#define LDARG	ld
#define SDARG	sd
#else
#define LDINT	lw
#define LDARG	lw
#define SDARG	sw
#endif


#ifndef F_INTERFACE
#define REALNAME ASMNAME
#else
#define REALNAME ASMFNAME
#endif

#if defined(ASSEMBLER) && !defined(NEEDPARAM)

#define PROLOGUE \
	.text ;\
	.set	mips64 ;\
	.align 5 ;\
	.globl	REALNAME ;\
	.ent	REALNAME ;\
	.type	REALNAME, @function ;\
REALNAME: ;\
	.set	noreorder ;\
	.set	nomacro

#define EPILOGUE \
	.set	macro ;\
	.set	reorder ;\
	.end	REALNAME

#define PROFCODE
#endif

#endif

#define SEEK_ADDRESS

#define BUFFER_SIZE     ( 32 << 20)

#if defined(LOONGSON3A)
#define PAGESIZE	(16UL << 10)
#define FIXED_PAGESIZE	(16UL << 10)
#endif

#if defined(LOONGSON3B)
#define PAGESIZE	(16UL << 10)
#define FIXED_PAGESIZE	(16UL << 10)
#endif

#ifndef PAGESIZE
#define PAGESIZE	(64UL << 10)
#endif
#define HUGE_PAGESIZE   ( 2 << 20)

#define BASE_ADDRESS (START_ADDRESS - BUFFER_SIZE * MAX_CPU_NUMBER)

#ifndef MAP_ANONYMOUS
#define MAP_ANONYMOUS MAP_ANON
#endif

#if defined(LOONGSON3A) || defined(LOONGSON3B)
#define PREFETCHD_(x) ld $0, x
#define PREFETCHD(x)  PREFETCHD_(x)  
#else
#define PREFETCHD(x) 
#endif

#endif
