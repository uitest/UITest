
//
//  HotTopicDetailVC.m
//  if_wapeng
//
//  Created by 早上好 on 14-9-11.
//  Copyright (c) 2014年 funeral. All rights reserved.
//话题详情
#define AttachmentImageSize 55
#import "HotTopicDetailVC.h"
#import "Item_HotTopDetailRow.h"
#import "Item_HotTopicDetail.h"
#import "Cell_HotTopDetailRowTableViewCell.h"
#import "Cell_HotTopicDetail.h"
#import "UIViewController+General.h"
#import "HMSegmentedControl.h"
#import "UIView+WhenTappedBlocks.h"
//#import "MJPhotoBrowser.h"
//#import "MJPhoto.h"
#import "MBProgressHUD.h"
//#import "MBProgressHUD+Add.h"
#import "TimeTool.h"

#import "UIViewController+General.h"
#import "DialogView.h"
#import "SVProgressHUD.h"
#import "UIViewController+MMDrawerController.h"
#import "UIScrollView+MJExtension.h"
#import "MJRefresh.h"
#import "UIView+WhenTappedBlocks.h"
#import "AppDelegate.h"
#import "CheckDataTool.h"
#import "CreateTAopicVC.h"
#import "UIImageView+WebCache.h"
#import "SBJsonParser.h"
#import "WUDemoKeyboardBuilder.h"
#import "SDImageCache.h"
#import "MWCommon.h"




@interface HotTopicDetailVC () <JSMessagesViewDelegate>
@property(nonatomic , strong) NSMutableArray * dataSource1;
@property(nonatomic , strong) NSMutableArray * dataSource2;
@property(nonatomic , strong) UITableView * tableView;
@property(nonatomic , strong) UITextView * importText;
@property(nonatomic , strong)UIButton * optionBtn;
@property(nonatomic , strong)UIButton * sendMsg;
@property(nonatomic , strong)UIView * importView;
@property(nonatomic , strong)NSString *topicID;//某个话题回复的id
@property(nonatomic , assign)TopicDetailSendType topicSendType ;
@property(nonatomic , assign)TopicOperationTyoe operationType;
@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic, strong) NSMutableArray *assets;
@end

@implementation HotTopicDetailVC
{
    AFN_HttpBase * http;
    MBProgressHUD * loading;
    NSString * sendName;//回复某人的名字
    AppDelegate * app;
    NSString * D_ID;
    TopicReplyQueryType trqType;//按照三种方式搜索
    NSInteger _pageNum;///请求页码
    ///页面底部
    NSInteger _isBottom;
    ///点赞状态
    NSInteger _supportType;
    ///收藏状态
    NSInteger _storeType;
    ///举报状态
    NSInteger _reportType;

    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"话题详情";
        http = [[AFN_HttpBase alloc]  init];
        [[SDImageCache sharedImageCache] cleanDisk];
        [[SDImageCache sharedImageCache] clearMemory];
        
        
        
        [self loadAssets];
    }
    return self;
}


-(void)showLoading{
	loading = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:loading];
	loading.labelText = @"Loading";
    [loading show:YES];
}
-(void)disMissLoading{
    if (nil != loading) {
        [loading  removeFromSuperview];
    }
}


///话题楼主键值对
-(NSDictionary *)setRequestParam{
    NSMutableDictionary * param = [[NSMutableDictionary alloc]  init];
    [param setValue:self._id forKey:@"topicQuery.id"];
    [param setValue:D_ID forKey:@"D_ID"];
    return param;
}
///话题回复键值对
-(NSDictionary *)setRequestReplyParamByTopId:(NSString*)topid andCommentText:(NSString *)comment andIsAnonymity:(NSInteger)isAnonymity
{

    NSMutableDictionary * param = [[NSMutableDictionary alloc]  init];
    [param setValue:D_ID forKey:@"D_ID"];
    [param  setValue:topid forKey:@"topicReply.topic.id"];
    [param setValue:[NSString stringWithFormat:@"%d",isAnonymity] forKey:@"topicReply.anonymousFlag"];
//    NSString * content;
//    NSString * textContent =  self.importText.text;
//    if (name.length <= 0||nil == name) {
//        content = textContent;
//    }else{
//        content = [NSString stringWithFormat:@"%@%@",name , textContent];
//    }
    [param setValue:comment forKey:@"topicReply.content"];
    return param;
}


//话题回复检索键值对
-(NSDictionary *)setRequestTalkReplyParam{
    NSMutableDictionary * param = [[NSMutableDictionary alloc]  init];
    [param setValue:self._id forKey:@"topicReplyQuery.topicID"];
    [param setValue:D_ID forKey:@"D_ID"];
    [param setValue:[NSString stringWithFormat:@"%ld",(long)_pageNum] forKey:@"topicReplyQuery.pageNum"];
    switch (trqType) {
        case TopicHot://热度
            [param setValue:@"1" forKey:@"topicReplyQuery.sort"];
            break;
        case TopicTime://时间
            [param setValue:@"2" forKey:@"topicReplyQuery.sort"];
            break;
        case TopicRelation://关系
            [param setValue:@"3" forKey:@"topicReplyQuery.sort"];
            break;
        default:
            break;
    }
    NSLog(@"-------- param = %@",param);
    return param;
}
//话题 举报某个话题参数
-(NSDictionary *)setParamReportTopicID:(NSString *)topic_Id content:(NSString *)info{
    NSMutableDictionary * param = [[NSMutableDictionary alloc]  init];
    [param setValue:D_ID forKey:@"D_ID"];
    [param setValue:info forKey:@"topicReport.content"];
    [param setValue:topic_Id forKey:@"topicReport.topic.id"];
    return param;
}

//话题 举报某个话题回复参数
-(NSDictionary *)setParamReplyReportTopicID:(NSString *)topic_Id content:(NSString *)info{
    NSMutableDictionary * param = [[NSMutableDictionary alloc]  init];
    [param setValue:D_ID forKey:@"D_ID"];
    [param setValue:info forKey:@"topicReplyReport.content"];
    [param setValue:topic_Id forKey:@"topicReplyReport.topicReply.id"];
    return param;
}
//收藏某个话题或者话题回复的参数
-(NSDictionary *)setParamTopicStoreTopId:(NSString*)topic_Id topicReplyId:(NSString *)repleyId  topicStoreType:(NSString *)type actType:(NSString *)actType
{
    NSMutableDictionary * param = [[NSMutableDictionary alloc]  init];
    [param setValue:D_ID forKey:@"D_ID"];
    [param setValue:topic_Id forKey:@"topicStore.topic.id"];
    [param setValue:repleyId forKey:@"topicStore.topicReply.id"];
    [param setValue:type forKey:@"topicStore.type"];
    [param setValue:actType forKey:@"topicStore.actType"];
    
    return param;
}


