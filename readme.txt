
Argus 3.210 (26-Mar-2001) 

Copyright (c) 1996-2001 RITLABS S.R.L.
Written by Maxim Masiutin


DESCRIPTION
-----------

Argus  is  a comprehensive FTN Mailer designed to work as a multi-line
system  using  two  widely  used  data  exchange  transports - Dial-up
networking and TCP/IP - simultaneously.

Argus     is    distributed    under    a    special    Open    Source
free-for-non-commercial  licence  (licence.txt)  which basically means
that  you are free to get and use it for non-commercial purposes, your
modifications  must be publicly-available and RITLABS may include such
modifications  into  standard  version  of  Argus. Commercial users of
Argus  must  pay  registration  fee to RITLABS. The licence permits to
derive  a product from Argus, but it may not be called "Argus" nor may
"Argus"  appear in its name, and you must put the acknowledgement that
the  product is based on Argus. However, you may charge a fee for such
new product. The licence also permits to charge a fee for the physical
act  of  transferring a copy of Argus, for installation and support of
Argus.


COMPILING
---------

Argus  was  written  in  Delphi. You need Delphi v5 (or Delphi v5 with
Update Pack #1) to compile Argus v3.206 (and later).

Peter  Sawatzki  wrote MD5 (RSA Data Security, Inc. MD5 Message-Digest
Algorithm)   implementation,  which  is  optimised  assembler  routine
(SRC/md5_386.tasm)  that needs TASM32 (Turbo Assembler Version 5.0) to
be compiled.

DES   encryption   implementation   was   written  by  Eric  Young  on
ANSI-compatible C.

PCRE  (Perl-Compatible  Regular  Expressions)  library  was written by
Philip  Hazel  on  ANSI-compatible  C  also.  The  PCRE is open source 
software, copyright by the University of Cambridge, England.

Both  DES  and  PCRE  are  compiled  by  BCC32i (Borland C++ 5.0 Win32
optimising compiler), which comes with Borland C 5.0 to compile it.

They can be also be compiled with BCC32, which comes with CBuilder (or
free  Borland  C++  5.5  command line compiler) but it doesn't support
intrinsic  functions  -  you  will need to make some modifications and
write support for the intrinsic functions in that case. I found no way
to force BCC32i to generate Delphi-compatible object-files, so Borland
C  compiler  generates ASM-files which are further compiled by TASM32.
If  you'll find a way to replace TASM32 by a free assembler (like Free
Netwide      Assembler     NASM,     which     is     available     at
http://www.kernel.org/pub/software/devel/nasm/binaries/win32/), please
drop  me  a  note.  I  also  would  like to cease from using Borland C
compilers at all in favour of other (free) compiler. Drop me a note if
you  have any idea. The problem of Borland C is that BCC32i of Borland
C  5.0 is a commercial product. BCC32 (5.5) is freely available but it
doesn't  support intrinsic functions and the generated code works much
slower comparing to BCC32i.

Compiled obj-files can be found at 
http://www.ritlabs.com/ftp/pub/argus/obj3207.rar

Providing  you  have  Delphi 5, BCC32i and TASM32 installed and in the
search   path,  change  to  SRC  directory  and  run  makeall.bat.  If
everything  went  fine,  you'll have four Argus executables in RELEASE
directory.



HOW TO CONTRIBUTE TO ARGUS
----------------------------

Development is coordinated by Max Masyutin (argus@ritlabs.com).

Argus source code base is maintained using CVS, but the public access 
to the repository (even read-only) has been temporarily suspended.

You may however download the source code from 
http://www.ritlabs.com/ftp/pub/argus/as3210.rar

If you would like to submit a patch, send it to argus@ritlabs.com with
the  string  "[PATCH]"  in  the  subject.  Please be sure to include a
textual explanation of what your patch does.

The preferred format for changes is "diff -u" output. 
