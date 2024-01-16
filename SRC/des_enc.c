/* crypto/des/des_enc.c */
/* Copyright (C) 1995-1997 Eric Young (eay@mincom.oz.au)
 * All rights reserved.
 *
 * This package is an SSL implementation written
 * by Eric Young (eay@mincom.oz.au).
 * The implementation was written so as to conform with Netscapes SSL.
 * 
 * This library is free for commercial and non-commercial use as long as
 * the following conditions are aheared to.  The following conditions
 * apply to all code found in this distribution, be it the RC4, RSA,
 * lhash, DES, etc., code; not just the SSL code.  The SSL documentation
 * included with this distribution is covered by the same copyright terms
 * except that the holder is Tim Hudson (tjh@mincom.oz.au).
 * 
 * Copyright remains Eric Young's, and as such any Copyright notices in
 * the code are not to be removed.
 * If this package is used in a product, Eric Young should be given attribution
 * as the author of the parts of the library used.
 * This can be in the form of a textual message at program startup or
 * in documentation (online or textual) provided with the package.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *    "This product includes cryptographic software written by
 *     Eric Young (eay@mincom.oz.au)"
 *    The word 'cryptographic' can be left out if the rouines from the library
 *    being used are not cryptographic related :-).
 * 4. If you include any Windows specific code (or a derivative thereof) from 
 *    the apps directory (application code) you must include an acknowledgement:
 *    "This product includes software written by Tim Hudson (tjh@mincom.oz.au)"
 * 
 * THIS SOFTWARE IS PROVIDED BY ERIC YOUNG ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 * The licence and distribution terms for any publically available version or
 * derivative of this code cannot be changed.  i.e. this code cannot simply be
 * copied and put under another distribution licence
 * [including the GNU Public Licence.]
 */


#define DES_LONG unsigned long

typedef unsigned char des_cblock[8];
typedef struct des_ks_struct
        {
        union   {
                des_cblock _;
                /* make sure things are correct size on machines with
                 * 8 byte longs */
                DES_LONG pad[2];
                } ks;
#undef _
#define _       ks._
        } des_key_schedule[16];

#define DES_KEY_SZ      (sizeof(des_cblock))
#define DES_SCHEDULE_SZ (sizeof(des_key_schedule))

#define c2l(c,l)        (l =((DES_LONG)(*((c)++))),l|=((DES_LONG)(*((c)++)))<< 8L,l|=((DES_LONG)(*((c)++)))<<16L,l|=((DES_LONG)(*((c)++)))<<24L)  
#define PERM_OP(a,b,t,n,m) ((t)=((((a)>>(n))^(b))&(m)),(b)^=(t),(a)^=((t)<<(n)))
#define ITERATIONS 16

#define ROTATE(a,n)     (((a)>>(n))|((a)<<(32-(n))))



/* NOTE - c is not incremented as per c2l */
#define c2ln(c,l1,l2,n) { \
                        c+=n; \
                        l1=l2=0; \
                        switch (n) { \
                        case 8: l2 =((DES_LONG)(*(--(c))))<<24L; \
                        case 7: l2|=((DES_LONG)(*(--(c))))<<16L; \
                        case 6: l2|=((DES_LONG)(*(--(c))))<< 8L; \
                        case 5: l2|=((DES_LONG)(*(--(c))));     \
                        case 4: l1 =((DES_LONG)(*(--(c))))<<24L; \
                        case 3: l1|=((DES_LONG)(*(--(c))))<<16L; \
                        case 2: l1|=((DES_LONG)(*(--(c))))<< 8L; \
                        case 1: l1|=((DES_LONG)(*(--(c))));     \
                                } \
                        }

#define l2c(l,c)        (*((c)++)=(unsigned char)(((l)     )&0xff), \
                         *((c)++)=(unsigned char)(((l)>> 8L)&0xff), \
                         *((c)++)=(unsigned char)(((l)>>16L)&0xff), \
                         *((c)++)=(unsigned char)(((l)>>24L)&0xff))

/* replacements for htonl and ntohl since I have no idea what to do
 * when faced with machines with 8 byte longs. */
#define HDRSIZE 4

#define n2l(c,l)        (l =((DES_LONG)(*((c)++)))<<24L, \
                         l|=((DES_LONG)(*((c)++)))<<16L, \
                         l|=((DES_LONG)(*((c)++)))<< 8L, \
                         l|=((DES_LONG)(*((c)++))))

