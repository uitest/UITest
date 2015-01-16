//
//  PublicStringTool.m
//  if_wapeng
//
//  Created by 心 猿 on 15-1-12.
//  Copyright (c) 2015年 funeral. All rights reserved.
//
#define kBegin_Flag @"["
#define kEnd_Flag @"]"

#import "PublicStringTool.h"

@implementation PublicStringTool

///把 [[[[微笑] 替换为 [[[[smile]  name emoji_1f37b.png
//                                meaning 干杯
//                                newname [1f37b]
+(NSString *)newRetStringWithArr:(NSMutableArray *)array
{
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
    
    NSLog(@"path:%@", path);
    
    NSArray * emotionArr= [NSArray arrayWithContentsOfFile:path];
    
    NSMutableString * ret = [[NSMutableString alloc]init];
    
    for (NSString * str in array) {
        
        if ([str hasPrefix:kBegin_Flag] && [str hasSuffix:kEnd_Flag]) {
            
            NSLog(@"有可能是是表情符号");
            //[[[[微笑] ，去掉这种情况
            
            //先拼接iOS端字符串
            [ret appendString:str];
            
            for (NSDictionary * dict in emotionArr) {
                
                NSString * meaning = [NSString stringWithFormat:@"[%@]",[dict objectForKey:@"meaning"]];
                //plist文件中有，证明是表情符号
                if ([str isEqualToString:meaning]) {
                    
                    NSRange range = [ret rangeOfString:str];
                    
                    [ret deleteCharactersInRange:range];
                    
//                    NSString * meaning = [NSString stringWithFormat:@"[%@]", [dict objectForKey:@"meaning"]];
                    NSString * newName = [dict objectForKey:@"newname"];
    
                    
                    [ret appendString:newName];
                    
                }
                
            }
            
            
        }else{
            
            [ret appendString:str];
        }
    }
    return ret;
}

///排除是 [[[[微笑] 这样的表情，把 [[[和 [微笑] 分离开来
+(NSArray *)exceptStringWithString:(NSString *)string
{
    NSMutableArray * arr = [[NSMutableArray alloc]init];
    
    if ([string hasPrefix:kBegin_Flag]) {
        NSRange range = [string rangeOfString:kBegin_Flag options: NSBackwardsSearch];
        
        NSString * str = [string substringToIndex:range.location];
        
        NSString * str2 = [string substringFromIndex:range.location];
        
        if (![str isEqualToString:@""]) {
            
            [arr addObject:str];
        }
        
        [arr addObject:str2];
        
    }else{
        
        [arr addObject:string];
        
    }
    
    return arr;
}


///把表情字符串分割为数组，递归算法
+(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    
    NSRange range=[message rangeOfString: kBegin_Flag];
    
    NSRange range1=[message rangeOfString: kEnd_Flag];
    
    //如果出现用户输入]]]的情况
    
    if (range.location > range1.location) {
        
        NSString * str = nil;
        
        str = [message substringToIndex:range.location];
        
        [array addObject:str];
        
        NSString * newstr = [[NSString alloc]initWithString:[message substringFromIndex:range.location]];
        
        [self getImageRange:newstr :array];
        return;
    }
    
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0) {
        
        if (range.location > 0) {
            
            NSLog(@"%@",NSStringFromRange(NSMakeRange(range.location, range1.location+1-range.location)));
            
            //分段截取字符串
            [array addObject:[message substringToIndex:range.location]];
            
            //                [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            
            NSString * suspectStr = [message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            
            NSArray * temp =  [self exceptStringWithString:suspectStr];
            NSLog(@"***********%@", suspectStr);
            NSLog(@"***********%@", temp);
            
            [array addObjectsFromArray:temp];
            //拿到剩下的字符创
            
            NSString *str=[NSString stringWithFormat:@"%@", [message substringFromIndex:range1.location+1]];
            
            [self getImageRange:str :array];
            return;
            
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                
                //                    [array addObject:@""];
                
                //                    [array addObject:nextstr];
                NSString * suspectStr = nextstr;
                NSArray * temp =  [self exceptStringWithString:suspectStr];
                
                [array addObjectsFromArray:temp];
                
                
                NSString *str=[message substringFromIndex:range1.location+1];
                
                [self getImageRange:str :array];
                return;
                
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        
        NSLog(@"%@", message);
        
        [array addObject:message];
        
        NSLog(@"%@", array);
        
        return;
    }
    
}
+(NSString *)unifyStringWithAndiordString:(NSString *)string
{
    NSMutableArray * temp = [[NSMutableArray alloc]init];
    
    [self getImageRange:string :temp];
    
    NSLog(@"%@", temp);

    NSString * ret =  [self newRetStringWithArr:temp];
    
    NSLog(@"%@",ret);
    
    return ret;

}

@end
