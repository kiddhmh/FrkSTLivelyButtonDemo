//
//  FrkSTLivelyButton.m
//  FrkSTLivelyButtonDemo
//
//  Created by Mr.Psychosis on 16/3/10.
//  Copyright © 2016年 Frank. All rights reserved.
//

#import "FrkSTLivelyButton.h"
//网上找来的宏定义我也不知道为啥
#define GOLDEN_RATIO 1.618

//动态按钮的属性，采用常量字符串形式存储
NSString *const kFrkSTLivelyButtonHighlightScale = @"kFrkSTLivelyButtonHighlightScale";
NSString *const kFrkSTLivelyButtonLineWidth = @"kFrkSTLivelyButtonLineWidth";
NSString *const kFrkSTLivelyButtonColor = @"kFrkSTLivelyButtonColor";
NSString *const kFrkSTLivelyButtonHighlightedColor = @"kFrkSTLivelyButtonHighlightedColor";
NSString *const kFrkSTLivelyButtonHighlightAnimationDuration = @"kFrkSTLivelyButtonHighlightAnimationDuration";
NSString *const kFrkSTLivelyButtonUnHighlightAnimationDuration = @"kFrkSTLivelyButtonUnHighlightAnimationDuration";
NSString *const kFrkSTLivelyButtonStyleChangeAnimationDuration = @"kFrkSTLivelyButtonStyleChangeAnimationDuration";

@interface FrkSTLivelyButton()
//按钮类型
@property (nonatomic) kFrkSTLivelyButtonStyle buttonStyle;
//
@property (nonatomic) CGFloat dimension;
//纠错值
@property (nonatomic) CGPoint offset;
//按钮坐标中心点
@property (nonatomic) CGPoint centerPoint;
//绘制按钮的四根线（三根线＋一个圆）
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *line1Layer;
@property (nonatomic, strong) CAShapeLayer *line2Layer;
@property (nonatomic, strong) CAShapeLayer *line3Layer;
//图形数组
@property (nonatomic, strong) NSArray *shapeLayers;
@end

@implementation FrkSTLivelyButton
#pragma mark -
#pragma mark - 懒加载
//图形数组
- (NSArray*)shapeLayers{
    if (_shapeLayers == nil) {
        _shapeLayers = @[self.circleLayer, self.line1Layer, self.line2Layer, self.line3Layer];
    }
    return _shapeLayers;
}
#pragma mark -
#pragma mark - 初始化方法
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitializer];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitializer];
    }
    return self;
}
- (void)commonInitializer{
    //用四根线实现按钮的绘制（QuartzCore绘画库）
    self.line1Layer = [[CAShapeLayer alloc] init];
    self.line2Layer = [[CAShapeLayer alloc] init];
    self.line3Layer = [[CAShapeLayer alloc] init];
    self.circleLayer = [[CAShapeLayer alloc] init];
    //设置按钮基本属性
    self.options = [FrkSTLivelyButton defaultOptions];
    
    //用enumerateObjectsUsingBlock枚举对象来加载内容，将线绘制在界面上
    [@[self.line1Layer, self.line2Layer, self.line3Layer, self.circleLayer]
     enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         CAShapeLayer *layer = obj;
         layer.fillColor = [UIColor clearColor].CGColor;
         layer.anchorPoint = CGPointMake(0.0, 0.0);
         layer.lineJoin = kCALineJoinRound;
         layer.lineCap = kCALineCapRound;
         layer.contentsScale = self.layer.contentsScale;
         
         // initialize with an empty path so we can animate the path w/o having to check for NULLs.
         CGPathRef dummyPath = CGPathCreateMutable();
         layer.path = dummyPath;
         CGPathRelease(dummyPath);
         
         [self.layer addSublayer:layer];
     }];
    
    //按钮按下，执行高亮动作
    [self addTarget:self action:@selector(showHighlight) forControlEvents:UIControlEventTouchDown];
    //按钮按下抬起，执行取消高亮操作
    [self addTarget:self action:@selector(showUnHighlight) forControlEvents:UIControlEventTouchUpInside];
    //按钮按下抬起，执行取消高亮操作
    [self addTarget:self action:@selector(showUnHighlight) forControlEvents:UIControlEventTouchUpOutside];
    
    //即使按钮没能正确绘制，在程序运行时offset纠偏也能发挥作用（好不好使谁知道，我试的反正没问题）重新将中心点坐标加载出来
    self.dimension = MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.offset = CGPointMake((CGRectGetWidth(self.frame)-self.dimension)/2.0f, (CGRectGetHeight(self.frame)-self.dimension)/2.0f);
    self.centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