//请求话题详细--包括楼主信息和下面的话题回复搜索
-(void) requestData:(NSDictionary *)param
{
    __weak HotTopicDetailVC * weakSelf = self;
    [http  fiveReuqestUrl:TOP_1_2_4 postDict:param succeed:^(NSObject *obj, BOOL isFinished) {
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
        
        //Data转换为JSON
        NSString* str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"-------- jsonStr = %@",str);

        
        Item_HotTopicDetail * item1= [[Item_HotTopicDetail alloc]  init];
        
        NSDictionary * value = [(NSDictionary*)obj objectForKey:@"value"];
        if (![value isKindOfClass:[NSNull class]]) {
            
            NSString * _id = [value  objectForKey:@"id"];
            item1._id = _id;
            NSNumber * viewReportFlag = [value objectForKey:@"viewReportFlag"];
            NSNumber * viewStoreFlag = [value objectForKey:@"viewStoreFlag"];
            NSNumber * viewSupportFlag = [value objectForKey:@"viewSupportFlag"];
            NSNumber * delFlag = [value objectForKey:@"delFlag"];
            
            
            NSNumber * anonymousFlag = [value objectForKey:@"anonymousFlag"];
            item1.anonymousFlag = anonymousFlag.integerValue;
            NSString * anonymousCode = [value objectForKey:@"anonymousCode"];
            NSString * placeName = [value objectForKey:@"placeName"];
            if (![placeName isKindOfClass:[NSNull class]] && ![@""isEqualToString:placeName]) {
                item1.placeName = placeName;
            }else{
                item1.placeName = @"无位置名称";
            }
            
             NSDictionary * author = [value objectForKey:@"author"];
            //1是匿名发布 2不是匿名
            if (![anonymousFlag isKindOfClass:[NSNull class]] && anonymousFlag.intValue == 1) {
                item1.petName = anonymousCode;
                item1.authorPhoto = @"22222";
            }else{
                if (![author isKindOfClass:[NSNull class]]) {
                    //家长昵称
                    NSString * petName = [author objectForKey:@"petName"];
                    if (![petName isKindOfClass:[NSNull class]]  && ![@"" isEqualToString:petName]) {
                        item1.petName = petName;
                    }else{
                        item1.petName = @"无昵称";
                    }
                    //家长头像地址
                    NSDictionary * photo = [author objectForKey:@"photo"];
                    NSLog(@"--------- photo = %@",photo);
                    if (![photo isKindOfClass:[NSNull class]]) {
                        NSString * relativePath = [photo objectForKey:@"relativePath"];
                        if (![relativePath isKindOfClass:[NSNull class]] && ![@"" isEqualToString:relativePath]) {
                            item1.authorPhoto = [NSString stringWithFormat:@"%@%@",dUrl_PhotoPrefixion,relativePath];
                        }else{
                            item1.authorPhoto = @"111111";
                        }
                        
                    }else{
                        item1.authorPhoto = @"111111";
                        
                    }

                }
            
            }

            
           
            if (![author isKindOfClass:[NSNull class]]) {
                NSString * createTime = [author objectForKey:@"createTime"];
                NSArray * childInfoList = [author objectForKey:@"childInfoList"];
                NSLog(@"------ childInfoList = %@",childInfoList);
                if (![childInfoList isKindOfClass:[NSNull class]] && childInfoList.count != 0) {
                    //selected为1,为当前需要显示的孩子
                    for (int i = 0 ; i<childInfoList.count; i++) {
                        NSDictionary * child1 = childInfoList[i];
                        NSNumber * selected = [child1 objectForKey:@"selected"];
                        if (selected.intValue == 1) {
                            NSString * birthday = [child1 objectForKey:@"birthday"];
                            NSLog(@"~~~~~~~~~~~birthday = %@",birthday);
                            //解析年龄
                            NSString * childAge = [TimeTool getBabyAgeWithBirthday:birthday publicTime:createTime];
                            NSLog(@"------- childAge = %@",childAge);
                            item1.childAge = childAge;
                            
                            //孩子性别
                            NSNumber * gender = [child1 objectForKey:@"gender"];
                            gender.integerValue == 1?(item1.childGender = @"王子"):(item1.childGender = @"公主");
                        }
                    }
                }else{
                    item1.childAge = 0;
                    item1.childGender = @"";
                }
            }
            
            //话题题目
            NSString * topicTitle = [value  objectForKey:@"title"];
            //无脏数据情况下不用判空
            if (![topicTitle isKindOfClass:[NSNull class]] && ![@"" isEqualToString:topicTitle]) {
                item1.TopicTitle = topicTitle;
            }else{
                item1.TopicTitle = @"无题目";
            }
            //话题内容
            NSString * topicContent = [value objectForKey:@"content"];
            if (![topicContent isKindOfClass:[NSNull class]] && ![@""isEqualToString:topicContent]) {
                item1.TopicContent = topicContent;
            }else{
                item1.TopicContent = @"无内容";
            }
            
            
            //附带图片
            NSArray * attachmentList = [value objectForKey:@"topicAttachmentList"];
            NSLog(@"~~~~~~~~~~ attachmentList = %@",attachmentList);
            if (![attachmentList isKindOfClass:[NSNull class]] && attachmentList.count != 0) {
                for (int i = 0 ; i<attachmentList.count; i++) {
                    NSDictionary * attachmentObj = attachmentList[i];
                    NSDictionary * attachment = [attachmentObj objectForKey:@"attachment"];
                    NSLog(@"~~~~~~~ attachment = %@",attachment);
                    if (![attachment isKindOfClass:[NSNull class]]) {
                        NSString * relativePath = [attachment objectForKey:@"relativePath"];
                        NSLog(@"--------- relativePath = %@",relativePath);
                        [item1.attachmentList addObject:[NSString stringWithFormat:@"%@%@",dUrl_PhotoPrefixion,relativePath]];
                    }
                    
                    
                }
            }else{
                item1.attachmentList = [attachmentList mutableCopy];
            }
            //话题是否关闭
            NSString * limitTime = [value objectForKey:@"limitTime"];
            BOOL a = [TimeTool limitTime:limitTime];
            if (!a == YES) {
                item1.isClosed = @"已关闭";
            }else{
                item1.isClosed = @"未关闭";
            }
//            NSString * viewSupportFlag = [value objectForKey:@"viewSupportFlag"];
            //回复数
            item1.commentCount = [[value objectForKey:@"replies"]intValue];
            //点赞数
            item1.likeCount = [[value objectForKey:@"supports"]intValue];

            item1.viewReportFlag = viewReportFlag.integerValue;
            _reportType = viewReportFlag.integerValue;
            item1.viewStoreFlag = viewStoreFlag.integerValue;
            if (item1.viewStoreFlag == 1) {//已收藏过
                _storeType = 2;
            }else{
                _storeType = 1;
            }
            item1.viewSupportFlag = viewSupportFlag.integerValue;
            item1.anonymousFlag = anonymousFlag.integerValue;
            
            [weakSelf.dataSource1  addObject:item1];
            [weakSelf.tableView reloadData];
 //           [weakSelf requestTalkReplyData:[weakSelf setRequestTalkReplyParam]];
        }
        
    } failed:^(NSObject *obj, BOOL isFinished) {
        [SVProgressHUD showSuccessWithStatus:@"楼主信息数据交互错误"];
        [weakSelf stopRefresh];
    }];
}
///TOP_1_4_2  话题回复列表搜索
-(void)requestTalkReplyData:(NSDictionary *)param{
    NSLog(@"-------  param %@",param);
    __weak HotTopicDetailVC * weakSelf = self;
    [http sixReuqestUrl:TOP_1_4_2 postDict:param succeed:^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
        
        //Data转换为JSON
        NSString* str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"-------- jsonStr = %@",str);

        
        NSDictionary * dic = [(NSDictionary*)obj objectForKey:@"value"];

        NSArray * array = [dic  objectForKey:@"list"];
        NSNumber * isBottom = [dic objectForKey:@"isButtom"];
        if ([isBottom isKindOfClass:[NSNull class]]) {
            _isBottom = 1;
        }
        _isBottom = isBottom.integerValue;
        if (![array isKindOfClass:[NSNull class]] && array.count != 0) {
            //
            for (int i = 0; i < array.count; i++) {
                Item_HotTopDetailRow * item2 = [[Item_HotTopDetailRow alloc]  init];
                NSDictionary * dic = [array  objectAtIndex:i];
                //评论内容
                NSString * content = [dic  objectForKey:@"content"];
//                NSLog(@"---内容  -- %@",content);
                //回复时间
                NSString * createTime = [dic objectForKey:@"createTime"];
                //当前用户是否给此回复点赞
                NSNumber * viewSupportFlag = [dic objectForKey:@"viewSupportFlag"];
                
                //当前用户是否给此回复收藏
                NSNumber * viewStoreFlag = [dic objectForKey:@"viewStoreFlag"];
                
                //当前用户是否给此回复举报
                NSNumber * viewReportFlag = [dic objectForKey:@"viewReportFlag"];
                
                //当前用户是否删除此回复
                NSNumber * delFlag = [dic objectForKey:@"delFlag"];
                NSDictionary * dicAuthor = [dic  objectForKey:@"author"];
                
                NSString * petName;
                NSString * authorPhoto;
                //匿名码
                NSString * anonymousCode = [dic objectForKey:@"anonymousCode"];
                //是否匿名回复
                NSNumber * anonymousFlag = [dic objectForKey:@"anonymousFlag"];
                if (anonymousFlag.integerValue == 2) {
                    //回复人昵称
                    petName = [dicAuthor objectForKey:@"petName"];
                    //回复人头像
                    NSDictionary * photo = [dicAuthor objectForKey:@"photo"];
                    
                    if (![photo isKindOfClass:[NSNull class]]) {
                        NSString * relativePath = [photo objectForKey:@"relativePath"];
                        authorPhoto = [NSString stringWithFormat:@"%@%@",dUrl_PhotoPrefixion,relativePath];
                    }else{
                        authorPhoto = @"11111";
                    }

                }else{
                    authorPhoto = @"22222";
                    petName = anonymousCode;
                    
                }
                
                
                NSString * _id = [dic objectForKey:@"id"];
                
                                //
                NSArray * childInfoList = [dicAuthor objectForKey:@"childInfoList"];
                NSNumber * gender;
                NSString * birthday;
                if (![childInfoList isKindOfClass:[NSNull class]] && childInfoList.count != 0) {
                    for (NSDictionary * child in childInfoList) {
                        NSNumber * selected = [child objectForKey:@"selected"];
                        //需要显示的孩子
                        if (selected.integerValue == 1) {
                            gender = [child objectForKey:@"gender"];
                            birthday = [child objectForKey:@"birthday"];
                        }
                    }

                }else{
                    gender = 0;
                    birthday= @"";
                }
                
                
                //点赞数
                NSNumber * supports = [dic objectForKey:@"supports"];
                
                
                item2._id = _id;
                item2.headerPath = authorPhoto;//头像
                item2.supports = supports.integerValue;//点赞数
                item2.content = content;//内容
                item2.petName = petName;//昵称
                //孩子性别和年龄
                if (gender != 0) {
                    gender.integerValue == 1?(item2.childGender = @"王子"): (item2.childGender = @"公主");
                }else{
                    item2.childGender = @"无";
                }
                if (![@"" isEqualToString:birthday]) {
                    NSString * age = [TimeTool getBabyAgeWithBirthday:birthday publicTime:createTime];
                    item2.childAge = age;
                }else{
                    item2.childAge = @"无";
                }
                
                
                item2.viewSupportFlag = viewSupportFlag.integerValue;
                item2.viewReportFlag = viewReportFlag.integerValue;
                item2.viewStoreFlag = viewStoreFlag.integerValue;
                if (item2.viewStoreFlag == 1) {//已收藏过
                    _storeType = 2;
                }else{
                    _storeType = 1;
                }
                item2.delFlag = delFlag.integerValue;
                item2.anonymousFlag = anonymousFlag.integerValue;
                
                [weakSelf.dataSource2  addObject:item2];
            }
            //

        }
                [weakSelf.tableView reloadData];
        [weakSelf stopRefresh];
        [weakSelf disMissLoading];
        
    } failed:^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
        [SVProgressHUD showSuccessWithStatus:@"话题回复搜索数据交互错误"];
        [weakSelf stopRefresh];
    }];
}

