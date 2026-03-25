#import "WCHookUtils.h"
#import "WCHookSettingViewController.h"

#pragma mark - 控制器实现
@implementation WCHookSettingViewController

// 初始化视图控制器，设置表格视图并加载配置
- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置配置文件路径
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    self.configFilePath = [libraryPath stringByAppendingPathComponent:WCConfigFile];

    // 设置数据
    if (!self.isSubpage) {
        self.settings = @[
            @{
                @"section": @"外观设置",
                @"items": @[
                    @{@"title": @"首页Cell圆角", @"subtitle": @"为首页cell增加圆角风格", @"type": @"subpage", @"key": @"HomeRadiusSettings", @"icon": @"capsule"},
                    @{@"title": @"启用首页Cell圆角", @"type": @"switch", @"key": @"EnableHomeCellRadius", @"parent": @"HomeRadiusSettings", @"icon": @"capsule", @"subpageSection":@"圆角设置"},
                    @{@"title": @"圆角度", @"type": @"slider", @"key": @"CellRadius", @"minValue": @(0), @"maxValue": @(30), @"defaultValue": @(18), @"showPercentage": @(NO), @"dependsOn": @"EnableHomeCellRadius", @"parent": @"HomeRadiusSettings", @"icon": @"slider.horizontal.below.rectangle", @"subpageSection":@"圆角设置"},
                    @{@"title": @"左右边距", @"type": @"slider", @"key": @"CellDistance", @"minValue": @(0), @"maxValue": @(30), @"defaultValue": @(15), @"showPercentage": @(NO), @"dependsOn": @"EnableHomeCellRadius", @"parent": @"HomeRadiusSettings", @"icon": @"rectangle.portrait.arrowtriangle.2.outward", @"subpageSection":@"圆角设置"},
                    @{@"title": @"上下间距", @"type": @"slider", @"key": @"CellSpacing", @"minValue": @(0), @"maxValue": @(30), @"defaultValue": @(15), @"showPercentage": @(NO), @"dependsOn": @"EnableHomeCellRadius", @"parent": @"HomeRadiusSettings", @"icon": @"rectangle.arrowtriangle.2.outward", @"subpageSection":@"圆角设置"},
                    @{@"title": @"Cell背景颜色", @"subtitle": @"选择浅色和深色模式的背景颜色", @"type": @"colorPicker", @"lightKey": @"CellLightColor", @"darkKey": @"CellDarkColor", @"parent": @"HomeRadiusSettings", @"dependsOn": @"EnableHomeCellRadius", @"icon": @"paintpalette", @"subpageSection":@"圆角设置"},
                    @{@"title": @"兼容替换搜索", @"subtitle": @"兼容ThemeBox的替换搜索分组栏", @"type": @"switch", @"key": @"EnableSearchGroupBarRadius", @"parent": @"HomeRadiusSettings", @"dependsOn": @"EnableHomeCellRadius", @"icon": @"rectangle.topthird.inset.filled", @"subpageSection":@"增强设置"}
                ]
            },
            @{
                @"section": @"隐藏设置",
                @"items": @[
                    @{@"title": @"隐藏分组角标", @"subtitle": @"隐藏ThemeBox的分组栏角标", @"type": @"switch", @"key": @"HideGroupBarBadge", @"icon": @"eye.slash"},
                    @{@"title": @"分组名称", @"subtitle": @"填写格式：分组1#分组2", @"type": @"text", @"key": @"BarBadgeName", @"dependsOn": @"HideGroupBarBadge", @"icon": @"textformat"},
                    @{@"title": @"移除我的二维码", @"subtitle": @"移除<我>页面二维码", @"type": @"switch", @"key": @"HideMyQRCode", @"icon": @"eye.slash"},
                    @{@"title": @"移除我的状态", @"subtitle": @"移除<我>页面状态", @"type": @"switch", @"key": @"HideMyState", @"icon": @"eye.slash"},
                    @{@"title": @"隐藏主页+号", @"subtitle": @"隐藏<主页>右上角+号，保留点击功能", @"type": @"switch", @"key": @"HideHomePlus", @"icon": @"eye.slash"},
                    @{@"title": @"移除转文字按钮", @"subtitle": @"移除<输入框>内的语音转文字按钮", @"type": @"switch", @"key": @"HideInputVoice", @"icon": @"eye.slash"}
                ]
            },
            @{
                @"section": @"增强设置",
                @"items": @[
                    @{@"title": @"置顶显示时间", @"subtitle": @"在置顶收藏文案末尾显示实时时间", @"type": @"switch", @"key": @"EnableTopFavoritesAddTime", @"icon": @"clock"},
                    @{@"title": @"左滑引用回复", @"subtitle": @"左滑<消息气泡>快速引用回复", @"type": @"switch", @"key": @"EnableLeftSwipeReply", @"icon": @"quote.bubble.rtl"},
                    @{@"title": @"右滑撤回消息", @"subtitle": @"右滑<发出的消息气泡>快速撤回消息", @"type": @"switch", @"key": @"EnableRightSwipeRevoke", @"dependsOn": @"EnableLeftSwipeReply", @"icon": @"arrow.uturn.forward"},
                    @{@"title": @"长按搜索表情", @"subtitle": @"长按<聊天输入框>快速搜索表情", @"type": @"switch", @"key": @"EnableLongPressSearchEmoji", @"icon": @"smiley"},
                    @{@"title": @"长按发送照片", @"subtitle": @"长按<照片/截屏>悬浮按钮自动发送", @"type": @"switch", @"key": @"EnableLongPressSendPhoto", @"icon": @"photo.stack"},
                    @{@"title": @"通话回拨确认", @"subtitle": @"<语音/视频>通话回拨二次确认", @"type": @"switch", @"key": @"EnableCallBackConfirm",  @"icon": @"phone.badge.checkmark"},
                    @{@"title": @"拍一拍确认", @"subtitle": @"双击<头像>拍一拍二次确认", @"type": @"switch", @"key": @"EnableDoubleClickConfirm",  @"icon": @"person.crop.circle.badge.checkmark"},
                    @{@"title": @"阻止删除聊天记录", @"type": @"switch", @"key": @"EnablePreventDeleteChatRecord",  @"icon": @"trash.slash"},
                    @{@"title": @"自动播放实况照片", @"type": @"switch", @"key": @"EnablePlayLivePhoto",  @"icon": @"livephoto.play"},
                    @{@"title": @"朋友圈显示详细时间", @"subtitle": @"时间格式：yyyy-MM-dd HH:mm", @"type": @"switch", @"key": @"EnablePreciseTime",  @"icon": @"calendar.badge.clock"}
                ]
            },
            @{
                @"section": @"其它设置",
                @"items": @[
                    @{@"title": @"热更新设置", @"subtitle": @"调整动态下发资源", @"type": @"subpage", @"key": @"HotUpdatesSettings", @"icon": @"icloud"},
                    @{@"title": @"禁用热更新", @"subtitle": @"@Netskao", @"type": @"switch", @"key": @"DisableHotUpdates", @"parent": @"HotUpdatesSettings", @"icon": @"xmark.icloud", @"color": @"systemRedColor"},
                    @{@"title": @"聊天实况照片", @"subtitle": @"仅支持8.0.57+  @Netskao", @"type": @"switch", @"key": @"EnableChatLivePhotos", @"parent": @"HotUpdatesSettings", @"icon": @"livephoto"},
                    @{@"title": @"清理缓存", @"subtitle": @"清理临时文件和缓存数据", @"type": @"button", @"action": @"clearCache", @"rightValue": @"计算中", @"icon": @"trash", @"color": @"systemRedColor"}
                ]
            },
            @{
                @"section": @"插件设置",
                @"items": @[
                    @{@"title": @"主题模式", @"type": @"dropdown", @"key": @"theme", @"options": @[@"跟随系统", @"浅色模式", @"深色模式"], @"action": @"showThemeSelectionForItem:atIndexPath:", @"icon": @"sun.max"},
                    @{@"title": @"导出配置", @"subtitle": @"分享或保存配置", @"type": @"button", @"action": @"exportConfig", @"icon": @"square.and.arrow.up", @"color": @"systemRedColor"},
                    @{@"title": @"导入配置", @"subtitle": @"从文件导入配置", @"type": @"button", @"action": @"importConfig", @"icon": @"square.and.arrow.down", @"color": @"systemRedColor"},
                    @{@"title": @"重置配置", @"subtitle": @"恢复默认设置", @"type": @"button", @"action": @"resetConfig", @"icon": @"arrow.triangle.2.circlepath", @"color": @"systemRedColor"}
                ]
            },
            @{
                @"section": @"关于",
                @"items": @[
                    @{@"title": WCName, @"subtitle": @"获取插件最新版本", @"type": @"normal", @"action": @"WCUpdate", @"rightValue": WCVersion, @"icon": @"exclamationmark.circle"},
                    @{@"title": @"更新日志", @"subtitle": @"查看更新历史记录", @"type": @"normal", @"action": @"WCLog", @"icon": @"doc.text"}
                ]
            }
        ];
    }

    // 加载或初始化配置
    [self loadConfig];

    // 应用主题
    NSString *selectedTheme = self.config[@"theme"] ?: @"跟随系统";
    [self applyTheme:selectedTheme];

    // 初始化表格视图
    self.title = self.isSubpage ? self.title : WCSettingsName;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60.0;
