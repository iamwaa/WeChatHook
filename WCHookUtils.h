#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 配置读取函数声明
// 获取布尔值配置
FOUNDATION_EXPORT BOOL WCSettingBool(NSString *key);

// 获取文本值配置
FOUNDATION_EXPORT NSString * _Nullable WCSettingText(NSString *key);

// 获取数值配置
FOUNDATION_EXPORT double WCSettingNumber(NSString *key);

// 获取布尔值配置（带默认值）
FOUNDATION_EXPORT BOOL WCSettingBoolDefault(NSString *key, BOOL defaultValue);

// 获取文本值配置（带默认值）
FOUNDATION_EXPORT NSString * _Nullable WCSettingTextDefault(NSString *key, NSString * _Nullable defaultValue);

// 获取数值配置（带默认值）
FOUNDATION_EXPORT double WCSettingNumberDefault(NSString *key, NSNumber *defaultValue);

#pragma mark - WCSettingColor 类声明
@interface WCSettingColor : NSObject

// UIColor 转十六进制字符串（#RRGGBBAA）
+ (NSString *)hexStringFromColor:(UIColor *)color;

// 十六进制字符串转 UIColor（支持 #RRGGBB 和 #RRGGBBAA）
+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end

NS_ASSUME_NONNULL_END
