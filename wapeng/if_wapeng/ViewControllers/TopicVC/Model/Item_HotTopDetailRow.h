//
//  Item_HotTopDetailRow.h
//  if_wapeng
//
//  Created by 早上好 on 14-9-11.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item_HotTopDetailRow : NSObject

@property (strong, nonatomic)  NSString *_id;
@property (strong, nonatomic)  NSString *headerPath;//回复人头像
@property (strong, nonatomic)  NSString *content;//回复内容
@property (strong, nonatomic)  NSString *petName;//回复人昵称

@property (strong, nonatomic)  NSString *childAge;//回复人孩子年龄
@property (strong, nonatomic)  NSString *
childGender;//回复人孩子性别
@property (assign , nonatomic)  NSInteger supports;//话题被赞数
@property (assign , nonatomic)  NSInteger
viewReportFlag;//是否举报
@property (assign , nonatomic)  NSInteger
viewStoreFlag;//是否收藏
@property (assign , nonatomic)  NSInteger
viewSupportFlag;//是否点赞
@property (assign , nonatomic)  NSInteger delFlag;//是否删除
@property (strong , nonatomic)  NSString * anonymousCode;//匿名码
@property (assign , nonatomic)  NSInteger anonymousFlag;//是否匿名回复



@end
