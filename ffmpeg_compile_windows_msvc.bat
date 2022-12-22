REM Dev Stef - 2022

REM install Microsoft Visual Studio Build Tools from https://aka.ms/vs/17/release/vs_BuildTools.exe
REM install msys2 https://www.msys2.org/ or download the installer from here https://github.com/msys2/msys2-installer/releases

@echo off

REM From the MSYS2 console
echo Getting the right packages from msys
pacman -Syu
pacman -S make git diffutils nasm yasm pkgconf
mv /usr/bin/link.exe /usr/bin/link.exe.bak


cd %userprofile%
mkdir tmp
cd tmp
mkdir sources
mkdir build
cd sources

REM Make sure you opened the x64 Native Tools Command Prompt for VS 2022 and then opened MSYS2 shell command
echo Getting libx264...
git clone https://code.videolan.org/videolan/x264.git

cd tmp/sources/x264
curl "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" > config.guess
sed -i 's/host_os = mingw/host_os = msys/' configure

cd tmp/build
mkdir x264
cd x264
 
CC=cl ../../sources/x264/configure --prefix=../../installed --enable-static
make -j 4
make install

echo Compiling ffmpeg...
git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg


CC=cl PKG_CONFIG_PATH=../../installed/lib/pkgconfig ../../sources/ffmpeg/configure --prefix=../../installed --toolchain=msvc --arch=x86_64 --enable-yasm --enable-asm --disable-shared --enable-static --enable-libx264 --enable-gpl --enable-nonfree --enable-debug --extra-ldflags="-LIBPATH:../../installed/lib" --extra-cflags="-I../../installed/include/"
make -j 4
REM make install