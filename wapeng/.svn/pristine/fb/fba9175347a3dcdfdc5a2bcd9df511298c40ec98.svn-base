//
//  Item_ACT_RemarkList.m
//  if_wapeng
//
//  Created by 心 猿 on 14-10-25.
//  Copyright (c) 2014年 funeral. All rights reserved.
//
#define FONT_SIZE 18
#define WIDTH     220
#import "Item_ACT_RemarkList.h"
#import "MyParserTool.h"
@implementation Item_ACT_RemarkList

-(CGFloat)height
{
    UIFont * font = [UIFont systemFontOfSize:FONT_SIZE];
    
    CGFloat width = WIDTH * (kMainScreenWidth / 320.0);
    
    MyParserTool * tool = [MyParserTool shareInstance];
    
    CGSize size = [tool sizeWithRawString:self.content
                        constrainsToWidth:width Font:font];
    
    CGFloat height = size.height;
    
    if (height < 135) {
        
        height = 135;
    }
    return height;
}

@end
