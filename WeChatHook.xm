// Developer By @Waa
// https://github.com/iamwaa

#import "WCHookUtils.h"
#import "WeChatHook.h"

#pragma mark - 首页Cell 圆角
// 在程序启动时初始化静态值
static CGFloat kHMargin;    // 左右间距
static CGFloat kSectionGap; // section 间距
static CGFloat kRadius;     // 圆角半径
static UIColor *kLightColor; // 浅色模式背景颜色
static UIColor *kDarkColor;  // 深色模式背景颜色

%ctor {
    kHMargin = WCSettingNumber(@"CellDistance");
    kSectionGap = WCSettingNumber(@"CellSpacing");
    kRadius = WCSettingNumber(@"CellRadius");
    kLightColor = [WCSettingColor colorFromHexString:WCSettingText(@"CellLightColor")];
    kDarkColor = [WCSettingColor colorFromHexString:WCSettingText(@"CellDarkColor")];
}

// 主页判断
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

static inline BOOL ShouldAdjustForView(UIView *v) {
    if (!WCSettingBool(@"EnableHomeCellRadius")) return NO;
    return IsViewInHome(v);
}

%hook NewMainFrameViewController

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!ShouldAdjustForView(tableView)) return %orig(tableView, section);

    CGFloat origH = %orig(tableView, section);
    if (origH > 0) return origH;
    return (section > 0) ? kSectionGap : 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!ShouldAdjustForView(tableView)) return %orig(tableView, section);

    UIView *origV = %orig(tableView, section);
    if (origV) return origV;
    if (section > 0) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, kSectionGap)];
        v.backgroundColor = [UIColor clearColor];
        return v;
    }
    return nil;
}

%end

%hook MMTableViewCell

- (void)setFrame:(CGRect)frame {
    if (!ShouldAdjustForView(self)) return %orig(frame);

    UITableView *tv = (UITableView *)self.superview;
    while (tv && ![tv isKindOfClass:[UITableView class]]) tv = (UITableView *)tv.superview;
    if (tv) {
        frame.origin.x = kHMargin;
        frame.size.width = tv.bounds.size.width - kHMargin * 2;
        // 修正裁剪空隙
        NSIndexPath *ip = [tv indexPathForCell:(id)self];
        if (ip) {
            NSInteger rows = [tv numberOfRowsInSection:ip.section];
            if (rows > 1 && ip.row > 0) {
                frame.origin.y -= 1.0;
            }
        }
    }

    %orig(frame);

    self.contentView.frame = self.bounds;
    if (self.selectedBackgroundView) {
        self.selectedBackgroundView.frame = self.bounds;
    }
}