#pragma mark -
#pragma mark - 接口方法
//重写按钮属性的set方法
- (void)setOptions:(NSDictionary*)options{
    //属性赋值
    _options = options;
    //枚举对象加载内容，绘线
    [@[self.line1Layer, self.line2Layer, self.line3Layer, self.circleLayer]
     enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         CAShapeLayer *layer = obj;
         layer.lineWidth = [[self valueForOptionKey:kFrkSTLivelyButtonLineWidth] floatValue];
         layer.strokeColor = [[self valueForOptionKey:kFrkSTLivelyButtonColor] CGColor];
     }];
}
//获取属性中值方法（泛用）
- (id)valueForOptionKey:(NSString *)key{
    if (self.options[key]) {
        return self.options[key];
    }
    return [FrkSTLivelyButton defaultOptions][key];
}
//返回按钮的基本属性
+ (NSDictionary*)defaultOptions
{
    
    return @{
             //设置按钮颜色
             kFrkSTLivelyButtonColor: [UIColor blackColor],
             //设置按钮被按下颜色
             kFrkSTLivelyButtonHighlightedColor: [UIColor lightGrayColor],
             //设置变换动画执行时的缩放比例
             kFrkSTLivelyButtonHighlightScale: @(0.9),
             //设置按钮线宽
             kFrkSTLivelyButtonLineWidth: @(1.0),
             //设置变幻动画的执行时间
             kFrkSTLivelyButtonHighlightAnimationDuration: @(0.1),
             //设置变换动画结束的执行时间
             kFrkSTLivelyButtonUnHighlightAnimationDuration: @(0.15),
             //设置按钮类型改变动画的时间
             kFrkSTLivelyButtonStyleChangeAnimationDuration: @(0.3)
             };
}
//接口方法，通过设置按钮类型实现按钮的动态变化
- (void)setStyle:(kFrkSTLivelyButtonStyle)style animated:(BOOL)animated
{
    //设置按钮类型
    self.buttonStyle = style;
    
    //给四个［绘制item］准备的锚点，默认为NULL
    CGPathRef newCirclePath = NULL;
    CGPathRef newLine1Path = NULL;
    CGPathRef newLine2Path = NULL;
    CGPathRef newLine3Path = NULL;
    //新圆透明度
    CGFloat newCircleAlpha = 0.0f;
    //新线透明度
    CGFloat newLine1Alpha = 0.0f;
    
    //第一次加载四个［绘制item］的锚点（根据类型不同，使用自定义方法获取不同的item的锚点）
    if (style == kFrkSTLivelyButtonStyleHamburger) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 1.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, -self.dimension/2.0f/GOLDEN_RATIO)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, self.dimension/2.0f/GOLDEN_RATIO)];
        
    } else if (style == kFrkSTLivelyButtonStylePlus) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:+M_PI_2 offset:CGPointMake(0, 0)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        
    } else if (style == kFrkSTLivelyButtonStyleCirclePlus) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/2.0f];
        newCircleAlpha = 1.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:M_PI_2 offset:CGPointMake(0, 0)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:0 offset:CGPointMake(0, 0)];
        
    } else if (style == kFrkSTLivelyButtonStyleClose) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:+M_PI_4 offset:CGPointMake(0, 0)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:-M_PI_4 offset:CGPointMake(0, 0)];
        
    } else if (style == kFrkSTLivelyButtonStyleCircleClose) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/2.0f];
        newCircleAlpha = 1.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:+M_PI_4 offset:CGPointMake(0, 0)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:-M_PI_4 offset:CGPointMake(0, 0)];
        
    } else if (style == kFrkSTLivelyButtonStyleCaretUp) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:M_PI_4 offset:CGPointMake(self.dimension/6.0f,0.0f)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:3*M_PI_4 offset:CGPointMake(-self.dimension/6.0f,0.0f)];
        
    } else if (style == kFrkSTLivelyButtonStyleCaretDown) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:-M_PI_4 offset:CGPointMake(self.dimension/6.0f,0.0f)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:-3*M_PI_4 offset:CGPointMake(-self.dimension/6.0f,0.0f)];
        
    } else if (style == kFrkSTLivelyButtonStyleCaretLeft) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:-3*M_PI_4 offset:CGPointMake(0.0f,self.dimension/6.0f)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:3*M_PI_4 offset:CGPointMake(0.0f,-self.dimension/6.0f)];
        
    } else if (style == kFrkSTLivelyButtonStyleCaretRight) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:-M_PI_4 offset:CGPointMake(0.0f,self.dimension/6.0f)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:M_PI_4 offset:CGPointMake(0.0f,-self.dimension/6.0f)];
        
    } else if (style == kFrkSTLivelyButtonStyleArrowLeft) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:M_PI offset:CGPointMake(0, 0)];
        newLine1Alpha = 1.0f;
        newLine2Path = [self createLineFromPoint:CGPointMake(0, self.dimension/2.0f)
                                         toPoint:CGPointMake(self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2+self.dimension/2.0f/GOLDEN_RATIO)];
        newLine3Path = [self createLineFromPoint:CGPointMake(0, self.dimension/2.0f)
                                         toPoint:CGPointMake(self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2-self.dimension/2.0f/GOLDEN_RATIO)];
        
    } else if (style == kFrkSTLivelyButtonStyleArrowRight) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 1.0f;
        newLine2Path = [self createLineFromPoint:CGPointMake(self.dimension, self.dimension/2.0f)
                                         toPoint:CGPointMake(self.dimension - self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2+self.dimension/2.0f/GOLDEN_RATIO)];
        newLine3Path = [self createLineFromPoint:CGPointMake(self.dimension, self.dimension/2.0f)
                                         toPoint:CGPointMake(self.dimension - self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2-self.dimension/2.0f/GOLDEN_RATIO)];
        
    } else {
        //纠错，设置了位置类型，给一个断言识别错误
        NSAssert(FALSE, @"unknown type");
    }
    
    
    //设置变幻动画时间
    NSTimeInterval duration = [[self valueForOptionKey:kFrkSTLivelyButtonStyleChangeAnimationDuration] floatValue];
    //所有线变换完的时间
    if (animated){
        {
            CABasicAnimation *circleAnim = [CABasicAnimation animationWithKeyPath:@"path"];
            circleAnim.removedOnCompletion = NO;
            circleAnim.duration = duration;
            circleAnim.fromValue = (__bridge id)self.circleLayer.path;
            circleAnim.toValue = (__bridge id)newCirclePath;
            [circleAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.circleLayer addAnimation:circleAnim forKey:@"animateCirclePath"];
        }
        {
            CABasicAnimation *circleAlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            circleAlphaAnim.removedOnCompletion = NO;
            circleAlphaAnim.duration = duration;
            circleAlphaAnim.fromValue = @(self.circleLayer.opacity);
            circleAlphaAnim.toValue = @(newCircleAlpha);
            [circleAlphaAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.circleLayer addAnimation:circleAlphaAnim forKey:@"animateCircleOpacityPath"];
        }
        {
            CABasicAnimation *line1Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line1Anim.removedOnCompletion = NO;
            line1Anim.duration = duration;
            line1Anim.fromValue = (__bridge id)self.line1Layer.path;
            line1Anim.toValue = (__bridge id)newLine1Path;
            [line1Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line1Layer addAnimation:line1Anim forKey:@"animateLine1Path"];
        }
        {
            CABasicAnimation *line1AlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            line1AlphaAnim.removedOnCompletion = NO;
            line1AlphaAnim.duration = duration;
            line1AlphaAnim.fromValue = @(self.line1Layer.opacity);
            line1AlphaAnim.toValue = @(newLine1Alpha);
            [line1AlphaAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line1Layer addAnimation:line1AlphaAnim forKey:@"animateLine1OpacityPath"];
        }
        {
            CABasicAnimation *line2Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line2Anim.removedOnCompletion = NO;
            line2Anim.duration = duration;
            line2Anim.fromValue = (__bridge id)self.line2Layer.path;
            line2Anim.toValue = (__bridge id)newLine2Path;
            [line2Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line2Layer addAnimation:line2Anim forKey:@"animateLine2Path"];
        }
        {
            CABasicAnimation *line3Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line3Anim.removedOnCompletion = NO;
            line3Anim.duration = duration;
            line3Anim.fromValue = (__bridge id)self.line3Layer.path;
            line3Anim.toValue = (__bridge id)newLine3Path;
            [line3Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line3Layer addAnimation:line3Anim forKey:@"animateLine3Path"];
        }
    }
    
    //设置圆的锚点
    self.circleLayer.path = newCirclePath;
    //设置圆的透明度
    self.circleLayer.opacity = newCircleAlpha;
    //设置第一个［绘制item］的锚点
    self.line1Layer.path = newLine1Path;
    self.line1Layer.opacity = newLine1Alpha;
    self.line2Layer.path = newLine2Path;
    self.line3Layer.path = newLine3Path;
    
    //释放缓存锚点
    CGPathRelease(newCirclePath);
    CGPathRelease(newLine1Path);
    CGPathRelease(newLine2Path);
    CGPathRelease(newLine3Path);
}


