LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_CPP_EXTENSION := .cc
LOCAL_MODULE := libglmark2-matrix
LOCAL_CFLAGS := -DGLMARK2_USE_GLESv2 -Wall -Wextra -Wnon-virtual-dtor \
                -Wno-error=unused-parameter
LOCAL_C_INCLUDES := $(LOCAL_PATH)/src
LOCAL_SRC_FILES := $(subst $(LOCAL_PATH)/,,$(wildcard $(LOCAL_PATH)/src/libmatrix/*.cc))

include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := libglmark2-png
LOCAL_SRC_FILES := $(subst $(LOCAL_PATH)/,,$(wildcard $(LOCAL_PATH)/src/libpng/*.c))

include $(BUILD_STATIC_LIBRARY)

#
# Removed libglmark2-jpeg and moved to glmark2/libglmark2-jpeg
# In Android 6 and earlier versions, external/jpeg is used.
# From Android 7 and above, external/libjpeg-turbo is used.
# There are conflicts between jpeg and libjpeg-turbo, to use libjpeg-turbo
# in Android 6 and earlier versions, we use libglmark2-jpeg. In Android 7
# or above, external/libjpeg-turbo can be used.
#
include $(CLEAR_VARS)

# By default, the build system generates ARM target binaries in thumb mode,
# where each instruction is 16 bits wide.  Defining this variable as arm
# forces the build system to generate object files in 32-bit arm mode.  This
# is the same setting previously used by libjpeg.
# TODO (msarett): Run performance tests to determine whether arm mode is still
#                 preferred to thumb mode for libjpeg-turbo.
LOCAL_ARM_MODE := arm

JPEG_PATH := ../$(LOCAL_PATH)
LOCAL_SRC_FILES := \
    $(JPEG_PATH)/src/libglmark2-jpeg/jcapimin.c $(JPEG_PATH)/src/libglmark2-jpeg/jcapistd.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jccoefct.c $(JPEG_PATH)/src/libglmark2-jpeg/jccolor.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jcdctmgr.c $(JPEG_PATH)/src/libglmark2-jpeg/jchuff.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jcinit.c $(JPEG_PATH)/src/libglmark2-jpeg/jcmainct.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jcmarker.c $(JPEG_PATH)/src/libglmark2-jpeg/jcmaster.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jcomapi.c $(JPEG_PATH)/src/libglmark2-jpeg/jcparam.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jcphuff.c $(JPEG_PATH)/src/libglmark2-jpeg/jcprepct.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jcsample.c $(JPEG_PATH)/src/libglmark2-jpeg/jctrans.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jdapimin.c $(JPEG_PATH)/src/libglmark2-jpeg/jdapistd.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jdatadst.c $(JPEG_PATH)/src/libglmark2-jpeg/jdatasrc.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jdcoefct.c $(JPEG_PATH)/src/libglmark2-jpeg/jdcolor.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jddctmgr.c $(JPEG_PATH)/src/libglmark2-jpeg/jdhuff.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jdinput.c $(JPEG_PATH)/src/libglmark2-jpeg/jdmainct.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jdmarker.c $(JPEG_PATH)/src/libglmark2-jpeg/jdmaster.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jdmerge.c $(JPEG_PATH)/src/libglmark2-jpeg/jdphuff.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jdpostct.c $(JPEG_PATH)/src/libglmark2-jpeg/jdsample.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jdtrans.c $(JPEG_PATH)/src/libglmark2-jpeg/jerror.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jfdctflt.c $(JPEG_PATH)/src/libglmark2-jpeg/jfdctfst.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jfdctint.c $(JPEG_PATH)/src/libglmark2-jpeg/jidctflt.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jidctfst.c $(JPEG_PATH)/src/libglmark2-jpeg/jidctint.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jidctred.c $(JPEG_PATH)/src/libglmark2-jpeg/jmemmgr.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jmemnobs.c $(JPEG_PATH)/src/libglmark2-jpeg/jquant1.c \
    $(JPEG_PATH)/src/libglmark2-jpeg/jquant2.c $(JPEG_PATH)/src/libglmark2-jpeg/jutils.c

# ARM v7 NEON
LOCAL_SRC_FILES_arm += $(JPEG_PATH)/src/libglmark2-jpeg/simd/jsimd_arm_neon.S \
    $(JPEG_PATH)/src/libglmark2-jpeg/simd/jsimd_arm.c

# If we are certain that the ARM v7 device has NEON (and there is no need for
# a runtime check), we can indicate that with a flag.
ifeq ($(strip $(TARGET_ARCH)),arm)
  ifeq ($(ARCH_ARM_HAVE_NEON),true)
    LOCAL_CFLAGS += -D__ARM_HAVE_NEON__
  endif
endif

# ARM v8 64-bit NEON
LOCAL_SRC_FILES_arm64 += $(JPEG_PATH)/src/libglmark2-jpeg/simd/jsimd_arm64_neon.S \
    $(JPEG_PATH)/src/libglmark2-jpeg/simd/jsimd_arm64.c

# x86 MMX and SSE2
LOCAL_SRC_FILES_x86 += \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jsimd_i386.c $(JPEG_PATH)/src/libglmark2-jpeg/simd/jccolor-mmx.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jccolor-sse2.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jcgray-mmx.asm  \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jcgray-sse2.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jcsample-mmx.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jcsample-sse2.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jdcolor-mmx.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jdcolor-sse2.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jdmerge-mmx.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jdmerge-sse2.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jdsample-mmx.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jdsample-sse2.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jfdctflt-3dn.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jfdctflt-sse.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jfdctfst-mmx.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jfdctfst-sse2.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jfdctint-mmx.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jfdctint-sse2.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jidctflt-3dn.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jidctflt-sse2.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jidctflt-sse.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jidctfst-mmx.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jidctfst-sse2.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jidctint-mmx.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jidctint-sse2.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jidctred-mmx.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jidctred-sse2.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jquant-3dn.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jquantf-sse2.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jquanti-sse2.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jquant-mmx.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jquant-sse.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jsimdcpu.asm
LOCAL_ASFLAGS_x86 += -DPIC -DELF
LOCAL_C_INCLUDES_x86 += $(JPEG_PATH)/src/libglmark2-jpeg/simd

# x86-64 SSE2
LOCAL_SRC_FILES_x86_64 += \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jsimd_x86_64.c $(JPEG_PATH)/src/libglmark2-jpeg/simd/jccolor-sse2-64.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jcgray-sse2-64.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jcsample-sse2-64.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jdcolor-sse2-64.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jdmerge-sse2-64.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jdsample-sse2-64.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jfdctflt-sse-64.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jfdctfst-sse2-64.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jfdctint-sse2-64.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jidctflt-sse2-64.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jidctfst-sse2-64.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jidctint-sse2-64.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jidctred-sse2-64.asm \
      $(JPEG_PATH)/src/libglmark2-jpeg/simd/jquantf-sse2-64.asm $(JPEG_PATH)/src/libglmark2-jpeg/simd/jquanti-sse2-64.asm

LOCAL_ASFLAGS_x86_64 += -D__x86_64__ -DPIC -DELF
LOCAL_C_INCLUDES_x86_64 += $(LOCAL_PATH)/src/libglmark2-jpeg/simd

LOCAL_SRC_FILES_mips += $(JPEG_PATH)/src/libglmark2-jpeg/jsimd_none.c
LOCAL_SRC_FILES_mips64 += $(JPEG_PATH)/src/libglmark2-jpeg/jsimd_none.c

LOCAL_CFLAGS += -O3 -fstrict-aliasing
LOCAL_CFLAGS += -Wno-unused-parameter
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/src/libglmark2-jpeg

ifneq (,$(TARGET_BUILD_APPS))
  # Unbundled branch, built against NDK.
  LOCAL_SDK_VERSION := 17
endif

ifeq ($(strip $(TARGET_ARCH)),x86_64)
    LOCAL_ASMFLAGS += $(LOCAL_ASFLAGS_x86_64)
    LOCAL_SRC_FILES += $(LOCAL_SRC_FILES_x86_64)
    LOCAL_C_INCLUDES := $(LOCAL_PATH)/src/libglmark2-jpeg $(LOCAL_C_INCLUDES_x86_64) 
endif

# Build as a static library.
LOCAL_MODULE := libglmark2-jpeg
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_CPP_EXTENSION := .cc
LOCAL_MODULE := libglmark2-ideas
LOCAL_CFLAGS := -DGLMARK_DATA_PATH="" -DGLMARK2_USE_GLESv2  -Wall -Wextra\
                -Wnon-virtual-dtor -Wno-error=unused-parameter
LOCAL_C_INCLUDES := $(LOCAL_PATH)/src \
                    $(LOCAL_PATH)/src/libmatrix
LOCAL_SRC_FILES := $(subst $(LOCAL_PATH)/,,$(wildcard $(LOCAL_PATH)/src/scene-ideas/*.cc))

include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libglmark2-android
LOCAL_STATIC_LIBRARIES := libglmark2-matrix libglmark2-png libglmark2-ideas libglmark2-jpeg
LOCAL_CFLAGS := -DGLMARK_DATA_PATH="" -DGLMARK_VERSION="\"2014.03\"" \
                -DGLMARK2_USE_GLESv2 -Wall -Wextra -Wnon-virtual-dtor \
                -Wno-error=unused-parameter
LOCAL_LDLIBS := -landroid -llog -lGLESv2 -lEGL -lz
LOCAL_C_INCLUDES := $(LOCAL_PATH)/src \
                    $(LOCAL_PATH)/src/libmatrix \
                    $(LOCAL_PATH)/src/scene-ideas \
                    $(LOCAL_PATH)/src/scene-terrain \
                    $(LOCAL_PATH)/src/libglmark2-jpeg \
                    $(LOCAL_PATH)/src/libpng
LOCAL_SRC_FILES := $(filter-out src/canvas% src/gl-state% src/native-state% src/main.cpp, \
                     $(subst $(LOCAL_PATH)/,,$(wildcard $(LOCAL_PATH)/src/*.cpp))) \
                   $(subst $(LOCAL_PATH)/,,$(wildcard $(LOCAL_PATH)/src/scene-terrain/*.cpp)) \
                   src/canvas-android.cpp

include $(BUILD_SHARED_LIBRARY)
