
if exist ..\RELEASE\argus.exe del ..\RELEASE\argus.exe
dcc32 -DNT argus  >..\out\res.txt
if errorlevel 1 goto exit
copy ..\bin\argus.exe ..\RELEASE\argus.exe
copy ..\bin\argus.map ..\out\
del ..\bin\argus.exe

del ..\bin\argus.map
del ..\out\res.txt
:exit