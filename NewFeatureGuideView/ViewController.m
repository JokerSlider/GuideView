//
//  ViewController.m
//  NewFeatureGuideView
//
//  Created by mac on 2017/10/26.
//  Copyright © 2017年 Joker. All rights reserved.
//

#import "ViewController.h"
#import "GuideView.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self add_GuideView];
}
#pragma mark 添加聚光灯引导
-(void)add_GuideView
{
    //坐标 点
    // 传控件的位置frame
    NSArray *pointArr  =   @[
                             [NSValue valueWithCGRect:CGRectMake(18, 24, 35, 35)],
                             [NSValue valueWithCGRect:CGRectMake(kScreenWidth-43, 30, 30, 30)],
                             [NSValue valueWithCGRect:CGRectMake(100,200+64+7,120,50)],
                             [NSValue valueWithCGRect:CGRectMake(0,200+35, kScreenWidth, 90)],
                             [NSValue valueWithCGRect:CGRectMake(0, kScreenHeight-130, kScreenWidth, 130/2)],
                             ];
   NSMutableArray * newpointArr  = [NSMutableArray arrayWithArray:pointArr];
    NSMutableArray *titleArray = [NSMutableArray arrayWithArray:@[@"这里是设置界面",@"签到跑这里来了",@"点击这里进行一键上网",@"新应用都在这",@"新增文件夹功能,让界面干净整洁"]];
    //初始化 引导页
    GuideView *markView = [[GuideView alloc]initWithFrame:self.view.bounds withRectArray:newpointArr andTitleArray:titleArray ];
    markView.model = GuideViewCleanModeOval;
    [self.view addSubview:markView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
