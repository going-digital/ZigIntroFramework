::: Build zig
setlocal
cd tmp
zig build-obj -target x86-windows-gnu -O ReleaseSmall -fsingle-threaded ..\src\main.zig
endlocal
if %errorlevel% neq 0 exit /b %errorlevel%

::: Crinkler link
set LIB=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.38.33130\ATLMFC\lib\x86;C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.38.33130\lib\x86;C:\Program Files (x86)\Windows Kits\10\lib\10.0.22000.0\ucrt\x86;C:\Program Files (x86)\Windows Kits\10\\lib\10.0.22000.0\\um\x86
tools\crinkler /out:bin\test.exe /subsystem:windows /print:imports /print:labels /range:opengl32 /compmode:slow /ordertries:1000 tmp\main.obj kernel32.lib user32.lib gdi32.lib opengl32.lib winmm.lib /report:bin\test.html

::: Clean up build files
del /q tmp\*.*
del /q src\packed.frag
