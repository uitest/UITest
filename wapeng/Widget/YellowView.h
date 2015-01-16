//
//  YellowView.h
//  if_wapeng
//
//  Created by 心 猿 on 14-12-12.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YellowView : UILabel
{
    
}

+(void)show;

+(void)showWithSimpString:(NSString *)smpleString;

+(void)dismiss;

+(instancetype)shareInstance;

@end
