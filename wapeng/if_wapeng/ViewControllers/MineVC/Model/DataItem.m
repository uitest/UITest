//
//  DataItem.m
//  if_wapeng
//
//  Created by 心 猿 on 14-11-12.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import "DataItem.h"

@implementation DataItem

//编码的时候被调用
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.located forKey:@"located"];
    [aCoder encodeObject:self.relativePath forKey:@"relativePath"];
    [aCoder encodeObject:self.petName forKey:@"petName"];
    [aCoder encodeObject:self.wpCode forKey:@"wpCode"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.gender]
                  forKey:@"gender"];
    [aCoder encodeObject:self.personnelSignature forKey:@"personnelSignature"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.userType] forKey:@"userType"];
    [aCoder encodeObject:self.mid forKey:@"mid"];
    
    [aCoder encodeObject:self.photoImage forKey:@"photoImage"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.located = [aDecoder decodeObjectForKey:@"located"];
        self.relativePath = [aDecoder decodeObjectForKey:@"relativePath"];
        self.petName = [aDecoder decodeObjectForKey:@"petName"];
        self.wpCode = [aDecoder decodeObjectForKey:@"wpCode"];
        self.gender = [[aDecoder decodeObjectForKey:@"gender"] intValue];
        self.personnelSignature = [aDecoder decodeObjectForKey:@"personnelSignature"];
        self.userType = [[aDecoder decodeObjectForKey:@"personnelSignature"] intValue];
        self.mid = [aDecoder decodeObjectForKey:@"mid"];
        self.photoImage = [aDecoder decodeObjectForKey:@"photoImage"];
        
    }
    return self;
    
}
/**返回保存路径**/
+(NSString *)savePath
{
   NSString * filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    filePath = [filePath stringByAppendingPathComponent:@"DataItem"];
    
    return filePath;
}

-(void)saveItem
{
    NSString * filePath = [DataItem savePath];
    
    [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

+(BOOL)deleteItem
{
    NSString * filePath = [DataItem savePath];
    
    NSFileManager * fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:filePath]) {
        
        if ([fm isDeletableFileAtPath:filePath]) {
            
            [fm removeItemAtPath:filePath error:nil];
            
            return YES;
        }
    }else{
        
        NSLog(@"文件不存在");
    }
    
    return NO;
}

+(DataItem *)readItem
{
    NSString * filePath = [DataItem savePath];
    DataItem * item = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    return item;
}
-(void)defData
{
    self.located = kNullData;
    self.relativePath = kNullData;
    self.petName = kNullData;
    self.wpCode = kNullData;
    self.gender = 0;
    self.personnelSignature = kNullData;
    self.userType = 0;
    self.mid = kNullData;
}
-(UIImage *)getImageWithUrl
{
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.relativePath]];
    UIImage * image = [UIImage imageWithData:data];
    self.photoImage = image;
    [self saveItem];
    return image;
}
@end
