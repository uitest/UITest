//
//  PrivateConnectionTask.m
//  if_wapeng
//
//  Created by 心 猿 on 14-12-13.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

typedef NS_ENUM(NSInteger, JSBubbleMessageType) {
    JSBubbleMessageTypeIncoming = 0,
    JSBubbleMessageTypeOutgoing
} ;

typedef NS_ENUM(NSInteger, JSBubbleMediaType) {
    JSBubbleMediaTypeText = 0,
    JSBubbleMediaTypeImage,
};

#import "PrivateConnectionTask.h"
#import "AFN_HttpBase.h"
#import "MessageData.h"
#import "TimeTool.h"
@implementation PrivateConnectionTask

-(id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

//组装请求字典
+(NSDictionary *)assmblePostDictWithUrl:(NSString *)url page:(int)page otherParaDict:(NSDictionary *)dict
{
    NSMutableDictionary * postDict = nil;
    NSUserDefaults * d = [NSUserDefaults standardUserDefaults];
    
    NSString * ddid = [d objectForKey:UD_ddid];
    //    获取和某人聊天的页面
    if ([url isEqualToString:dUrl_P2P_1_1_5]) {
        
        NSString * pageStr = [NSString stringWithFormat:@"%d", page];
        
        postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:ddid, @"D_ID", pageStr, @"letterQuery.pageNum", nil];
    }
    
    if (dict != nil) {
        
        [postDict addEntriesFromDictionary:dict];
    }
    
    NSLog(@"postDict:%@", postDict);
    
    return postDict;
}


+(void)requestWithUrl:(NSString *)url postDict:(NSDictionary *)postDict completeBlock:(TaskComplete)aBlock
{
    
    AFN_HttpBase * http = [[AFN_HttpBase alloc]init];
    
    [http fiveReuqestUrl:url postDict:postDict succeed:^(NSObject *obj, BOOL isFinished) {
        
        NSDictionary * root = (NSDictionary *)obj;
        
        NSMutableArray * tempDataArray = nil;
        
        tempDataArray = [self parserWithUrl:url resultDict:root];

        aBlock(tempDataArray ,YES);
        
    } failed:^(NSObject *obj, BOOL isFinished) {
        
        NSMutableArray * tempDataArray = nil;
        
        tempDataArray = [self parserWithUrl:url resultDict:nil];
        
        aBlock(tempDataArray ,YES);
    }];
}

+(NSMutableArray *)parserWithUrl:(NSString *)url resultDict:(NSDictionary *)rootDict
{
    if (rootDict == nil) {
        return nil;
    }
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    
    if ([url isEqualToString:dUrl_P2P_1_1_5]) {
        if (isNotNull([rootDict objectForKey:@"value"])) {
            
            if (isNotNull([[rootDict objectForKey:@"value"] objectForKey:@"list"])) {
                
                NSArray * list = [[rootDict objectForKey:@"value"] objectForKey:@"list"];
                if ([url  isEqualToString:dUrl_P2P_1_1_5]) {
                    for (NSDictionary * dict in list) {
                        MessageData * item = [[MessageData alloc]init];
                        item.isButtom = [[[rootDict objectForKey:@"value"] objectForKey:@"isButtom"] intValue];
                        item.text = [dict objectForKey:@"content"];
                        item.date = [TimeTool timeStrTransverterDate:[dict objectForKey:@"createTime"]];
                        item.mediaType = JSBubbleMediaTypeText;//文字
                        //暂时先这么写
                        //                    item.messageType = []JSBubbleMessageTypeIncoming;
                        /*obuser是观察者 viewowner 1 观察者发的私信  2观察者接收的私信*/
                        int a = [[dict objectForKey:@"viewOwner"] intValue];
                        
                        if (a == 2) {
                            item.messageType =JSBubbleMessageTypeIncoming;
                        }
                        if (a == 1) {
                            
                            item.messageType =  JSBubbleMessageTypeOutgoing;
                        }
                        
                        item.msgId = [dict objectForKey:@"id"];
                        
                        //默认是发送成功的
                        item.isSendSuccess = YES;
                        //对方昵称
                        item.peerPetName = [[dict objectForKey:@"orUser"] objectForKey:@"petName"];
                        
                        
                        item.peerPhotoUrl = kNullData;
                        if (isNotNull([[dict objectForKey:@"orUser"] objectForKey:@"photo"])) {
                            
                            item.peerPhotoUrl = [NSString stringWithFormat:@"%@%@", dUrl_PhotoPrefixion,[[[dict objectForKey:@"orUser"] objectForKey:@"photo"] objectForKey:@"relativePath"]];
        
                        }
                        
                        item.observePhotoUrl = kNullData;
                        
                        if (isNotNull([[dict objectForKey:@"obUser"] objectForKey:@"photo"])) {
                            
                            item.peerPhotoUrl = [NSString stringWithFormat:@"%@%@", dUrl_PhotoPrefixion,[[[dict objectForKey:@"obUser"] objectForKey:@"photo"] objectForKey:@"relativePath"]];
                            
                        }

                        
                        [dataArray addObject:item];
                    }
                }
                
            }
        }
    }

    return dataArray;
}
@end
