#import <UIKit/UIKit.h>
#import <substrate.h>
#import <SafariServices/SafariServices.h>

#pragma mark - 插件信息定义
#define WCName @"WeChatHook"
#define WCSettingsName @"WeChatHook Settings"
#define WCVersion @"1.0-0"
#define WCConfigFile @"Preferences/com.waa.wechathook.plist"

#pragma mark - 接口声明
@interface WCHookSettingViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, UITextFieldDelegate, UIColorPickerViewControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *filteredSettings;
@property (nonatomic, strong) NSMutableDictionary *config;
@property (nonatomic, strong) NSString *configFilePath; 
@property (nonatomic, strong) NSArray *settings;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) UIDocumentPickerViewController *documentPicker;
@property (nonatomic, assign) BOOL isSubpage;
@property (nonatomic, strong) NSString *currentColorKey;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSString *cachedCacheSize;
@end

#pragma mark - 微信相关类声明
@interface WCPluginsMgr : NSObject
+ (instancetype)sharedInstance;
- (void)registerControllerWithTitle:(NSString *)title version:(NSString *)version controller:(NSString *)controller;
@end

@interface MMTableView : UITableView
@end

@interface WCTableViewManager : NSObject
- (instancetype)initWithTableView:(UIView *)view;
- (MMTableView *)getTableView;
- (void)addSection:(id)section;
- (void)insertSection:(id)section At:(NSUInteger)index;
@end

@interface WCTableViewSectionManager : NSObject
+ (instancetype)sectionInfoDefaut;
- (void)addCell:(id)cell;
@end

@interface WCTableViewCellManager : NSObject
+ (instancetype)switchCellForSel:(SEL)sel
                          target:(id)target
                           title:(NSString *)title
                              on:(BOOL)on;
@end

@interface WCTableViewNormalCellManager : NSObject
+ (instancetype)normalCellForSel:(SEL)sel
                          target:(id)target
                           title:(NSString *)title
                      rightValue:(NSString *)rightValue
                   accessoryType:(NSInteger)type;
@end

@interface NewSettingViewController : UIViewController
@end
