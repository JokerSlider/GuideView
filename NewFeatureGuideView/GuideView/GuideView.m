//
//  GuideView.h
//
//  Created by mac on 15/11/23.
//  Copyright © 2017 joker. All rights reserved.
//


#import "GuideView.h"
#import <CoreText/CoreText.h>
#import <CoreImage/CoreImage.h>
#import "UIView+Layout.h"
#define UPIMAGE ([UIImage imageNamed:@"upgiude_up"])
#define DOWNIMAGE ([UIImage imageNamed:@"giude_un"])
#define KNOWIMAGE ([UIImage imageNamed:@"iknow"])
#define DEFAULTCORNERRADIUS (5.0f)
#define DefaultDotLine  (@[@10,@5])
static CGFloat const backgroundDepth = .6f;
@interface GuideView()
@property(nonatomic)CGRect showRect;    //透明范围
@property(nonatomic)BOOL fullShow;  //透明范围全部显示
@property(nonatomic,strong)UIColor *guideColor; //覆盖颜色
@property(nonatomic)BOOL showMark;  //是否显示提示
@property(nonatomic,copy)NSString *markText;    //提示文本
@end
@implementation GuideView

{
    UITextView *markTextView;
    UIImageView *markImageView;
    UIButton *knowImageView;
    CAShapeLayer *maskLayer;
    NSMutableArray *_pointArray;//坐标数组
    NSMutableArray *_titleArray;//标题数组
}

/**
 创建箭头 文字 和透明聚焦

 @param rect 要创建的位置
 @param title 标题
 */
-(void)showViewDrawRect:(CGRect )rect angTitle:(NSString *)title
{
    [self remoview];

    UIBezierPath *fullPath  = [UIBezierPath bezierPathWithRect:self.bounds];
            switch (self.model)
            {
                case GuideViewCleanModeOval:
                {
//                    UIBezierPath *showPath = [UIBezierPath bezierPathWithOvalInRect:self.fullShow?([self ovalFrameScale:self.showRect s:[self ovalDrawScale]]):self.showRect];
//                    [fullPath appendPath:[showPath bezierPathByReversingPath]];
                    //绘制圆圈
//                    [fullPath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.showRect.origin.x, self.showRect.origin.y) radius:100 startAngle:0 endAngle:2*M_PI clockwise:NO]];
                    
                    [fullPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:self.showRect cornerRadius:self.showRect.size.width/2] bezierPathByReversingPath]];
                    [self addLayer:fullPath];
                }
                    break;
                case GuideViewCleanModeRoundRect:
                {
                    UIBezierPath *showPath = [UIBezierPath bezierPathWithRoundedRect:self.fullShow?([self roundRectScale:self.showRect]):self.showRect cornerRadius:DEFAULTCORNERRADIUS];
                    [fullPath appendPath:[showPath bezierPathByReversingPath]];
                    [self addLayer:showPath];
                }
                    break;
                default:
                {
                    UIBezierPath *showPath = [UIBezierPath bezierPathWithRect:self.fullShow?([self rectScale:self.showRect]):self.showRect];
                    [fullPath appendPath:[showPath bezierPathByReversingPath]];
                    [self addLayer:showPath];
                }
                    break;
            }
            if (self.showMark) {
                [self drawMarkwithRect:rect];
            }
            else
            {
                [self remoview];
        }

}

/**
 绘制透明聚焦点

 @param path 贝泽尔曲线
 */
-(void)addLayer:(UIBezierPath *)path
{
    maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    maskLayer.strokeColor = [UIColor whiteColor].CGColor;
    maskLayer.fillColor = [UIColor redColor].CGColor;
    [self.layer setMask:maskLayer];
}

/**
 移除layer
 */
-(void)remoview
{
    [markTextView removeFromSuperview];
    [markImageView removeFromSuperview];
    [knowImageView removeFromSuperview];
    [maskLayer removeFromSuperlayer];
}

/**
 确定箭头位置

 @param rect 位置
 */