///话题回复请求
-(void)requestTopicReply:(NSString *) replyUrl setParam:(NSDictionary *)param
{
    __weak HotTopicDetailVC *weakSelf = self;
    [http sixReuqestUrl:replyUrl postDict:param succeed:^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
        NSString * value = [(NSDictionary *)obj objectForKey:@"value"];
        NSString * valueS = [NSString stringWithFormat:@"%@",value];
        if ([valueS  isEqualToString:@"1"]) {
            [SVProgressHUD showSuccessWithStatus:@"提交信息成功"];
            trqType = TopicHot;
            sendName = nil;
            weakSelf.importText.text = @"";
            [weakSelf.dataSource2  removeAllObjects];
            [NSThread sleepForTimeInterval:4]; //延时3秒钟
            [weakSelf requestTalkReplyData:[weakSelf setRequestTalkReplyParam]];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"提交信息失败"];
        }
    } failed:
     ^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
         weakSelf.importText.text = @"";
         [self disMissLoading];
     }];
}
///举报某个话题回复的请求
-(void)requestReportData:(NSDictionary *)param setUrl:(NSString *)reportUrl{
    [http  sixReuqestUrl:reportUrl postDict:param succeed:^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
        _reportType--;
        NSDictionary * dic = (NSDictionary *)obj;
        NSString *value = [NSString stringWithFormat:@"%@",[dic  objectForKey:@"value"]];
        if ([value isEqualToString:@"1"]) {
            [SVProgressHUD showSuccessWithStatus:@"举报成功"];
        }else{
            
        }
        [self disMissLoading];
    } failed:^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
        [SVProgressHUD showSuccessWithStatus:@"举报失败"];
        [self disMissLoading];
    }];
}
///收藏某个话题或者话题回复的请求
-(void) requestTopicStoreDataURl:(NSString *)url setParam:(NSDictionary *)param
{
    [http  sixReuqestUrl:url postDict:param succeed:^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
        
        if (_storeType == 1) {
            _storeType++;
        }else{
            _storeType--;
        }
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
        
        //Data转换为JSON
        NSString* str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"-------- jsonStr = %@",str);
        
        NSDictionary * dic = (NSDictionary *)obj;
        NSString * value = [NSString stringWithFormat:@"%@",[dic objectForKey:@"value"]];
        if ([value isEqualToString:@"1"]) {
           // NSLog(@"-----param = %@",param);
            if ([[param objectForKey:@"topicStore.actType"] isEqualToString:@"1"]) {
                [SVProgressHUD showSuccessWithStatus:@"收藏成功"];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"取消收藏成功"];
            }
            
        }else{
            [SVProgressHUD showSuccessWithStatus:@"收藏失败"];
        }
        [self disMissLoading];
    } failed:^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
        [SVProgressHUD showSuccessWithStatus:@"收藏失败"];
        [self disMissLoading];
    }];
    
}
-(void)requestTopicCommentWithURl:(NSString *)url setParam:(NSDictionary*)param{
    [http sixReuqestUrl:url postDict:param succeed:^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
        NSLog(@"----obj = %@",obj);
        NSDictionary * dic = (NSDictionary *)obj;
        NSNumber * value = [dic objectForKey:@"value"];
        if (value.integerValue == 1) {
            [SVProgressHUD showSuccessWithStatus:@"回复成功"];
        }
        [self disMissLoading];
    } failed:^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
        [SVProgressHUD showSuccessWithStatus:@"回复请求失败"];
        [self disMissLoading];
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    trqType = TopicHot;
    app = [AppDelegate shareInstace];
    D_ID = [app.loginDict  objectForKey:@"d_ID"];
//    self.view.backgroundColor = [UIColor whiteColor];
    self.dataSource1 = [[NSMutableArray alloc]  init];
    self.dataSource2 = [[NSMutableArray alloc]  init];
   
    [self createComponent];
    
    NSLog(@"%@", NSStringFromCGRect(self.tableView.frame));
    
    [self setupRefresh:self.tableView];
}


