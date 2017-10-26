//
//  GuideView.h
//
//  Created by mac on 15/11/23.
//  Copyright © 2017 joker. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GuideViewCleanMode) {
    GuideViewCleanModeRect, //矩形
    GuideViewCleanModeRoundRect,      // 圆角矩形
    GuideViewCleanModeOval     //椭圆
};

@interface GuideView : UIView

@property(nonatomic)GuideViewCleanMode model;   //透明区域范围

-(instancetype)initWithFrame:(CGRect)frame withRectArray:(NSMutableArray *)rectarray andTitleArray:(NSMutableArray *)titleArray;

@end