- (void)layoutSubviews {
    %orig;
    if (!ShouldAdjustForView(self)) return;

    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];

    // 获取 indexPath 和 section 行数
    UITableView *tv = (UITableView *)self.superview;
    while (tv && ![tv isKindOfClass:[UITableView class]]) tv = (UITableView *)tv.superview;

    NSIndexPath *ip = nil;
    NSInteger rows = 0;
    if (tv) {
        ip = [tv indexPathForCell:self];
        if (ip) rows = [tv numberOfRowsInSection:ip.section];
    }

    //  计算首尾圆角
    UIRectCorner corners = 0;
    if (rows <= 1) {
        corners = UIRectCornerAllCorners;
    } else {
        if (ip.row == 0) corners = UIRectCornerTopLeft | UIRectCornerTopRight;
        else if (ip.row == rows - 1) corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
        else corners = 0;
    }

    //  圆角裁剪
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(kRadius, kRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;

    //  背景
    const NSInteger kBGTag = 0xABCDEF09;
    UIView *bg = [self.contentView viewWithTag:kBGTag];
    if (!bg) {
        bg = [[UIView alloc] initWithFrame:self.contentView.bounds];
        bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        bg.tag = kBGTag;
        bg.userInteractionEnabled = NO;
        [self.contentView insertSubview:bg atIndex:0];
    }
    bg.frame = self.contentView.bounds;

    if (@available(iOS 11.0, *)) {
        bg.layer.cornerRadius = kRadius;
        unsigned int m = 0;
        if (corners & UIRectCornerTopLeft)     m |= kCALayerMinXMinYCorner;
        if (corners & UIRectCornerTopRight)    m |= kCALayerMaxXMinYCorner;
        if (corners & UIRectCornerBottomLeft)  m |= kCALayerMinXMaxYCorner;
        if (corners & UIRectCornerBottomRight) m |= kCALayerMaxXMaxYCorner;
        bg.layer.maskedCorners = m;
        bg.layer.masksToBounds = YES;
    }

    if (@available(iOS 13.0, *)) {
        bg.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *tc) {
            return (tc.userInterfaceStyle == UIUserInterfaceStyleDark) ? kDarkColor : kLightColor;
        }];
    } else {
        bg.backgroundColor = kLightColor;
    }

    //  选中背景
    if (!self.selectedBackgroundView) {
        UIView *sel = [[UIView alloc] initWithFrame:self.bounds];
        sel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        sel.backgroundColor = (@available(iOS 13.0, *) ? [UIColor colorWithWhite:0.5 alpha:0.2] : [UIColor colorWithWhite:0.5 alpha:0.2]);

        if (@available(iOS 11.0, *)) {
            sel.layer.cornerRadius = kRadius;
            unsigned int m = 0;
            if (corners & UIRectCornerTopLeft)     m |= kCALayerMinXMinYCorner;
            if (corners & UIRectCornerTopRight)    m |= kCALayerMaxXMinYCorner;
            if (corners & UIRectCornerBottomLeft)  m |= kCALayerMinXMaxYCorner;
            if (corners & UIRectCornerBottomRight) m |= kCALayerMaxXMaxYCorner;
            sel.layer.maskedCorners = m;
            sel.layer.masksToBounds = YES;
        }

        self.selectedBackgroundView = sel;
    } else {
        self.selectedBackgroundView.frame = self.bounds;
        self.selectedBackgroundView.backgroundColor = (@available(iOS 13.0, *) ? [UIColor colorWithWhite:0.5 alpha:0.2] : [UIColor colorWithWhite:0.5 alpha:0.2]);
        if (@available(iOS 11.0, *)) {
            self.selectedBackgroundView.layer.cornerRadius = kRadius;
            unsigned int m = 0;
            if (corners & UIRectCornerTopLeft)     m |= kCALayerMinXMinYCorner;
            if (corners & UIRectCornerTopRight)    m |= kCALayerMaxXMinYCorner;
            if (corners & UIRectCornerBottomLeft)  m |= kCALayerMinXMaxYCorner;
            if (corners & UIRectCornerBottomRight) m |= kCALayerMaxXMaxYCorner;
            self.selectedBackgroundView.layer.maskedCorners = m;
            self.selectedBackgroundView.layer.masksToBounds = YES;
        }
    }
}

%end

%hook ColorGradientView

- (void)layoutSubviews {
    %orig;
    if (!ShouldAdjustForView(self)) return;

    UIUserInterfaceStyle style = self.traitCollection.userInterfaceStyle;
    UIColor *baseColor = (style == UIUserInterfaceStyleDark) ? kDarkColor : kLightColor;

    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            CAGradientLayer *gradientLayer = (CAGradientLayer *)layer;

            gradientLayer.colors = @[
                (__bridge id)[baseColor colorWithAlphaComponent:0.0].CGColor, // 透明
                (__bridge id)[baseColor colorWithAlphaComponent:1.0].CGColor  // 不透明
            ];
        }
    }
}

%end

static char BannerLabelTimerKey;
static char BannerLabelLastTimeKey;