//-(void)viewWillAppear:(BOOL)animated
//{
//    if (IOS7) {
//        self.navigationController.navigationBar.translucent = NO;
//        self.automaticallyAdjustsScrollViewInsets = YES;
//    }
//}
//-(void)viewWillDisappear:(BOOL)animated
//{
//    [[NSNotificationCenter defaultCenter]  removeObserver:self name:dNoti_isHideKeyBoard object:nil];
//}

-(void)createComponent
{
    [self initLeftItem];
    
//    [self keyboardNotification];
    self.delegate = self;
//    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - 64 - 44)];
//    [self.view  addSubview:self.tableView];
//    self.tableView.delegate = self;
//    self.tableView.dataSource  =self;
//    self.tableView.backgroundColor = [UIColor whiteColor];
    //    [self.tableView setEditing:YES animated:NO];
//    [self createImportView];
     self.textView =  self.inputToolBarView.textView;
}
-(void) createImportView{
    
    self.importView = [[UIView alloc]  initWithFrame:CGRectMake(0, self.view.frame.size.height - 49 - 64 - 44 , self.view.frame.size.width, 44)];
    UIImageView * importBg = [[UIImageView alloc]  initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    importBg.backgroundColor = [UIColor redColor];
    [importBg setImage:[UIImage imageNamed:@"回复底图.png"]];
    [self.importView  addSubview:importBg];
    
    self.optionBtn = [[UIButton alloc]  initWithFrame:CGRectMake(5,10, 30, 30)];
    [self.optionBtn setBackgroundImage:[UIImage imageNamed:@"register1_check1.png"] forState:UIControlStateSelected];
    [self.optionBtn addTarget:self action:@selector(changeBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.optionBtn setBackgroundImage:[UIImage imageNamed:@"register1_check0.png"] forState:UIControlStateNormal];
    self.optionBtn.selected = NO;
    self.optionBtn.adjustsImageWhenHighlighted = NO;
    [self.importView  addSubview:self.optionBtn];
    
    int distance = 2;
    UILabel * lable = [[UILabel alloc]  initWithFrame:CGRectMake(self.optionBtn.frame.origin.x+self.optionBtn.frame.size.width + distance, 10, 40, 30)];
    lable.text = @"匿名";
    
    [self.importView addSubview:lable];
    
    self.importText = [[UITextView alloc]  initWithFrame:CGRectMake(self.optionBtn.frame.origin.x+self.optionBtn.frame.size.width + distance + lable.frame.size.width+2,10 , 320-(self.optionBtn.frame.origin.x+self.optionBtn.frame.size.width+distance+lable.frame.size.width+distance+2+5)-40, 30)];
    self.importText.backgroundColor = [UIColor whiteColor];
    self.importText.font = [UIFont boldSystemFontOfSize:14];
    //    UIImageView * imgView = [[UIImageView alloc]init];
    //    self.importText.delegate = self;
    //    CGRect frame = self.importText.frame;
    //    frame.origin = CGPointMake(0, 0);
    //    imgView.frame = frame;
    //    imgView.image = [UIImage imageNamed:@"回应输入框.png"];
    __weak HotTopicDetailVC * weakSelf = self;
    [self.mm_drawerController setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch) {
        [weakSelf.importText resignFirstResponder];
        return 0;
    }];
    //    [self.importText addSubview:imgView];
    self.importText.delegate = self;
    [self.importView addSubview:self.importText];
    self.sendMsg = [[UIButton alloc]  initWithFrame:CGRectMake(self.view.frame.size.width - 40, 10, 38, 30)];
    self.sendMsg.backgroundColor = [UIColor redColor];
    [self.sendMsg  setTitle:@"发送" forState:UIControlStateNormal];
    self.sendMsg.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.sendMsg  addTarget:self action:@selector(onTouchClick) forControlEvents:UIControlEventTouchUpInside];
    self.sendMsg.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.importView addSubview:self.sendMsg];
    
    [self.view addSubview:self.importView];
}
//对话题的发送信息和对话题回复帖子的发送各种信息(举报，删除，回复等)
//-(void)onTouchClick{
//    if (![CheckDataTool checkInfoForString:self.importText msgContent:@"请您输入信息"]){
//        return;
//    }
//    [self showLoading ];
//    switch (self.topicSendType) {
//        case TopicDetailReply:
//            if (self.operationType == TopicOperationAuthor) {
//                [self requestTopicReply:TOP_1_4_1 setParam:[self setRequestReplyParam:nil]];
//            }else{
//                [self requestTopicReply:TOP_1_4_1 setParam:[self setRequestReplyParam:sendName]];
//            }
//            break;
//        case TopicDetailCollect:
//            
//            break;
//        case TopicDetailCopy:
//            
//            break;
//        case TopicDetailReport:
//            if (self.operationType == TopicOperationAuthor) {//判断是给楼主举报还是回帖
//                [self requestReportData:[self setParamReportTopicID:self.topicID content:self.importText.text] setUrl:TOP_1_6_1];
//            }else{
//                [self requestReportData:[self setParamReplyReportTopicID:self.topicID content:self.importText.text] setUrl:TOP_1_10_1];
//            }
//            break;
//        case TopicDetailDelete:
//            
//            break;
//            
//        default:
//            break;
//    }
//    
//    
//    
//}
-(void)changeBtn:(UIButton *)b
{
    b.selected = !b.selected;
}

