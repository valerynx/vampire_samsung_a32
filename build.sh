#!/bin/bash

# ==========================================================
#  Telegram & User Configuration
# ==========================================================
TG_TOKEN="your_bot_token_here"
TG_CHAT_ID="your_chat_id_here"
USER_NAME="ncatt"
HOST_NAME="ncatt"

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
NC='\033[0m'

# ==========================================================
#  Kernel Configuration
# ==========================================================
export ARCH=arm64
export defconfig="a32_k+e_defconfig"
export CLANG_PATH="$(pwd)/clang"
export OUT_DIR="$(pwd)/out"
export KCFLAGS='-w -pipe -O3'
export KCPPFLAGS='-O3'
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

# ==========================================================
#  UI Utilities
# ==========================================================
header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo '                 _              '
    echo ' _   __   ____ _   ____ ___     ____      (_)  _____   ___   '
    echo ' | | / /  / __ `/  / __ `__ \   / __ \   / /  / ___/  / _ \ '
    echo ' | |/ /  / /_/ /  / / / / / /  / /_/ /  / /  / /      /  __/ '
    echo ' |___/   \__,_/  /_/ /_/ /_/  / .___/  /_/  /_/       \___/  '
    echo '                             /_/                             '
    echo -e "${NC}"
    echo -e "${YELLOW}user:${NC} $USER_NAME"
    echo -e "${YELLOW}kernel:${NC} vampire"
    echo -e "${YELLOW}config:${NC} $defconfig"
    echo -e "${BLUE}--------------------------------------------${NC}"
}

show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [${CYAN}%c${NC}]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ==========================================================
#  Functions
# ==========================================================
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

patch_rksu() {
    echo -e "${BLUE}[plus] wget-ing patch...${NC}"
    curl -LSs "https://raw.githubusercontent.com/rksuorg/kernel_patches/master/manual_hook/kernel-4.14.patch" > rksu.patch
    if patch -p1 < rksu.patch; then
        echo -e "${GREEN}[tick] applied successfully.${NC}"; rm rksu.patch
    else
        echo -e "${RED}[warn] patch failed.${NC}"; rm rksu.patch; exit 1
    fi
}

add_ksu() {
    echo -e "\n${PURPLE}[*] select kernelsu variant:${NC}"
    echo "1) kernelsu next (legacy)"
    echo "2) rsuntk kernelsu"
    echo "3) [hook] rksu"
    echo "4) skip"
    read -p "Choice: " ksu_choice
    case $ksu_choice in
        1) curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/main/kernel/setup.sh" | bash -s legacy ;;
        2) curl -LSs "https://raw.githubusercontent.com/rsuntk/KernelSU/main/kernel/setup.sh" | bash ;;
        3) patch_rksu ;;
        *) echo -e "${YELLOW}[!] skip setup.${NC}" ;;
    esac
}

clone_toolchain() {
    if [ ! -d "$CLANG_PATH" ]; then
        echo -e "${BLUE}[plus] cloning clang...${NC}"
        git clone --depth=1 https://github.com/EmanuelCN/zyc_clang-14 "$CLANG_PATH"
    else
        echo -e "${GREEN}[tick] clang found.${NC}"
    fi
}

upload_to_tg() {
    local file=$1
    local K_VER=$(make kernelversion)
    echo -e "${BLUE}[plus] uploading to telegram...${NC}"

    local caption="✅ *Build Successful!*

⚙️ *Build Information:*
- *Host:* ${USER_NAME}@${HOST_NAME}
- *Kernel version:* $K_VER
- *Build type:* Debug

📄 *Notes:*
- _You're RESPONSIBLE for EVERY DAMAGE if u flash this kernel._"

    curl -F document=@"$file" \
         -F "chat_id=$TG_CHAT_ID" \
         -F "parse_mode=Markdown" \
         -F "caption=$caption" \
         "https://api.telegram.org/bot$TG_TOKEN/sendDocument" > /dev/null

    [ $? -eq 0 ] && echo -e "${GREEN}[tick] upload done.${NC}" || echo -e "${RED}[warn] upload failed.${NC}"
}

run_build() {
    setup_env
    mkdir -p "$OUT_DIR"

    echo -e "${YELLOW}[stage 1] cleaning & config...${NC}"
    make -C $(pwd) O=$OUT_DIR clean mrproper > /dev/null 2>&1
    make -C $(pwd) O=$OUT_DIR $defconfig -j$(nproc) > /dev/null 2>&1

    echo -ne "${YELLOW}[stage 2] compiling kernel...${NC}"
    make -C $(pwd) O=$OUT_DIR -j$(nproc) > build.log 2>&1 &
    local pid=$!
    show_spinner $pid
    wait $pid

    if [ -f "$OUT_DIR/arch/arm64/boot/Image" ]; then
        echo -e "\n${GREEN}${BOLD}[tick] build Successful!${NC}"
        finalize
    else
        echo -e "\n${RED}${BOLD}[warn] build failed, check build.log.${NC}"
        exit 1
    fi
}

finalize() {
    local FINAL_OUT="$HOME/vampire_output"
    mkdir -p "$FINAL_OUT"
    local BUILT_IMG="$OUT_DIR/arch/arm64/boot/Image"
    local DEST="$FINAL_OUT/Image-$(date +%Y%m%d-%H%M)"
    
    cp "$BUILT_IMG" "$DEST"
    echo -e "${CYAN}[info] kernel image: ${NC}$DEST"
    upload_to_tg "$DEST"
}

# ==========================================================
#  Main Execution
# ==========================================================
header
clone_toolchain
add_ksu
run_build