#define l2n(l,c)        (*((c)++)=(unsigned char)(((l)>>24L)&0xff), \
                         *((c)++)=(unsigned char)(((l)>>16L)&0xff), \
                         *((c)++)=(unsigned char)(((l)>> 8L)&0xff), \
                         *((c)++)=(unsigned char)(((l)     )&0xff))

/* NOTE - c is not incremented as per l2c */
#define l2cn(l1,l2,c,n) { \
                        c+=n; \
                        switch (n) { \
                        case 8: *(--(c))=(unsigned char)(((l2)>>24L)&0xff); \
                        case 7: *(--(c))=(unsigned char)(((l2)>>16L)&0xff); \
                        case 6: *(--(c))=(unsigned char)(((l2)>> 8L)&0xff); \
                        case 5: *(--(c))=(unsigned char)(((l2)     )&0xff); \
                        case 4: *(--(c))=(unsigned char)(((l1)>>24L)&0xff); \
                        case 3: *(--(c))=(unsigned char)(((l1)>>16L)&0xff); \
                        case 2: *(--(c))=(unsigned char)(((l1)>> 8L)&0xff); \
                        case 1: *(--(c))=(unsigned char)(((l1)     )&0xff); \
                                } \
                        }


/* Don't worry about the LOAD_DATA() stuff, that is used by
 * fcrypt() to add it's little bit to the front */

#ifdef DES_FCRYPT

#define LOAD_DATA_tmp(R,S,u,t,E0,E1) \
        { DES_LONG tmp; LOAD_DATA(R,S,u,t,E0,E1,tmp); }

#define LOAD_DATA(R,S,u,t,E0,E1,tmp) \
        t=R^(R>>16L); \
        u=t&E0; t&=E1; \
        tmp=(u<<16); u^=R^s[S  ]; u^=tmp; \
        tmp=(t<<16); t^=R^s[S+1]; t^=tmp
#else
#define LOAD_DATA_tmp(a,b,c,d,e,f) LOAD_DATA(a,b,c,d,e,f,g)
#define LOAD_DATA(R,S,u,t,E0,E1,tmp) \
        u=R^s[S  ]; \
        t=R^s[S+1]
#endif

/* The changes to this macro may help or hinder, depending on the
 * compiler and the achitecture.  gcc2 always seems to do well :-).
 * Inspired by Dana How <how@isl.stanford.edu>
 * DO NOT use the alternative version on machines with 8 byte longs.
 * It does not seem to work on the Alpha, even when DES_LONG is 4
 * bytes, probably an issue of accessing non-word aligned objects :-( */
#ifdef DES_PTR

/* It recently occured to me that 0^0^0^0^0^0^0 == 0, so there
 * is no reason to not xor all the sub items together.  This potentially
 * saves a register since things can be xored directly into L */

#if defined(DES_RISC1) || defined(DES_RISC2)
#ifdef DES_RISC1
#define D_ENCRYPT(LL,R,S) { \
        unsigned int u1,u2,u3; \
        LOAD_DATA(R,S,u,t,E0,E1,u1); \
        u2=(int)u>>8L; \
        u1=(int)u&0xfc; \
        u2&=0xfc; \
        t=ROTATE(t,4); \
        u>>=16L; \
        LL^= *(DES_LONG *)((unsigned char *)des_SP      +u1); \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x200+u2); \
        u3=(int)(u>>8L); \
        u1=(int)u&0xfc; \
        u3&=0xfc; \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x400+u1); \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x600+u3); \
        u2=(int)t>>8L; \
        u1=(int)t&0xfc; \
        u2&=0xfc; \
        t>>=16L; \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x100+u1); \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x300+u2); \
        u3=(int)t>>8L; \
        u1=(int)t&0xfc; \
        u3&=0xfc; \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x500+u1); \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x700+u3); }
