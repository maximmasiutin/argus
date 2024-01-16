del des_enc.obj
del set_key.obj
del sp_trans.obj
del md5_386.obj
del pcre.obj

call .\cc des_enc.c
tasm32 /m des_enc.asm,des_enc.obj
del des_enc.asm

call .\cc set_key.c
tasm32 /m set_key.asm,set_key.obj
del set_key.asm

call .\cc pcre.c
tasm32 /m pcre.asm,pcre.obj
del pcre.asm

tasm32 /m sp_trans.tasm,sp_trans.obj
tasm32 /m md5_386.tasm,md5_386.obj

