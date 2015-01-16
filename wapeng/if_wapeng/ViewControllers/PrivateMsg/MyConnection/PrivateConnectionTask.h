//
//  PrivateConnectionTask.h
//  if_wapeng
//
//  Created by 心 猿 on 14-12-13.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

typedef void (^TaskComplete) (NSMutableArray * tempDataArray,BOOL  isFinished);//网络任务是否完成

@class AFN_HttpBase;

#import <Foundation/Foundation.h>

@interface PrivateConnectionTask : NSObject

/**网络请求**/
+(void)requestWithUrl:(NSString *)url postDict:(NSDictionary *)postDict  completeBlock:(TaskComplete)aBlock;

+(NSDictionary *)assmblePostDictWithUrl:(NSString *)url page:(int)page otherParaDict:(NSDictionary *)dict;


@end