#endif
#ifdef DES_RISC2
#define D_ENCRYPT(LL,R,S) { \
        unsigned int u1,u2,s1,s2; \
        LOAD_DATA(R,S,u,t,E0,E1,u1); \
        u2=(int)u>>8L; \
        u1=(int)u&0xfc; \
        u2&=0xfc; \
        t=ROTATE(t,4); \
        LL^= *(DES_LONG *)((unsigned char *)des_SP      +u1); \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x200+u2); \
        s1=(int)(u>>16L); \
        s2=(int)(u>>24L); \
        s1&=0xfc; \
        s2&=0xfc; \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x400+s1); \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x600+s2); \
        u2=(int)t>>8L; \
        u1=(int)t&0xfc; \
        u2&=0xfc; \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x100+u1); \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x300+u2); \
        s1=(int)(t>>16L); \
        s2=(int)(t>>24L); \
        s1&=0xfc; \
        s2&=0xfc; \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x500+s1); \
        LL^= *(DES_LONG *)((unsigned char *)des_SP+0x700+s2); }
#endif
#else
#define D_ENCRYPT(LL,R,S) { \
        LOAD_DATA_tmp(R,S,u,t,E0,E1); \
        t=ROTATE(t,4); \
        LL^= \
        *(DES_LONG *)((unsigned char *)des_SP      +((u     )&0xfc))^ \
        *(DES_LONG *)((unsigned char *)des_SP+0x200+((u>> 8L)&0xfc))^ \
        *(DES_LONG *)((unsigned char *)des_SP+0x400+((u>>16L)&0xfc))^ \
        *(DES_LONG *)((unsigned char *)des_SP+0x600+((u>>24L)&0xfc))^ \
        *(DES_LONG *)((unsigned char *)des_SP+0x100+((t     )&0xfc))^ \
        *(DES_LONG *)((unsigned char *)des_SP+0x300+((t>> 8L)&0xfc))^ \
        *(DES_LONG *)((unsigned char *)des_SP+0x500+((t>>16L)&0xfc))^ \
        *(DES_LONG *)((unsigned char *)des_SP+0x700+((t>>24L)&0xfc)); }
#endif

#else /* original version */

#if defined(DES_RISC1) || defined(DES_RISC2)
#ifdef DES_RISC1
#define D_ENCRYPT(LL,R,S) {\
        unsigned int u1,u2,u3; \
        LOAD_DATA(R,S,u,t,E0,E1,u1); \
        u>>=2L; \
        t=ROTATE(t,6); \
        u2=(int)u>>8L; \
        u1=(int)u&0x3f; \
        u2&=0x3f; \
        u>>=16L; \
        LL^=des_SPtrans[0][u1]; \
        LL^=des_SPtrans[2][u2]; \
        u3=(int)u>>8L; \
        u1=(int)u&0x3f; \
        u3&=0x3f; \
        LL^=des_SPtrans[4][u1]; \
        LL^=des_SPtrans[6][u3]; \
        u2=(int)t>>8L; \
        u1=(int)t&0x3f; \
        u2&=0x3f; \
        t>>=16L; \
        LL^=des_SPtrans[1][u1]; \
        LL^=des_SPtrans[3][u2]; \
        u3=(int)t>>8L; \
        u1=(int)t&0x3f; \
        u3&=0x3f; \
        LL^=des_SPtrans[5][u1]; \
        LL^=des_SPtrans[7][u3]; }
#endif
#ifdef DES_RISC2
#define D_ENCRYPT(LL,R,S) {\
        unsigned int u1,u2,s1,s2; \
        LOAD_DATA(R,S,u,t,E0,E1,u1); \
        u>>=2L; \
        t=ROTATE(t,6); \
        u2=(int)u>>8L; \
        u1=(int)u&0x3f; \
        u2&=0x3f; \
        LL^=des_SPtrans[0][u1]; \
        LL^=des_SPtrans[2][u2]; \
        s1=(int)u>>16L; \
        s2=(int)u>>24L; \
        s1&=0x3f; \
        s2&=0x3f; \
        LL^=des_SPtrans[4][s1]; \
        LL^=des_SPtrans[6][s2]; \
        u2=(int)t>>8L; \
        u1=(int)t&0x3f; \
        u2&=0x3f; \
        LL^=des_SPtrans[1][u1]; \
        LL^=des_SPtrans[3][u2]; \
        s1=(int)t>>16; \
        s2=(int)t>>24L; \
        s1&=0x3f; \
        s2&=0x3f; \
        LL^=des_SPtrans[5][s1]; \
        LL^=des_SPtrans[7][s2]; }
#endif

#else