//键盘出现
-(void) keyboardWillShow:(NSNotification*)aNotification
{
    [[NSNotificationCenter defaultCenter]  postNotificationName:dNoti_isHideKeyBoard object:@"0"];
    NSDictionary* info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect frame = self.importView.frame;
    frame.origin.y = (ScreenHegiht-64)-(kbSize.height+self.importView.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        self.importView.frame = frame;
    }];
    
    
}
//键盘隐藏
-(void)keyboardWillHide:(NSNotification*)aNotification
{
    [[NSNotificationCenter defaultCenter]  postNotificationName:dNoti_isHideKeyBoard object:@"1"];
    
    
    [UIView animateWithDuration:0.2 animations:^{
        self.importView.frame = CGRectMake(0,self.view.frame.size.height - 49  - 44 , self.view.frame.size.width, 44);
    }];
    
    
}
//系统的Item方法
-(void)navItemClick:(UIButton *)button
{
    if (IOS7) {
        self.navigationController.navigationBar.translucent = YES;
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    [self.navigationController  popViewControllerAnimated:YES];
}



#pragma mark tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 26;
    }else{
        return 26;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *v = [[UIView alloc]  initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 26)];
        v.backgroundColor = [UIColor whiteColor];
        UIButton * iv2 = [[UIButton alloc]  initWithFrame:CGRectMake(0, 0, 60, 25)];
        [iv2 setTitle:@"楼主" forState:UIControlStateNormal];
        iv2.titleLabel.font = [UIFont systemFontOfSize: 12.0];
        [iv2 setBackgroundImage:[UIImage imageNamed:@"header.png"] forState:UIControlStateNormal];
        [iv2  whenTapped:^{
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }];
        [v addSubview:iv2];
        UIImageView * line = [[UIImageView alloc]  initWithFrame:CGRectMake(0, 25, self.view.frame.size.width , 1)];
        [line  setImage:[UIImage imageNamed:@"line"]];
        [v addSubview:line];
        
        return v;
    }else{
        UIView *v = [[UIView alloc]  initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 26)];
        v.backgroundColor = [UIColor whiteColor];
        
        UIImageView * line = [[UIImageView alloc]  initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , 2)];
        [line  setImage:[UIImage imageNamed:@"line"]];
        [v addSubview:line];
        
        UIButton * iv2 = [[UIButton alloc]  initWithFrame:CGRectMake(0, 2, 60, 25)];
        [iv2 setTitle:@"跟帖" forState:UIControlStateNormal];
        [iv2 setBackgroundImage:[UIImage imageNamed:@"header.png"] forState:UIControlStateNormal];
        iv2.titleLabel.font = [UIFont systemFontOfSize: 12.0];
        [v addSubview:iv2];
        [iv2  whenTapped:^{
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }];
        NSArray * array = @[@"按热度",@"按时间",@"按关系"];
        HMSegmentedControl *segmented = [[HMSegmentedControl alloc]  initWithSectionTitles:array];
        [segmented setSelectedSegmentIndex:trqType];
        segmented.selectionIndicatorColor = [UIColor redColor];
        segmented.frame = CGRectMake(65, 2, self.view.frame.size.width - 65, 22);
        [segmented setSelectedTextColor:[UIColor redColor                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ]];
        segmented.selectionStyle = HMSegmentedControlSelectionStyleBox;
        [segmented setFont:[UIFont systemFontOfSize:14]];
        [segmented setIndexChangeBlock:^(NSInteger index) {
            [self showLoading];
            switch (index) {
                case 0:
                {
                    trqType = TopicHot;
                    [self requestTalkReplyData:[self setRequestTalkReplyParam]];
                }
                    break;
                case 1:
                {
                    trqType = TopicTime;
                    [self requestTalkReplyData:[self setRequestTalkReplyParam]];
                }
                    break;
                case 2:
                {
                    trqType = TopicRelation;
                    [self requestTalkReplyData:[self setRequestTalkReplyParam]];
                }
                    break;
                default:
                    break;
            }
        }];
        
        [v addSubview:segmented];
        UIImageView * line2 = [[UIImageView alloc]  initWithFrame:CGRectMake(0, 25, self.view.frame.size.width , 1)];
        [line2  setImage:[UIImage imageNamed:@"line"]];
        [v addSubview:line2];
        return v;
    }
}
static NSString *identifier=@"ID";
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        Item_HotTopicDetail * item = [self.dataSource1  objectAtIndex:indexPath.row];
        float height =0 ;
        //题目的高度如何计算。。。。。。
        height += 37 + 21 + 10 +[item getTopicContentViewHeight] + 20 + [item getTopicImageGroupHeight] + 94 + 20;
        return height;
        
    }else{
        return 139;
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.dataSource1.count;
    }else{
        return self.dataSource2.count;
    }
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
      __weak HotTopicDetailVC * weakSelf = self;
    if (indexPath.section == 0){
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        BOOL displayActionButton = YES;
        BOOL displaySelectionButtons = NO;
        BOOL displayNavArrows = NO;
        BOOL enableGrid = YES;
        BOOL startOnGrid = NO;
        
        
        Cell_HotTopicDetail * cell1 = [tableView dequeueReusableCellWithIdentifier:
                                       identifier];
        if (nil == cell1) {
            cell1 = [[[NSBundle mainBundle] loadNibNamed:@"Cell_HotTopicDetail" owner:self options:nil] lastObject];
        }
        Item_HotTopicDetail * item = [self.dataSource1  objectAtIndex:indexPath.row];
        NSLog(@"----- item = %@",item);
        // cell1.TopicContent.text = item.TopicContent;
        cell1.hotTopicDetail = item;
       
//        cell1.TopicContent.backgroundColor = [UIColor whiteColor];
        [cell1.authorPhotoIV whenTapped:^{
            if (item.anonymousFlag == 1) {
                //
            }else{
                NSLog(@"~~~~~~~~点击头像");
            }
        }];
        [cell1.petName whenTapped:^{
            if (item.anonymousFlag == 1) {
                //
            }else{
                NSLog(@"~~~~~~~~点击昵称");
            }

        }];
        //点击图片进行浏览
        NSLog(@"------ frame = %@",NSStringFromCGRect(cell1.imageGroupView.frame));
        cell1.imageGroupView.backgroundColor = [UIColor redColor];
        cell1.imageGroupView.userInteractionEnabled = YES;
        for (UIImageView * iv in cell1.imageGroupView.subviews) {
            [iv whenTapped:^{
                NSLog(@"点击每张图");
            }];
        }
        
        
//        [cell1.imageGroupView whenTapped:^{
//            NSLog(@"------点击图片组%@",item.attachmentList);
//            for (NSString * imgUrl in item.attachmentList) {
//                [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:imgUrl]]];
//            }
//            self.photos = photos;
//            
//            // Create browser
//            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:weakSelf];
//            browser.displayActionButton = displayActionButton;
//            browser.displayNavArrows = displayNavArrows;
//            browser.displaySelectionButtons = displaySelectionButtons;
//            browser.alwaysShowControls = displaySelectionButtons;
//            browser.zoomPhotosToFill = YES;
//#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
//            browser.wantsFullScreenLayout = YES;
//#endif
//            browser.enableGrid = enableGrid;
//            browser.startOnGrid = startOnGrid;
//            browser.enableSwipeToDismiss = YES;
//            [browser setCurrentPhotoIndex:0];
//            
//            // Reset selections
////            if (displaySelectionButtons) {
////                _selections = [NSMutableArray new];
////                for (int i = 0; i < photos.count; i++) {
////                    [_selections addObject:[NSNumber numberWithBool:NO]];
////                }
////            }
//            
//            // Show
////            if (_segmentedControl.selectedSegmentIndex == 0) {
//                // Push
////                [self.navigationController pushViewController:browser animated:YES];
////            } else {
////                // Modal
//                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
//                nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//                [self presentViewController:nc animated:YES completion:nil];
////            }
//            
//            // Release
//            
//            // Deselect
//            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//            
//            // Test reloading of data after delay
//            double delayInSeconds = 3;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                
//                //        // Test removing an object
//                //        [_photos removeLastObject];
//                //        [browser reloadData];
//                //
//                //        // Test all new
//                //        [_photos removeAllObjects];
//                //        [_photos addObject:[MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo3" ofType:@"jpg"]]];
//                //        [browser reloadData];
//                //    
//                //        // Test changing photo index
//                //        [browser setCurrentPhotoIndex:9];
//                
//                //        // Test updating selections
//                //        _selections = [NSMutableArray new];
//                //        for (int i = 0; i < [self numberOfPhotosInPhotoBrowser:browser]; i++) {
//                //            [_selections addObject:[NSNumber numberWithBool:YES]];
//                //        }
//                //        [browser reloadData];
//                
//            });
//            
//            
//            
//        }];
        
//        cell1.TopicContent.backgroundColor = [UIColor whiteColor];
       
        
        [cell1.clickGood  whenTapped:^{
            if (item.viewSupportFlag == 1) {
                _supportType = 2;
                item.viewSupportFlag++;
                item.likeCount--;
                [SVProgressHUD showSuccessWithStatus:@"取消点赞"];
            }else{
                _supportType = 1;
                item.viewSupportFlag--;
                item.likeCount++;
                [SVProgressHUD showSuccessWithStatus:@"点赞成功"];
            }
            [self requestClickGoodData:item._id setActtype:_supportType isAuthor:indexPath.section indexPath:indexPath.row];
                }];
        cell1.contentView.userInteractionEnabled = YES;
        cell1.imageGroupView.userInteractionEnabled = YES;
        
        return cell1;
        
        
//

    }else{
        static NSString *identifier=@"ID2";
        Cell_HotTopDetailRowTableViewCell * cell2 = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell2) {
            cell2 = [[[NSBundle mainBundle] loadNibNamed:@"Cell_HotTopDetailRowTableViewCell" owner:self options:nil] lastObject];
        }
        Item_HotTopDetailRow * item2 = [self.dataSource2 objectAtIndex:indexPath.row];
        
        //头像设置
        if ([item2.headerPath isEqualToString:@"111111"]){
            cell2.header.image = [UIImage imageNamed:@"zjgw_logo"];
        }else if([item2.headerPath isEqualToString:@"22222"]){
            cell2.header.image = [UIImage imageNamed:@"匿名"];
        }else{
            [cell2.header setImageWithURL:[NSURL URLWithString:item2.headerPath] placeholderImage:[UIImage imageNamed:@"zjgw_logo"]];
        }
        
        cell2.header.layer.cornerRadius = AllCornerRadius;
        cell2.header.layer.masksToBounds = YES;
        
        [cell2.header whenTapped:^{
            if (item2.anonymousFlag == 1) {
                //
            }else{
                NSLog(@"~~~~~~~~点击头像");
            }

        }];

        
        cell2.good.text = [NSString stringWithFormat:@"%d",item2.supports];
        
        
        cell2.content.text = item2.content;
        cell2.name.text = item2.petName;
        [cell2.name whenTapped:^{
            if (item2.anonymousFlag == 1) {
                //
            }else{
                NSLog(@"~~~~~~~~点击昵称");
            }

        }];
        
        
        if (item2.anonymousFlag == 1) {
            cell2.age.text = @"";
        }else{
            cell2.age.text = [NSString stringWithFormat:@"%@/%@",item2.childGender,item2.childAge];
        }
        
        
        
        if (item2.viewSupportFlag == 1 ) {
            cell2.goodIv.image = [UIImage imageNamed:@"good_1.png"];
        }else{
            cell2.goodIv.image = [UIImage imageNamed:@"good_2.png"];
        }
        
        cell2.contentView.backgroundColor = [UIColor clearColor];
        
        UIView *aView = [[UIView alloc] initWithFrame:cell2.contentView.frame];
        
        aView.backgroundColor = [UIColor whiteColor];
        
        cell2.selectedBackgroundView = aView;

        
        
        
        [cell2.goodIv whenTapped:^{
            if (item2.viewSupportFlag == 1) {
                _supportType = 2;
                item2.viewSupportFlag++;
                item2.supports--;
                [SVProgressHUD showSuccessWithStatus:@"取消点赞"];
            }else{
                _supportType = 1;
                item2.viewSupportFlag--;
                item2.supports++;
                [SVProgressHUD showSuccessWithStatus:@"点赞成功"];
            }
            [self requestClickGoodData:item2._id setActtype:_supportType isAuthor:indexPath.section indexPath:indexPath.row];
            NSLog(@"～～～～～～点赞");
            
        }];
        return cell2;
        
        
        
    }
    
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Load Assets

