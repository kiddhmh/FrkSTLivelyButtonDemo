//
//  FrkSTLivelyButton.h
//  FrkSTLivelyButtonDemo
//
//  Created by Mr.Psychosis on 16/3/10.
//  Copyright © 2016年 Frank. All rights reserved.
//

#import <UIKit/UIKit.h>

//枚举按钮类型
typedef enum {
    kFrkSTLivelyButtonStyleHamburger,//三条横线
    kFrkSTLivelyButtonStyleClose,//叉号
    kFrkSTLivelyButtonStylePlus,//加号
    kFrkSTLivelyButtonStyleCirclePlus,//加号带个圈
    kFrkSTLivelyButtonStyleCircleClose,//叉号带个圈
    kFrkSTLivelyButtonStyleCaretUp,//上方向
    kFrkSTLivelyButtonStyleCaretDown,//下方向
    kFrkSTLivelyButtonStyleCaretLeft,//左方向
    kFrkSTLivelyButtonStyleCaretRight,//右方向
    kFrkSTLivelyButtonStyleArrowLeft,//左箭头
    kFrkSTLivelyButtonStyleArrowRight//右箭头
} kFrkSTLivelyButtonStyle;

@interface FrkSTLivelyButton : UIButton
//按钮基本属性
@property (strong, nonatomic) NSDictionary *options;
//向外部提供一个获取按钮类型的get方法（成员变量被设置成了私有）
- (kFrkSTLivelyButtonStyle)buttonStyle;
//接口方法，通过设置按钮类型实现按钮的动态变化（第一次使用是加载，而后才是动画）
- (void)setStyle:(kFrkSTLivelyButtonStyle)style animated:(BOOL)animated;
//设置按钮基本属性
+ (NSDictionary*)defaultOptions;


// scale to apply to the button CGPath(s) when the button is pressed. Default is 0.9:
extern NSString *const kFrkSTLivelyButtonHighlightScale;
// the button CGPaths stroke width, default 1.0f pixel
extern NSString *const kFrkSTLivelyButtonLineWidth;
// the button CGPaths stroke color, default is black
extern NSString *const kFrkSTLivelyButtonColor;
// the button CGPaths stroke color when highlighted, default is light gray
extern NSString *const kFrkSTLivelyButtonHighlightedColor;
// duration in second of the highlight (pressed down) animation, default 0.1
extern NSString *const kFrkSTLivelyButtonHighlightAnimationDuration;
// duration in second of the unhighlight (button release) animation, defualt 0.15
extern NSString *const kFrkSTLivelyButtonUnHighlightAnimationDuration;
// duration in second of the style change animation, default 0.3
extern NSString *const kFrkSTLivelyButtonStyleChangeAnimationDuration;

@end