//    self.tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionHeaderHeight = 40.0;
    self.tableView.sectionFooterHeight = 0.0;
    self.tableView.backgroundColor = [self dynamicBackgroundColor];
    [self.view addSubview:self.tableView];

    // 注册自定义页眉和页脚
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"HeaderView"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"FooterView"];

    // 初始化动态数据源
    self.filteredSettings = [NSMutableArray arrayWithArray:self.settings];
    [self updateFilteredSettings];

    // 初始化缓存显示
    [self updateCacheDisplayWithSize:@"计算中"];
    self.cachedCacheSize = nil;

    // 异步计算缓存大小
    __weak WCHookSettingViewController *weakSelf = self;
    [self getCacheSizeAsyncWithCompletion:^(NSString *cacheSize) {
        __strong WCHookSettingViewController *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        strongSelf.cachedCacheSize = cacheSize;
        [strongSelf updateCacheDisplayWithSize:cacheSize];
        [strongSelf.tableView reloadData];
    }];

    // 异步检查版本更新
    [self checkVersionUpdateAsync];

    // 刷新设置页面
    [self refreshSettings];
}

// 在加载页面前保存配置
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadConfig];
    [self saveConfig];
}

#pragma mark - 表格视图数据源
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.filteredSettings.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *items = self.filteredSettings[section][@"items"];
    return items.count;
}

// 配置表格视图的section页眉
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"HeaderView"];
    header.textLabel.text = self.filteredSettings[section][@"section"];
    header.textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    header.textLabel.textColor = [UIColor systemGrayColor];
    header.contentView.backgroundColor = [self dynamicBackgroundColor];
    return header;
}

