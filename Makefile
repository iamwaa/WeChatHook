# 基本配置
TARGET = iphone:clang:latest:15.0
ARCHS = arm64 arm64e

DEBUG = 0

# 注入目标应用
INSTALL_TARGET_PROCESSES = WeChat

# Tweak 配置
TWEAK_NAME = WeChatHook
WeChatHook_FILES = WeChatHook.xm WCHookSettingViewController.xm WCHookUtils.m SearchGroupBarRadius.xm
WeChatHook_CFLAGS = -fobjc-arc -w
WeChatHook_FRAMEWORKS = UIKit

# Logos 默认生成器
WeChatHook_LOGOS_DEFAULT_GENERATOR = internal
THEOS_STRICT_LOGOS = 0
ERROR_ON_WARNINGS = 0

# 编译设置
# 如果你的项目不使用 C++，下面两行可以删掉
CXXFLAGS += -std=c++11
CCFLAGS += -std=c++11

# 设备信息（可选）
THEOS_DEVICE_IP = 192.168.31.222
THEOS_DEVICE_PORT = 22

# Include Theos Makefiles
include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

# 自定义 clean
clean::
	@echo -e "\033[31m==>\033[0m Cleaning packages…"
	@rm -rf .theos packages