#define D_ENCRYPT(LL,R,S) {\
        LOAD_DATA_tmp(R,S,u,t,E0,E1); \
        t=ROTATE(t,4); \
        LL^=\
                des_SPtrans[0][(u>> 2L)&0x3f]^ \
                des_SPtrans[2][(u>>10L)&0x3f]^ \
                des_SPtrans[4][(u>>18L)&0x3f]^ \
                des_SPtrans[6][(u>>26L)&0x3f]^ \
                des_SPtrans[1][(t>> 2L)&0x3f]^ \
                des_SPtrans[3][(t>>10L)&0x3f]^ \
                des_SPtrans[5][(t>>18L)&0x3f]^ \
                des_SPtrans[7][(t>>26L)&0x3f]; }
#endif
#endif

        /* IP and FP
         * The problem is more of a geometric problem that random bit fiddling.
         0  1  2  3  4  5  6  7      62 54 46 38 30 22 14  6
         8  9 10 11 12 13 14 15      60 52 44 36 28 20 12  4
        16 17 18 19 20 21 22 23      58 50 42 34 26 18 10  2
        24 25 26 27 28 29 30 31  to  56 48 40 32 24 16  8  0

        32 33 34 35 36 37 38 39      63 55 47 39 31 23 15  7
        40 41 42 43 44 45 46 47      61 53 45 37 29 21 13  5
        48 49 50 51 52 53 54 55      59 51 43 35 27 19 11  3
        56 57 58 59 60 61 62 63      57 49 41 33 25 17  9  1

        The output has been subject to swaps of the form
        0 1 -> 3 1 but the odd and even bits have been put into
        2 3    2 0
        different words.  The main trick is to remember that
        t=((l>>size)^r)&(mask);
        r^=t;
        l^=(t<<size);
        can be used to swap and move bits between words.

        So l =  0  1  2  3  r = 16 17 18 19
                4  5  6  7      20 21 22 23
                8  9 10 11      24 25 26 27
               12 13 14 15      28 29 30 31
        becomes (for size == 2 and mask == 0x3333)
           t =   2^16  3^17 -- --   l =  0  1 16 17  r =  2  3 18 19
                 6^20  7^21 -- --        4  5 20 21       6  7 22 23
                10^24 11^25 -- --        8  9 24 25      10 11 24 25
                14^28 15^29 -- --       12 13 28 29      14 15 28 29

        Thanks for hints from Richard Outerbridge - he told me IP&FP
        could be done in 15 xor, 10 shifts and 5 ands.
        When I finally started to think of the problem in 2D
        I first got ~42 operations without xors.  When I remembered
        how to use xors :-) I got it to its final state.
        */

#define IP(l,r) \
        { \
        register DES_LONG tt; \
        PERM_OP(r,l,tt, 4,0x0f0f0f0fL); \
        PERM_OP(l,r,tt,16,0x0000ffffL); \
        PERM_OP(r,l,tt, 2,0x33333333L); \
        PERM_OP(l,r,tt, 8,0x00ff00ffL); \
        PERM_OP(r,l,tt, 1,0x55555555L); \
        }

#define FP(l,r) \
        { \
        register DES_LONG tt; \
        PERM_OP(l,r,tt, 1,0x55555555L); \
        PERM_OP(r,l,tt, 8,0x00ff00ffL); \
        PERM_OP(l,r,tt, 2,0x33333333L); \
        PERM_OP(r,l,tt,16,0x0000ffffL); \
        PERM_OP(l,r,tt, 4,0x0f0f0f0fL); \
        }

extern const DES_LONG des_SPtrans[8][64];

void des_encrypt(DES_LONG *data,des_key_schedule ks, int enc);


