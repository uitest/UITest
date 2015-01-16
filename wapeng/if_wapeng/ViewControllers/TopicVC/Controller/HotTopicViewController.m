//
//  HotTopicViewController.m
//  if_wapeng
//
//  Created by 心 猿 on 14-8-7.
//  Copyright (c) 2014年 funeral. All rights reserved.
//身边热点 熟人话题 同龄段话题 身边机构  分类话题 话题收藏

#define dTag_rightBtn 101
#define dTag_searchText 102
#import "HotTopicViewController.h"
#import "HotTopicTVCell.h"
#import "HotTopicEntity.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "MMDrawerController.h"
#import "UIView+WhenTappedBlocks.h"
#import "TalkColumnVC.h"
#import "AFN_HttpBase.h"
#import "HotTopicDetailVC.h"
#import "LoadingDialog.h"
#import "SVProgressHUD.h"
//#import "PullingRefreshTableView.h"
#import "AppDelegate.h"
#import "LetterVC.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+AFNetworking.h"
#import "FileManger.h"
#import "DownloadImageManger.h"
#import "TimeTool.h"
#import "Item_HotWord.h"
#import "CheckDataTool.h"
#import "StringTool.h"
#import "HotTopicTopTenCell.h"
#import "CreateTAopicVC.h"
#import "UIViewController+General.h"

/**/
#import "PushAcitivityController.h"
@interface HotTopicViewController ()
{
    //身边热帖
    NSString* disNo ;
    NSString* startIndex;
    NSString* isButtom;
    //熟人话题
    NSString * pageNum;
    
    UIButton  *_lastBtn;
    
    NSString * requestUrl;
    NSMutableDictionary * parameter;
    AppDelegate * app;
    NSString * D_ID;//登陆的d_id
    NSString * searchContent;
    //刷新加载
    int pageIndex;//当前页码
}
@property(nonatomic ,strong)NSMutableArray * hotWordArray;//热词搜索

@property (nonatomic, assign) int isBottom;//是否有下一页
@property (nonatomic, assign) BOOL operation;//yes = 下拉刷新 no = 上拉加载

@end

@implementation HotTopicViewController
{
    AFN_HttpBase * http;
    NSUserDefaults * ud;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titileS = @"身边热点";
        self.dateSource = [[NSMutableArray alloc]  init];
        parameter = [[NSMutableDictionary alloc] init];
        self.hotWordArray = [[NSMutableArray alloc]  init];
        [self  resetRequestData];
        http = [[AFN_HttpBase alloc]  init];
        ud = [NSUserDefaults standardUserDefaults];
        D_ID = [ud objectForKey:UD_ddid];
        self.talkMark = RoundHot;
    }
    return self;
}
-(void)resetRequestData{
    //初始化 身边热点
    disNo = @"3";
    startIndex = @"1";
    isButtom = @"0";
    //熟人话题
    pageNum = @"1";
}
- (void)viewWillAppear:(BOOL)animated;
{
    if (IOS7) {
        self.navigationController.navigationBar.translucent = NO;
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    D_ID = [app.loginDict  objectForKey:@"d_ID"];
    [self createNavigation];
//    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector (refreshSrocll:) name:@"hotWord" object:nil];
//
//}
}
//-(void)refreshSrocll:(NSNotification *)notification
//{
//    [self createSearchHotWord];
//    
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kRGB(237, 237, 237);
    app = [AppDelegate shareInstace];
    self.title = self.titileS;
    pageIndex = 1;
    [self setRequesParameterAndRequesData:pageIndex];
    [self  createComponent];
        
}

