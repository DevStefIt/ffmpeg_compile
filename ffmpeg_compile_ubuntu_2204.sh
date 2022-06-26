echo System updating...
sudo apt update && sudo apt upgrade

echo Getting all the dependencies...
sudo apt install -y autoconf \
automake \
build-essential \
cmake \
git-core \
libass-dev \
libfreetype6-dev \
libgnutls28-dev \
libmp3lame-dev \
libsdl2-dev \
libtool \
libva-dev \
libvdpau-dev \
libvorbis-dev \
libxcb1-dev \
libxcb-shm0-dev \
libxcb-xfixes0-dev \
meson \
ninja-build \
pkg-config \
texinfo \
wget \
yasm \
zlib1g-dev

sudo apt install libunistring-dev
sudo apt install nasm

# The following line has been removed since the following codecs do not work properly
#sudo apt install libaom-dev libdav1d-dev

echo Getting libx264...
sudo apt install libx264-dev

echo Getting libx265...
sudo apt install libx265-dev libnuma-dev

echo Getting libvpx...
sudo apt install libvpx-dev

echo Getting aac...
sudo apt install libfdk-aac-dev

echo Getting libopus...
sudo apt install libopus-dev

echo making the necessary folders...
mkdir -pv ~/ffmpeg_sources ~/ffmpeg_build

echo Compiling libaom...
cd ~/ffmpeg_sources && \
git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
mkdir -pv aom_build && \
cd aom_build && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_TESTS=OFF -DENABLE_NASM=on ../aom && \
PATH="$HOME/bin:$PATH" make && \
make install
cd ~

echo Compiling SVT-AV1...
cd ~/ffmpeg_sources && \
git -C SVT-AV1 pull 2> /dev/null || git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git && \
mkdir -pv SVT-AV1/build && \
cd SVT-AV1/build && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF .. && \
PATH="$HOME/bin:$PATH" make && \
make install
cd ~

echo Compiling libdav1d...
cd ~/ffmpeg_sources && \
git -C dav1d pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/dav1d.git && \
mkdir -p dav1d/build && \
cd dav1d/build && \
meson setup -Denable_tools=false -Denable_tests=false --default-library=static .. --prefix "$HOME/ffmpeg_build" --libdir="$HOME/ffmpeg_build/lib" && \
ninja && \
ninja install
cd ~

echo Compiling vmaf...
cd ~/ffmpeg_sources && \
wget https://github.com/Netflix/vmaf/archive/v2.1.1.tar.gz && \
tar xvf v2.1.1.tar.gz && \
mkdir -pv vmaf-2.1.1/libvmaf/build &&\
cd vmaf-2.1.1/libvmaf/build && \
meson setup -Denable_tests=false -Denable_docs=false --buildtype=release --default-library=static .. --prefix "$HOME/ffmpeg_build" --bindir="$HOME/ffmpeg_build/bin" --libdir="$HOME/ffmpeg_build/lib" && \
ninja && \
ninja install
cd ~

#echo Creating folder where to put the binaries
#mkdir -pv ~/bin

git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
cd ffmpeg && \
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --enable-debug=3 \
  --disable-optimizations \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --extra-libs="-lpthread -lm" \
  --ld="g++" \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-gnutls \
  --enable-libaom \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libsvtav1 \
  --enable-libdav1d \
  --enable-libsvtav1 \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree && \
PATH="$HOME/bin:$PATH" make -j2
# make install
hash -r