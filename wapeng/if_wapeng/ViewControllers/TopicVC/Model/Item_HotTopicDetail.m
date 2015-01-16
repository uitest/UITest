//
//  Item_HotTopicDetail.m
//  if_wapeng
//
//  Created by 早上好 on 14-9-11.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import "Item_HotTopicDetail.h"
#import "TQRichTextView.h"
#import "Constant_general.h"
#import "MyParserTool.h"
#define AttachmentImageSize 55
@implementation Item_HotTopicDetail

-(id)init
{
    self = [super init];
    if (self) {
        self.attachmentList = [NSMutableArray array];
    }
    return self;
    
}

-(float)getTopicDetailCellHeight:(float)newHeight{
    
    float height = 0;
    height += newHeight;
    //textview动态高度

//    height += [[MyParserTool shareInstance] sizeWithRawString:self.content constrainsToWidth:(kMainScreenWidth * 0.6) Font:[UIFont systemFontOfSize:14]].height;
    ;
    
    
//    //附带图片动态高度
//
//
    return height;
}
/**根据话题内容计算高度**/
-(float)getTopicContentViewHeight
{
    CGRect frame = [self.TopicContent boundingRectWithSize:CGSizeMake(kMainScreenWidth * 0.6, 999) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:ContentFontSize]} context:nil];
    
    return frame.size.height+5;
}
/**计算所有附件图片占用的高度**/
-(float)getTopicImageGroupHeight
{
    float height = 0;
    NSInteger count = self.attachmentList.count;
    if (count > 0  && count < 4) {
        height += AttachmentImageSize;
    }else if (count < 7 && count > 3){
        height += AttachmentImageSize*2 + 10;

    }else if (count < 10 && count > 6){
        height += AttachmentImageSize*3 + 10*2;
    }
    NSLog(@"~~~~~~~~ height = %f",height);
    return height;
}

@end