//设置请求参数 并 请求数据
-(void)setRequesParameterAndRequesData:(int)page
{
    switch (self.talkMark) {
        case RoundHot:
            requestUrl = TOP_1_2_11;
            [self setRoundHotDictionaryValue:startIndex];
            break;
        case FriendSTalk:
            requestUrl = TOP_1_2_7;
            [self setFriendSTalkDictionaryValue:page];
//            int pag = [pageNum intValue] + 1;//每次请求后 都加1
//            pageNum = [NSString stringWithFormat:@"%d",pag];
            break;
            
        case AgeSearch://全网同龄话题
            requestUrl = TOP_1_2_12;
            [self setAgeSearchDictionaryValue:startIndex];
            break;
        case RoundOrganization:
            requestUrl = TOP_1_2_11;
            break;
        case TenTop:
            requestUrl = TOP_1_2_8;
            [self setTenTopDictionaryValue];
            break;
        case TalkCollect:
            requestUrl = TOP_1_2_11;
            break;
            
        case AgeTalk:
            requestUrl = TOP_1_2_1;
            [self setAgeTalkDictionaryValue];
            break;
        case SearchWord:
            requestUrl = TOP_1_2_3;
            [self setParamForSearch:searchContent];
            int pag2 = [pageNum intValue] + 1;//每次请求后 都加1
            pageNum = [NSString stringWithFormat:@"%d",pag2];
            break;
            
        case MyTopicList:
            requestUrl = TOP_1_2_9;
            [self setRequestParticipationParam:page];
            
            break;
        default:
            break;
    }
    [self requestHttp];
}
//请求网络连接
-(void)requestHttp{
    [SVProgressHUD showWithStatus:@"正在加载"];
    __weak HotTopicViewController * weakSelf = self;
    [http fiveReuqestUrl:requestUrl postDict:parameter succeed:^(NSObject *obj, BOOL isFinished) {
        [SVProgressHUD dismiss];
        if (weakSelf.operation == YES) {
            [weakSelf.dateSource removeAllObjects];
        }
        if (self.talkMark == TenTop) {
            self.isBottom = 1;
           NSLog(@"------ obj = %@",obj);
            NSArray * array = [(NSDictionary *)obj  objectForKey:@"value"];
//            NSLog(@"-------- array = %@",array);
            [weakSelf responeTenTopData:array];
        }else if(self.talkMark == MyTopicList){
            NSDictionary * dic = [(NSDictionary *)obj  objectForKey:@"value"];
//            NSLog(@"-------- dic = %@",dic);
            [weakSelf responeMyTopicListData:dic];
            
        }else{
            NSDictionary * dic = [(NSDictionary *)obj  objectForKey:@"value"];
            NSLog(@"-------- dic = %@",dic);
            if([dic isKindOfClass:[NSNull class]]){
                [weakSelf  stopRefresh];
                [SVProgressHUD showSuccessWithStatus:@"无数据"];
                return;
            }
            [weakSelf responeData:dic];
        }
    } failed:^(NSObject *obj, BOOL isFinished) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%u数据交互错误",self.talkMark]];
        [weakSelf stopRefresh];
    }];
    
}
//最近三天热词
//-(void)requestHotWord{
//    __weak HotTopicViewController * weakSelf = self;
//    [http fiveReuqestUrl:TOP_1_1_1 postDict:parameter succeed:^(NSObject *obj, BOOL isFinished) {
//        NSDictionary * dic = (NSDictionary *)obj;
//        NSDictionary *value = [dic  objectForKey:@"value"];
//        NSArray * array = [value  objectForKey:@"list"];
//        for (int i = 0; i < array.count; i++) {
//            Item_HotWord * item = [[Item_HotWord alloc] init];
//            NSDictionary * dicIndex = [array  objectAtIndex:i];
//            NSString * content = [dicIndex  objectForKey:@"content"];
//            NSString * _id = [dicIndex  objectForKey:@"id"];
//            NSString * useDate = [dicIndex  objectForKey:@"useDate"];
//            NSString * useTime = [NSString stringWithFormat:@"%@",[dicIndex  objectForKey:@"useTime"]];
//            item.content = content;
//            item._id = _id;
//            item.useDate = useDate;
//            item.useTime = useTime;
//            [weakSelf.hotWordArray addObject:item];
//        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"hotWord" object:nil];
//    } failed:^(NSObject *obj, BOOL isFinished) {
//        [SVProgressHUD showSuccessWithStatus:@"数据交互错误"];
//        [weakSelf stopRefresh];
//    }];
//}


//我的话题  包括两个请求 一个是我发起的 第二个是我参与的 现请求完成 再把数据重新排序升序
-(void)requesMyTopicListData{
    __weak HotTopicViewController * weakSelf = self;
    NSLog(@"-----我参与的 parameter = %@",parameter);
    [http fiveReuqestUrl:TOP_1_2_10 postDict:parameter succeed:^(NSObject *obj, BOOL isFinished) {
        NSDictionary * dic = (NSDictionary *)obj;
        if (![dic isKindOfClass:[NSNull class]]) {
            NSDictionary *value = [dic  objectForKey:@"value"];
            NSLog(@"%@",value);
            if (![value isKindOfClass:[NSNull class]]) {
                NSNumber * isbuttom = [value objectForKey:@"isButtom"];
                if ([isbuttom isKindOfClass:[NSNull class]]) {
                    self.isBottom = 1;
                }
                if (self.isBottom == 1) {
                    NSLog(@"-----最后一页");
                }
//                else{
                    NSArray * array = [value objectForKey:@"list"];
                    if (![array isKindOfClass:[NSNull class]] && array.count != 0) {
                        for (int i = 0; i < array.count; i++) {
                            HotTopicEntity * hotTop = [[HotTopicEntity alloc] init];
                            NSDictionary * d = [array  objectAtIndex:i];
                            NSString * content = [d objectForKey:@"content"];
                            //解析photo和petname
                            NSDictionary * author = [d objectForKey:@"author"];
                            NSLog(@"-------author = %@",author);
                            NSString * petName;
                            //解析头像
                            NSDictionary * photo;
                            //
                            NSNumber * anonymousFlag = [d objectForKey:@"anonymousFlag"];
                            NSString * anonymousCode = [d objectForKey:@"anonymousCode"];
                            //1是匿名发布 2不是匿名
                            if (![anonymousFlag isKindOfClass:[NSNull class]] && anonymousFlag.intValue == 1) {
                                hotTop.petName = anonymousCode;
                                hotTop.userPhotoUrl = @"22222";
                            }else{
                                if (![author isKindOfClass:[NSNull class]]) {
                                    petName = [author objectForKey:@"petName"];
                                    //解析头像
                                    photo = [author objectForKey:@"photo"];
                                    //
                                    
                                }
                                //设置authorName
                                if([petName isEqual:[NSNull null]]){
                                    hotTop.petName = @"无昵称";
                                }else{
                                    NSLog(@"authorName = %@",petName);
                                    hotTop.petName = petName;
                                }
                                //
                                //设置照片url
                                if ([photo isEqual:[NSNull null]]) {
                                    hotTop.userPhotoUrl = @"11111";
                                }else{
                                    NSString * relativePath = [photo objectForKey:@"relativePath"];
                                    NSLog(@"relativePath data = %@",relativePath);
                                    hotTop.userPhotoUrl = [NSString stringWithFormat:@"%@%@",dUrl_PhotoPrefixion,relativePath];
                                    NSLog(@"~~~~~~~~~~~~userPhotoUrl = %@",hotTop.userPhotoUrl);
                                }
                                //
                                
                                
                            }
                            
                            
                            NSString * replies = [NSString stringWithFormat:@"%@",[d objectForKey:@"replies"]];
                            NSString * friendPartInCount = [NSString stringWithFormat:@"%@",[d objectForKey:@"viewFriendPartInCount"]];
                            NSString * title = [d objectForKey:@"title"];
                            NSString * _id = [d objectForKey:@"id"];
                            NSDate * createTime = [TimeTool timeStrTransverterDate:[d objectForKey:@"createTime"]];
                            
                            if ([@"<null>" isEqualToString:friendPartInCount]||[@"(null)" isEqualToString:friendPartInCount]) {
                                friendPartInCount = @"0";
                            }
                            
                            hotTop._id = _id;
                            hotTop.reply = replies;
                            hotTop.person =friendPartInCount;
                            hotTop.content = content;
                            hotTop.name = title;
                            hotTop.createTime = createTime;
                            hotTop.anonymousFlag = anonymousFlag;
                            [weakSelf.dateSource addObject:hotTop];
                        }
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"无数据"];
                    }
//                }
                
                
                //按照
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:YES];
                [weakSelf.dateSource sortUsingDescriptors:[NSArray arrayWithObject:sort]];
                [weakSelf.tableView reloadData];
                [weakSelf stopRefresh];
            }
           
        }
        
    } failed:^(NSObject *obj, BOOL isFinished) {
        [SVProgressHUD showSuccessWithStatus:@"我参与的话题_数据交互错误"];
        [weakSelf stopRefresh];
    }];
}