void des_encrypt(data, ks, encrypt)
DES_LONG *data;
des_key_schedule ks;
int encrypt;
        {
        register DES_LONG l,r,t,u;
#ifdef DES_PTR
        register unsigned char *des_SP=(unsigned char *)des_SPtrans;
#endif
        register DES_LONG *s;

        r=data[0];
        l=data[1];

        IP(r,l);
        /* Things have been modified so that the initial rotate is
         * done outside the loop.  This required the
         * des_SPtrans values in sp.h to be rotated 1 bit to the right.
         * One perl script later and things have a 5% speed up on a sparc2.
         * Thanks to Richard Outerbridge <71755.204@CompuServe.COM>
         * for pointing this out. */
        /* clear the top bits on machines with 8byte longs */
        /* shift left by 2 */
        r=ROTATE(r,29)&0xffffffffL;
        l=ROTATE(l,29)&0xffffffffL;

        s=(DES_LONG *)ks;
        /* I don't know if it is worth the effort of loop unrolling the
         * inner loop */
        if (encrypt)
                {
                D_ENCRYPT(l,r, 0); /*  1 */
                D_ENCRYPT(r,l, 2); /*  2 */
                D_ENCRYPT(l,r, 4); /*  3 */
                D_ENCRYPT(r,l, 6); /*  4 */
                D_ENCRYPT(l,r, 8); /*  5 */
                D_ENCRYPT(r,l,10); /*  6 */
                D_ENCRYPT(l,r,12); /*  7 */
                D_ENCRYPT(r,l,14); /*  8 */
                D_ENCRYPT(l,r,16); /*  9 */
                D_ENCRYPT(r,l,18); /*  10 */
                D_ENCRYPT(l,r,20); /*  11 */
                D_ENCRYPT(r,l,22); /*  12 */
                D_ENCRYPT(l,r,24); /*  13 */
                D_ENCRYPT(r,l,26); /*  14 */
                D_ENCRYPT(l,r,28); /*  15 */
                D_ENCRYPT(r,l,30); /*  16 */
                }
        else
                {
                D_ENCRYPT(l,r,30); /* 16 */
                D_ENCRYPT(r,l,28); /* 15 */
                D_ENCRYPT(l,r,26); /* 14 */
                D_ENCRYPT(r,l,24); /* 13 */
                D_ENCRYPT(l,r,22); /* 12 */
                D_ENCRYPT(r,l,20); /* 11 */
                D_ENCRYPT(l,r,18); /* 10 */
                D_ENCRYPT(r,l,16); /*  9 */
                D_ENCRYPT(l,r,14); /*  8 */
                D_ENCRYPT(r,l,12); /*  7 */
                D_ENCRYPT(l,r,10); /*  6 */
                D_ENCRYPT(r,l, 8); /*  5 */
                D_ENCRYPT(l,r, 6); /*  4 */
                D_ENCRYPT(r,l, 4); /*  3 */
                D_ENCRYPT(l,r, 2); /*  2 */
                D_ENCRYPT(r,l, 0); /*  1 */
                }

        /* rotate and clear the top bits on machines with 8byte longs */
        l=ROTATE(l,3)&0xffffffffL;
        r=ROTATE(r,3)&0xffffffffL;

        FP(r,l);
        data[0]=l;
        data[1]=r;
        l=r=t=u=0;
        }


void des_ncbc_encrypt(input, output, schedule, ivec, encrypt)
des_cblock (*input);
des_cblock (*output);
des_key_schedule schedule;
des_cblock (*ivec);
int encrypt;
	{
	register DES_LONG tin0,tin1;
	register DES_LONG tout0,tout1,xor0,xor1;
	register unsigned char *in,*out;
	DES_LONG tin[2];
	unsigned char *iv;

	in=(unsigned char *)input;
	out=(unsigned char *)output;
	iv=(unsigned char *)ivec;

	if (encrypt)
		{
		c2l(iv,tout0);
		c2l(iv,tout1);
				c2l(in,tin0);
				c2l(in,tin1);
			tin0^=tout0; tin[0]=tin0;
			tin1^=tout1; tin[1]=tin1;
			des_encrypt((DES_LONG *)tin,schedule,1);
			tout0=tin[0]; l2c(tout0,out);
			tout1=tin[1]; l2c(tout1,out);
		iv=(unsigned char *)ivec;
		l2c(tout0,iv);
		l2c(tout1,iv);
		}
	else
		{
		c2l(iv,xor0);
		c2l(iv,xor1);
			c2l(in,tin0); tin[0]=tin0;
			c2l(in,tin1); tin[1]=tin1;
			des_encrypt((DES_LONG *)tin,schedule,0);
			tout0=tin[0]^xor0;
			tout1=tin[1]^xor1;
				l2c(tout0,out);
				l2c(tout1,out);
			xor0=tin0;
			xor1=tin1;
		iv=(unsigned char *)ivec;
		l2c(xor0,iv);
		l2c(xor1,iv);
		}
	tin0=tin1=tout0=tout1=xor0=xor1=0;
	tin[0]=tin[1]=0;
	}