// 配置表格视图的单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.filteredSettings[indexPath.section][@"items"][indexPath.row];
    NSString *type = item[@"type"];
    NSString *identifier = [NSString stringWithFormat:@"Cell_%@", type];
    
    UITableViewCellStyle cellStyle = UITableViewCellStyleSubtitle;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
        cell.detailTextLabel.textColor = [UIColor systemGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
            return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [WCSettingColor colorFromHexString:@"#1F1F1FFF"] : [WCSettingColor colorFromHexString:@"#FFFFFFFF"];
        }];
    }
    
    cell.textLabel.text = item[@"title"];
    
    BOOL hasSubtitle = item[@"subtitle"] && [item[@"subtitle"] length] > 0;
    BOOL needsDetailText = [type isEqualToString:@"slider"] || [type isEqualToString:@"dropdown"];
    
    if (hasSubtitle) {
        cell.detailTextLabel.text = item[@"subtitle"];
    } else if (needsDetailText) {
        if ([type isEqualToString:@"slider"]) {
            NSNumber *value = self.config[item[@"key"]] ?: item[@"defaultValue"] ?: item[@"minValue"];
            NSString *valueText = [item[@"showPercentage"] boolValue] ? [NSString stringWithFormat:@"%d%%", (int)[value floatValue]] : [NSString stringWithFormat:@"%d", (int)[value floatValue]];
            cell.detailTextLabel.text = valueText;
        } else if ([type isEqualToString:@"dropdown"]) {
            cell.detailTextLabel.text = self.config[item[@"key"]] ?: item[@"options"][0];
        }
    } else {
        cell.detailTextLabel.text = nil;
    }
    
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSString *colorName = item[@"color"] ?: @"labelColor";
    if ([UIColor respondsToSelector:NSSelectorFromString(colorName)]) {
        cell.textLabel.textColor = [UIColor performSelector:NSSelectorFromString(colorName)];
    } else {
        cell.textLabel.textColor = [UIColor labelColor];
    }
    
    if ([type isEqualToString:@"switch"]) {
        UISwitch *sw = [[UISwitch alloc] init];
        id defaultValue = item[@"defaultValue"] ?: @(NO);
        sw.on = self.config[item[@"key"]] ? [self.config[item[@"key"]] boolValue] : [defaultValue boolValue];
        [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        sw.tag = indexPath.row + indexPath.section * 1000;
        cell.accessoryView = sw;
        cell.accessibilityLabel = [NSString stringWithFormat:@"%@开关，%@", item[@"title"], item[@"subtitle"] ?: @""];
    } else if ([type isEqualToString:@"slider"]) {
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
        slider.minimumValue = [item[@"minValue"] floatValue];
        slider.maximumValue = [item[@"maxValue"] floatValue];
        NSNumber *defaultValue = item[@"defaultValue"] ?: @(slider.minimumValue);
        slider.value = self.config[item[@"key"]] ? [self.config[item[@"key"]] floatValue] : [defaultValue floatValue];
        [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        slider.tag = indexPath.row + indexPath.section * 1000;
        cell.accessoryView = slider;
        NSString *valueText = [item[@"showPercentage"] boolValue] ? [NSString stringWithFormat:@"%d%%", (int)slider.value] : [NSString stringWithFormat:@"%d", (int)slider.value];
        cell.detailTextLabel.text = valueText;
        cell.accessibilityLabel = [NSString stringWithFormat:@"%@滑块，%@", item[@"title"], item[@"subtitle"] ?: @""];
    } else if ([type isEqualToString:@"text"]) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
        textField.text = self.config[item[@"key"]] ?: item[@"defaultValue"];
        textField.placeholder = @"请输入";
        textField.delegate = self;
        textField.tag = indexPath.row + indexPath.section * 1000;
        textField.textAlignment = NSTextAlignmentRight;
        textField.font = [UIFont systemFontOfSize:15];
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        cell.accessoryView = textField;
        cell.accessibilityLabel = [NSString stringWithFormat:@"%@输入框，%@", item[@"title"], item[@"subtitle"] ?: @""];
    } else if ([type isEqualToString:@"dropdown"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.detailTextLabel.text = self.config[item[@"key"]] ?: item[@"options"][0];
        cell.accessibilityLabel = [NSString stringWithFormat:@"%@下拉菜单，%@", item[@"title"], item[@"subtitle"] ?: @""];
    } else if ([type isEqualToString:@"subpage"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessibilityLabel = [NSString stringWithFormat:@"%@子页面，%@", item[@"title"], item[@"subtitle"] ?: @""];
    } else if ([type isEqualToString:@"button"]) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSString *rightValue = item[@"rightValue"];
        if (rightValue && rightValue.length > 0) {
            UILabel *rightLabel = [[UILabel alloc] init];
            rightLabel.text = rightValue;
            rightLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
            rightLabel.textColor = [UIColor systemGrayColor];
            [rightLabel sizeToFit];
            cell.accessoryView = rightLabel;
        }
        cell.accessibilityLabel = [NSString stringWithFormat:@"%@按钮，%@", item[@"title"], item[@"subtitle"] ?: @""];
    } else if ([type isEqualToString:@"normal"]) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    static const NSInteger kRightLabelTag = 9999;
    NSString *rightValue = item[@"rightValue"];
    UILabel *rightLabel = [cell.contentView viewWithTag:kRightLabelTag];
    if (!rightLabel) {
        rightLabel = [[UILabel alloc] init];
        rightLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        rightLabel.textColor = [UIColor systemGrayColor];
        rightLabel.textAlignment = NSTextAlignmentRight;
        rightLabel.tag = kRightLabelTag;
        rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:rightLabel];
        [NSLayoutConstraint activateConstraints:@[
            [rightLabel.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [rightLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-8],
            [rightLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:cell.contentView.leadingAnchor constant:150]
        ]];
        [rightLabel setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                    forAxis:UILayoutConstraintAxisHorizontal];
        [rightLabel setContentHuggingPriority:UILayoutPriorityDefaultLow
                                      forAxis:UILayoutConstraintAxisHorizontal];
    }
    rightLabel.text = rightValue;
    rightLabel.hidden = (rightValue.length == 0);
    cell.accessibilityLabel = [NSString stringWithFormat:@"%@，%@", item[@"title"], item[@"subtitle"] ?: @""];
} else if ([type isEqualToString:@"colorPicker"]) {
        BOOL hasLight = item[@"lightKey"] != nil;
        BOOL hasDark = item[@"darkKey"] != nil;
        NSInteger numColors = (hasLight ? 1 : 0) + (hasDark ? 1 : 0);
        CGFloat containerWidth = numColors == 1 ? 60.0 : numColors * 28.0;
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerWidth, 44)];
        
        CGFloat xOffset = numColors == 1 ? (containerWidth - 24.0) / 2.0 : 4.0;
        if (hasLight) {
            UIView *lightColorView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 10, 24, 24)];
            lightColorView.layer.cornerRadius = 12;
            lightColorView.layer.borderWidth = 1.5;
            NSString *lightHex = self.config[item[@"lightKey"]] ?: @"#FFFFFFFF";
            UIColor *lightColor = [WCSettingColor colorFromHexString:lightHex];
            lightColorView.backgroundColor = lightColor;
            lightColorView.layer.borderColor = [self borderColorForFill:lightColor].CGColor;
            lightColorView.tag = (indexPath.row + indexPath.section * 1000) * 10 + 1;
            [lightColorView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorViewTapped:)]];
            lightColorView.userInteractionEnabled = YES;
            [containerView addSubview:lightColorView];
            xOffset += numColors == 1 ? 0 : 28.0;
        }
        
        if (hasDark) {
            UIView *darkColorView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 10, 24, 24)];
            darkColorView.layer.cornerRadius = 12;
            darkColorView.layer.borderWidth = 1.5;
            NSString *darkHex = self.config[item[@"darkKey"]] ?: @"#000000FF";
            UIColor *darkColor = [WCSettingColor colorFromHexString:darkHex];
            darkColorView.backgroundColor = darkColor;
            darkColorView.layer.borderColor = [self borderColorForFill:darkColor].CGColor;
            darkColorView.tag = (indexPath.row + indexPath.section * 1000) * 10 + 2;
            [darkColorView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorViewTapped:)]];
            darkColorView.userInteractionEnabled = YES;
            [containerView addSubview:darkColorView];
        }
        
        cell.accessoryView = containerView;
        cell.accessibilityLabel = [NSString stringWithFormat:@"%@颜色选择器，%@", item[@"title"], item[@"subtitle"] ?: @""];
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessibilityLabel = [NSString stringWithFormat:@"%@，%@", item[@"title"], item[@"subtitle"] ?: @""];
    }

    // 控件默认icon
    NSString *iconName = item[@"icon"] ?: @"gearshape";
    cell.imageView.image = [UIImage systemImageNamed:iconName];
    
    return cell;
}