%hook MFBannerBtn
// Cell背景颜色
- (void)layoutSubviews {
    %orig;
    if (!ShouldAdjustForView(self)) return;

    const NSInteger kBGTag = 0xABCDEF09;
    UIView *bg = [self viewWithTag:kBGTag];
    if (!bg) {
        bg = [[UIView alloc] initWithFrame:self.bounds];
        bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        bg.tag = kBGTag;
        bg.userInteractionEnabled = NO;
        [self insertSubview:bg atIndex:0];
    }
    bg.frame = self.bounds;

    if (@available(iOS 13.0, *)) {
        bg.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *tc){
            return (tc.userInterfaceStyle == UIUserInterfaceStyleDark) ? kDarkColor : kLightColor;
        }];
    } else {
        bg.backgroundColor = kLightColor;
    }
}

// 置顶收藏末显示当前时间
- (void)didMoveToWindow {
    %orig;

    if (!WCSettingBool(@"EnableTopFavoritesAddTime")) return;
    if (![NSStringFromClass([self class]) isEqualToString:@"MFBannerBtn"]) return;
    if (!self.window) return;

    UILabel *label = nil;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            label = (UILabel *)subview;
            break;
        }
    }
    if (!label) return;

    if (objc_getAssociatedObject(label, &BannerLabelTimerKey)) return;

    __weak UILabel *weakLabel = label;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong UILabel *startLabel = weakLabel;
        if (!startLabel || !startLabel.window) return;

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd E HH:mm:ss"];

        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull tt) {
            __strong UILabel *ss = weakLabel;
            if (!ss || !ss.window) {
                [tt invalidate];
                if (ss) objc_setAssociatedObject(ss, &BannerLabelTimerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                return;
            }

            NSString *dateString = [formatter stringFromDate:[NSDate date]];
            NSString *lastTime = objc_getAssociatedObject(ss, &BannerLabelLastTimeKey);
            if (lastTime && [lastTime isEqualToString:dateString]) return;

            objc_setAssociatedObject(ss, &BannerLabelLastTimeKey, dateString, OBJC_ASSOCIATION_COPY_NONATOMIC);

            NSString *text = ss.text ?: @"";
            NSRange range = [text rangeOfString:@"⁣"];
            NSString *originalText = (range.location != NSNotFound) ? [text substringToIndex:range.location] : text;
            originalText = [originalText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            ss.text = [NSString stringWithFormat:@"%@⁣%@", originalText, dateString];

            [ss sizeToFit];
            CGRect frame = ss.frame;
            frame.origin.y = (ss.superview.bounds.size.height - frame.size.height) / 2;
            ss.frame = frame;

            [ss.superview setNeedsLayout];
            [ss.superview layoutIfNeeded];
        }];

        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        objc_setAssociatedObject(startLabel, &BannerLabelTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
}

%end

// 隐藏分组栏角标
%hook ThemeBadgeView

- (void)layoutSubviews {
    %orig;
    if (!WCSettingBool(@"HideGroupBarBadge")) return;

    NSArray *targetTexts = [WCSettingText(@"BarBadgeName") componentsSeparatedByString:@"#"];

    UIView *superview = self.superview;
    NSUInteger currentIndex = [superview.subviews indexOfObject:self];
    if (currentIndex == NSNotFound || currentIndex == 0) {
        return;
    }

    UIView *previousSibling = superview.subviews[currentIndex - 1];
    if ([previousSibling isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)previousSibling;
        if ([targetTexts containsObject:label.text]) {
            self.hidden = YES;
            return;
        }
    }
}

%end

#pragma mark - 隐藏我的二维码
%hook MMUIButton

- (void)layoutSubviews {
    %orig;

    if (!WCSettingBool(@"HideMyQRCode")) return;

    if ([self.accessibilityLabel isEqualToString:@"我的二维码"]) {
        self.hidden = YES;
    }
}

%end

#pragma mark - 隐藏我的状态
%hook TextStatePublishEntryButton

- (void)layoutSubviews {
    %orig;

    if (WCSettingBool(@"HideMyState")) {
        self.hidden = YES;
    }
}

%end
%hook TextStateFriendTopicButton

- (void)layoutSubviews {
    %orig;

    if (WCSettingBool(@"HideMyState")) {
        self.hidden = YES;
    }
}

%end

#pragma mark - 隐藏输入框内语音按钮
%hook MMGrowDictationIconView

- (void)layoutSubviews {
    %orig;

    if (WCSettingBool(@"HideInputVoice")){
        self.hidden = YES;
    }
}

%end

#pragma mark - 隐藏主页+号
%hook MMBarButton

- (void)layoutSubviews {
    %orig;
    if (!WCSettingBool(@"HideHomePlus") && !IsViewInHome(self)) return;
    
    if ([self.accessibilityLabel isEqualToString:@"快捷操作"]) {
        self.alpha = 0.0;
    }
}

%end

#pragma mark - 左滑快速引用&右滑撤回消息
static UIView * FindCellSuperview(UIView *sourceView) {
    UIView *v = sourceView;
    while (v && ![NSStringFromClass([v class]) containsString:@"Cell"]) {
        v = v.superview;
    }
    return v;
}

// 可撤回消息类型
static BOOL IsRevokeableCellViewClass(UIView *view) {
    NSSet *classes = [NSSet setWithArray:@[
        @"TextMessageCellView",
        @"EmoticonMessageCellView",
        @"AppFileMessageCellView",
        @"ImageMessageCellView",
        @"BizAppReaderMessageCellView",
        @"AppRecordMessageCellView",
        @"VideoMessageCellView",
        @"VoiceMessageCellView"
    ]];
    return [classes containsObject:NSStringFromClass([view class])];
}

// 在 cell 内递归查找可撤回的消息 CellView
static UIView * FindRevokeableMessageCellView(UIView *root) {
    if (IsRevokeableCellViewClass(root)) {
        return root;
    }
    for (UIView *sub in root.subviews) {
        UIView *found = FindRevokeableMessageCellView(sub);
        if (found) return found;
    }
    return nil;
}

static void TriggerReplyFromView(UIView *sourceView) {
    if (!WCSettingBool(@"EnableLeftSwipeReply")) return;

    UIView *cell = FindCellSuperview(sourceView);
    if (!cell) return;

    SEL sel = NSSelectorFromString(@"onShowMsgReplyMenuItem:");
    if ([cell respondsToSelector:sel]) {
        [cell performSelector:sel withObject:nil];
        // 触感反馈
        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [gen prepare];
        [gen impactOccurred];
    }
}

static void TriggerRevokeFromView(UIView *sourceView) {
    if (!WCSettingBool(@"EnableLeftSwipeReply")) return;
    if (!WCSettingBool(@"EnableRightSwipeRevoke")) return;

    UIView *cell = FindCellSuperview(sourceView);
    if (!cell) return;

    UIView *msgCellView = FindRevokeableMessageCellView(cell);
    if (!msgCellView) return;

    NSString *accLabel = msgCellView.accessibilityLabel;
    if (![accLabel isKindOfClass:[NSString class]]) return;

    if (![accLabel hasPrefix:@"我,"]) return;

    SEL sel = NSSelectorFromString(@"onRevokeMsg:");
    if ([cell respondsToSelector:sel]) {
        [cell performSelector:sel withObject:nil];
        // 触感反馈
        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [gen prepare];
        [gen impactOccurred];
    }
}

static void AddSwipeGestureIfNeeded(UIView *view) {
    if (!WCSettingBool(@"EnableLeftSwipeReply")) return;

    view.userInteractionEnabled = YES;

    BOOL hasLeft = NO;
    BOOL hasRight = NO;

    for (UIGestureRecognizer *gr in view.gestureRecognizers) {
        if ([gr isKindOfClass:[UISwipeGestureRecognizer class]]) {
            UISwipeGestureRecognizer *sw = (UISwipeGestureRecognizer *)gr;
            if (sw.direction == UISwipeGestureRecognizerDirectionLeft) {
                hasLeft = YES;
            } else if (sw.direction == UISwipeGestureRecognizerDirectionRight) {
                hasRight = YES;
            }
        }
    }

    // 左滑（回复）
    if (!hasLeft) {
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:view action:@selector(mySwipeAction:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [view addGestureRecognizer:swipeLeft];
    }

    // 右滑（撤回）
    if (WCSettingBool(@"EnableRightSwipeRevoke") && !hasRight) {
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:view action:@selector(mySwipeAction:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [view addGestureRecognizer:swipeRight];
    }
}

// 气泡
%hook YYAsyncImageView
- (void)didMoveToWindow {
    %orig;
    if (self.window) {
        AddSwipeGestureIfNeeded(self);
    }
}
%new
- (void)mySwipeAction:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        TriggerReplyFromView(self);
    } else if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        TriggerRevokeFromView(self);
    }
}
%end