- (void)loadAssets {
    
    // Initialise
    _assets = [NSMutableArray new];
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Run in the background as it takes a while to get all assets from the library
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
        
        // Process assets
        void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                    NSURL *url = result.defaultRepresentation.url;
                    [_assetLibrary assetForURL:url
                                   resultBlock:^(ALAsset *asset) {
                                       if (asset) {
                                           @synchronized(_assets) {
                                               [_assets addObject:asset];
                                               if (_assets.count == 1) {
                                                   // Added first asset so reload data
                                                   [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                               }
                                           }
                                       }
                                   }
                                  failureBlock:^(NSError *error){
                                      NSLog(@"operation was not successfull!");
                                  }];
                    
                }
            }
        };
        
        // Process groups
        void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                [assetGroups addObject:group];
            }
        };
        
        // Process!
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                         usingBlock:assetGroupEnumerator
                                       failureBlock:^(NSError *error) {
                                           NSLog(@"There is an error");
                                       }];
        
    });
    
}

///设置话题回复点赞的设置
-(NSMutableDictionary*)setParamTopicReplySupportWith:(NSString *)topId setActtype:(NSInteger)type{
    NSMutableDictionary * paramGood = [[NSMutableDictionary alloc]  init];
    [paramGood  setValue:D_ID forKey:@"D_ID"];
    [paramGood  setValue:topId forKey:@"topicReplySupport.topicReply.id"];
    [paramGood setValue:[NSString stringWithFormat:@"%d",type] forKey:@"topicReplySupport.acttype"];
    return paramGood;
}
///设置话题点赞的设置
-(NSMutableDictionary*)setParamTopicSupportWith:(NSString *)topId setActtype:(NSInteger)type{
    NSMutableDictionary * paramGood = [[NSMutableDictionary alloc]  init];
    [paramGood  setValue:D_ID forKey:@"D_ID"];
    [paramGood  setValue:topId forKey:@"topicSupport.topic.id"];
    [paramGood setValue:[NSString stringWithFormat:@"%d",type] forKey:@"topicSupport.acttype"];
    return paramGood;
}


