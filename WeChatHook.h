#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dispatch/dispatch.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

#pragma mark - Cell圆角
@interface UISearchBar (SearchGroupBarRadius);
@end

@interface ThemeBoxSegmentedView : UIView
@end

@interface MMTableViewCell : UITableViewCell
@end

@interface ColorGradientView : UIView
@end

#pragma mark - Cell圆角&置顶收藏时间
@interface MFBannerBtn : UIButton
@end

#pragma mark - 隐藏分组栏角标
@interface ThemeBadgeView : UIView
@end

#pragma mark - 隐藏我的状态
@interface TextStatePublishEntryButton : UIButton
@end
@interface TextStateFriendTopicButton : UIButton
@end

#pragma mark - 隐藏输入框内语音按钮
@interface MMGrowDictationIconView : UIButton
@end

#pragma mark - 隐藏主页+号
@interface MMBarButton : UIButton
@end

#pragma mark - 左滑快速引用
// 气泡
@interface YYAsyncImageView: UIImageView
@end

// 表情
@interface MMEmoticonView: UIView
@end

// 视频
@interface SightIconView: UIView
@end

// 链接
@interface RichTextView: UIView
@end

#pragma mark - 长按输入框搜索表情
@interface MMUIButton : UIButton
- (void)tw_installEmojiLongPress;
- (UIView *)tw_findSearchCellInView:(UIView *)view;
@end

@interface MMInputToolView : UIView
- (void)onExpressionButtonClicked:(id)sender;
@end

@interface MMUIButton (TWGesture) <UIGestureRecognizerDelegate>
@end

#pragma mark - 长按发送照片
@interface MMCapturePreviewBrowserController : UIViewController
- (void)handleSend:(id)sender;
@end

@interface UIButton (LongPressSendPhoto)
- (UIButton *)findSendButtonInView:(UIView *)view;
@end

#pragma mark - 自动播放实况照片
@interface WCC2CImageScrollView : UIView
- (void)playLivePhotoWithFile;
@end

@interface WCMediaImageScrollView : UIScrollView
@property (retain, nonatomic) UIView *imageTagView;
- (void)livePhotoButtonClickedInImageTagView:(id)a0;
- (void)displayViewModel:(id)a0 withImage:(id)a1 frame:(struct CGRect)a2;
@end

@interface WCImageFullScreenViewContainer : UIScrollView
@property (readonly, nonatomic) UIView *imageTagView;
- (void)livePhotoButtonClickedInImageTagView:(id)a0;
- (void)didDisplay;
@end

// 朋友圈显示详细时间
@interface WCDataItem : NSObject
@property (nonatomic) unsigned int createtime;
@end

@interface WCTimeLineCellView : UIView
@property (readonly, nonatomic) WCDataItem *m_dataItem;
@property (readonly, nonatomic) UILabel *m_timeLabel;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
- (void)initTimeLabel;
- (void)updateWithDataItem:(WCDataItem *)dataItem actionAreaVM:(id)actionAreaVM;
@end