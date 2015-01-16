//
//  WeiXinVC.m
//  if_wapeng
//
//  Created by 心 猿 on 14-12-12.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import "WeiXinVC.h"
#import "LoginViewController.h"
@interface WeiXinVC ()

@end

@implementation WeiXinVC


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goLogin:(id)sender {
    
    LoginViewController * loginVC = [[LoginViewController alloc]init];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (IBAction)goRegister:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