//设置身边热帖参数
-(void)setRoundHotDictionaryValue:(NSString *)newStartIndex
{
    [parameter  removeAllObjects];
    
    [parameter setValue:D_ID forKey:@"D_ID"];
    [parameter setValue:disNo forKey:@"topicQuery.disNo"];
    [parameter setValue:newStartIndex forKey:@"topicQuery.startIndex"];
}
//设置熟人话题参数
-(void)setFriendSTalkDictionaryValue:(int)newPageIndex
{
    [parameter  removeAllObjects];
    [parameter setValue:D_ID forKey:@"D_ID"];
    [parameter setValue:[NSString stringWithFormat:@"%d",newPageIndex] forKey:@"topicQuery.pageNum"];
}

//设置同年龄段话题参数
-(void)setAgeSearchDictionaryValue:(NSString *)newStartIndex
{
    [parameter  removeAllObjects];
    [parameter setValue:D_ID forKey:@"D_ID"];
    [parameter setValue:disNo forKey:@"topicQuery.disNo"];
    [parameter setValue:newStartIndex forKey:@"topicQuery.startIndex"];
    
//    app = [AppDelegate shareInstace];
//    NSString * latitude = [app.loginDict objectForKey:@"latitude"];
//    NSString * longitude = [app.loginDict objectForKey:@"longitude"];
//    latitude = [NSString stringWithFormat:@"%@",latitude];
//    longitude = [NSString stringWithFormat:@"%@",longitude];
//    [parameter setValue:longitude forKey:@"topicQuery.longitude"];
//    [parameter setValue:latitude forKey:@"topicQuery.latitude"];
    
}



//设置十大热门 和 最近三天热词 参数
-(void)setTenTopDictionaryValue
{
    [parameter  removeAllObjects];
    [parameter setValue:D_ID forKey:@"D_ID"];
}

//设置同年龄段话题参数
-(void)setAgeTalkDictionaryValue
{
    [parameter  removeAllObjects];
    [parameter setValue:D_ID forKey:@"D_ID"];
    [parameter setValue:pageNum forKey:@"topicQuery.pageNum"];
    [parameter setValue:self.ageGroupID forKey:@"topicQuery.ageGroupID"];
}
//话题全局搜索
-(void)setParamForSearch:(NSString *)searchWork{
    [parameter  removeAllObjects];
    [parameter setValue:D_ID forKey:@"D_ID"];
    [parameter setValue:searchWork forKey:@"topicQuery.searchWord"];
    [parameter setValue:pageNum forKey:@"topicQuery.pageNum"];
}


//我参与的//我发起的
-(void)setRequestParticipationParam:(int)newPageIndex{
    [parameter removeAllObjects];
    [parameter setValue:D_ID  forKey:@"D_ID"];
    [parameter setValue:[NSString stringWithFormat:@"%d",newPageIndex] forKey:@"topicQuery.pageNum"];
}




//上拉刷新
-(void)headerRereshing{

    self.operation = YES;
    disNo = @"3";
    pageIndex = 1;
    startIndex = [NSString stringWithFormat:@"%d",1];
    
    [self setRequesParameterAndRequesData:pageIndex];
}
//下拉加载
-(void)footerRereshing{
    self.operation = NO;
    if (self.isBottom == 1) {
        [self.tableView footerEndRefreshing];
        [SVProgressHUD showErrorWithStatus:@"没有更多数据"];
        return;
    }
    pageIndex++;
    
    [self setRequesParameterAndRequesData:pageIndex];
}

