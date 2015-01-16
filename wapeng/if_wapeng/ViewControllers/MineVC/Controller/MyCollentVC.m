//
//  MyCollentVC.m
//  if_wapeng
//
//  Created by 心 猿 on 14-11-28.
//  Copyright (c) 2014年 funeral. All rights reserved.
//
typedef NS_ENUM(NSInteger, kPageType) {
    LEFT = 0,
    MIDDLE = 1,
    RIGHT = 2
};

#define MAX_TAG 100
#define SEGHEIGHT 40 //seg的高度
#import "MyCollentVC.h"
#import "UIViewController+General.h"
#import "HMSegmentedControl.h"
#import "HotTopicTVCell.h"
#import "HotTopicEntity.h"
#import "UIImageView+WebCache.h"
#import "CollectionActItem.h"
#import "Cell_SellerActi3.h"
#import "Item_MyMailEntity.h"
#import "Cell_MyMail.h"
#import "Cell_Mail.h"
#import "AppDelegate.h"
#import "UIViewController+MMDrawerController.h"

#import "ActivityDetailVC.h"
#import "MyChatVC.h"
#import "AnnouncementDetailVC.h"
@interface MyCollentVC ()<UITableViewDataSource, UITableViewDelegate>
{
    int pageIndex1;
    int pageIndex2;
    int pageIndex3;//三种
    AFN_HttpBase * http;
}
@property (nonatomic, assign) kPageType type;
@property (nonatomic, strong)UIScrollView * bgScrollView;
@property (nonatomic, strong) HMSegmentedControl * segCtrl;
@property (nonatomic, strong) UITableView * correntTableView;
@end

@implementation MyCollentVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        http = [[AFN_HttpBase alloc]init];
        self.leftArr = [[NSMutableArray alloc]init];
        self.rightArr = [[NSMutableArray alloc]init];
        self.middleArr = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    AppDelegate * app = [AppDelegate shareInstace];
    app.mTbc.mainView.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    AppDelegate * app = [AppDelegate shareInstace];
    app.mTbc.mainView.hidden = NO;
}
//TOP_1_7_2 ACT_1_6_2 P2P_1_2_2

/**
 收藏的话题请求
 **/

#pragma mark - 话题请求

-(void)startTopicHttpRequestWithPage:(int)page
{
    NSString * newPage = [NSString stringWithFormat:@"%d", page];
    
    NSUserDefaults * d = [NSUserDefaults standardUserDefaults];
    
    NSString * ddid = [d objectForKey:UD_ddid];
    
    NSDictionary * postDict =[NSDictionary dictionaryWithObjectsAndKeys:ddid, @"D_ID", newPage, @"topicStoreQuery.pageNum", nil];
    
    self.leftTableView = (UITableView *)[self.view viewWithTag:MAX_TAG];
    __weak MyCollentVC * weakSelf = self;
    [http fiveReuqestUrl:TOP_1_7_2 postDict:postDict succeed:^(NSObject *obj, BOOL isFinished) {
        
        NSDictionary * root = (NSDictionary *)obj;
       
        if (isNotNull([root objectForKey:@"value"])) {
            
            if (isNotNull([[root objectForKey:@"value"] objectForKey:@"list"])) {
                
                 NSArray *list = [[root objectForKey:@"value"] objectForKey:@"list"];
                
                for (NSDictionary * dict in list) {
                    
                    HotTopicEntity * item = [[HotTopicEntity alloc]init];
                    item.createTime = [dict objectForKey:@"storeTime"];
                    item.name = [[[dict objectForKey:@"topic"] objectForKey:@"author"] objectForKey:@"petName"];
                    item.head = [NSString stringWithFormat:@"%@%@", dUrl_PhotoPrefixion,[[[[dict objectForKey:@"topic"] objectForKey:@"author"] objectForKey:@"photo"] objectForKey:@"relativePath"]];
                    item.content = [[dict objectForKey:@"topic"] objectForKey:@"content"];
                    item.isButtom = [[[root objectForKey:@"value"] objectForKey:@"isButtom"] intValue];
                    item._id = [[dict objectForKey:@"topic"] objectForKey:@"id"];

                    [weakSelf.leftArr addObject:item];
                }
                
                NSLog(@"%@", weakSelf.leftArr);
                
                [weakSelf.leftTableView reloadData];
            }else{
                 [SVProgressHUD showSuccessWithStatus:dTips_noMoreData];
            }
        }else{
            
            [SVProgressHUD showSuccessWithStatus:dTips_noMoreData];
        }
        [weakSelf.leftTableView headerEndRefreshing];
        [weakSelf.leftTableView footerEndRefreshing];
        
    } failed:^(NSObject *obj, BOOL isFinished) {
        
    }];
    
}
#pragma mark - 活动请求