///为某个话题点赞
-(void)requestClickGoodData:(NSString *)topId setActtype:(NSInteger)type isAuthor:(NSInteger)isAuthor indexPath:(NSInteger )index
{
    NSLog(@"--^^^^^^^^^^^^^^-- %d",type);
    NSMutableDictionary * paramGood = [[NSMutableDictionary alloc]  init];
    NSString * url;
    if (isAuthor == 0) {
        paramGood = [self setParamTopicSupportWith:topId setActtype:type];
        url = TOP_1_5_1;
    }else{
        paramGood = [self setParamTopicReplySupportWith:topId setActtype:type];
        url = TOP_1_9_1;
    }
    __weak HotTopicDetailVC * weakSelfG = self;
    [http sixReuqestUrl:url postDict:paramGood succeed:^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
        NSString * value = [(NSDictionary*)obj objectForKey:@"value"];
        value = [NSString stringWithFormat:@"%@",value];
        
        if ([value isEqualToString:@"1"]){
            [self.tableView reloadData];
            
        }else{
            if (type == 0) {
                [SVProgressHUD showSuccessWithStatus:@"点赞失败"];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"取消点赞失败"];
            }
            
        }
    } failed:^(AFHTTPRequestOperation *operation, NSObject *obj, BOOL succeed) {
        if (type == 2) {
            [SVProgressHUD showSuccessWithStatus:@"点赞失败"];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"取消点赞失败"];
        }
        
    }];
}


-(void)createPhotoBrowser:(int)tag image:(UIImage *)image
{
//    tag = 1;
//    int count = 9;
//    // 1.封装图片数据
//    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
//    for (int i = 0; i<count; i++) {
//        // 替换为中等尺寸图片
//        //        NSString *url = [_urls[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
//        MJPhoto *photo = [[MJPhoto alloc] init];
//        photo.url = [NSURL URLWithString:nil]; // 图片路径
//        photo.srcImageView = (UIImageView *)[self.view viewWithTag:1001]; // 来源于哪个UIImageView
//        //        photo.placeholder = image;
//        [photos addObject:photo];
//    }
//    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
//    browser.currentPhotoIndex = tag; // 弹出相册时显示的第一张图片是？
//    browser.photos = photos; // 设置所有的图片
//    [browser show];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self topicOperationShowDialog:indexPath.row andSection:indexPath.section];
}

