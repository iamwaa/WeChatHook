#import "WCHookUtils.h"
#import "WeChatHook.h"

#pragma mark - 静态配置
static CGFloat kCellDistance; 
static CGFloat kCellRadius;   
static UIColor *kLightColor;  
static UIColor *kDarkColor;  

%ctor {
    kCellDistance = WCSettingNumber(@"CellDistance");
    kCellRadius = WCSettingNumber(@"CellRadius");
    kLightColor = [WCSettingColor colorFromHexString:WCSettingText(@"CellLightColor")];
    kDarkColor = [WCSettingColor colorFromHexString:WCSettingText(@"CellDarkColor")];
}

static inline BOOL IsViewInHome(UIView *v) {
    UIResponder *r = v.nextResponder;
    while (r) {
        if ([r isKindOfClass:NSClassFromString(@"NewMainFrameViewController")]) {
            return YES;
        }
        r = r.nextResponder;
    }
    return NO;
}

static inline BOOL IsSessionShowAreaEnabled() {
    NSString *plistPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.tencent.themebox.plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if (!dict) return NO;

    NSNumber *value = dict[@"SESSION_SHOW_AREA"];
    if (!value) return NO;

    return (value.intValue == 0);
}

static inline BOOL shouldExecuteAdjustForView(UIView *v) {
    return IsViewInHome(v) &&
           WCSettingBool(@"EnableHomeCellRadius") &&
           WCSettingBool(@"EnableSearchGroupBarRadius") &&
           IsSessionShowAreaEnabled();
}

UIView *findMFBannerBtn(UIView *view) {
    if ([view isKindOfClass:NSClassFromString(@"MFBannerBtn")]) {
        return view;
    }
    for (UIView *subview in view.subviews) {
        UIView *found = findMFBannerBtn(subview);
        if (found) return found;
    }
    return nil;
}

%hook UISearchBar

- (void)setFrame:(CGRect)frame {
    if (shouldExecuteAdjustForView(self)) {
        frame.origin.x = kCellDistance;
        frame.size.width = self.superview.bounds.size.width - kCellDistance * 2;
        frame.size.height = 48;
    }
    %orig(frame); // 调用原始 setFrame
    [self setNeedsLayout]; // 触发 layoutSubviews
    [self layoutIfNeeded]; // 立即执行布局
}

- (void)layoutSubviews {
    %orig;

    if (!shouldExecuteAdjustForView(self)) return;

    // 设置圆角
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = kCellRadius;

    // 检查 bannerBtn 以设置圆角
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow) {
        UIView *bannerBtn = findMFBannerBtn(keyWindow);
        BOOL useTopCorners = NO;
        if (bannerBtn && bannerBtn.superview && bannerBtn.superview.superview) {
            UIView *grandparent = bannerBtn.superview.superview;
            if (!grandparent.hidden) {
                useTopCorners = YES;
            }
        }

        if (@available(iOS 11.0, *)) {
            self.layer.maskedCorners = useTopCorners
                ? (kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner)
                : (kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner |
                   kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner);
        }
    }

    // 背景色动态适配
    if (@available(iOS 13.0, *)) {
        self.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *tc){
            return (tc.userInterfaceStyle == UIUserInterfaceStyleDark) ? kDarkColor : kLightColor;
        }];
    } else {
        self.backgroundColor = kLightColor;
    }
}

%end

// 调整分组栏内容
%hook ThemeBoxSegmentedView

static BOOL _isAdjustingThemeBox = NO;

- (void)setFrame:(CGRect)frame {
    if (!shouldExecuteAdjustForView(self)) { %orig; return; }
    
    if (!_isAdjustingThemeBox) {
        _isAdjustingThemeBox = YES;
        frame.origin.x = 2;
        %orig(frame);
        _isAdjustingThemeBox = NO;
    } else {
        %orig(frame);
    }
}

- (void)layoutSubviews {
    %orig;
    if (!shouldExecuteAdjustForView(self)) return;

    if (!_isAdjustingThemeBox) {
        _isAdjustingThemeBox = YES;
        CGRect f = self.frame;
        f.origin.x = 2;
        self.frame = f;
        _isAdjustingThemeBox = NO;
    }
}

- (void)didMoveToWindow {
    %orig;
    if (!shouldExecuteAdjustForView(self)) return;

    if (!_isAdjustingThemeBox) {
        _isAdjustingThemeBox = YES;
        CGRect f = self.frame;
        f.origin.x = 2;
        self.frame = f;
        _isAdjustingThemeBox = NO;
    }
}

%end

// 增加遮罩
%hook MFBannerBtn

- (void)layoutSubviews {
    %orig;

    UIView *tableViewCell = self.superview;
    while (tableViewCell && ![tableViewCell isKindOfClass:NSClassFromString(@"MMTableViewCell")]) {
        tableViewCell = tableViewCell.superview;
    }

    if (!tableViewCell || tableViewCell.hidden) {
        UIView *superview = self.superview;
        while (superview) {
            for (UIView *subview in superview.subviews) {
                if ([subview.accessibilityIdentifier isEqualToString:@"CustomMaskView"]) {
                    [subview removeFromSuperview];
                }
            }
            superview = superview.superview;
        }
        return;
    }

    if (!shouldExecuteAdjustForView(self)) return;

    UIView *tableView = tableViewCell.superview;
    while (tableView && ![tableView isKindOfClass:[UITableView class]]) {
        tableView = tableView.superview;
    }

    if (!tableView) return;

    UIView *minYTableViewCell = tableViewCell;
    CGFloat minY = tableViewCell.frame.origin.y;
    for (UIView *sibling in tableViewCell.superview.subviews) {
        if ([sibling isKindOfClass:NSClassFromString(@"MMTableViewCell")] && sibling.frame.origin.y < minY) {
            minY = sibling.frame.origin.y;
            minYTableViewCell = sibling;
        }
    }

    if (tableViewCell != minYTableViewCell) return;

    for (UIView *subview in tableViewCell.superview.subviews) {
        if ([subview.accessibilityIdentifier isEqualToString:@"CustomMaskView"]) {
            [subview removeFromSuperview];
        }
    }

    CGRect maskFrame = [tableViewCell.superview convertRect:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height / 2) fromView:self.superview];

    UIView *maskView = [[UIView alloc] initWithFrame:maskFrame];
    maskView.accessibilityIdentifier = @"CustomMaskView";
    maskView.layer.cornerRadius = 0;

    if (@available(iOS 13.0, *)) {
        maskView.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
            return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? kDarkColor : kLightColor;
        }];
    } else {
        maskView.backgroundColor = kLightColor;
    }

    [tableViewCell.superview insertSubview:maskView belowSubview:tableViewCell];
}

%end