// 配置表格视图的section页脚
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == self.filteredSettings.count - 1 && !self.isSubpage) {
        UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"FooterView"];
        footer.textLabel.text = [NSString stringWithFormat:@"@Waa\nhttps://github.com/iamwaa"];
        footer.textLabel.numberOfLines = 0;
        footer.textLabel.textAlignment = NSTextAlignmentLeft;
        footer.textLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        footer.textLabel.textColor = [UIColor systemGrayColor];
        footer.contentView.backgroundColor = [self dynamicBackgroundColor];
        
        footer.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openHomepage)];
        [footer addGestureRecognizer:tap];
        
        return footer;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return (section == self.filteredSettings.count - 1 && !self.isSubpage) ? 50.0 : 0.0;
}

// 打开主页
- (void)openHomepage {
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://github.com/iamwaa"]];
    [self presentViewController:safariVC animated:YES completion:nil];
}

#pragma mark - 控件交互处理
// 处理开关控件变化
- (void)switchChanged:(UISwitch *)sw {
    NSIndexPath *indexPath = [self indexPathForTag:sw.tag];
    NSDictionary *item = self.filteredSettings[indexPath.section][@"items"][indexPath.row];
    self.config[item[@"key"]] = @(sw.isOn);
    [self saveConfig];
    
    [self updateFilteredSettings];
    [self.tableView reloadData];
}

// 处理滑块控件变化
- (void)sliderChanged:(UISlider *)slider {
    NSIndexPath *indexPath = [self indexPathForTag:slider.tag];
    NSDictionary *item = self.filteredSettings[indexPath.section][@"items"][indexPath.row];
    self.config[item[@"key"]] = @(slider.value);
    [self saveConfig];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *valueText = [item[@"showPercentage"] boolValue] ? [NSString stringWithFormat:@"%d%%", (int)slider.value] : [NSString stringWithFormat:@"%d", (int)slider.value];
    cell.detailTextLabel.text = valueText;
}

// 处理文本输入框实时变化
- (void)textFieldDidChange:(UITextField *)textField {
    NSIndexPath *indexPath = [self indexPathForTag:textField.tag];
    NSDictionary *item = self.filteredSettings[indexPath.section][@"items"][indexPath.row];
    self.config[item[@"key"]] = textField.text ?: @"";
    [self saveConfig];
}

// 处理文本输入框编辑结束（作为备用）
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self textFieldDidChange:textField];
}

// 处理颜色选择控件点击
- (void)colorViewTapped:(UITapGestureRecognizer *)gesture {
    UIView *colorView = gesture.view;
    NSIndexPath *indexPath = [self indexPathForTag:colorView.tag / 10];
    NSDictionary *item = self.filteredSettings[indexPath.section][@"items"][indexPath.row];
    NSString *key = colorView.tag % 10 == 1 ? item[@"lightKey"] : item[@"darkKey"];
    
    self.currentColorKey = key;
    self.currentIndexPath = indexPath;
    
    UIColorPickerViewController *colorPicker = [[UIColorPickerViewController alloc] init];
    colorPicker.delegate = self;
    colorPicker.selectedColor = [WCSettingColor colorFromHexString:self.config[key]];
    colorPicker.supportsAlpha = YES;
    [self presentViewController:colorPicker animated:YES completion:nil];
}

