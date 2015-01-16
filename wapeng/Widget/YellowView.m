//
//  YellowView.m
//  if_wapeng
//
//  Created by 心 猿 on 14-12-12.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#define kYellowViewHeight 40

#import "YellowView.h"
#import "AppDelegate.h"
static YellowView * _instance;
static UIControl * _ctrl;
@implementation YellowView


+(id)allocWithZone:(struct _NSZone *)zone
{
    
    
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
       
        _instance = [super allocWithZone:zone];
        
    });
    return _instance;
}


-(id)init
{
    if (self = [super init]) {
        
        if (_instance == nil) {
            
            _instance = [[YellowView alloc]init];
//            _instance.frame = CGRectMake(0, 0, kMainScreenWidth, kYellowViewHeight);
        }
    }
    return self;
}

+(instancetype)shareInstance
{
    if (_instance == nil) {
        
        _instance = [[YellowView alloc]init];
//        _instance.frame = CGRectMake(0, 0, kMainScreenWidth, kYellowViewHeight);
        _instance.backgroundColor = [UIColor yellowColor];
        _instance.alpha = 0.5;
        [_instance setTextColor:[UIColor redColor]];
        _instance.textAlignment = NSTextAlignmentCenter;
        _instance.font = [UIFont systemFontOfSize:16];
        
    }
    return _instance;
}


+(void)show
{
    
    if (_instance == nil) {
        
        [self shareInstance];
    }
    
   UIWindow * keyWindow =  [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:_instance];
    
    _instance.frame =  CGRectMake(0, 64, kMainScreenHeight, 0.1);
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _instance.frame = CGRectMake(0, 64, kMainScreenWidth, kYellowViewHeight);
    }];
    
    UIControl * control = [[UIControl alloc]initWithFrame:keyWindow.bounds];
    [control addTarget:self action:@selector(ctrlClick) forControlEvents:UIControlEventTouchUpInside];
    
//    control.backgroundColor = [UIColor grayColor];
    
//    control.alpha = 0.5;
    
    [keyWindow addSubview:control];
    
    _ctrl = control;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self dismiss];
    });
}

+(void)showWithSimpString:(NSString *)smpleString
{
    if (_instance == nil) {
        
        [self shareInstance];
    }
    _instance.text = [smpleString copy];
    [self show];
}

#pragma mark - 消失
+(void)ctrlClick
{
    [self dismiss];
}

+(void)dismiss
{
    [UIView animateWithDuration:0.5 animations:^{

        _instance.frame = CGRectMake(0, 64, kMainScreenWidth, 0);

            } completion:^(BOOL finished) {
                
                [_instance removeFromSuperview];
                [_ctrl removeFromSuperview];

            }];
}
@end
