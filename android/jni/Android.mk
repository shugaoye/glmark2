LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_CPP_EXTENSION := .cc
LOCAL_MODULE := libglmark2-matrix
LOCAL_CFLAGS := -DGLMARK2_USE_GLESv2 -Werror -Wall -Wextra -Wnon-virtual-dtor \
                -Wno-error=unused-parameter
LOCAL_C_INCLUDES := $(LOCAL_PATH)/src
LOCAL_SRC_FILES := $(subst $(LOCAL_PATH)/,,$(wildcard $(LOCAL_PATH)/src/libmatrix/*.cc))
LOCAL_SHARED_LIBRARIES := libdl libstlport

include external/stlport/libstlport.mk

include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := libglmark2-png
LOCAL_SRC_FILES := $(subst $(LOCAL_PATH)/,,$(wildcard $(LOCAL_PATH)/src/libpng/*.c))
LOCAL_C_INCLUDES := external/zlib

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

LOCAL_CPP_EXTENSION := .cc
LOCAL_MODULE := libglmark2-ideas
LOCAL_CFLAGS := -DGLMARK_DATA_PATH="" -DGLMARK2_USE_GLESv2 -Werror -Wall -Wextra\
                -Wnon-virtual-dtor -Wno-error=unused-parameter
LOCAL_C_INCLUDES := $(LOCAL_PATH)/src \
                    $(LOCAL_PATH)/src/libmatrix
LOCAL_SRC_FILES := $(subst $(LOCAL_PATH)/,,$(wildcard $(LOCAL_PATH)/src/scene-ideas/*.cc))
LOCAL_SHARED_LIBRARIES := libdl libstlport

include external/stlport/libstlport.mk

include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libglmark2-android
LOCAL_STATIC_LIBRARIES := libglmark2-matrix libglmark2-png libglmark2-ideas libglmark2-jpeg
LOCAL_CFLAGS := -DGLMARK_DATA_PATH="" -DGLMARK_VERSION="\"2014.03\"" \
                -DGLMARK2_USE_GLESv2 -Werror -Wall -Wextra -Wnon-virtual-dtor \
                -Wno-error=unused-parameter
LOCAL_SHARED_LIBRARIES := liblog libz libEGL libGLESv2 libandroid libdl libstlport
LOCAL_C_INCLUDES := $(LOCAL_PATH)/src \
                    $(LOCAL_PATH)/src/libmatrix \
                    $(LOCAL_PATH)/src/scene-ideas \
                    $(LOCAL_PATH)/src/scene-terrain \
                    $(LOCAL_PATH)/src/libjpeg-turbo \
                    $(LOCAL_PATH)/src/libpng \
                    external/zlib
LOCAL_SRC_FILES := $(filter-out src/canvas% src/gl-state% src/native-state% src/main.cpp, \
                     $(subst $(LOCAL_PATH)/,,$(wildcard $(LOCAL_PATH)/src/*.cpp))) \
                   $(subst $(LOCAL_PATH)/,,$(wildcard $(LOCAL_PATH)/src/scene-terrain/*.cpp)) \
                   src/canvas-android.cpp
LOCAL_PRELINK_MODULE := false

include external/stlport/libstlport.mk

include $(BUILD_SHARED_LIBRARY)
