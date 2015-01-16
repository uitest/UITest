//
//  RegisterVC07.h
//  if_wapeng
//
//  Created by 心 猿 on 14-8-20.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterVC07 : UIViewController<UITextFieldDelegate , UITableViewDelegate , UITableViewDataSource>
@property(nonatomic,strong)NSString * kind_Name;
@property (nonatomic, assign)int operaiton;//1-  -2
@property (nonatomic, assign)int isButtom;
@property(nonatomic , strong) UITableView * tableview;

@property (nonatomic, strong) NSString * latitude;//纬度
@property (nonatomic, strong) NSString * longtitude;//经度
@property (nonatomic, strong) NSString * areaID;//区域id


@property (nonatomic, assign) int type; // type == 1 修改宝宝信息
@end
