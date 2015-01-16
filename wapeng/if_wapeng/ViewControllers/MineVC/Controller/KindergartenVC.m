//
//  KindergartenVC.m
//  if_wapeng
//
//  Created by 心 猿 on 14-12-2.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import "KindergartenVC.h"
#import "UIViewController+General.h"
#import "Cell_KinderGarten.h"
#import "Item_Kindergarten.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
@interface KindergartenVC ()
{
    AFN_HttpBase * http;
    int pageIndex;
    AppDelegate * app;
}
@end

@implementation KindergartenVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
        http = [[AFN_HttpBase alloc]init];
        self.dataArray = [[NSMutableArray alloc]init];

    }
    return self;
}

-(void)httpWithPage:(int)page
{
    NSString* pageStr = [NSString stringWithFormat:@"%d", page];
    
    NSUserDefaults * d = [NSUserDefaults standardUserDefaults];
    NSString * ddid  = [d objectForKey:UD_ddid];
    
    NSString * userInfoID = [d objectForKey:@"userInfoID"];
    
    NSDictionary * postDict = [NSDictionary dictionaryWithObjectsAndKeys:ddid, @"D_ID", userInfoID, @"organizationBranchQuery.id", pageStr, @"activityQuery.pageNum", nil];
    
    
    
    
   int user = [[d objectForKey:UD_userType] intValue];
    
    NSString * urlStr = nil;
    
    if (user == AGENT_USER) {
        
        urlStr = dUrl_OSM_1_2_1;
        
    }else{
        
        urlStr = dUrl_OSM_1_1_2;
        
        postDict = [NSDictionary dictionaryWithObjectsAndKeys:ddid, @"D_ID",pageStr,@"userInfoQuery.pageNum", nil];
    }
    
    
    __weak KindergartenVC * weakSelf = self;
    
    [http fiveReuqestUrl:urlStr postDict:postDict succeed:^(NSObject *obj, BOOL isFinished) {
        
        NSDictionary * root = (NSDictionary *)obj;
        
        if (!isNotNull([root objectForKey:@"value"])) {
            
            [weakSelf.tableVeiw headerEndRefreshing];
            [weakSelf.tableVeiw footerEndRefreshing];
            return;
        }
        if (!isNotNull([[root objectForKey:@"value"] objectForKey:@"list"])) {
            
            [weakSelf.tableVeiw headerEndRefreshing];
            [weakSelf.tableVeiw footerEndRefreshing];
            return;
        }
        
        NSArray * list = [[root objectForKey:@"value"] objectForKey:@"list"];
        
        for (NSDictionary * dict in list) {
            
            Item_Kindergarten * item = [[Item_Kindergarten alloc]init];
            
            item.isButtom = [[[root objectForKey:@"value"] objectForKey:@"isButtom"] intValue];
            
            item.petName = kNullData;
            if (isNotNull([dict objectForKey:@"description"])) {
                item.petName = [dict objectForKey:@"description"];
            }
            item.name = kNullData;
            if ([dict objectForKey:@"name"]) {
                item.name = [dict objectForKey:@"name"];

            }
            
            item.relativePath = kNullData;
            
            if (isNotNull([dict objectForKey:@"organization"])) {
                if (isNotNull([dict objectForKey:@"organization"])) {
                    
                    if (isNotNull([[dict objectForKey:@"organization"] objectForKey:@"photo"])) {
                        
                        if (isNotNull([[[dict objectForKey:@"organization"] objectForKey:@"photo"] objectForKey:@"relativePath"])) {
                            item.relativePath = [NSString stringWithFormat:@"%@%@", dUrl_PhotoPrefixion,[[[dict objectForKey:@"organization"] objectForKey:@"photo"] objectForKey:@"relativePath"]];
                        }
                    }
                }
            }
            
            [weakSelf.dataArray addObject:item];
        }
        
        [weakSelf.tableVeiw headerEndRefreshing];
        [weakSelf.tableVeiw footerEndRefreshing];
        [weakSelf.tableVeiw reloadData];
        
    } failed:^(NSObject *obj, BOOL isFinished) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    app.mTbc.mainView.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    app.mTbc.mainView.hidden =NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IOS7) {
        self.navigationController.navigationBar.translucent = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSUserDefaults * d = [NSUserDefaults standardUserDefaults];
    
    int user = [[d objectForKey:UD_userType] intValue];
    
    if (user == TEACHER_USER) {
        self.title = @"我的学生（家长）";
    }
    if (user == AGENT_USER) {
        
        self.title = @"我的学生";
    }
    
    app = [AppDelegate shareInstace];
    
    [self initLeftItem];
    
    [self createUIView];
    
    pageIndex = 1;
    
    [self httpWithPage:pageIndex];
}

-(void)navItemClick:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
//必须被重写
-(void)headerRereshing
{
    pageIndex = 1;
    
    [self httpWithPage:pageIndex];
}//必须被重写
-(void)footerRereshing
{
    Item_Kindergarten * item = [_dataArray lastObject];
    
    if (item.isButtom == 1) {
        
        [self.tableVeiw footerEndRefreshing];
        
        [SVProgressHUD showSuccessWithStatus:dTips_noMoreData];
        return;
    }
    pageIndex++;
    [self httpWithPage:pageIndex];
}

-(void)createUIView
{
    self.tableVeiw = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - 44) style:UITableViewStylePlain];
    self.tableVeiw.delegate = self;
    self.tableVeiw.dataSource = self;
    [self.view addSubview:self.tableVeiw];
    [self setupRefresh:self.tableVeiw];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * strID = @"ID";
    
    Cell_KinderGarten * cell = [tableView dequeueReusableCellWithIdentifier:strID];
    
    if (nil == cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"Cell_KinderGarten" owner:self options:nil]lastObject];

    }
    
    Item_Kindergarten * item = [self.dataArray objectAtIndex:indexPath.row];
    cell.teacherNick.text = item.petName;
    cell.className.text = item.name;
    
    NSURL * url = [NSURL URLWithString:item.relativePath];
    
    [cell.headerImageView setImageWithURL:url placeholderImage:kDefaultPic];

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
@end