//show出 对话题操作的 dialog
-(void)topicOperationShowDialog:(NSInteger )indexPathRow andSection:(NSInteger)section
{
    
    
    DialogView * dialog = [DialogView  shareInstance];
    
    dialog.transform = CGAffineTransformMakeScale(1.3, 1.3);
    dialog.alpha = 0.5;
    [UIView animateWithDuration:0.3 animations:^{
        
        dialog.transform = CGAffineTransformMakeScale(1, 1);
        dialog.alpha = 1;
    }];
    __weak HotTopicDetailVC * weakSelf = self;
    dialog.block = ^(NSInteger index)
    {
        NSLog(@"-----weakSelf.dataSource2 = %@",weakSelf.dataSource2);
        //弹出键盘
        Item_HotTopicDetail * detailItem1;
        Item_HotTopDetailRow * detailItem2;
        if (section != 0 ) {
            detailItem1 = [weakSelf.dataSource1 objectAtIndex:0];
            
            detailItem2 =  [weakSelf.dataSource2 objectAtIndex:indexPathRow];
        }else{
            detailItem1 = [weakSelf.dataSource1 objectAtIndex:0];
        }
       
        
        switch (index) {
            case 0://话题回复
            {
                if (section == 0) {
                    NSInteger i = arc4random() % 1000;
                    [self requestTopicCommentWithURl:TOP_1_4_1 setParam:[self setRequestReplyParamByTopId:detailItem1._id andCommentText:[NSString stringWithFormat:@"--测试回复话题%d",i] andIsAnonymity:2]];
                        //暂时设定位不匿名
                }else{
                    NSInteger i = arc4random() % 1000;
                    [self requestTopicCommentWithURl:TOP_1_4_1 setParam:[self setRequestReplyParamByTopId:detailItem1._id andCommentText:[NSString stringWithFormat:@"--测试回复评论者%d",i] andIsAnonymity:2]];

                }
                
            }
                break;
            case 1://收藏
            {

                if (section == 0) {//枚举 区分是对楼主还是某个回帖
                    [self requestTopicStoreDataURl:TOP_1_7_1 setParam:[self setParamTopicStoreTopId:detailItem1._id topicReplyId:nil topicStoreType:@"1" actType:[NSString stringWithFormat:@"%d",_storeType]]];

                }else{
                    [self requestTopicStoreDataURl:TOP_1_7_1 setParam:[self setParamTopicStoreTopId:detailItem1._id topicReplyId:detailItem2._id topicStoreType:@"2" actType:[NSString stringWithFormat:@"%d",_storeType]]];
                    

                }
            }
                break;
            case 2:
            {
                NSLog(@"复制");
                if (section == 0) {//枚举 区分是对楼主还是某个回帖
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = detailItem1.TopicContent;
                }else{
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = detailItem2.content;
                }
                
            }
                break;
            case 3://举报
            {
                if (section == 0) {//判断是给楼主举报还是回帖
                    if (_reportType == 2) {
                        [self requestReportData:[self setParamReportTopicID:detailItem1._id content:@"测试举报"] setUrl:TOP_1_6_1];
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"已举报过当前话题"];
                    }
                    
                }else{
                    if (_reportType == 2) {
                        //举报请求成功，但是无效
                        [self requestReportData:[self setParamReplyReportTopicID:detailItem2._id content:@"测试话题回复举报"] setUrl:TOP_1_10_1];
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"已举报过当前回复"];
                    }
                    
                }
                
                
                
                
            }
                break;
            case 4:
            {
                NSLog(@"删除");
            }
                break;
            default:
                break;
        }
    };
    
}

//屏幕出现的tableview的item的indexPath
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"----   indexpath - --- %ld---  分割    ---%ld" , indexPath.section , indexPath.row);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

//#pragma mark textviewdelegouet
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
//{
//    NSString * text = textView.text;
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        return NO;
//    }
//    return YES;
//}





-(void)keyboardNotification
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillShow:)
     
                                                 name:UIKeyboardWillShowNotification
     
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillHide:)
     
                                                 name:UIKeyboardWillHideNotification
     
                                               object:nil];
}

#pragma mark 开始进入刷新状态
- (void)stopRefresh
{
    [self.tableView reloadData];
    [self.tableView footerEndRefreshing];
    [self.tableView headerEndRefreshing];
}
//下拉刷新
-(void)headerRereshing{
    [self.dataSource1 removeAllObjects];
    [self.dataSource2 removeAllObjects];
    _pageNum = 1;
    [self requestData:[self setRequestParam]];
    [self requestTalkReplyData:[self setRequestTalkReplyParam]];
    
}
///上拉加载
-(void)footerRereshing{
    if(_isBottom == 0){
        _pageNum++;
        [self requestTalkReplyData:[self setRequestTalkReplyParam]];
    }else{
        [SVProgressHUD showSuccessWithStatus:@"无更多数据"];
        [self stopRefresh];
    }
    
}

///重置请求参数
-(void)resetParam{
    _pageNum = 1;
}


/////设置请求参数
//- (void)setupRefresh
//{
//    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
//    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
//    //#warning 自动刷新(一进入程序就下拉刷新)
//    [self.tableView headerBeginRefreshing];
//    
//    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
//    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    //    NSLog(@"****");
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    //    NSLog(@"****");
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //    NSLog(@"****");
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    //    NSLog(@"****");
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //    NSLog(@"****");
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    //    NSLog(@"****");
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
    //    NSLog(@"****");
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    //    NSLog(@"****");
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    //    NSLog(@"****");
    return YES;
}

#pragma mark - msgdelegate
#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    NSLog(@"发送文字");
    
    [self.inputToolBarView.textView resignFirstResponder];
    
    [self finishSend:NO];
}

- (void)cameraPressed:(id)sender{
    
    NSLog(@"cameraClick!");
    if (self.textView.isFirstResponder) {
        if (self.textView.emoticonsKeyboard) [self.textView switchToDefaultKeyboard];
        else [self.textView switchToEmoticonsKeyboard:[WUDemoKeyboardBuilder sharedEmoticonsKeyboard]];
    }else{
        [self.textView switchToEmoticonsKeyboard:[WUDemoKeyboardBuilder sharedEmoticonsKeyboard]];
        [self.textView becomeFirstResponder];
    }
    
}



- (UIButton *)sendButton
{
    return [UIButton defaultSendButton];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    AppDelegate * app = [AppDelegate shareInstace];
    app.mTbc.mainView.hidden = YES;
    
    [self.tableView headerBeginRefreshing];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:YES];
    AppDelegate * app = [AppDelegate shareInstace];
    app.mTbc.mainView.hidden = NO;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
