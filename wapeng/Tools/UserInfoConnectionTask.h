//
//  UserInfoConnectionTask.h
//  if_wapeng
//
//  Created by 心 猿 on 14-12-17.
//  Copyright (c) 2014年 funeral. All rights reserved.
//
@class DataItem;
@class UserInfoConnectionTask;

@protocol getUserInfoDelegate <NSObject>

-(void)getItemFailed:(UserInfoConnectionTask *)task;

-(void)getItemFinished:(UserInfoConnectionTask *)task;

@end

#import <Foundation/Foundation.h>

@interface UserInfoConnectionTask : NSObject

@property (nonatomic , weak) id <getUserInfoDelegate> delegate;

@property (nonatomic, strong) DataItem * item;

@property (nonatomic, assign) int tag;//用于区分不同对象

-(void)getUserInfo;
@end