// 处理颜色选择器选择颜色
- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)controller {
    NSString *hexColor = [WCSettingColor hexStringFromColor:controller.selectedColor];
    self.config[self.currentColorKey] = hexColor;
    [self saveConfig];
    
    [self.tableView reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

// 处理颜色选择器完成
- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

// 处理表格视图单元格点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.filteredSettings[indexPath.section][@"items"][indexPath.row];
    NSString *type = item[@"type"];
    NSString *action = item[@"action"];
    
    // 处理子页面类型
    if ([type isEqualToString:@"subpage"]) {
        [self showSubpageForItem:item];
    }
    // 处理下拉菜单类型
    else if ([type isEqualToString:@"dropdown"] && action && [self respondsToSelector:NSSelectorFromString(action)]) {
        [self performSelector:NSSelectorFromString(action) withObject:item withObject:indexPath];
    }
    // 处理按钮或普通类型
    else if (([type isEqualToString:@"button"] || [type isEqualToString:@"normal"]) && action && [self respondsToSelector:NSSelectorFromString(action)]) {
        [self performSelector:NSSelectorFromString(action)];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 辅助方法
// 动态背景颜色
- (UIColor *)dynamicBackgroundColor {
    return [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
        return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark
            ? [WCSettingColor colorFromHexString:@"#000000FF"]
            : [WCSettingColor colorFromHexString:@"#F2F2F2FF"];
    }];
}

// 更新dependsOn设置项
- (void)updateFilteredSettings {
    self.filteredSettings = [NSMutableArray array];
    
    for (NSDictionary *section in self.settings) {
        NSMutableArray *filteredItems = [NSMutableArray array];
        for (NSDictionary *item in section[@"items"]) {
            NSArray *dependsOnKeys = item[@"dependsOn"];
            NSString *parentKey = item[@"parent"];
            BOOL shouldInclude = YES;
            
            if ([dependsOnKeys isKindOfClass:[NSArray class]]) {
                for (NSString *key in dependsOnKeys) {
                    if (![self.config[key] boolValue]) {
                        shouldInclude = NO;
                        break;
                    }
                }
            } else if ([dependsOnKeys isKindOfClass:[NSString class]]) {
                shouldInclude = [self.config[dependsOnKeys] boolValue];
            }
            
            if (parentKey && !self.isSubpage) {
                shouldInclude = NO;
            }
            
            if (!dependsOnKeys && !parentKey || shouldInclude) {
                [filteredItems addObject:item];
            }
        }
        if (filteredItems.count > 0) {
            [self.filteredSettings addObject:@{@"section": section[@"section"], @"items": filteredItems}];
        }
    }
}

// 显示子页面
- (void)showSubpageForItem:(NSDictionary *)item {
    WCHookSettingViewController *subpageVC = [[WCHookSettingViewController alloc] init];
    subpageVC.title = item[@"title"];
    subpageVC.isSubpage = YES;
    
    NSMutableDictionary *sectionDict = [NSMutableDictionary dictionary];
    NSMutableArray *sectionOrder = [NSMutableArray array];
    
    for (NSDictionary *section in self.settings) {
        for (NSDictionary *sectionItem in section[@"items"]) {
            if ([sectionItem[@"parent"] isEqualToString:item[@"key"]]) {
                NSString *subpageSection = sectionItem[@"subpageSection"] ?: @"默认设置";
                if (!sectionDict[subpageSection]) {
                    sectionDict[subpageSection] = [NSMutableArray array];
                    [sectionOrder addObject:subpageSection];
                }
                [sectionDict[subpageSection] addObject:sectionItem];
            }
        }
    }
    
    NSMutableArray *subpageSettings = [NSMutableArray array];
    for (NSString *sectionName in sectionOrder) {
        [subpageSettings addObject:@{@"section": sectionName, @"items": sectionDict[sectionName]}];
    }
    
    subpageVC.settings = subpageSettings;
    subpageVC.config = self.config;
    subpageVC.configFilePath = self.configFilePath;
    subpageVC.cachedCacheSize = self.cachedCacheSize;
    
    [self.navigationController pushViewController:subpageVC animated:YES];
}

// 根据标签获取索引路径
- (NSIndexPath *)indexPathForTag:(NSInteger)tag {
    NSInteger section = tag / 1000;
    NSInteger row = tag % 1000;
    return [NSIndexPath indexPathForRow:row inSection:section];
}

// 显示弹窗
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

// 颜色选择器处理方法
- (UIColor *)darkerColor:(UIColor *)color factor:(CGFloat)factor {
    CGFloat hue, saturation, brightness, alpha;
    if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        brightness = MAX(brightness * factor, 0.0);
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }
    return color;
}

- (UIColor *)lighterColor:(UIColor *)color {
    CGFloat hue, saturation, brightness, alpha;
    if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        brightness = MIN(brightness + 0.2, 1.0);
        saturation = MAX(saturation - 0.05, 0.0);
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }
    return color;
}

- (UIColor *)borderColorForFill:(UIColor *)color {
    CGFloat hue, saturation, brightness, alpha;
    if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        if (brightness > 0.7) {
            return [self darkerColor:color factor:0.8];
        } else {
            return [self lighterColor:color];
        }
    }
    return [UIColor separatorColor];
}