-(void)startActHttpRequestWithPage:(int)page
{
    NSString * newPage = [NSString stringWithFormat:@"%d", page];
    
    NSUserDefaults * d = [NSUserDefaults standardUserDefaults];
    
    NSString * ddid = [d objectForKey:UD_ddid];
    
    NSDictionary * postDict =[NSDictionary dictionaryWithObjectsAndKeys:ddid, @"D_ID", newPage, @"activityStoreQuery.pageNum", nil];
    
    self.middleTableView = (UITableView *)[self.view viewWithTag:MAX_TAG + 1];
    
    __weak MyCollentVC * weakSelf = self;
    
    [http fiveReuqestUrl:ACT_1_6_2 postDict:postDict succeed:^(NSObject *obj, BOOL isFinished) {
        
        NSDictionary * root = (NSDictionary *)obj;
        
        if (isNotNull([root objectForKey:@"value"])) {
            
            if (isNotNull([[root objectForKey:@"value"] objectForKey:@"list"])) {
                
                NSArray * list = [[root objectForKey:@"value"] objectForKey:@"list"];
                
                for (NSDictionary * dict in list) {
                    
                    CollectionActItem * item = [[CollectionActItem alloc]init];
                    item.content = [[dict objectForKey:@"activity"] objectForKey:@"content"];
                    item.relativePath = [NSString stringWithFormat:@"%@%@", dUrl_PhotoPrefixion, [[[dict objectForKey:@"activity"] objectForKey:@"photo"] objectForKey:@"relativePath"]];
                    item.petName = [[[dict objectForKey:@"activity"] objectForKey:@"author"] objectForKey:@"petName"];
                    item.isButtom = [[[root objectForKey:@"value"] objectForKey:@"isButtom"] intValue];
                    item.mid = [[dict objectForKey:@"activity"] objectForKey:@"id"];
                    [weakSelf.middleArr addObject:item];
                }
                
                NSLog(@"%@", weakSelf.middleArr);
                
                [weakSelf.correntTableView reloadData];

            }else{
                
                [SVProgressHUD showSuccessWithStatus:dTips_noMoreData];
            }
        }else{
            
            [SVProgressHUD showSuccessWithStatus:dTips_noMoreData];
        }
        
        [weakSelf.middleTableView headerEndRefreshing];
        [weakSelf.middleTableView footerEndRefreshing];
        
        
    } failed:^(NSObject *obj, BOOL isFinished) {
        
    }];

}
#pragma mark - 私信请求
-(void)startMailHttpRequestWithPage:(int)page
{
    
    NSUserDefaults * d = [NSUserDefaults standardUserDefaults];
    
    NSString * ddid = [d objectForKey:UD_ddid];
    
    NSString * pageStr = [NSString stringWithFormat:@"%d", page];
    
    NSDictionary * postDict = [[NSDictionary alloc]initWithObjectsAndKeys:ddid, @"D_ID", pageStr , @"letterStoreQuery.pageNum", nil];
    
    self.rightTableView = (UITableView *)[self.view viewWithTag:MAX_TAG + 2];
    
    __weak MyCollentVC * weakSelf = self;
    
    [http sixReuqestUrl:P2P_1_2_2 postDict:postDict succeed:^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
        //        weakSelf.segmented.enabled = NO;
        //        self.isLoadData = YES;
        
        NSDictionary * root =  (NSDictionary *)obj;
        

        if (isNotNull([root objectForKey:@"value"])) {
            
            if (isNotNull([[root objectForKey:@"value"] objectForKey:@"list"])) {
                
                NSArray * list = [[root objectForKey:@"value"] objectForKey:@"list"];
                
                for (NSDictionary * dict in list) {
                    
                    Item_MyMailEntity * item = [[Item_MyMailEntity alloc]init];
                    item.isButtom = [[[root objectForKey:@"value"] objectForKey:@"isButtom"] intValue];
                    
                    NSLog(@"%d", item.isButtom);
                    
                    NSArray * letterList = [dict objectForKey:@"letterList"];
                    NSDictionary * newDict = [letterList lastObject];
                    item.content = [newDict objectForKey:@"content"];
                    item.createTime = [newDict objectForKey:@"createTime"];
                    item.read = [[dict objectForKey:@"read"]intValue];
                    item.petName = kNullData;
                    if (isNotNull([[dict objectForKey:@"sender"] objectForKey:@"petName"])) {
                        item.petName = [[dict objectForKey:@"sender"] objectForKey:@"petName"];
                    }
                    
                    
                    item.relativePath = kNullData;
                    if (isNotNull([dict objectForKey:@"photo"])) {
                        if (isNotNull([[dict objectForKey:@"photo"] objectForKey:@"relativePath"])) {
                            item.relativePath = [NSString stringWithFormat:@"%@%@", dUrl_PhotoPrefixion,[[dict objectForKey:@"photo"] objectForKey:@"relativePath"]];
                        }
                    }
                    
                    [weakSelf.rightArr addObject:item];
                }
                [weakSelf.rightTableView reloadData];
                
                
                
            }else{
                
                [SVProgressHUD showSuccessWithStatus:dTips_noMoreData];
            }
        }else{
            [SVProgressHUD showSuccessWithStatus:dTips_noMoreData];
        }
        [weakSelf.rightTableView headerEndRefreshing];
        [weakSelf.rightTableView footerEndRefreshing];
        
        
    } failed:^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
        
    }];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (IOS7) {
        self.navigationController.navigationBar.translucent = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //初始化页数
    pageIndex1 = 1;
    pageIndex2 = 1;
    pageIndex3 = 1;
    self.type = LEFT;
    
    self.title = @"我的收藏";
    
    [self createUIView];
    [self createRightItem];
    [self startTopicHttpRequestWithPage:pageIndex1];

}
-(void)rightItemClick:(UIBarButtonItem *)item
{
    if (self.correntTableView.editing == YES) {
        
        item.title = @"编辑";
    
    }else{
        
        item.title = @"完成";
    }
    //改变状态
    self.correntTableView.editing = !self.correntTableView.editing;
}
-(void)createRightItem
{
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}
#pragma mark - 下拉刷新
//必须被重写
-(void)headerRereshing
{
    switch (self.type) {
            
        case LEFT:
        {
            pageIndex1 = 1;
            [self.leftArr removeAllObjects];
            [self startTopicHttpRequestWithPage:pageIndex1];
        }
            break;
        case MIDDLE:
        {
            pageIndex2 = 1;
            [self.middleArr removeAllObjects];
            [self startActHttpRequestWithPage:pageIndex2];
        }
            break;
        case RIGHT:
        {
            pageIndex3 = 1;
            [self.rightArr removeAllObjects];
            [self startMailHttpRequestWithPage:pageIndex3];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - 上拉刷新
//必须被重写
-(void)footerRereshing
{
    int isButtom = - 1;
    switch (self.type) {
        case LEFT:
        {
            HotTopicEntity * item = [self.leftArr lastObject];
            isButtom = item.isButtom;
        }
            break;
        case MIDDLE:
        {
            CollectionActItem * item = [self.middleArr lastObject];
            isButtom = item.isButtom;
        }
            break;
        case RIGHT:
        {
            Item_MyMailEntity * item = [self.rightArr lastObject];
            isButtom = item.isButtom;
        }
            break;
            
        default:
            break;
    }
    
    if (isButtom == 1) {
        
        [SVProgressHUD showSuccessWithStatus:dTips_noMoreData];
        
        [self.leftTableView footerEndRefreshing];
        [self.middleTableView footerEndRefreshing];
        [self.rightTableView footerEndRefreshing];
        return;
    }
    
    switch (self.type) {
            
        case LEFT:
        {
            pageIndex1++;
            [self.leftArr removeAllObjects];
            [self startTopicHttpRequestWithPage:pageIndex1];
        }
            break;
        case MIDDLE:
        {
            pageIndex2++;
            [self.middleArr removeAllObjects];
            [self startActHttpRequestWithPage:pageIndex2];
        }
            break;
        case RIGHT:
        {
            pageIndex3++;
            [self.rightArr removeAllObjects];
            [self startMailHttpRequestWithPage:pageIndex3];
        }
            break;
            
        default:
            break;
    }

}

#pragma mark - 创建UI
-(void)createUIView
{
    //创建背景scrollView
    self.bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - 44)];
    self.bgScrollView.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - 44);
    self.bgScrollView.contentSize = CGSizeMake(kMainScreenWidth * 3, kMainScreenHeight - 44);
    self.bgScrollView.pagingEnabled = YES;
    self.bgScrollView.bounces = NO;
    self.bgScrollView.scrollEnabled = NO;
    [self.view addSubview:self.bgScrollView];
    
    for (int i = 0; i < 3; i++) {
        
        UITableView * tableView = [[UITableView alloc]initWithFrame:CGRectMake(kMainScreenWidth * i, SEGHEIGHT, kMainScreenWidth, kMainScreenHeight - 44 - 40) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag = i + MAX_TAG;
        [self.bgScrollView addSubview:tableView];
        //注册下拉刷新
        [self setupRefresh:tableView];
    }
    
    self.correntTableView = (UITableView *)[self.view viewWithTag:MAX_TAG];
    NSArray * titles = @[@"话题", @"活动", @"私信"];
    
    HMSegmentedControl * seg = [[HMSegmentedControl alloc]initWithSectionTitles:titles];
    seg.selectionIndicatorColor = [UIColor redColor];
    seg.frame = CGRectMake(0, 0, kMainScreenWidth, SEGHEIGHT);
    [seg setSelectedTextColor:[UIColor redColor]];
    seg.selectionStyle = HMSegmentedControlSelectionStyleBox;
    [seg setFont:[UIFont systemFontOfSize:14]];
    [self.bgScrollView addSubview:seg];
    
    __weak HMSegmentedControl * newSeg = seg;
    
    __weak MyCollentVC * weakSelf = self;
    
    [seg setIndexChangeBlock:^(NSInteger index) {
        
        weakSelf.navigationItem.rightBarButtonItem.title = @"编辑";
        //拿到对应的tableView
         weakSelf.correntTableView = (UITableView *)[self.view viewWithTag:MAX_TAG + index];
         weakSelf.correntTableView.editing = NO;
        CGRect frame = CGRectZero;
        frame = newSeg.frame;
        frame.origin.x = index * kMainScreenWidth;
        
        CGPoint point = CGPointMake(kMainScreenWidth * index, 0);
        
        weakSelf.bgScrollView.scrollEnabled = YES;
        [UIView animateWithDuration:0.3 animations:^{
            
            newSeg.frame = frame;
            weakSelf.bgScrollView.contentOffset = point;

        }];
        
        weakSelf.bgScrollView.scrollEnabled = NO;
        
        self.type = index;
        //开始刷新列表
        [self.correntTableView headerBeginRefreshing];
        
        
    }];
    
    [self initLeftItem];
}

-(void)navItemClick:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 120;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.type == LEFT) {
        
        return self.leftArr.count;
    }
    if (self.type == MIDDLE) {
        
        return  self.middleArr.count;
    }
    if (self.type == RIGHT) {
        
        return self.rightArr.count;
    }
        return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.type == LEFT) {
        
        static NSString *identifier=@"cell";
        
        HotTopicTVCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell=[[HotTopicTVCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        if (self.leftArr.count >= indexPath.row + 1) {
            
            HotTopicEntity * item = [self.leftArr objectAtIndex:indexPath.row];
            
            cell.contentLable.text = item.content;
            
            cell.nameLable.text = item.name;
            
            NSURL * url = [NSURL URLWithString:item.head];
            [cell.headImageView setImageWithURL:url placeholderImage:kDefaultPic];
            
        }
        return cell;
        
    }else if (self.type == MIDDLE)
    {
        static NSString * strID1 = @"ID";
        
        Cell_SellerActi3 * cell = [tableView dequeueReusableCellWithIdentifier:strID1];
        
        if (nil == cell) {
            
            cell = [[Cell_SellerActi3 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strID1];
        }
        
        if (self.middleArr.count >= indexPath.row + 1) {
            
            CollectionActItem * item = [self.middleArr objectAtIndex:indexPath.row];
            cell.mainLabel.text = item.content;
            NSURL * url = [NSURL URLWithString:item.relativePath];
            cell.userLabel.text = item.petName;
            [cell.headerImage setImageWithURL:url placeholderImage:kDefaultPic];
        }
        
        return cell;
        
    }else{
        
        static NSString *identifier=@"cell";
        Cell_Mail *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell=[[Cell_Mail alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        
        /*快速点击seg的时候如果lfetArr 被清空同时 cellforrow还在取数据模型，会崩溃所以要加判断*/
        if (self.rightArr.count >= indexPath.row + 1) {
            
            Item_MyMailEntity * item = self.rightArr[indexPath.row]
            ;
            [cell.headerIV setImageWithURL:[NSURL URLWithString:item.relativePath] placeholderImage:kDefaultPic];
            cell.mailContent.text = item.content;
            cell.name.text = item.petName;
            
        }
        return cell;
    }
}

#pragma mark - 点击进入详情
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([tableView isEqual:(UITableView *)[self.view viewWithTag:MAX_TAG]]) {
        NSLog(@"话题详情");
        AnnouncementDetailVC * annocentDetailVC = [[AnnouncementDetailVC alloc]init];
        [self.navigationController pushViewController:annocentDetailVC animated:YES];
    }
    if ([tableView isEqual:(UITableView *)[self.view viewWithTag:MAX_TAG + 1]]) {
        NSLog(@"活动详情");
        
        CollectionActItem * item = [self.middleArr objectAtIndex:indexPath.row];
        ActivityDetailVC * detailVC = [[ActivityDetailVC alloc]init];
        detailVC.activityID = item.mid;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    if ([tableView isEqual:(UITableView *)[self.view viewWithTag:MAX_TAG + 2]]) {
        
        MyChatVC * chatVC = [[MyChatVC alloc]init];
        
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

#pragma mark - 滑动删除

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (!tableView.isEditing)
//        
//    {
//
//        return UITableViewCellEditingStyleDelete;
//        
//    }
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%@", NSStringFromCGRect(cell.frame));
    
    return UITableViewCellEditingStyleDelete;
    
}
-(NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexpath
{
    return @"删除";
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView isEqual:[self.view viewWithTag:MAX_TAG]]) {
        
        HotTopicEntity * item = [self.leftArr objectAtIndex:indexPath.row];
        [self cancelCollectionTopicWithID:item._id];
    }
    if ([tableView isEqual:[self.view viewWithTag:MAX_TAG + 1]]) {
        
        CollectionActItem * item = [self.middleArr objectAtIndex:indexPath.row];
        
        [self cancelConllectionActWithID:item.mid];
    }
    
    if ([tableView isEqual:[self.view viewWithTag:MAX_TAG + 2]]) {
        
        Item_MyMailEntity * item = [self.rightArr objectAtIndex:indexPath.row];
        
        [self cancelConllectionPrivateMsg:item.recieverID];
    }
    
    [tableView reloadData];
}
#pragma mark - 取消话题收藏

-(void)cancelCollectionTopicWithID:(NSString * )mid
{
    NSUserDefaults * d = [NSUserDefaults standardUserDefaults];
    
    NSString * ddid = [d objectForKey:UD_ddid];
    
    __weak MyCollentVC * weakSelf = self;
    
    [http thirdRequestWithUrl:TOP_1_7_1 succeed:^(NSObject *obj, BOOL isFinished) {
        
        [SVProgressHUD showSuccessWithStatus:@"取消收藏"];
        
        UITableView * tableView = (UITableView *)[weakSelf.view viewWithTag:MAX_TAG ];
        [tableView reloadData];
        
    } failed:^(NSObject *obj, BOOL isFinished) {
        
    } andKeyValuePairs:@"D_ID",ddid, @"topicStore.topic.id", mid, @"topicStore.type", @"1", @"topicStore.actType", @"2", nil];

}
#pragma mark - 两个代理方法是为了防止滑动产出的时候红色按钮被遮挡


-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    CGRect frame = cell.frame;
    frame.origin.x = 0;
    cell.frame = frame;
}
-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    CGRect frame = cell.frame;
    frame.origin.x += 50;
    cell.frame = frame;
}

- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - 取消收藏活动

-(void)cancelConllectionActWithID:(NSString *)mid
{
    NSUserDefaults * d = [NSUserDefaults standardUserDefaults];
    
    NSString * ddid = [d objectForKey:UD_ddid];
    
    __weak MyCollentVC * weakSelf = self;
    
    [http thirdRequestWithUrl:dUrl_ACT_1_6_1 succeed:^(NSObject *obj, BOOL isFinished) {
        
        [SVProgressHUD showSuccessWithStatus:@"取消收藏"];
        
        UITableView * tableView = (UITableView *)[weakSelf.view viewWithTag:MAX_TAG + 1];
        [tableView reloadData];
        
    } failed:^(NSObject *obj, BOOL isFinished) {
        
    } andKeyValuePairs:@"D_ID",ddid, @"activityStore.activity.id", mid, @"activityStore.type", @"1", @"activityStore.actType", @"2", nil];
}

#pragma mark - 取消收藏私信

-(void)cancelConllectionPrivateMsg:(NSString *)mid
{
    NSUserDefaults * d = [NSUserDefaults standardUserDefaults];
    
    NSString * ddid = [d objectForKey:UD_ddid];
    [http thirdRequestWithUrl:dUrl_P2P_1_2_3 succeed:^(NSObject *obj, BOOL isFinished) {
        
    } failed:^(NSObject *obj, BOOL isFinished) {
        
    } andKeyValuePairs:@"D_ID", ddid, @"letterStoreQuery.letterIDs", mid, nil];
}
@end