// 表情
%hook MMEmoticonView
- (void)didMoveToWindow {
    %orig;
    if (self.window) {
        AddSwipeGestureIfNeeded(self);
    }
}
%new
- (void)mySwipeAction:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        TriggerReplyFromView(self);
    } else if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        TriggerRevokeFromView(self);
    }
}
%end

// 视频
%hook SightIconView
- (void)didMoveToWindow {
    %orig;
    if (self.window) {
        AddSwipeGestureIfNeeded(self);
    }
}
%new
- (void)mySwipeAction:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        TriggerReplyFromView(self);
    } else if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        TriggerRevokeFromView(self);
    }
}
%end

// 链接
%hook RichTextView
- (void)didMoveToWindow {
    %orig;
    if (self.window) {
        AddSwipeGestureIfNeeded(self);
    }
}
%new
- (void)mySwipeAction:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        TriggerReplyFromView(self);
    } else if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        TriggerRevokeFromView(self);
    }
}
%end

#pragma mark - 长按输入框搜索表情
static char kEmojiLongPressKey;

%hook MMUIButton

- (void)didMoveToWindow {
    %orig;
    if ([self.accessibilityLabel isEqualToString:@"表情"]) {
        [self tw_installEmojiLongPress];
    }
}

%new
- (void)tw_installEmojiLongPress {
    if (!WCSettingBool(@"EnableLongPressSearchEmoji")) return;

    UILongPressGestureRecognizer *exist = (UILongPressGestureRecognizer *)objc_getAssociatedObject(self, &kEmojiLongPressKey);
    NSArray *grs = self.gestureRecognizers ?: @[];
    if (exist && [grs containsObject:exist]) return;

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tw_handleEmojiLongPress:)];
    longPress.minimumPressDuration = 0.5;
    longPress.allowableMovement = 20;
    longPress.cancelsTouchesInView = NO;
    longPress.numberOfTouchesRequired = 1;
    longPress.delegate = (id<UIGestureRecognizerDelegate>)self;

    [self addGestureRecognizer:longPress];
    objc_setAssociatedObject(self, &kEmojiLongPressKey, longPress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (void)tw_handleEmojiLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;

    UIResponder *responder = self;
    Class ToolViewCls = objc_getClass("MMInputToolView");
    while (responder && ![responder isKindOfClass:ToolViewCls]) {
        responder = [responder nextResponder];
    }
    if (!responder) return;

    if ([responder respondsToSelector:@selector(onExpressionButtonClicked:)]) {
        [(id)responder onExpressionButtonClicked:nil];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIView *cellView = [self tw_findSearchCellInView:window];
        if (cellView && [cellView isKindOfClass:NSClassFromString(@"EmoticonBoardDynamicTabBarCollectionCell")]) {
            UIView *v = cellView.superview;
            while (v && ![v isKindOfClass:[UICollectionView class]]) {
                v = v.superview;
            }
            UICollectionView *collectionView = (UICollectionView *)v;
            if (collectionView) {
                NSIndexPath *indexPath = [collectionView indexPathForCell:(UICollectionViewCell *)cellView];
                if (indexPath && [collectionView.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
                    [collectionView.delegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
                    // 触感反馈
                    UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
                    [gen prepare];
                    [gen impactOccurred];
                }
            }
        }
    });
}

%new
- (UIView *)tw_findSearchCellInView:(UIView *)view {
    if ([view isKindOfClass:NSClassFromString(@"EmoticonBoardDynamicTabBarCollectionCell")]) {
        return view;
    }
    for (UIView *sub in view.subviews) {
        UIView *found = [self tw_findSearchCellInView:sub];
        if (found) return found;
    }
    return nil;
}

%new
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

%new
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)other {
    return YES;
}

