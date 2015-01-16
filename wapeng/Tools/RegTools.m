//
//  RegTools.m
//  if_wapeng
//
//  Created by 心 猿 on 14-12-4.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import "RegTools.h"

@implementation RegTools

#pragma mark - 判断手机号码是否合法
/**判断手机号码是否合法**/
+(BOOL)regResultWithString:(NSString *)string
{
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
     BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

/**判断所输入的昵称是否合法**/
+(BOOL)regResultWithNickString:(NSString *)nickString
{
    NSString * regex  = @"^[\u4e00-\u9fa5a-zA-Z0-9_-]{1,24}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:nickString];
    return isMatch;
    
}
@end
