#import "WCHookUtils.h"
#import "WCHookSettingViewController.h"

#pragma mark - WCSettings配置函数
// 获取配置文件路径
static NSString *WCSettingsFilePath(void) {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    return [libraryPath stringByAppendingPathComponent:WCConfigFile];
}

// 加载配置文件
static NSDictionary *WCLoadConfig(void) {
    return [NSDictionary dictionaryWithContentsOfFile:WCSettingsFilePath()] ?: @{};
}

// 获取布尔值配置
BOOL WCSettingBool(NSString *key) {
    return WCSettingBoolDefault(key, NO);
}

// 获取文本值配置
NSString *WCSettingText(NSString *key) {
    return WCSettingTextDefault(key, nil);
}

// 获取数值配置
double WCSettingNumber(NSString *key) {
    return WCSettingNumberDefault(key, @(0));
}

// 获取布尔值配置，带默认值
BOOL WCSettingBoolDefault(NSString *key, BOOL defaultValue) {
    if (!key) return defaultValue;
    NSDictionary *config = WCLoadConfig();
    id value = config[key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }
    return defaultValue;
}

// 获取文本值配置，带默认值
NSString *WCSettingTextDefault(NSString *key, NSString *defaultValue) {
    if (!key) return defaultValue;
    NSDictionary *config = WCLoadConfig();
    id value = config[key];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return defaultValue;
}

// 获取数值配置，带默认值
double WCSettingNumberDefault(NSString *key, NSNumber *defaultValue) {
    if (!key) return defaultValue.doubleValue;
    NSDictionary *config = WCLoadConfig();
    id value = config[key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value doubleValue];
    }
    return defaultValue.doubleValue;
}

#pragma mark - WCSettingColor颜色转换函数
@implementation WCSettingColor

+ (NSString *)hexStringFromColor:(UIColor *)color {
    if (!color) return @"#000000FF";
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX",
            lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255)];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    if (!hexString || [hexString length] == 0) return [UIColor whiteColor];
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    unsigned rgbValue = 0;
    unsigned alphaValue = 255;
    NSScanner *scanner = [NSScanner scannerWithString:cleanString];
    
    if ([cleanString length] == 8) {
        [scanner scanHexInt:&rgbValue];
        alphaValue = rgbValue & 0xFF;
        rgbValue >>= 8;
    } else if ([cleanString length] == 6) {
        [scanner scanHexInt:&rgbValue];
    } else {
        return [UIColor whiteColor];
    }
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0x00FF00) >> 8)/255.0
                            blue:(rgbValue & 0x0000FF)/255.0
                           alpha:alphaValue/255.0];
}

@end