//十大数据请求
-(void) responeTenTopData:(NSArray *) array{
    if (![array isKindOfClass:[NSNull class]] && array.count != 0) {
        for (int i = 0; i < array.count; i++) {
            HotTopicEntity * hotTop = [[HotTopicEntity alloc] init];
            NSDictionary * d = [array  objectAtIndex:i];
            NSString * _id = [d objectForKey:@"id"];
            NSString * content = [d objectForKey:@"content"];
            //解析话题author name
            NSDictionary * author = [d objectForKey:@"author"];
            NSLog(@"-------author = %@",author);
            NSString * petName;
            NSDictionary * photo;
            NSNumber * anonymousFlag = [d objectForKey:@"anonymousFlag"];
            NSString * anonymousCode = [d objectForKey:@"anonymousCode"];
            //1是匿名发布 2不是匿名
            if (![anonymousFlag isKindOfClass:[NSNull class]] && anonymousFlag.intValue == 1) {
                hotTop.petName = anonymousCode;
                hotTop.userPhotoUrl = @"22222";
            }else{
                if (![author isKindOfClass:[NSNull class]]) {
                    petName = [author objectForKey:@"petName"];
                    //解析头像
                    photo = [author objectForKey:@"photo"];
                    //
                    
                }
                //设置authorName
                if([petName isEqual:[NSNull null]]){
                    hotTop.petName = @"无昵称";
                }else{
                    NSLog(@"authorName = %@",petName);
                    hotTop.petName = petName;
                }
                //
                //设置照片url
                if ([photo isEqual:[NSNull null]]) {
                    hotTop.userPhotoUrl = @"11111";
                }else{
                    NSString * relativePath = [photo objectForKey:@"relativePath"];
                    NSLog(@"relativePath data = %@",relativePath);
                    hotTop.userPhotoUrl = [NSString stringWithFormat:@"%@%@",dUrl_PhotoPrefixion,relativePath];
                    NSLog(@"~~~~~~~~~~~~userPhotoUrl = %@",hotTop.userPhotoUrl);
                }
                //

            
            }
            
            
            
            
            
            
            
            
            NSString * replies = [NSString stringWithFormat:@"%@",[d objectForKey:@"replies"]];
            NSString * friendPartInCount = [NSString stringWithFormat:@"%@",[d objectForKey:@"viewFriendPartInCount"]];
            NSString * title = [d objectForKey:@"title"];
            
            
            if ([@"<null>" isEqualToString:friendPartInCount]||[@"(null)" isEqualToString:friendPartInCount]) {
                friendPartInCount = @"0";
            }
           
            //
            hotTop._id = _id;
            hotTop.reply = replies;
            hotTop.person =friendPartInCount;
            hotTop.content = content;
            hotTop.name = title;
            hotTop.anonymousFlag = anonymousFlag.integerValue;
            [self.dateSource addObject:hotTop];
        }

    }else{


        [SVProgressHUD showSuccessWithStatus:@"无数据"];
    }
        [self stopRefresh];
}