#pragma mark -
#pragma mark - 按钮变幻方法
//缩放变幻法方法
- (CGAffineTransform)transformWithScale:(CGFloat)scale
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation((self.dimension + 2 * self.offset.x) * ((1-scale)/2.0f),
                                                                   (self.dimension + 2 * self.offset.y)  * ((1-scale)/2.0f));
    return CGAffineTransformScale(transform, scale, scale);
}
//根据半径绘制圆形方法
- (CGPathRef)createCenteredCircleWithRadius:(CGFloat)radius
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, self.centerPoint.x + radius, self.centerPoint.y);
    //如果clockwise没设置对，圆画不出来
    //即使模拟器好使，真机也没用
    //所以这里设置了clockwise为false
    CGPathAddArc(path, NULL, self.centerPoint.x, self.centerPoint.y, radius, 0, 2 * M_PI, false);
    
    return path;
}
//根据半径绘制直线方法
- (CGPathRef)createCenteredLineWithRadius:(CGFloat)radius angle:(CGFloat)angle offset:(CGPoint)offset
{
    //创建锚点
    CGMutablePathRef path = CGPathCreateMutable();
    
    //使用余弦函数计算横坐标缩放比例
    float c = cosf(angle);
    //使用余弦函数计算纵坐标缩放比例
    float s = sinf(angle);
    
    //绘制直线
    CGPathMoveToPoint(path, NULL, (self.centerPoint.x+offset.x+radius*c), (self.centerPoint.y+offset.y+radius*s));
    //绘制直线轨迹
    CGPathAddLineToPoint(path, NULL, (self.centerPoint.x+offset.x-radius*c), (self.centerPoint.y+offset.y-radius*s));
    
    return path;
}
//由点画线方法（绘制箭头使用）
- (CGPathRef)createLineFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2
{
    //创建锚点
    CGMutablePathRef path = CGPathCreateMutable();
    
    //令一个点从锚点移动到另外一个点
    CGPathMoveToPoint(path, NULL, self.offset.x+p1.x, self.offset.y+p1.y);
    //在两点之间绘制轨迹（简称画线）
    CGPathAddLineToPoint(path, NULL, self.offset.x+p2.x, self.offset.y+p2.y);
    
    return path;
}

