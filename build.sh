#!/bin/bash

# ==========================================================
#  Colors & Formatting
# ==========================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ==========================================================
#  Configuration
# ==========================================================
export ARCH=arm64
export defconfig="a32_kpluse_defconfig"
export DEFCONFIG_PATH="arch/arm64/configs/$defconfig"
export CLANG_PATH="$(pwd)/clang"
export OUT_DIR="$(pwd)/out"

# Compiler Flags
export KCFLAGS='-w -pipe -O3'
export KCPPFLAGS='-O3'
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

setup_env() {
    export CROSS_COMPILE=$CLANG_PATH/bin/aarch64-linux-gnu-
    export CROSS_COMPILE_ARM32=$CLANG_PATH/bin/arm-linux-gnueabi-
    export CC=$CLANG_PATH/bin/clang
    export LD=$CLANG_PATH/bin/ld.lld
    export OBJCOPY=$CLANG_PATH/bin/llvm-objcopy
    export AS=$CLANG_PATH/bin/llvm-as
    export NM=$CLANG_PATH/bin/llvm-nm
    export STRIP=$CLANG_PATH/bin/llvm-strip
    export OBJDUMP=$CLANG_PATH/bin/llvm-objdump
    export READELF=$CLANG_PATH/bin/llvm-readelf
}

header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo '                                           _              '
    echo ' _   __   ____ _   ____ ___     ____      (_)  _____   ___   '
    echo ' | | / /  / __ `/  / __ `__ \   / __ \   / /  / ___/  / _ \ '
    echo ' | |/ /  / /_/ /  / / / / / /  / /_/ /  / /  / /     /  __/ '
    echo ' |___/   \__,_/  /_/ /_/ /_/  / .___/  /_/  /_/      \___/  '
    echo '                             /_/                            '
    echo -e "${NC}"
    echo -e "${YELLOW}user:${NC} $USER"
    echo -e "${YELLOW}kernel:    ${NC} vampire"
    echo -e "${YELLOW}config:    ${NC} $defconfig"
    echo -e "${BLUE}--------------------------------------------${NC}"
}

# ==========================================================
#  Patching Functions
# ==========================================================
patch_rksu() {
    echo -e "${BLUE}[plus] wget-ing patch(es)...${NC}"
    local PATCH_URL="https://raw.githubusercontent.com/rksuorg/kernel_patches/master/manual_hook/kernel-4.14.patch"
    curl -LSs "$PATCH_URL" > rksu.patch
    
    if patch -p1 < rksu.patch; then
        echo -e "${GREEN}[tick] applied successfully.${NC}"
        rm rksu.patch
    else
        echo -e "${RED}[warn] failed, check logs please.${NC}"
        rm rksu.patch
        exit 1
    fi
}

# ==========================================================
#  KernelSU Functions
# ==========================================================
add_ksu() {
    echo -e "\n${PURPLE}[*] select kernelsu variant:${NC}"
    echo "1) kernelsu next (legacy)"
    echo "2) rsuntk kernelsu"
    echo "3) no kernelsu"
    echo "4) [hook] rksu"
    read -p "Choice [1-3]: " ksu_choice

    case $ksu_choice in
        1)
            echo -e "${GREEN}[plus] adding ksunext...${NC}"
            curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/main/kernel/setup.sh" | bash -s legacy
            ;;
        2)
            echo -e "${GREEN}[plus] adding rksu...${NC}"
            # Standard rsuntk setup (Adjust URL/command if repo changes)
            curl -LSs "https://raw.githubusercontent.com/rsuntk/KernelSU/main/kernel/setup.sh" | bash
            ;;
        3)
            patch_rksu
            ;;
        *)
            echo -e "${YELLOW}[!] skip setup kernelsu.${NC}"
            ;;
    esac
}

# ==========================================================
#  Build Logic
# ==========================================================
clone_toolchain() {
    if [ ! -d "$CLANG_PATH" ]; then
        echo -e "${BLUE}[plus] cloning clang...${NC}"
        git clone --depth=1 https://github.com/EmanuelCN/zyc_clang-14 clang
    else
        echo -e "${GREEN}[tick] clang found.${NC}"
    fi
}

run_build() {
    echo -e "${BLUE}[plus] starting build, please patient...${NC}"
    setup_env
    
    # Cleaning
    echo -e "${YELLOW}[stage 1] cleaning output...${NC}"
    make -C $(pwd) O=$OUT_DIR clean mrproper -j$(nproc)

    # Config
    echo -e "${YELLOW}[stage 2] generating defconfig...${NC}"
    make -C $(pwd) O=$OUT_DIR $defconfig -j$(nproc)

    # Compile
    echo -e "${YELLOW}[stage 3] compiling...${NC}"
    make -C $(pwd) O=$OUT_DIR -j$(nproc)

    if [ -f "$OUT_DIR/arch/arm64/boot/Image" ]; then
        echo -e "${GREEN}${BOLD}[tick] build Successful!${NC}"
        finalize
    else
        echo -e "${RED}${BOLD}[warn] build failed, please check logs.${NC}"
        exit 1
    fi
}

finalize() {
    local FINAL_OUT="$HOME/vampire_output"
    mkdir -p "$FINAL_OUT"
    
    cp "$OUT_DIR/arch/arm64/boot/Image" "$FINAL_OUT/Image"
    echo -e "${CYAN}[info] kernel image output: ${NC}$FINAL_OUT/Image"
}

# ==========================================================
#  Main Menu
# ==========================================================
header
clone_toolchain
add_ksu
run_build