%new
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)other {
    return NO;
}

%end

#pragma mark - 长按发送照片
static __weak MMCapturePreviewBrowserController *gCaptureVC = nil;
static char kLongPressAddedKey;

%hook MMCapturePreviewBrowserController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    gCaptureVC = self; // 保存当前编辑页面实例
}
%end

%hook UIButton

- (void)didMoveToSuperview {
    %orig;

    // 检查设置开关
    if (!WCSettingBool(@"EnableLongPressSendPhoto")) return;

    if ([self.accessibilityLabel isEqualToString:@"发送截屏"]) {
        NSNumber *added = objc_getAssociatedObject(self, &kLongPressAddedKey);
        if (added && [added boolValue]) return;

        // 添加长按手势阻止短按发送
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
            initWithTarget:self action:@selector(handleLongPress:)];
        longPress.minimumPressDuration = 0.5;
        longPress.cancelsTouchesInView = YES;
        [self addGestureRecognizer:longPress];

        objc_setAssociatedObject(self, &kLongPressAddedKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

%new
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;

    // 触感反馈
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [generator prepare];
    [generator impactOccurred];

    UIButton *btn = (UIButton *)gesture.view;

    // 调用 onSendCaptrueButtonClicked: 进入编辑界面
    for (id t in [btn allTargets].allObjects) {
        for (NSString *selStr in [btn actionsForTarget:t forControlEvent:UIControlEventTouchUpInside]) {
            if ([selStr isEqualToString:@"onSendCaptrueButtonClicked:"]) {
                SEL sel = NSSelectorFromString(selStr);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [t performSelector:sel withObject:btn];
#pragma clang diagnostic pop
                break;
            }
        }
    }

    // 轮询编辑页面出现后直发
    __block int attempts = 0;
    __block void (^poll)(void) = ^{
        attempts++;
        if (gCaptureVC) {
            UIButton *sendBtn = [self findSendButtonInView:gCaptureVC.view];
            if (sendBtn) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [gCaptureVC handleSend:sendBtn];
#pragma clang diagnostic pop
            }
        } else if (attempts < 10) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), poll);
        }
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), poll);
}