#pragma mark -
#pragma mark - 按钮动作方法
//按钮高亮状态
- (void)showHighlight
{
    //获取按钮按下时所需缩放比例
    float highlightScale = [[self valueForOptionKey:kFrkSTLivelyButtonHighlightScale] floatValue];
    //枚举数组执行加载
    [self.shapeLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //设置高亮按钮颜色
        [obj setStrokeColor:[[self valueForOptionKey:kFrkSTLivelyButtonHighlightedColor] CGColor]];
        //获取［绘制item］
        CAShapeLayer *layer = obj;
        //设置变幻缩放比例
        CGAffineTransform transform = [self transformWithScale:highlightScale];
        //设置缩放缓存锚点
        CGPathRef scaledPath =  CGPathCreateMutableCopyByTransformingPath(layer.path, &transform);
        
        //设置基本动画
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
        //设置动画时间
        anim.duration = [[self valueForOptionKey:kFrkSTLivelyButtonHighlightAnimationDuration] floatValue];
        //动画完毕后是否消除绘制轨迹
        anim.removedOnCompletion = NO;
        //变幻起始点
        anim.fromValue = (__bridge id) layer.path;
        //变幻终止点
        anim.toValue = (__bridge id) scaledPath;
        //设置动画方式［淡入淡出］
        [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        //给［绘制item］添加动画
        [layer addAnimation:anim forKey:nil];
        
        //重设［绘制item］锚点
        layer.path = scaledPath;
        //移除缓存锚点
        CGPathRelease(scaledPath);
    }];
}
//按钮取消高亮状态
- (void)showUnHighlight
{
    //获取按钮抬起时所需缩放比例
    float unHighlightScale = 1/[[self valueForOptionKey:kFrkSTLivelyButtonHighlightScale] floatValue];
    //枚举数组执行加载
    [self.shapeLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //设置高亮按钮颜色
        [obj setStrokeColor:[[self valueForOptionKey:kFrkSTLivelyButtonColor] CGColor]];
        //获取［绘制item］
        CAShapeLayer *layer = obj;
        
        //获取［绘制item］的变幻轨迹
        CGPathRef path = layer.path;
        //按照取消比例的最终缩放轨迹
        CGAffineTransform transform = [self transformWithScale:unHighlightScale];
        //设置取消轨迹的锚点
        CGPathRef finalPath =  CGPathCreateMutableCopyByTransformingPath(path, &transform);
        //按照放大比例的缩放轨迹
        CGAffineTransform uptransform = [self transformWithScale:unHighlightScale * 1.07];
        //设置放大轨迹的锚点
        CGPathRef scaledUpPath = CGPathCreateMutableCopyByTransformingPath(path, &uptransform);
        //按照缩小比例的缩放轨迹
        CGAffineTransform downtransform = [self transformWithScale:unHighlightScale * 0.97];
        //设置缩小轨迹的锚点
        CGPathRef scaledDownPath = CGPathCreateMutableCopyByTransformingPath(path, &downtransform);
        //把变幻轨迹和缩放轨迹存放到数组当中
        NSArray *values = @[
                            (__bridge id) layer.path,
                            (id) CFBridgingRelease(scaledUpPath),//CG类的破玩意和Foundation不互通引用计数，使用桥接统一管理
                            (id) CFBridgingRelease(scaledDownPath),
                            (__bridge id) finalPath
                            ];
        //对应设置所需的时间（变换轨迹一项由于为获取，是已经执行完毕的轨迹，故不需要执行时间。设置0即可）
        NSArray *times = @[@(0.0), @(0.85), @(0.93), @(1.0)];
        
        //设置基本动画
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"path"];
        //设置基本动画时间
        anim.duration = [[self valueForOptionKey:kFrkSTLivelyButtonUnHighlightAnimationDuration] floatValue];
        //设置动画方式［线变幻］
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        //动画完毕后是否消除绘制轨迹
        anim.removedOnCompletion = NO;
        //需要执行的动画
        anim.values = values;
        //动画需要执行的时间
        anim.keyTimes = times;
        //［绘制item］执行动画
        [layer addAnimation:anim forKey:nil];
        
        //最终设置［绘制item］轨迹为取消轨迹
        layer.path = finalPath;
        //移除缓存锚点
        CGPathRelease(finalPath);
    }];
    return;
}

-(void) dealloc{
    
}
@end