#pragma mark - 缓存管理
// 获取缓存大小
- (void)getCacheSizeAsyncWithCompletion:(void (^)(NSString *))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *paths = @[
            NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,
            NSTemporaryDirectory()
        ];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        unsigned long long totalSize = 0;
        
        for (NSString *cachePath in paths) {
            NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:cachePath];
            for (NSString *fileName in enumerator) {
                NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
                NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:nil];
                if (attributes) {
                    totalSize += [attributes fileSize];
                }
            }
        }
        
        NSString *result;
        if (totalSize == 0) {
            result = @"0.00 MB";
        } else {
            CGFloat sizeInMB = (CGFloat)totalSize / (1024.0 * 1024.0);
            result = [NSString stringWithFormat:@"%.2f MB", sizeInMB];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(result);
            }
        });
    });
}

// 清理缓存文件
- (void)clearCacheFiles {
    NSArray *paths = @[
        NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,
        NSTemporaryDirectory()
    ];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *protectedExtensions = @[@"plist", @"db"];
    
    for (NSString *cachePath in paths) {
        NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:cachePath];
        for (NSString *fileName in enumerator) {
            NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
            NSString *extension = [[filePath pathExtension] lowercaseString];
            
            if (![protectedExtensions containsObject:extension]) {
                [fileManager removeItemAtPath:filePath error:nil];
            }
        }
    }
}

// 更新缓存显示
- (void)updateCacheDisplayWithSize:(NSString *)sizeString {
    NSMutableArray *newSettings = [NSMutableArray arrayWithArray:self.settings];
    
    for (NSInteger section = 0; section < newSettings.count; section++) {
        NSMutableDictionary *sectionDict = [newSettings[section] mutableCopy];
        NSMutableArray *items = [sectionDict[@"items"] mutableCopy];
        
        for (NSInteger row = 0; row < items.count; row++) {
            NSMutableDictionary *item = [items[row] mutableCopy];
            if ([item[@"action"] isEqualToString:@"clearCache"]) {
                item[@"rightValue"] = sizeString;
                items[row] = item;
            }
        }
        
        sectionDict[@"items"] = items;
        newSettings[section] = sectionDict;
    }
    
    self.settings = newSettings;
    [self updateFilteredSettings];
}

// 显示清理中状态
- (void)showClearingState {
    NSMutableArray *newSettings = [NSMutableArray arrayWithArray:self.settings];
    
    for (NSInteger section = 0; section < newSettings.count; section++) {
        NSMutableDictionary *sectionDict = [newSettings[section] mutableCopy];
        NSMutableArray *items = [sectionDict[@"items"] mutableCopy];
        
        for (NSInteger row = 0; row < items.count; row++) {
            NSMutableDictionary *item = [items[row] mutableCopy];
            if ([item[@"action"] isEqualToString:@"clearCache"]) {
                item[@"rightValue"] = @"清理中";
                items[row] = item;
            }
        }
        
        sectionDict[@"items"] = items;
        newSettings[section] = sectionDict;
    }
    
    self.settings = newSettings;
    [self updateFilteredSettings];
    [self.tableView reloadData];
}

// 清理缓存
- (void)clearCache {
    __weak WCHookSettingViewController *weakSelf = self;
    
    [self getCacheSizeAsyncWithCompletion:^(NSString *cacheSize) {
        __strong WCHookSettingViewController *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSString *message = [NSString stringWithFormat:@"当前缓存大小为 %@，确定要清除所有缓存吗？", cacheSize];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清理缓存" 
                                                                     message:message 
                                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            __strong WCHookSettingViewController *strongSelf = weakSelf;
            [strongSelf showClearingState];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [strongSelf clearCacheFiles];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf updateCacheDisplayWithSize:@"0.00 MB"];
                    [strongSelf.tableView reloadData];
                    [strongSelf showAlertWithTitle:@"提示" message:@"缓存已清除"];
                });
            });
        }]];
        
        [strongSelf presentViewController:alert animated:YES completion:nil];
    }];
}