%new
- (UIButton *)findSendButtonInView:(UIView *)view {
    if ([NSStringFromClass(view.class) isEqualToString:@"FixTitleColorButton"] && [view isKindOfClass:[UIButton class]]) {
        return (UIButton *)view;
    }
    for (UIView *sub in view.subviews) {
        UIButton *btn = [self findSendButtonInView:sub];
        if (btn) return btn;
    }
    return nil;
}

%end

#pragma mark -操作二次确认
static void ShowConfirmAlert(NSString *message, void (^onConfirm)(void)) {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];

    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
        if (onConfirm) {
            onConfirm();
        }
    }];

    [alert addAction:cancel];
    [alert addAction:confirm];

    [rootVC presentViewController:alert animated:YES completion:nil];
}

%hook VoIPBubbleMessageCellView

- (void)startVoiceVoip {
    if (WCSettingBool(@"EnableCallBackConfirm")) {
        ShowConfirmAlert(@"是否要回拨语音通话？", ^{
            %orig;
        });
    } else {
        %orig;
    }
}

- (void)startVideoVoip {
    if (WCSettingBool(@"EnableCallBackConfirm")) {
        ShowConfirmAlert(@"是否要回拨视频通话？", ^{
            %orig;
        });
    } else {
        %orig;
    }
}

