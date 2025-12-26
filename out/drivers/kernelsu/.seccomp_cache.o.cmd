cmd_drivers/kernelsu/seccomp_cache.o := /home/tuong/vampire_samsung_a32/clang/bin/clang -Wp,-MD,drivers/kernelsu/.seccomp_cache.o.d -nostdinc -isystem /home/tuong/vampire_samsung_a32/clang/lib/clang/14.0.6/include -I../arch/arm64/include -I./arch/arm64/include/generated  -I../include -I../drivers/misc/mediatek/include -I./include -I../arch/arm64/include/uapi -I./arch/arm64/include/generated/uapi -I../include/uapi -I./include/generated/uapi -include ../include/linux/kconfig.h  -I../drivers/kernelsu -Idrivers/kernelsu -D__KERNEL__ -Qunused-arguments -mlittle-endian -DKASAN_SHADOW_SCALE_SHIFT=3 -O3 -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -fshort-wchar -Werror-implicit-function-declaration -Wno-format-security -Wno-int-conversion -std=gnu89 --target=aarch64-linux-gnu --prefix=/home/tuong/vampire_samsung_a32/clang/bin/aarch64-linux-gnu- --gcc-toolchain=/home/tuong/vampire_samsung_a32/clang -no-integrated-as -Werror=unknown-warning-option -fuse-ld=lld -fno-PIE -mno-implicit-float -DCONFIG_AS_LSE=1 -fno-asynchronous-unwind-tables -fno-pic -Wno-asm-operand-widths -DKASAN_SHADOW_SCALE_SHIFT=3 -fno-delete-null-pointer-checks -Wno-frame-address -Wno-int-in-bool-context -Wno-address-of-packed-member -O3 --param=allow-store-data-races=0 -mcpu=cortex-a55 -DCC_HAVE_ASM_GOTO -Wframe-larger-than=2800 -fstack-protector-strong -Wno-format-invalid-specifier -Wno-gnu -Wno-duplicate-decl-specifier -Wno-tautological-compare -mno-global-merge -Wno-unused-but-set-variable -Wno-unused-const-variable -fno-omit-frame-pointer -fno-optimize-sibling-calls -Wdeclaration-after-statement -Wno-pointer-sign -Wno-array-bounds -fno-strict-overflow -fno-merge-all-constants -fno-stack-check -Werror=implicit-int -Werror=strict-prototypes -Werror=date-time -Werror=incompatible-pointer-types -fmacro-prefix-map=../= -Wno-initializer-overrides -Wno-unused-value -Wno-format -Wno-sign-compare -Wno-format-zero-length -Wno-uninitialized -Wno-pointer-to-enum-cast -Wno-unaligned-access -Wno-enum-compare-conditional -Wno-enum-enum-conversion -w -pipe -O3  -I../security/selinux  -I../security/selinux/include  -I./security/selinux -include ../include/uapi/asm-generic/errno.h -DKSU_VERSION=40265 -DKSU_VERSION_FULL=\"v4.1.0-24c6cabc@builtin\" -DCONFIG_KSU_MANUAL_HOOK -DKSU_COMPAT_HAS_CURRENT_SID -DKSU_COMPAT_USE_SELINUX_STATE -DKSU_OPTIONAL_KERNEL_READ -DKSU_OPTIONAL_KERNEL_WRITE -DKSU_HAS_PATH_UMOUNT -DSAMSUNG_UH_DRIVER_EXIST -DSAMSUNG_SELINUX_PORTING -Wno-implicit-function-declaration -Wno-strict-prototypes -Wno-declaration-after-statement -Wno-unused-function -Wno-unused-variable -Wno-missing-braces -Wno-int-to-pointer-cast -Wno-declaration-after-statement    -DKBUILD_BASENAME='"seccomp_cache"'  -DKBUILD_MODNAME='"kernelsu"' -c -o drivers/kernelsu/.tmp_seccomp_cache.o ../drivers/kernelsu/seccomp_cache.c

source_drivers/kernelsu/seccomp_cache.o := ../drivers/kernelsu/seccomp_cache.c

deps_drivers/kernelsu/seccomp_cache.o := \
  ../include/linux/compiler_types.h \
    $(wildcard include/config/have/arch/compiler/h.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/enable/warn/deprecated.h) \
  ../include/linux/compiler-gcc.h \
    $(wildcard include/config/arch/supports/optimized/inlining.h) \
    $(wildcard include/config/optimize/inlining.h) \
    $(wildcard include/config/retpoline.h) \
    $(wildcard include/config/arm64.h) \
    $(wildcard include/config/gcov/kernel.h) \
    $(wildcard include/config/arch/use/builtin/bswap.h) \
  ../include/linux/compiler-clang.h \
    $(wildcard include/config/lto/clang.h) \
    $(wildcard include/config/ftrace/mcount/record.h) \
  ../include/uapi/asm-generic/errno.h \
  ../include/uapi/asm-generic/errno-base.h \
  include/generated/uapi/linux/version.h \

drivers/kernelsu/seccomp_cache.o: $(deps_drivers/kernelsu/seccomp_cache.o)

$(deps_drivers/kernelsu/seccomp_cache.o):