#pragma mark - 主题管理
// 应用主题
- (void)applyTheme:(NSString *)theme {
    UIColor *backgroundColor;
    UIColor *arrowColor;
    
    if ([theme isEqualToString:@"跟随系统"]) {
        if (@available(iOS 13.0, *)) self.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
        arrowColor = [UIColor labelColor];
        backgroundColor = [self dynamicBackgroundColor];
    } else if ([theme isEqualToString:@"浅色模式"]) {
        if (@available(iOS 13.0, *)) self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        arrowColor = [UIColor blackColor];
        backgroundColor = [WCSettingColor colorFromHexString:@"#F2F2F2FF"];
    } else if ([theme isEqualToString:@"深色模式"]) {
        if (@available(iOS 13.0, *)) self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
        arrowColor = [UIColor whiteColor];
        backgroundColor = [WCSettingColor colorFromHexString:@"#000000FF"];
    }
    
    self.view.backgroundColor = backgroundColor;
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = backgroundColor;
        appearance.shadowColor = nil;
        appearance.titleTextAttributes = @{ NSForegroundColorAttributeName: arrowColor };
        
        self.navigationItem.standardAppearance = appearance;
        self.navigationItem.scrollEdgeAppearance = appearance;
        self.navigationItem.compactAppearance = appearance;
    } else {
        navBar.barTintColor = backgroundColor;
        navBar.shadowImage = [UIImage new];
        navBar.titleTextAttributes = @{ NSForegroundColorAttributeName: arrowColor };
    }
    
    // 隐藏系统默认返回按钮
    self.navigationItem.hidesBackButton = YES;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // 调整箭头大小和粗细
    CGFloat arrowSize = 20;
    UIImageSymbolWeight arrowWeight = UIImageSymbolWeightLight;
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:arrowSize weight:arrowWeight];
    UIImage *arrowImage = [UIImage systemImageNamed:@"chevron.left" withConfiguration:config];
    
    [backButton setImage:arrowImage forState:UIControlStateNormal];
    backButton.tintColor = arrowColor;
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [backButton sizeToFit];
    
    [backButton addTarget:self action:@selector(customBackAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    // 刷新状态栏
    [self setNeedsStatusBarAppearanceUpdate];
}

// 自定义返回动作
- (void)customBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

// 显示主题选择
- (void)showThemeSelectionForItem:(NSDictionary *)item atIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择主题" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *options = item[@"options"];
    NSString *currentValue = self.config[item[@"key"]] ?: options[0];
    
    for (NSString *option in options) {
        UIAlertActionStyle style = [option isEqualToString:currentValue] ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault;
        [alert addAction:[UIAlertAction actionWithTitle:option style:style handler:^(UIAlertAction * _Nonnull action) {
            self.config[item[@"key"]] = option;
            [self saveConfig];
            [self applyTheme:option];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 配置管理
// 加载配置文件（添加错误处理和默认值）
- (void)loadConfig {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *dirPath = [self.configFilePath stringByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:dirPath]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            [self showAlertWithTitle:@"错误" message:@"创建配置目录失败"];
            return;
        }
    }
    
    if ([fileManager fileExistsAtPath:self.configFilePath]) {
        NSError *readError = nil;
        NSData *data = [NSData dataWithContentsOfFile:self.configFilePath options:0 error:&readError];
        if (readError) {
            [self showAlertWithTitle:@"错误" message:@"加载配置失败，使用默认配置"];
            self.config = [NSMutableDictionary dictionary];
        } else if (data) {
            NSError *plistError = nil;
            id plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:NULL error:&plistError];
            if (plistError || ![plist isKindOfClass:[NSDictionary class]]) {
                [self showAlertWithTitle:@"错误" message:@"配置格式无效，使用默认配置"];
                self.config = [NSMutableDictionary dictionary];
            } else {
                self.config = [NSMutableDictionary dictionaryWithDictionary:plist];
            }
        } else {
            self.config = [NSMutableDictionary dictionary];
        }
    } else {
        self.config = [NSMutableDictionary dictionary];
    }
    
    BOOL needSave = NO;
    
    for (NSDictionary *section in self.settings) {
        NSArray *items = section[@"items"];
        for (NSDictionary *item in items) {
            NSString *key = item[@"key"];
            NSString *lightKey = item[@"lightKey"];
            NSString *darkKey = item[@"darkKey"];
            
            if (key && ![self.config.allKeys containsObject:key]) {
                id defaultValue = nil;
                
                if (item[@"defaultValue"] != nil) {
                    defaultValue = item[@"defaultValue"];
                } else {
                    NSString *type = item[@"type"];
                    if ([type isEqualToString:@"switch"]) {
                        defaultValue = @(NO);
                    } else if ([type isEqualToString:@"slider"]) {
                        defaultValue = item[@"minValue"] ?: @(0);
                    } else if ([type isEqualToString:@"text"]) {
                        defaultValue = @"";
                    } else if ([type isEqualToString:@"dropdown"]) {
                        NSArray *options = item[@"options"];
                        defaultValue = (options.count > 0 ? options[0] : @"");
                    } else {
                        defaultValue = @"";
                    }
                }
                
                self.config[key] = defaultValue;
                needSave = YES;
            }
            
            if (lightKey && ![self.config.allKeys containsObject:lightKey]) {
                self.config[lightKey] = @"#FFFFFFFF";
                needSave = YES;
            }
            
            if (darkKey && ![self.config.allKeys containsObject:darkKey]) {
                self.config[darkKey] = @"#000000FF";
                needSave = YES;
            }
        }
    }
    
    if (needSave) {
        [self saveConfig];
    }
}

// 保存配置文件
- (void)saveConfig {
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:self.config format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    if (error) {
        [self showAlertWithTitle:@"错误" message:@"序列化配置失败"];
        return;
    }
    NSError *writeError = nil;
    BOOL success = [data writeToFile:self.configFilePath options:NSDataWritingAtomic error:&writeError];
    if (!success || writeError) {
        [self showAlertWithTitle:@"错误" message:@"保存配置失败"];
    }
}

// 刷新设置页面
- (void)refreshSettings {
    [self updateFilteredSettings];
    [self.tableView reloadData];
}

// 导出配置文件
- (void)exportConfig {
    NSString *tmpPath = NSTemporaryDirectory();
    NSString *exportPath = [tmpPath stringByAppendingPathComponent:@"com.waa.wechathook_export.plist"];
    
    BOOL success = [self.config writeToFile:exportPath atomically:YES];
    
    if (success) {
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:exportPath]];
        self.documentController.delegate = self;
        [self.documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
    } else {
        [self showAlertWithTitle:@"错误" message:@"导出配置失败"];
    }
}

// 导入配置文件
- (void)importConfig {
    self.documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    self.documentPicker.delegate = self;
    self.documentPicker.allowsMultipleSelection = NO;
    [self presentViewController:self.documentPicker animated:YES completion:nil];
}

// 提供文档交互控制器的视图控制器
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

// 处理文档选择器选择的文件
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count > 0) {
        NSURL *url = urls[0];
        NSDictionary *importedConfig = [NSDictionary dictionaryWithContentsOfURL:url];
        if (importedConfig) {
            self.config = [NSMutableDictionary dictionaryWithDictionary:importedConfig];
            [self saveConfig];
            [self updateFilteredSettings];
            [self.tableView reloadData];
            [self showAlertWithTitle:@"提示" message:@"配置已导入"];
        } else {
            [self showAlertWithTitle:@"错误" message:@"导入配置失败，文件格式不正确"];
        }
    }
}

