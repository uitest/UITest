//
//  ASIVC02.m
//  if_wapeng
//
//  Created by 心 猿 on 14-12-18.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import "ASIVC02.h"
#import "UserInfoConnectionTask.h"
@interface ASIVC02 ()<getUserInfoDelegate>

@end

@implementation ASIVC02

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lbl.text = @"111111sdfgsssssssssssss111111sdfgsssssssssssss111111sdfgsssssssssssss111111sdfgsssssssssssss111111sdfgsssssssssssss111111sdfgsssssssssssss";
    
    self.lbl.text = @"[微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑][微笑]";
}




-(void)btnClick
{
    UserInfoConnectionTask * task = [[UserInfoConnectionTask alloc]init];
    task.delegate = self;
    
    [task getUserInfo];

}
-(void)getItemFinished:(DataItem *)item
{
    NSLog(@"%@", item);
}
-(void)getItemFailed
{
    NSLog(@"failed!");
}
@end
