//
//  DataItem.h
//  if_wapeng
//
//  Created by 心 猿 on 14-11-12.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataItem : NSObject<NSCoding>

@property (nonatomic, strong) NSString * located;//居住地

@property (nonatomic, strong) NSString * relativePath;//头像地址

@property (nonatomic, strong) NSString * petName;

@property (nonatomic, strong) NSString * wpCode;

@property (nonatomic, assign) int gender;

@property (nonatomic, strong) NSString * personnelSignature;//个性签名

@property (nonatomic, assign) int userType;//用户类型1，家长那个2教师3其他

@property (nonatomic, strong) NSString * mid;

@property (nonatomic, strong) UIImage * photoImage;

/**保存路径**/
+(NSString *)savePath;
/**保存**/
-(void)saveItem;
/**读取**/
+(DataItem *)readItem;
/**删除**/
+(BOOL)deleteItem;
/**置空**/
-(void)defData;
/*根据url获得image*/
-(UIImage *)getImageWithUrl;
@end