-(void)drawMarkwithRect:(CGRect)rect
{
    CGRect showLocationRect = rect;
    if (self.fullShow)
    {
        switch (self.model)
        {
            case GuideViewCleanModeOval:
            {
                showLocationRect = [self ovalFrameScale:rect s:[self ovalDrawScale]];
            }
                break;
            case GuideViewCleanModeRoundRect:
            {
                showLocationRect = [self roundRectScale:rect];
            }
                break;
            default:
            {
                showLocationRect = [self rectScale:rect];
            }
                break;
        }
    }
    CGPoint markCenter = CGPointMake(CGRectGetMinX(showLocationRect), CGRectGetMinY(showLocationRect));
    CGFloat centerX = self.bounds.size.width/2.0f;
    CGFloat centerY = self.bounds.size.height/2.0f;
    CGFloat  rightDistance = showLocationRect.size.width/2;
    CGFloat  topDistance   = 20;
    CGFloat  leftDistance  =  -showLocationRect.size.width/2;
    [markTextView setText:_markText];
    if (markCenter.x<=centerX&&markCenter.y<=centerY)//左上
    {
        CGFloat right = (self.bounds.size.width-showLocationRect.origin.x-showLocationRect.size.width)*(self.bounds.size.height-showLocationRect.origin.y);
        CGFloat bottom = (self.bounds.size.width-showLocationRect.origin.x)*(self.bounds.size.height-showLocationRect.origin.y-showLocationRect.size.height);
        if (right>=bottom)//右侧
        {
            [markImageView setFrame:CGRectMake(showLocationRect.origin.x+showLocationRect.size.width, showLocationRect.origin.y, markImageView.frame.size.width, markImageView.frame.size.height)];
            [markImageView setImage:UPIMAGE];
            [markImageView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_4)];
            [self addSubview:markImageView];
            CGFloat width = self.bounds.size.width-showLocationRect.origin.x-showLocationRect.size.width-markImageView.frame.size.width;
            CGFloat height = self.bounds.size.height-showLocationRect.origin.y-markImageView.frame.size.height;
            CGSize size = [markTextView sizeThatFits:CGSizeMake(width, height)];
            [markTextView setFrame:CGRectMake(markImageView.frame.origin.x+markImageView.frame.size.width-markTextView.font.pointSize, markImageView.frame.origin.y+markImageView.frame.size.height, size.width, size.height)];
            [self addSubview:markTextView];
            
            //朕  知道了
            knowImageView.centerX = self.width/2;
            knowImageView.top = markTextView.bottom +20;
            [self addSubview:knowImageView];
        }
        else//下面
        {
            [markImageView setFrame:CGRectMake(showLocationRect.origin.x+rightDistance, showLocationRect.origin.y+showLocationRect.size.height, markImageView.frame.size.width, markImageView.frame.size.height)];
            [markImageView setImage:DOWNIMAGE];
            [markImageView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, M_PI)];
            [self addSubview:markImageView];
            CGFloat width = self.bounds.size.width-showLocationRect.origin.x-markImageView.frame.size.width;
            CGFloat height = self.bounds.size.height-showLocationRect.origin.y-showLocationRect.size.height-markImageView.frame.size.height;
            CGSize size = [markTextView sizeThatFits:CGSizeMake(width, height)];
            [markTextView setFrame:CGRectMake(markImageView.frame.origin.x+markImageView.frame.size.width+leftDistance, markImageView.frame.origin.y+markImageView.frame.size.height-markTextView.font.pointSize+topDistance, size.width, size.height)];
            [self addSubview:markTextView];
            //朕  知道了
            knowImageView.centerX = self.width/2;
            knowImageView.top = markTextView.bottom +20;
            [self addSubview:knowImageView];
        }
    }
    else if (markCenter.x>=centerX&&markCenter.y<=centerY)//右上
    {
        CGFloat left = (showLocationRect.origin.x)*(self.bounds.size.height-showLocationRect.origin.y);
        CGFloat bottom = (showLocationRect.origin.x+showLocationRect.size.width)*(self.bounds.size.height-showLocationRect.origin.y-showLocationRect.size.height);
        if (left>=bottom)//左侧
        {
            [markImageView setFrame:CGRectMake(showLocationRect.origin.x-markImageView.frame.size.width, showLocationRect.origin.y, markImageView.frame.size.width, markImageView.frame.size.height)];
            [markImageView setImage:DOWNIMAGE];
            [markImageView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_4)];
            [self addSubview:markImageView];
            CGFloat width = showLocationRect.origin.x-markImageView.frame.size.width;
            CGFloat height = self.bounds.size.height-showLocationRect.origin.y-markImageView.frame.size.height;
            CGSize size = [markTextView sizeThatFits:CGSizeMake(width, height)];
            [markTextView setFrame:CGRectMake(markImageView.frame.origin.x-size.width+markTextView.font.pointSize, markImageView.frame.origin.y+markImageView.frame.size.height, size.width, size.height)];
            [self addSubview:markTextView];
            //朕  知道了
            knowImageView.centerX = self.width/2;
            knowImageView.top = markTextView.bottom +20;
            [self addSubview:knowImageView];
        }
        else//下面
        {
            [markImageView setFrame:CGRectMake(showLocationRect.origin.x+showLocationRect.size.width-markImageView.frame.size.width+leftDistance, showLocationRect.origin.y+showLocationRect.size.height, markImageView.frame.size.width, markImageView.frame.size.height)];
            [markImageView setImage:UPIMAGE];
            [markImageView setTransform:CGAffineTransformIdentity];
            [self addSubview:markImageView];
            CGFloat width = showLocationRect.origin.x+showLocationRect.size.width-markImageView.frame.size.width;
            CGFloat height = self.bounds.size.height-showLocationRect.origin.y-showLocationRect.size.height-markImageView.frame.size.height;
            CGSize size = [markTextView sizeThatFits:CGSizeMake(width, height)];
            [markTextView setFrame:CGRectMake(markImageView.frame.origin.x-size.width+rightDistance, markImageView.frame.origin.y+markImageView.frame.size.height-markTextView.font.pointSize+topDistance, size.width, size.height)];
            [self addSubview:markTextView];
            //朕  知道了
            knowImageView.centerX = self.width/2;
            knowImageView.top = markTextView.bottom +20;
            [self addSubview:knowImageView];
        }
    }
    else if (markCenter.x<=centerX&&markCenter.y>=centerY)//左下
    {
        CGFloat right = (self.bounds.size.width-showLocationRect.origin.x-showLocationRect.size.width)*(showLocationRect.origin.y+showLocationRect.size.height);
        CGFloat up = (self.bounds.size.width-showLocationRect.origin.x)*(showLocationRect.origin.y);
        if (right>=up)//右侧
        {
            [markImageView setFrame:CGRectMake(showLocationRect.origin.x+showLocationRect.size.width, showLocationRect.origin.y+showLocationRect.size.height-markImageView.frame.size.height, markImageView.frame.size.width, markImageView.frame.size.height)];
            [markImageView setImage:DOWNIMAGE];
            [markImageView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_4)];
            [self addSubview:markImageView];
            CGFloat width = self.bounds.size.width-showLocationRect.origin.x-showLocationRect.size.width-markImageView.frame.size.width;
            CGFloat height = showLocationRect.origin.y+showLocationRect.size.height-markImageView.frame.size.height;
            CGSize size = [markTextView sizeThatFits:CGSizeMake(width, height)];
            [markTextView setFrame:CGRectMake(markImageView.frame.origin.x+markImageView.frame.size.width-markTextView.font.pointSize, markImageView.frame.origin.y-size.height, size.width, size.height)];
            [self addSubview:markTextView];
            //朕  知道了
            knowImageView.centerX = self.width/2;
            knowImageView.top = markTextView.bottom +20;
            [self addSubview:knowImageView];
        }
        else//上面
        {
            [markImageView setFrame:CGRectMake(showLocationRect.origin.x+rightDistance, showLocationRect.origin.y-markImageView.frame.size.height, markImageView.frame.size.width, markImageView.frame.size.height)];
            [markImageView setImage:UPIMAGE];
            [markImageView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, M_PI)];
            [self addSubview:markImageView];
            CGFloat width = self.bounds.size.width-showLocationRect.origin.x-markImageView.frame.size.width;
            CGFloat height = showLocationRect.origin.y-markImageView.frame.size.height;
            CGSize size = [markTextView sizeThatFits:CGSizeMake(width, height)];
            [markTextView setFrame:CGRectMake(markImageView.frame.origin.x+markImageView.frame.size.width+leftDistance, markImageView.frame.origin.y-size.height+markTextView.font.pointSize-topDistance, size.width, size.height)];
            [self addSubview:markTextView];
            //朕  知道了
            knowImageView.centerX = self.width/2;
            knowImageView.bottom = markTextView.bottom -50;
            [self addSubview:knowImageView];
        }
    }
    else if (markCenter.x>=centerX&&markCenter.y>=centerY)//右下
    {
        CGFloat left = (showLocationRect.origin.x)*(showLocationRect.origin.y+showLocationRect.size.height);
        CGFloat up = (showLocationRect.origin.x+showLocationRect.size.width)*(showLocationRect.origin.y);
        if (left>=up)//左侧
        {
            [markImageView setFrame:CGRectMake(showLocationRect.origin.x-markImageView.frame.size.width, showLocationRect.origin.y+showLocationRect.size.height-markImageView.frame.size.height, markImageView.frame.size.width, markImageView.frame.size.height)];
            [markImageView setImage:UPIMAGE];
            [markImageView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_4)];
            [self addSubview:markImageView];
            CGFloat width = showLocationRect.origin.x-markImageView.frame.size.width;
            CGFloat height = showLocationRect.origin.y+showLocationRect.size.height-markImageView.frame.size.height;
            CGSize size = [markTextView sizeThatFits:CGSizeMake(width, height)];
            [markTextView setFrame:CGRectMake(markImageView.frame.origin.x-size.width+markTextView.font.pointSize, markImageView.frame.origin.y-size.height, size.width, size.height)];
            [self addSubview:markTextView];
            //朕  知道了
            knowImageView.centerX = self.width/2;
            knowImageView.top = markTextView.bottom +20;
            [self addSubview:knowImageView];
        }
        else//上面
        {
            [markImageView setFrame:CGRectMake(showLocationRect.origin.x+showLocationRect.size.width-markImageView.frame.size.width+leftDistance, showLocationRect.origin.y-markImageView.frame.size.height, markImageView.frame.size.width, markImageView.frame.size.height)];
            [markImageView setImage:DOWNIMAGE];
            [markImageView setTransform:CGAffineTransformIdentity];
            [self addSubview:markImageView];
            CGFloat width = showLocationRect.origin.x+showLocationRect.size.width-markImageView.frame.size.width;
            CGFloat height = showLocationRect.origin.y-markImageView.frame.size.height;
            CGSize size = [markTextView sizeThatFits:CGSizeMake(width, height)];
            [markTextView setFrame:CGRectMake(markImageView.frame.origin.x-size.width+rightDistance, markImageView.frame.origin.y-size.height+markTextView.font.pointSize-topDistance, size.width, size.height)];
            [self addSubview:markTextView];
            //朕  知道了
            knowImageView.centerX = self.width/2;
            knowImageView.bottom = markTextView.bottom -50;
            [self addSubview:knowImageView];
        }
    }

}
-(instancetype)initWithFrame:(CGRect)frame withRectArray:(NSArray *)rectarray andTitleArray:(NSArray *)titleArray
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //初始化坐标和标题数组
        _pointArray = [NSMutableArray arrayWithArray:rectarray];
        _titleArray = [NSMutableArray arrayWithArray:titleArray];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:backgroundDepth];
        //设置默认值
        NSValue* theRectObj = [_pointArray firstObject];
        CGRect pointRect = [theRectObj CGRectValue];
        //初始化第一个位置
        self.showRect = pointRect;
        //初始化第一个显示的文字
        self.markText = [_titleArray firstObject];

        self.fullShow = NO;
        self.model = GuideViewCleanModeOval;
        self.guideColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.68];
        self.showMark = YES;
        //箭头
        markImageView = [[UIImageView alloc]initWithImage:UPIMAGE];
        [markImageView setFrame:CGRectMake(0, 0, 70, 70)];
        [markImageView setContentMode:UIViewContentModeScaleAspectFit];
        //我知道了
        knowImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        [knowImageView setImage:[UIImage imageNamed:@"iknow"] forState:UIControlStateNormal];
        [knowImageView sizeToFit];
        [knowImageView addTarget:self action:@selector(okbtnAction) forControlEvents:UIControlEventTouchUpInside];
        //文本框
        markTextView = [[UITextView alloc]initWithFrame:CGRectZero];
        [markTextView setEditable:NO];
        [markTextView setTextColor:[UIColor whiteColor]];
        [markTextView setFont:[UIFont systemFontOfSize:16.0f]];
        [markTextView setScrollEnabled:NO];
        [markTextView setText:self.markText];
        [markTextView setBackgroundColor:[UIColor clearColor]];
        
        knowImageView.userInteractionEnabled = YES;
        
        [self showViewDrawRect:pointRect angTitle:[_titleArray firstObject]];

    }
    return self;
}
-(CGRect)roundRectScale:(CGRect)rect
{
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGRect newRect = CGRectMake(center.x - width * 0.5 - DEFAULTCORNERRADIUS, center.y - height * 0.5 - DEFAULTCORNERRADIUS, width + DEFAULTCORNERRADIUS * 2.0, height + DEFAULTCORNERRADIUS * 2.0);
    
    return newRect;
}
-(CGRect)rectScale:(CGRect)rect
{
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGRect newRect = CGRectMake(center.x - width * 0.5 - 2.0, center.y - height * 0.5 - 2.0, width + 4.0, height + 4.0);
    
    return newRect;
}
-(CGFloat)ovalDrawScale
{
    CGFloat a = MAX(self.showRect.size.width, self.showRect.size.height);
    CGFloat b = MIN(self.showRect.size.width, self.showRect.size.height);
    CGFloat bigger = (b + sqrt(4.0 * a * a + b * b) - 2 * a)/2.0;
    CGFloat scale = 1.0 + bigger / a;
    return scale;
}
-(CGRect)ovalFrameScale:(CGRect)rect s:(CGFloat)s
{

    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGRect newRect = CGRectMake(center.x - width * s * 0.5, center.y - height * s * 0.5*0.5, width * s, height * s*0.5);
    
    return newRect;
}
-(UIImage*)imageFromView:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
-(UIImage*)imageFromImage:(UIImage*)image rect:(CGRect)rect
{
    CGImageRef sourceImageRef = image.CGImage;
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage* newImage = [UIImage imageWithCGImage:newImageRef];
    CFRelease(newImageRef);
    return newImage;
}
#pragma mark 代理
-(void)okbtnAction
{
    
    if (_pointArray.count>=1) {
        [_pointArray removeObjectAtIndex:0];
        [_titleArray removeObjectAtIndex:0];
    }
    
    if(_pointArray.count==0){
        [self dismiss];
        return;
    }
    NSValue* theRectObj = [_pointArray firstObject];
    CGRect pointRect = [theRectObj CGRectValue];
    CGPoint point = CGPointMake(pointRect.origin.x, pointRect.origin.y);
    
    self.fullShow = NO;
    self.showRect = CGRectMake(point.x, point.y, pointRect.size.width, pointRect.size.height);
    self.markText = [_titleArray firstObject];
    
    [self showViewDrawRect:pointRect angTitle:[_titleArray firstObject]];

}
- (void)dismiss {
    [UIView animateWithDuration:0.35 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"GuideViewDissMiss"];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self okbtnAction];
}
@end
