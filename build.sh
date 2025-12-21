#!/bin/bash

# ==========================================================
#  Clang & defconfig info
# ==========================================================
export defconfig="arch/arm64/configs/a32_k+e_defconfig"

export CROSS_COMPILE=clang/bin/aarch64-linux-gnu-
export LD=clang/bin/ld.lld
export OBJCOPY=clang/bin/llvm-objcopy
export AS=clang/bin/llvm-as
export NM=clang/bin/llvm-nm
export STRIP=clang/bin/llvm-strip
export OBJDUMP=clang/bin/llvm-objdump
export READELF=clang/bin/llvm-readelf
export CC=clang/bin/clang
export CROSS_COMPILE_ARM32=clang/bin/arm-linux-gnueabi-
export ARCH=arm64
export ANDROID_MAJOR_VERSION=r

export KCFLAGS=' -w -pipe -O3'
export KCPPFLAGS=' -O3'
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

echo "                              _         "
echo " _   ______ _____ ___  ____  (_)_______ "
echo "| | / / __ `/ __ `__ \/ __ \/ / ___/ _ \ "
echo "| |/ / /_/ / / / / / / /_/ / / /  /  __/ "
echo "|___/\__,_/_/ /_/ /_/ .___/_/_/   \___/ "
echo "                   /_/                  "

echo "Have a nice day, $USER!"

echo "Infomation:"
echo "kernel: vampire | version: 4.14.356 | config: $defconfig"

echo "Building, please wait."

make -C $(pwd) O=$(pwd)/out KCFLAGS=' -w -pipe -O3' CONFIG_SECTION_MISMATCH_WARN_ONLY=y clean -j$(nproc) && make -C $(pwd) O=$(pwd)/out KCFLAGS='-w -O3' CONFIG_SECTION_MISMATCH_WARN_ONLY=y mrproper -j$(nproc)
clear
make -C $(pwd) O=$(pwd)/out KCFLAGS=' -w -pipe -O3' CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc) $defconfig
make -C $(pwd) O=$(pwd)/out KCFLAGS=' -w -pipe -O3' CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc)

#to copy all the kernel modules (.ko) to "modules" folder.
#mkdir -p modules
#find . -type f -name "*.ko" -exec cp -n {} modules \;
#echo "Module files copied to the 'modules' folder."
echo "Creating out folder in your home."
mkdir $HOME/out

echo "Copying to out folder!"
cp out/arch/arm64/boot/Image $(pwd)/arch/arm64/boot/Image
cp out/arch/arm64/boot/Image $HOME/out

echo "Build done! Your out image file ís on $HOME/out"