%end

%hook MMHeadImageView

- (void)OnImageDoubleClick:(id)sender {
    if (WCSettingBool(@"EnableDoubleClickConfirm")) {
        ShowConfirmAlert(@"是否要拍一拍？", ^{
            %orig;
        });
    } else {
        %orig;
    }
}

%end


#pragma mark - 防删聊天记录
%hook CMessageMgr

// 单条消息/多选删除
- (void)DelMsg:(id)a0 MsgList:(id)a1 DelAll:(BOOL)a2 {
    if (WCSettingBool(@"EnablePreventDeleteChatRecord")) {
        return;
    }
    %orig;
}

// 全部删除
- (void)DelAllMsgs:(id)a0 {
    if (WCSettingBool(@"EnablePreventDeleteChatRecord")) {
        return;
    }
    %orig;
}

%end

#pragma mark - 禁用热更新@Netsako
// WCUpdateMgr基本已在8.0.61+被废弃 看了一下原始调用它的方法依旧存在 让我们来禁用它
/*
%hook WCUpdateMgr
- (void)loadAndExecute {

}
%end
*/

%hook MicroMessengerAppDelegate

- (void)loadUpdateAndExcute {
    if (WCSettingBool(@"DisableHotUpdates")) {
        return;
    }
    %orig;
}

%end

#pragma mark - 聊天实况照片@Netsako
%hook ImageMessageUtils

+ (BOOL)isOpenLiveMsgUpload {
    if (WCSettingBool(@"EnableChatLivePhotos")) {
        return YES;
    } else {
        return %orig;
    }
}

%end

#pragma mark - 自动播放实况照片
%hook WCC2CImageScrollView

- (void)didMoveToWindow {
    %orig;
    if (!WCSettingBool(@"EnablePlayLivePhoto")) return;

    if (self.window) {
        [self playLivePhotoWithFile];
    }
}

%end

%hook WCMediaImageScrollView

- (void)displayViewModel:(id)a0 withImage:(id)a1 frame:(struct CGRect)a2 {
    %orig;
    if (!WCSettingBool(@"EnablePlayLivePhoto")) return;

    if (self.imageTagView) {
        [self livePhotoButtonClickedInImageTagView:self.imageTagView];
    }
}

%end

%hook WCImageFullScreenViewContainer

- (void)didDisplay {
    %orig;
    if (!WCSettingBool(@"EnablePlayLivePhoto")) return;

    if (self.imageTagView) {
        [self livePhotoButtonClickedInImageTagView:self.imageTagView];
    }
}

%end

// 朋友圈显示详细时间
%hook WCTimeLineCellView
%property (nonatomic, strong) NSDateFormatter *timeFormatter;

- (NSDateFormatter *)timeFormatter {
    NSDateFormatter *formatter = %orig;
    if (WCSettingBool(@"EnablePreciseTime") && !formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        self.timeFormatter = formatter;
    }
    return formatter;
}

- (void)initTimeLabel {
    %orig;
    if (self.m_dataItem.createtime > 0 && WCSettingBool(@"EnablePreciseTime")) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.m_dataItem.createtime];
        self.m_timeLabel.text = [self.timeFormatter stringFromDate:date];
    }
}

- (void)updateWithDataItem:(WCDataItem *)dataItem actionAreaVM:(id)actionAreaVM {
    %orig(dataItem, actionAreaVM);
    if (dataItem.createtime > 0 && WCSettingBool(@"EnablePreciseTime")) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:dataItem.createtime];
        self.m_timeLabel.text = [self.timeFormatter stringFromDate:date];
    }
}

%end
