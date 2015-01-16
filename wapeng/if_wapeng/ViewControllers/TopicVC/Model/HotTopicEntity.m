//
//  HotTopicEntity.m
//  if_wapeng
//
//  Created by 心 猿 on 14-8-7.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import "HotTopicEntity.h"
#import "MyParserTool.h"
@implementation HotTopicEntity

/**根据话题内容计算高度**/
-(float)getTopicContentViewHeight
{
   
    if (![self.content isKindOfClass:[NSNull class]]) {
        CGSize size =  [[MyParserTool shareInstance] sizeWithRawString:self.content constrainsToWidth:kMainScreenWidth * 0.65 Font:[UIFont systemFontOfSize:ContentFontSize]];
        return size.height;
    }else{
        return 0;
    }
    
    
    
}


@end