//请求数据
-(void) responeData:(NSDictionary *) dic{
    disNo = [NSString stringWithFormat:@"%@",[dic  objectForKey:@"disNo"]];
    startIndex = [NSString stringWithFormat:@"%@",[dic  objectForKey:@"startIndex"]];
    NSNumber * isbuttom = [dic objectForKey:@"isButtom"];
    if ([isbuttom isKindOfClass:[NSNull class]]) {
        self.isBottom = 1;
    }

    if (self.isBottom == 1 ) {
        NSLog(@"------最后一页");
    }
//    }else{
        NSMutableArray * array;
        array = [dic objectForKey:@"list"];
    NSLog(@"------------ array%@",array);
    if (![array isKindOfClass:[NSNull class]] && array.count != 0) {
        
        for (int i = 0; i < array.count; i++) {
            HotTopicEntity * hotTop = [[HotTopicEntity alloc] init];
            NSDictionary * d = [array  objectAtIndex:i];
            
            NSString * content = [d objectForKey:@"content"];
            //解析photo和petname
            NSDictionary * author = [d objectForKey:@"author"];
            NSLog(@"-------author = %@",author);
            NSString * petName;
            NSDictionary * photo;
            NSNumber * anonymousFlag = [d objectForKey:@"anonymousFlag"];
            NSString * anonymousCode = [d objectForKey:@"anonymousCode"];
            //1是匿名发布 2不是匿名
            if (![anonymousFlag isKindOfClass:[NSNull class]] && anonymousFlag.intValue == 1) {
                hotTop.petName = anonymousCode;
                hotTop.userPhotoUrl = @"22222";
            }else{
                if (![author isKindOfClass:[NSNull class]]) {
                    petName = [author objectForKey:@"petName"];
                    //解析头像
                    photo = [author objectForKey:@"photo"];
                    //
                    
                }
                //设置authorName
                if([petName isEqual:[NSNull null]]){
                    hotTop.petName = @"无昵称";
                }else{
                    NSLog(@"authorName = %@",petName);
                    hotTop.petName = petName;
                }
                //
                //设置照片url
                if ([photo isEqual:[NSNull null]]) {
                    hotTop.userPhotoUrl = @"11111";
                }else{
                    NSString * relativePath = [photo objectForKey:@"relativePath"];
                    NSLog(@"relativePath data = %@",relativePath);
                    hotTop.userPhotoUrl = [NSString stringWithFormat:@"%@%@",dUrl_PhotoPrefixion,relativePath];
                    NSLog(@"~~~~~~~~~~~~userPhotoUrl = %@",hotTop.userPhotoUrl);
                }
                //
                
            }
            
//            if (![author isKindOfClass:[NSNull class]]) {
//                petName = [author objectForKey:@"petName"];
//                //解析头像
//                photo = [author objectForKey:@"photo"];
//                //
//
//            }
            NSString * replies = [NSString stringWithFormat:@"%@",[d objectForKey:@"replies"]];
            NSString * friendPartInCount = [NSString stringWithFormat:@"%@",[d objectForKey:@"viewFriendPartInCount"]];
            NSString * title = [d objectForKey:@"title"];
            NSString * _id = [d objectForKey:@"id"];
            
            if ([@"<null>" isEqualToString:friendPartInCount]||[@"(null)" isEqualToString:friendPartInCount]) {
                friendPartInCount = @"0";
            }
//            //设置authorName
//            if([petName isEqual:[NSNull null]]){
//                hotTop.petName = @"无昵称";
//            }else{
//                NSLog(@"authorName = %@",petName);
//                hotTop.petName = petName;
//            }
//            //
//            //设置照片url
//            if ([photo isEqual:[NSNull null]]) {
//                hotTop.userPhotoUrl = @"11111";
//            }else{
//                NSString * relativePath = [photo objectForKey:@"relativePath"];
//                NSLog(@"relativePath data = %@",relativePath);
//                hotTop.userPhotoUrl = [NSString stringWithFormat:@"%@%@",dUrl_PhotoPrefixion,relativePath];
//                NSLog(@"~~~~~~~~~~~~userPhotoUrl = %@",hotTop.userPhotoUrl);
//            }
//            //
            
            hotTop._id = _id;
            hotTop.reply = replies;
            hotTop.person =friendPartInCount;
            hotTop.content = content;
            hotTop.name = title;
            hotTop.anonymousFlag = anonymousFlag.integerValue;
            [self.dateSource addObject:hotTop];
        }

    }else{
        [SVProgressHUD showSuccessWithStatus:@"无数据"];
    }
//    }
    [self stopRefresh];
}
//我的话题
-(void)responeMyTopicListData:(NSDictionary *)dic{
    NSNumber * isbuttom = [dic objectForKey:@"isButtom"];
    if ([isbuttom isKindOfClass:[NSNull class]]) {
        self.isBottom = 1;
    }

    if (self.isBottom == 1) {
        NSLog(@"-----最后一页");
    }
//    else{
        if (![dic isKindOfClass:[NSNull class]]) {
            NSArray * array = [dic objectForKey:@"list"];
            if (![array isKindOfClass:[NSNull class]] && array.count != 0) {
                for (int i = 0; i < array.count; i++) {
                    HotTopicEntity * hotTop = [[HotTopicEntity alloc] init];
                    NSDictionary * d = [array  objectAtIndex:i];
                    NSString * content = [d objectForKey:@"content"];
                    //解析photo和petname
                    NSDictionary * author = [d objectForKey:@"author"];
                    NSLog(@"-------author = %@",author);
                    NSString * petName;
                    NSDictionary * photo;
                    NSNumber * anonymousFlag = [d objectForKey:@"anonymousFlag"];
                    NSString * anonymousCode = [d objectForKey:@"anonymousCode"];
                    //1是匿名发布 2不是匿名
                    if (![anonymousFlag isKindOfClass:[NSNull class]] && anonymousFlag.intValue == 1 ) {
                        hotTop.petName = anonymousCode;
                        hotTop.userPhotoUrl = @"22222";
                    }else{
                        if (![author isKindOfClass:[NSNull class]]) {
                            petName = [author objectForKey:@"petName"];
                            //解析头像
                            photo = [author objectForKey:@"photo"];
                            //
                            
                        }
                        //设置authorName
                        if([petName isEqual:[NSNull null]]){
                            hotTop.petName = @"无昵称";
                        }else{
                            NSLog(@"authorName = %@",petName);
                            hotTop.petName = petName;
                        }
                        //
                        //设置照片url
                        if ([photo isEqual:[NSNull null]]) {
                            hotTop.userPhotoUrl = @"11111";
                        }else{
                            NSString * relativePath = [photo objectForKey:@"relativePath"];
                            NSLog(@"relativePath data = %@",relativePath);
                            hotTop.userPhotoUrl = [NSString stringWithFormat:@"%@%@",dUrl_PhotoPrefixion,relativePath];
                            NSLog(@"~~~~~~~~~~~~userPhotoUrl = %@",hotTop.userPhotoUrl);
                        }
                        //
                        
                        
                    }
                    
                    
                    
                    NSString * replies = [NSString stringWithFormat:@"%@",[d objectForKey:@"replies"]];
                    NSString * friendPartInCount = [NSString stringWithFormat:@"%@",[d objectForKey:@"viewFriendPartInCount"]];
                    NSString * title = [d objectForKey:@"title"];
                    NSString * _id = [d objectForKey:@"id"];
                    NSDate * createTime = [TimeTool timeStrTransverterDate:[d objectForKey:@"createTime"]];
                    
                    if ([@"<null>" isEqualToString:friendPartInCount]||[@"(null)" isEqualToString:friendPartInCount]) {
                        friendPartInCount = @"0";
                    }
                                        
                    hotTop._id = _id;
                    hotTop.reply = replies;
                    hotTop.person =friendPartInCount;
                    hotTop.content = content;
                    hotTop.name = title;
                    hotTop.createTime = createTime;

                    [self.dateSource addObject:hotTop];
                }
                
            }else{
                [SVProgressHUD showSuccessWithStatus:@"无数据"];
            }
        }
//    }
    
    
    [self requesMyTopicListData];
}



#pragma mark 开始进入刷新状态
- (void)stopRefresh
{
    [self.tableView reloadData];
    [self.tableView headerEndRefreshing];
    [self.tableView footerEndRefreshing];
}