// 重置配置文件
- (void)resetConfig {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"重置配置" message:@"确定要恢复默认设置吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.config = [NSMutableDictionary dictionary];
        [self saveConfig];
        [self updateFilteredSettings];
        [self.tableView reloadData];
        [self showAlertWithTitle:@"提示" message:@"配置已重置"];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 版本更新
- (void)WCUpdate {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"检查更新" 
                                                                 message:@"正在检查更新..." 
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/iamwaa/WeChatHook/refs/heads/main/WCLog.json"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !data) {
                alert.message = @"检查更新失败，请检查网络连接";
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                return;
            }
            
            NSError *jsonError = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (jsonError || ![jsonDict isKindOfClass:[NSDictionary class]]) {
                alert.message = @"解析更新信息失败";
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                return;
            }
            
            NSString *latestVersion = jsonDict[@"version"];
            NSString *updateUrl = jsonDict[@"update_url"] ?: @"https://github.com/iamwaa";
            
            if (!latestVersion) {
                alert.message = @"未找到版本信息";
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                return;
            }
            
            if ([latestVersion isEqualToString:WCVersion]) {
                alert.message = [NSString stringWithFormat:@"当前版本: %@\n已是最新版本", WCVersion];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            } else {
                alert.message = [NSString stringWithFormat:@"当前版本: %@\n发现新版本: %@", WCVersion, latestVersion];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *url = [NSURL URLWithString:updateUrl];
                    if (url) {
                        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
                        [self presentViewController:safariVC animated:YES completion:nil];
                    }
                }]];
            }
        });
    }];
    
    [task resume];
    
    if (@available(iOS 13.0, *)) {
        alert.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
    }
}

// 异步检查版本更新
- (void)checkVersionUpdateAsync {
    __weak WCHookSettingViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/iamwaa/WeChatHook/refs/heads/main/WCLog.json"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong WCHookSettingViewController *strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (data) {
                NSError *jsonError = nil;
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                if (!jsonError && [jsonDict isKindOfClass:[NSDictionary class]]) {
                    NSString *latestVersion = jsonDict[@"version"];
                    
                    if (latestVersion && ![latestVersion isEqualToString:WCVersion]) {
                        for (NSInteger section = 0; section < strongSelf.settings.count; section++) {
                            NSMutableDictionary *sectionDict = [strongSelf.settings[section] mutableCopy];
                            NSMutableArray *items = [sectionDict[@"items"] mutableCopy];
                            
                            for (NSInteger row = 0; row < items.count; row++) {
                                NSMutableDictionary *item = [items[row] mutableCopy];
                                if ([item[@"action"] isEqualToString:@"WCUpdate"]) {
                                    item[@"rightValue"] = @"有更新";
                                    items[row] = item;
                                    
                                    sectionDict[@"items"] = items;
                                    NSMutableArray *newSettings = [strongSelf.settings mutableCopy];
                                    newSettings[section] = sectionDict;
                                    strongSelf.settings = newSettings;
                                    
                                    [strongSelf updateFilteredSettings];
                                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                                    [strongSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                    
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        });
    });
}

#pragma mark - 查看日志
- (void)WCLog {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"更新日志" message:@"加载中..." preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    titleParagraphStyle.alignment = NSTextAlignmentCenter;
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"更新日志" attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightBold],
        NSForegroundColorAttributeName: [UIColor labelColor],
        NSParagraphStyleAttributeName: titleParagraphStyle
    }];
    [alert setValue:attributedTitle forKey:@"attributedTitle"];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil]];
    
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/iamwaa/WeChatHook/refs/heads/main/WCLog.json"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *logText = error ? @"无法加载更新日志，请检查网络连接。" : @"更新日志为空。";
        
        if (!error && data) {
            NSError *jsonError = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (!jsonError && [jsonDict isKindOfClass:[NSDictionary class]]) {
                NSString *logContent = jsonDict[@"log"];
                if (logContent && [logContent length] > 0) {
                    logText = logContent;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.alignment = NSTextAlignmentLeft;
            NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:logText attributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightRegular],
                NSForegroundColorAttributeName: [UIColor labelColor],
                NSParagraphStyleAttributeName: paragraphStyle
            }];
            [alert setValue:attributedMessage forKey:@"attributedMessage"];
        });
    }];
    [task resume];
    
    if (@available(iOS 13.0, *)) {
        alert.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
    }
    [self presentViewController:alert animated:YES completion:nil];
}

@end

#pragma mark - 插件设置入口
static BOOL g_WCPluginsMgrRegistered = NO;

%hook NewSettingViewController

- (void)reloadTableData {
    if (g_WCPluginsMgrRegistered) {
        %orig;
        return;
    }

    %orig;

    WCTableViewManager *tableViewMgr = MSHookIvar<WCTableViewManager *>(self, "m_tableViewMgr");
    if (!tableViewMgr) {
        return;
    }

    WCTableViewSectionManager *sectionMgr = [%c(WCTableViewSectionManager) sectionInfoDefaut];
    WCTableViewNormalCellManager *settingCell =
        [%c(WCTableViewNormalCellManager) normalCellForSel:@selector(wbplugin_openSetting)
                                                    target:self
                                                     title:WCName
                                                rightValue:WCVersion
                                             accessoryType:1];
    [sectionMgr addCell:settingCell];
    [tableViewMgr insertSection:sectionMgr At:0];
    MMTableView *tableView = [tableViewMgr getTableView];
    [tableView reloadData];
}

%new
- (void)wbplugin_openSetting {
    WCHookSettingViewController *vc = [[WCHookSettingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

%end

%ctor {
    Class pluginsMgrClass = NSClassFromString(@"WCPluginsMgr");
    if (pluginsMgrClass) {
        WCPluginsMgr *mgr = [objc_getClass("WCPluginsMgr") sharedInstance];
        if (mgr) {
            [mgr registerControllerWithTitle:WCName
                                    version:WCVersion
                                 controller:@"WCHookSettingViewController"];
            g_WCPluginsMgrRegistered = YES;
            return;
        }
    }

    g_WCPluginsMgrRegistered = NO;
}