-(void)createNavigation{
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.navLeftType == LeftDrawer) {
        //        [leftBtn setBackgroundImage:dPic_Public_topmenu forState:UIControlStateNormal];
        [leftBtn setImage:[UIImage imageNamed:@"top_icon_huati_normal"] forState:UIControlStateNormal];
        [leftBtn setImage:[UIImage imageNamed:@"top_icon_huati_selected"] forState:UIControlStateHighlighted];
    }else{
        [leftBtn setBackgroundImage:dPic_Public_back forState:UIControlStateNormal];
    }
    //    leftBtn.backgroundColor = [UIColor greenColor];
    leftBtn.frame = CGRectMake(0, 0, 25, 25);
    [leftBtn addTarget:self action:@selector(leftDrawerButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setBackgroundImage:dPic_Public_toprelease forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 0, 25, 25);
    rightBtn.tag = dTag_rightBtn;
    [rightBtn addTarget:self action:@selector(navItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
}
//搜素栏
//-(void)createSearchField{
//    UIView * v = [[UIView alloc]  initWithFrame:CGRectMake(0,0 ,self.view.frame.size.width, 44)];
//    self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(5, 2, self.view.frame.size.width - 60 , 40)];
//    self.searchField.delegate = self;
//    UIImageView * magnify = [[UIImageView alloc]  initWithFrame:CGRectMake(10, 10, 20, 20)];
//    UIImage * image = [UIImage imageNamed:@"public_ magnify.png"];
//    magnify.image = image;
//    self.searchField.placeholder = @"版内搜索";
//    self.searchField.borderStyle = UITextBorderStyleRoundedRect;//设置textField的边框
//    self.searchField.clearButtonMode = UITextFieldViewModeAlways;//吧textfield加叉叉
//    self.searchField.keyboardType = UITextAutocorrectionTypeDefault;//键盘类型
//    self.searchField.returnKeyType =UIReturnKeyDone;//return文字
//    self.searchField.adjustsFontSizeToFitWidth = YES;
//    self.searchField.clearsOnBeginEditing = YES;
//    self.searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    self.searchField.leftView = magnify;
//    self.searchField.leftViewMode = UITextFieldViewModeAlways;
//    
//    UIButton * searchBtn = [[UIButton alloc]  initWithFrame:CGRectMake(self.searchField.frame.origin.x + self.searchField.frame.size.width + 2, 2, 50, 40)];
//    [searchBtn  setTitle:@"搜索" forState:UIControlStateNormal];
//    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    searchBtn.backgroundColor = [UIColor grayColor];
//    [searchBtn whenTapped:^{
//        [self textFieldShouldReturn:self.searchField];
//    }];
//    [self.searchField addTarget:self action:@selector(changeContent:) forControlEvents:UIControlEventEditingChanged];
//    [v addSubview:searchBtn];
//    [v  addSubview:self.searchField];
//    [self.view addSubview:v];
//}

//三天热词scroll
//-(void)createSearchHotWord{
//    NSArray * imageArr = @[dPic_redpoint, dPic_greenpoint, dPic_bluepoint, dPic_orangepoint];
//    NSMutableArray * array = [[NSMutableArray alloc]  init];
//    for (int i = 0; i<self.hotWordArray.count; i++) {
//        Item_HotWord * item = [self.hotWordArray objectAtIndex:i];
//        [array addObject:item.content];
//    }
//    for (int i = 0; i < array.count; i ++) {
//        Item_HotWord *item = self.hotWordArray[i];
//        [self addHotWordBtn:item.content index:i];
//    }
    //    int wordCount = [StringTool returnWordCountWithHotWordArray:array];
    //    NSMutableArray * imageArray = [[NSMutableArray alloc]init];
    //
    //    for (int i = 0; i < wordCount-1; i++) {
    //        [imageArray addObject:imageArr[i % 4]];
    //    }
    //    int allWide = 0;
    //    for (int i = 0; i<wordCount-1; i++) {
    //        Item_HotWord * item = [self.hotWordArray objectAtIndex:i];
    //        UIView * v = [[UIView alloc]  initWithFrame:CGRectZero];
    //
    //        UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(2, 5, 13, 13)];
    //        iv.image = [imageArray  objectAtIndex:i];
    //        UILabel * label1 = [[UILabel alloc]  initWithFrame:CGRectZero];
    //        [label1 setNumberOfLines:1];
    ////        [label1 sizeToFit];
    //
    //        label1.text = item.content;
    ////        label1.adjustsFontSizeToFitWidth = YES;
    //        label1.textAlignment = NSTextAlignmentCenter;
    //        label1.textColor = [UIColor blackColor];
    //        label1.font = [UIFont boldSystemFontOfSize:13];
    //        int wide = [StringTool returnTextWidthWithContent:item.content];
    //        label1.frame = CGRectMake(17, 5, wide, 20);
    //        v.frame = CGRectMake(allWide, 5, wide+19 , 30);
    //        allWide += wide+19;
    //        [v addSubview:iv];
    //        [v addSubview:label1];
    //
    //        v.tag = 100+i;
    //
    //        [v  whenTapped:^{
    //            if (!self.tableView.footerRefreshing){//头部是否正在刷新
    //                searchContent = item.content;
    //                [self.dateSource  removeAllObjects];
    //                self.talkMark = SearchWord;
    //                [self.tableView headerBeginRefreshing];
    //            }
    //        }];
    //        [self.searchView addSubview:v];
    //    }
    //
    //    [self.view  addSubview:self.searchView];
//}

//-(void)addHotWordBtn:(NSString *)title index:(int)index{
//    NSArray * imageArr = @[dPic_redpoint, dPic_greenpoint, dPic_bluepoint, dPic_orangepoint];
//    UIImage *image = imageArr[index%4];
//    CGSize  size = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 18) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil].size;
//    CGFloat x = _lastBtn ? (CGRectGetMaxX(_lastBtn.frame) +13) : 10;
//    CGFloat width = size.width + image.size.width + 12;
//    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(self.searchField.frame) + 8, width, 18)];
//    btn.titleLabel.font = [UIFont systemFontOfSize:16];
//    [btn setTitle:title forState:UIControlStateNormal];
//    [btn setImage:image forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
//    [btn addTarget:self action:@selector(hotWordBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    if (CGRectGetMaxX(btn.frame) > self.view.frame.size.width) {
//        btn.hidden = YES;
//    }
//    [self.view addSubview:btn];
//    _lastBtn = btn;
//}

//-(void)hotWordBtnClick:(UIButton *)sender{
//    if (!self.tableView.footerRefreshing){//头部是否正在刷新
//        searchContent = [sender titleForState:UIControlStateNormal];
//        [self.dateSource  removeAllObjects];
//        self.talkMark = SearchWord;
//        [self.tableView headerBeginRefreshing];
//    }
//}

//初始化控件
-(void)createComponent{
//    [self createSearchField];
//    self.searchView = [[UIView alloc]  initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 30)];
    //    self.searchView.backgroundColor = [UIColor blueColor];
//    [self requestHotWord];

    
    
    self.tableView = [[UITableView alloc]  initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kMainScreenHeight-app.mTbc.mainView.frame.size.height + 5)];
    self.tableView.backgroundColor = kRGB(237, 237, 237);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.scrollEnabled = YES;
    [self setupRefresh:self.tableView];
    [self.view  addSubview:self.tableView];
    //[self.tableView headerBeginRefreshing];
    
}
/**设置请求参数**/
//- (void)setupRefresh:(UITableView *)newTableView
//{
//    [super setupRefresh:newTableView];
//    if (self.talkMark != TenTop) {
//        [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
//    }
//    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
//    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
//    //#warning 自动刷新(一进入程序就下拉刷新)
//    [self.tableView headerBeginRefreshing];
//    
//    if(self.talkMark != TenTop) {
//    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
//        [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
//    
//    }
//    
//    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
//    self.tableView.headerPullToRefreshText = @"下拉刷新数据";
//    self.tableView.headerReleaseToRefreshText = @"松开刷新数据";
//    self.tableView.headerRefreshingText = @"正在刷新数据，请稍等";
//    
//    self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
//    self.tableView.footerReleaseToRefreshText = @"松开马上加载更多数据了";
//    self.tableView.footerRefreshingText = @"正在加载数据，请稍等";
//}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HotTopicEntity * item = [self.dateSource objectAtIndex:indexPath.row];
    CGFloat height = [item getTopicContentViewHeight]+40;


    if (self.talkMark == TenTop) {
        if (height > 117) {
            return  height +40;
        }else{
            return 117;
        }
        
    }else{
        if (height > 102) {
            return height+40;
        }else{
            return 102;
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dateSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.talkMark == TenTop) {
        static NSString *identifierTopTen=@"topTenCell";
        HotTopicTopTenCell *cell=[tableView dequeueReusableCellWithIdentifier:identifierTopTen];
        if (!cell) {
            cell=[[HotTopicTopTenCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifierTopTen];
        }
        UIColor *color = (indexPath.row == 0) ? [UIColor redColor] : [UIColor yellowColor];
        HotTopicEntity * hotTopic = [_dateSource objectAtIndex:indexPath.row];
        cell.v.hidden = YES;
        cell.topLable.text = [NSString stringWithFormat:@"TOP: %d",indexPath.row+1];
        cell.topLable.textColor = color;
        cell.replyLable.text = hotTopic.reply;
        cell.personLable.text = hotTopic.person;
        
        //动态算高
        CGRect frame = cell.contentLable.frame;
        frame.size.height = [hotTopic getTopicContentViewHeight]+5;
        cell.contentLable.frame = frame;
//        cell.contentLable.backgroundColor = [UIColor lightGrayColor];
        
        CGFloat height = CGRectGetMaxY(cell.contentLable.frame) + 5 ;
        //
        CGRect commentFrame = cell.comment.frame;
        commentFrame.origin.y = height;
        cell.comment.frame = commentFrame;
        
        CGRect replyFrame = cell.replyLable.frame;
        replyFrame.origin.y = height;
        cell.replyLable.frame = replyFrame;
        
        CGRect acquaintanceFrame = cell.acquaintance.frame;
        acquaintanceFrame.origin.y = height;
        cell.acquaintance.frame = acquaintanceFrame;
        
        CGRect personFrame = cell.personLable.frame;
        personFrame.origin.y = height;
        cell.personLable.frame = personFrame;
        
        //
        CGRect bgFrame = cell.bg.frame;
        bgFrame.size.height = cell.contentView.frame.size.height;
        cell.bg.frame = bgFrame;
        
        
        cell.contentLable.text = hotTopic.content;
        cell.nameLable.text = hotTopic.petName;
        [cell.nameLable whenTapped:^{
            if (hotTopic.anonymousFlag == 1) {
                //
            }else{
                NSLog(@"--------点击昵称");
            }

        }];
        
//        NSString * url = @"http://115.100.250.35:8080/wpa/wb/wpub/imgAction_img.action?A_ID=11/8/8/3/29699304-da21-4038-9931-e419af712fa3_jpg";
//        NSString * imageName = [NSString stringWithFormat:@"%@%@%@",[FileManger documentPath] ,@"/tableImage",@"/tupian.jpg"];
//        //判断文件在document下是否存在
//        if ([FileManger opinionFileIsEmpty:imageName]) {
//            UIImage *img = [UIImage imageWithContentsOfFile:imageName];
//            cell.headImageView.image = img;
//        }else{
//            [DownloadImageManger downloadImageUrl:url setImageView:cell.headImageView];
//        }
        //设置头像
        if ([hotTopic.userPhotoUrl isEqualToString:@"11111"]) {
            [cell.headImageView setImage:[UIImage imageNamed:@"tab_selected.jpg"]];
        }else if([hotTopic.userPhotoUrl isEqualToString:@"22222"]){
            [cell.headImageView setImage:[UIImage imageNamed:@"匿名"]];
        }else{
            [cell.headImageView setImageWithURL:[NSURL URLWithString:hotTopic.userPhotoUrl]];
        }
        cell.headImageView.layer.cornerRadius = AllCornerRadius;
        cell.headImageView.layer.masksToBounds = YES;
        //
        [cell.headImageView whenTapped:^{
            if (hotTopic.anonymousFlag == 1) {
                //
            }else{
                NSLog(@"--------点击头像");
            }

        }];
        
        return cell;
        
    }else{
        static NSString *identifier=@"cell";
        HotTopicTVCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell=[[HotTopicTVCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        
        HotTopicEntity * hotTopic = [_dateSource objectAtIndex:indexPath.row];
        //        cell.v.hidden = YES;
        //        if (self.talkMark == TenTop) {
        //            cell.topLable.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
        //            cell.v.hidden = NO;
        //        }else{
        //            cell.v.hidden = YES;
        //        }
        
        
        cell.replyLable.text = hotTopic.reply;
        cell.personLable.text = hotTopic.person;
        if((NSNull *)hotTopic.content == [NSNull null]){
            hotTopic.content = @"无话题内容";
        }
        //动态算高
        CGRect frame = cell.contentLable.frame;
        frame.size.height = [hotTopic getTopicContentViewHeight]+5;
        cell.contentLable.frame = frame;
//        cell.contentLable.backgroundColor = [UIColor lightGrayColor];
        
        CGFloat height = CGRectGetMaxY(cell.contentLable.frame) + 5 ;
        //
        CGRect commentFrame = cell.comment.frame;
        commentFrame.origin.y = height;
        cell.comment.frame = commentFrame;
        
        CGRect replyFrame = cell.replyLable.frame;
        replyFrame.origin.y = height;
        cell.replyLable.frame = replyFrame;
        
        CGRect acquaintanceFrame = cell.acquaintance.frame;
        acquaintanceFrame.origin.y = height;
        cell.acquaintance.frame = acquaintanceFrame;
        
        CGRect personFrame = cell.personLable.frame;
        personFrame.origin.y = height;
        cell.personLable.frame = personFrame;
        
        //
        CGRect bgFrame = cell.bg.frame;
        bgFrame.size.height = cell.contentView.frame.size.height;
        cell.bg.frame = bgFrame;
        
        
        cell.contentLable.text = hotTopic.content;
        if((NSNull *)hotTopic.name == [NSNull null]){
            hotTopic.name = @"无话题题目";
        }
        
        
        
        cell.nameLable.text = hotTopic.petName;
        
        [cell.nameLable whenTapped:^{
            if (hotTopic.anonymousFlag == 1) {
                //
            }else{
             NSLog(@"--------点击昵称");
            }
        }];
        
//        NSString * url = @"http://115.100.250.35:8080/wpa/wb/wpub/imgAction_img.action?A_ID=11/8/8/3/29699304-da21-4038-9931-e419af712fa3_jpg";
//        NSString * imageName = [NSString stringWithFormat:@"%@%@%@",[FileManger documentPath] ,@"/tableImage",@"/tupian.jpg"];
//        //        //判断文件在document下是否存在
//        if ([FileManger opinionFileIsEmpty:imageName]) {
//            UIImage *img = [UIImage imageWithContentsOfFile:imageName];
//            cell.headImageView.image = img;
//        }else{
//            [DownloadImageManger downloadImageUrl:url setImageView:cell.headImageView];
//        }
        //设置头像
        if ([hotTopic.userPhotoUrl isEqualToString:@"11111"]) {
            [cell.headImageView setImage:[UIImage imageNamed:@"tab_selected.jpg"]];
        }else if([hotTopic.userPhotoUrl isEqualToString:@"22222"]){
            [cell.headImageView setImage:[UIImage imageNamed:@"匿名"]];
        }else{
            [cell.headImageView setImageWithURL:[NSURL URLWithString:hotTopic.userPhotoUrl]];
        }
        
        cell.headImageView.layer.cornerRadius = AllCornerRadius;
        cell.headImageView.layer.masksToBounds = YES;
        //
        [cell.headImageView whenTapped:^{
            if (hotTopic.anonymousFlag == 1) {
                //
            }else{
                NSLog(@"--------点击头像");
            }
        }];
        NSLog(@"------ %@",hotTopic.content);
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HotTopicDetailVC * talk = [[HotTopicDetailVC alloc] init];
    HotTopicEntity * item = [self.dateSource objectAtIndex:indexPath.row];
    talk._id = item._id;
    [self.navigationController pushViewController:talk animated:YES];
    //    [self.mm_drawerController setCenterViewController:navigation withCloseAnimation:YES completion:nil];
}

#pragma mark textField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (![CheckDataTool checkInfo:self.searchField msgContent:@"请填写搜索关键字"]) {
        return YES;
    }
    if (!self.tableView.footerRefreshing){//头部是否正在刷新
        searchContent = self.searchField.text;
        [self.dateSource  removeAllObjects];
        self.talkMark = SearchWord;
        [self.tableView headerBeginRefreshing];
    }
    return YES;
}

-(void)changeContent:(UITextField*)textField
{
    if (textField.text.length == 0){
        
    }
}



//返回或抽屉
-(void)leftDrawerButtonPress:(id)sender{
    if (self.navLeftType == LeftBack) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
}


-(void)navItemClick:(UIButton *)button
{

    PushAcitivityController * publicVC = [[PushAcitivityController alloc]init];
    publicVC.type = 1;
    [self.navigationController pushViewController:publicVC animated:YES];
    
}



@end