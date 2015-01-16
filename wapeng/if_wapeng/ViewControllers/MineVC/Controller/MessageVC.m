//
//  MessageVC.m
//  if_wapeng
//
//  Created by 早上好 on 14-9-18.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import "MessageVC.h"
#import "AFN_HttpBase.h"
#import "UIViewController+MMDrawerController.h"
#import "IQSegmentedNextPrevious.h"
#import "RegisterMapViewController.h"
#import "AppDelegate.h"
#import "IQKeyBoardManager.h"
#import "IQSegmentedNextPrevious.h"
#import "CommonView.h"
#import "TimeTool.h"
#import "ChangeCityVC01.h"
#import "ChageCityItem.h"
#import "RegisterVC08.h"
#import "RegisterVC07.h"
#import "ChangeHospitalVC.h"
#import "Item_BabyInfo.h"
#import "TimeTool.h"
#import "Item_RC08.h"
#import "R07TableCellM.h"
@interface MessageVC ()<UITextFieldDelegate, ChangeHospitalDelegate>
{
    UIButton    *_selectBtn;
    UIButton    *_rightBtn;
    UIView      *_tempView;
    CGRect      _oldFrame;
    NSString    *_sex;
    AFN_HttpBase * http;
    int pageIndex;
}
@property (weak, nonatomic) IBOutlet UITextField *babyNick;
@property (weak, nonatomic) IBOutlet UIButton *man;

@property (weak, nonatomic) IBOutlet UIButton *women;

@property (weak, nonatomic) IBOutlet UITextField *birthday;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (weak, nonatomic) IBOutlet UITextField *hospital;
@property (weak, nonatomic) IBOutlet UITextField *kindergarten;
@property (weak, nonatomic) IBOutlet UITextField *babyClass;

@property (nonatomic, strong) UIDatePicker * datePicker;
@end

@implementation MessageVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"宝宝信息";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated;
{
    
    AppDelegate * app = [AppDelegate shareInstace];
    app.mTbc.mainView.hidden = YES;
    //键盘自动布局
    [IQKeyBoardManager installKeyboardManager];
    [IQKeyBoardManager enableKeyboardManger];
}

-(void)viewWillDisappear:(BOOL)animated{
//    AppDelegate * app = [AppDelegate shareInstace];
//    app.mTbc.mainView.hidden = NO;
    //取消键盘自动布局
    [IQKeyBoardManager disableKeyboardManager];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    http=[[AFN_HttpBase alloc]init];
    self.item = [[Item_BabyInfo alloc]init];
    
    self.view.backgroundColor = kRGB(237,237,237);
    
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 25)];
    [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(savaInfo) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.hidden = NO;
    UIColor *titleColor = kRGB(38, 138, 247);
    [rightBtn setTitleColor:titleColor forState:UIControlStateNormal];
    _rightBtn = rightBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    _sex = [NSString string];
    _sex = @"男";
    self.man.selected = YES;
    _selectBtn = self.man;
    
//
    self.birthday.text = @"2月11日";
//
//    
    self.city.text = @"成都";
//
    self.hospital.text =@"协和";
//
//    
    self.kindergarten.text = @"无忧小学";
//
//    
    self.babyClass.text = @"五年二班";

    UIImage *backImage = [UIImage imageNamed:@"public_back"];
    UIButton *back = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    [back setImage:backImage forState:UIControlStateNormal];
    [back setImage:[UIImage imageNamed:@"public_back_hightLight"] forState:UIControlStateHighlighted];
    [back addTarget:self action:@selector(navItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = left;
    
    [self headHttpPage];

    UIDatePicker * datePicker = [CommonView datePickerViewWithFrame:CGRectMake(0, 0, kMainScreenWidth, 0)];
    self.datePicker = datePicker;
    self.birthday.inputView = datePicker;
    UIToolbar * toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 40)];
    UIBarButtonItem * space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * confirm = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confrimDate)];
    NSMutableArray * items = [NSMutableArray array];
    
    [items addObject:space];
    [items addObject:confirm];
    toolbar.items = items;
    self.birthday.inputAccessoryView = toolbar;
    [self.city addTarget:self action:@selector(selectCityClick) forControlEvents:UIControlEventTouchUpInside];
    
//    self.city.enabled = NO;
    
    CGRect frame = self.city.frame;
    frame.origin = CGPointZero;
    
    NSLog(@"%@", NSStringFromCGRect(frame));
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
//    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(selectCityClick) forControlEvents:UIControlEventTouchUpInside];
    [self.city addSubview:btn];
    
    frame = self.babyClass.frame;
    frame.origin = CGPointZero;
    UIButton * classBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    classBtn.frame = frame;
    [classBtn addTarget:self action:@selector(selectClass) forControlEvents:UIControlEventTouchUpInside];
    [self.babyClass addSubview:classBtn];
    
    UIButton * kindergatdenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    frame = self.kindergarten.frame;
    frame.origin = CGPointZero;
    kindergatdenBtn.frame = frame;
    [self.kindergarten addSubview:kindergatdenBtn];
    [kindergatdenBtn addTarget:self action:@selector(kindergartenClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    frame = self.hospital.frame;
    frame.origin = CGPointZero;
    UIButton * hospital = [UIButton buttonWithType:UIButtonTypeCustom];
    hospital.frame = frame;
    [self.hospital addSubview:hospital];
    [hospital addTarget:self action:@selector(selectHospital) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNoti:) name:@"changeCity" object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNoti2:) name:dNoti_changBabyClass object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNoti3:) name:dNoti_changeBabyKinder object:nil];
    
}

-(void)receiveNoti3:(NSNotification *)notify
{
    R07TableCellM * item = notify.object;
    self.item.classID = @"";
    self.item.className = @"";
    self.babyClass.text = self.item.className;
    self.item.mDescription = item.title;
    self.item.childkindergartenID = item.kindergarten_Id;
    self.kindergarten.text = item.title;
    
}
-(void)receiveNoti2:(NSNotification *)notify
{
    Item_RC08 * item = notify.object;
   
    self.item.classID = item._id;
    self.item.className = item.name;
     self.babyClass.text = self.item.className;
    self.item.mDescription = item.kindName;
    self.item.childkindergartenID = item.kindID;
    self.kindergarten.text = item.kindName;
}
#pragma mark- 选择幼儿园

-(void)kindergartenClick
{
    RegisterVC07 * regVC07 = [[RegisterVC07 alloc]init];
    regVC07.type = 1;
    regVC07.latitude = self.item.latitude;
    regVC07.longtitude = self.item.longtitude;
    regVC07.areaID = self.item.cityID;
    [self.navigationController pushViewController:regVC07 animated:YES];
}

-(void)selectHospital
{
    ChangeHospitalVC * hospitalVC = [[ChangeHospitalVC alloc]init];
    hospitalVC.delegate = self;
    hospitalVC.areaID = self.item.areaID;
    hospitalVC.cityID = self.item.cityID;
    [self.navigationController pushViewController:hospitalVC animated:YES];
}

#pragma mark - 选择班级
-(void)selectClass
{
//    RegisterVC08 * registerVC08 = [[RegisterVC08 alloc]init];
//    [self.navigationController pushViewController:registerVC08 animated:YES];
    RegisterVC07 * regVC07 = [[RegisterVC07 alloc]init];
    regVC07.type = 1;
    regVC07.latitude = self.item.latitude;
    regVC07.longtitude = self.item.longtitude;
    regVC07.areaID = self.item.cityID;
    [self.navigationController pushViewController:regVC07 animated:YES];
}

#pragma mark - 选择城市
-(void)selectCityClick
{
    ChangeCityVC01 * changeCityVC = [[ChangeCityVC01 alloc]init];
    [self.navigationController pushViewController:changeCityVC animated:YES];
}

-(void)receiveNoti:(NSNotification *)notify
{
    ChageCityItem * item = notify.object;
    self.city.text = item.name;
    //获取新的经纬度
    self.item.longtitude = item.longitude;
    self.item.latitude = item.latitude;
    self.item.areaID = item.sid;
    self.item.cityID = item.mid;
}

#pragma mark - 确定日期
-(void)confrimDate
{
    NSDate * date = self.datePicker.date;
    
    NSString * time = [TimeTool getTimeWithDate:self.datePicker.date andFormatterString:@"yyyy-MM-dd"];
    self.birthday.text = time;
    [self.birthday resignFirstResponder];
    NSLog(@"%@",date);
}

-(void)headHttpPage
{
    self.operation=@"1";
    pageIndex=1;
    NSString * page=[NSString stringWithFormat:@"%d",pageIndex];
    [self httpRequestData:page];
}
#pragma mark 请求数据
-(void)httpRequestData:(NSString *)page
{
    NSUserDefaults * d = [NSUserDefaults standardUserDefaults];
    NSString * ddid = [d objectForKey:UD_ddid];
    
    __weak MessageVC * weakSelf = self;
    [http thirdRequestWithUrl:dUrl_OSM_1_3_1 succeed:^(NSObject *obj, BOOL isFinished) {
        [SVProgressHUD showSuccessWithStatus:@"请求成功"];
        
        NSDictionary * root = (NSDictionary *)obj;
        
        if (isNotNull([root objectForKey:@"value"])) {
            
            if (isNotNull([[root objectForKey:@"value"] objectForKey:@"list"] )) {
                 NSArray * list =[[root objectForKey:@"value"] objectForKey:@"list"];
                if (list.count != 0) {
                    
                    
                    NSDictionary * value0 = nil;
                    
                    for (NSDictionary * dict in list) {
                        
                        int isSelected = [[dict objectForKey:@"selected"] intValue];
                        
                        if (isSelected == YES) {
                            
                            value0 = dict;
                            break;
                        }
                    }
                    weakSelf.item.birthday = [value0 objectForKey:@"birthday"];
                    weakSelf.item.gender = [[value0 objectForKey:@"gender"] integerValue];
                    weakSelf.item.hospitalName = [NSString stringWithFormat:@"%@", [[value0 objectForKey:@"hospital"] objectForKey:@"name"]];
                    weakSelf.item.babyName = [NSString stringWithFormat:@"%@", [value0 objectForKey:@"name"]];
                    weakSelf.item.className = [[value0 objectForKey:@"organizationBranch"] objectForKey:@"name"];
                    weakSelf.item.zoneName = [[value0 objectForKey:@"zoneArea"] objectForKey:@"name"];
                   
                    weakSelf.item.petName = [[value0 objectForKey:@"kindergarten"] objectForKey:@"name"];
                    
                    
                    //各种id
                    weakSelf.item.childID = [value0 objectForKey:@"id"];
                    
                    weakSelf.item.cityID = [[[value0 objectForKey:@"zoneArea"] objectForKey:@"parent"] objectForKey:@"id"];
                    
                    weakSelf.item.areaID = [[value0 objectForKey:@"zoneArea"] objectForKey:@"id"];
                    
                    weakSelf.item.hospitalID = [NSString stringWithFormat:@"%@", [[value0 objectForKey:@"hospital"] objectForKey:@"id"]];
                    weakSelf.item.childkindergartenID = [[value0 objectForKey:@"kindergarten"] objectForKey:@"id"];
                    weakSelf.item.classID = [[value0 objectForKey:@"organizationBranch"] objectForKey:@"id"];
                    
                    NSUserDefaults * d = [NSUserDefaults standardUserDefaults];
    
                    //初始化经纬度
                    weakSelf.item.latitude = [[d objectForKey:UD_loginDict] objectForKey:@"latitude"];
                    weakSelf.item.longtitude = [[d objectForKey:UD_loginDict] objectForKey:@"longitude"];
                    
                    
                    switch (weakSelf.item.gender) {
                        case 1:
                        {
                            weakSelf.man.selected = YES;
                            weakSelf.women.selected = NO;
                        }
                            break;
                        case 2:
                        {
                            weakSelf.women.selected = YES;
                            weakSelf.man.selected = NO;
                        }
                            break;
                        default:
                            break;
                    }
                    weakSelf.babyNick.text = weakSelf.item.babyName;
                    weakSelf.birthday.text = [weakSelf.item.birthday substringToIndex:10];
                    weakSelf.city.text = weakSelf.item.zoneName;
                    weakSelf.hospital.text = weakSelf.item.hospitalName;
                    weakSelf.kindergarten.text = weakSelf.item.petName;
                    NSLog(@"%@", weakSelf.item.petName);
                    weakSelf.babyClass.text = weakSelf.item.className;
                    
                }else{
                    
                    [SVProgressHUD showSuccessWithStatus:dTips_noMoreData];
                }
               
               
            }
             [SVProgressHUD showSuccessWithStatus:dTips_noMoreData];
        }else{
             [SVProgressHUD showSuccessWithStatus:dTips_noMoreData];
        }
    
    } failed:^(NSObject *obj, BOOL isFinished) {
        [SVProgressHUD showSuccessWithStatus:@"请求失败"];
    } andKeyValuePairs:@"D_ID",ddid,@"childInfoQuery.pageNum",page,nil];
}

- (IBAction)genderClick:(id)sender {
    
    if ([self.man isEqual:sender]) {
        self.man.selected = YES;
        self.women.selected = NO;
        self.item.gender = 1;
    }else{
        self.man.selected = NO;
        self.women.selected = YES;
        self.item.gender = 2;
    }
    
}


-(void)saveHttpRequestWithType:(int)type
{
    NSUserDefaults * d = [NSUserDefaults standardUserDefaults];
    NSString * ddid = [d objectForKey:UD_ddid];
    
    NSDictionary * loginDict = [d objectForKey:UD_loginDict];
    NSString * userInfoID = [loginDict objectForKey:@"userInfoID"];
    if (type == 1 ) {
        [http thirdRequestWithUrl:dUrl_OSM_1_3_2 succeed:^(NSObject *obj, BOOL isFinished) {
            
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            
        } failed:^(NSObject *obj, BOOL isFinished) {
            
            [SVProgressHUD showSuccessWithStatus:@"保存失败"];
            
        } andKeyValuePairs:@"D_ID", ddid , @"childInfo.id" ,self.item.childID, @"childInfo.name", self.item.babyName, @"childInfo.birthday", self.item.birthday, @"childInfo.gender", [NSString stringWithFormat:@"%d", self.item.gender],@"childInfo.zoneArea.id", self.item.areaID, @"childInfo.hospital.id", self.item.hospitalID, @"childInfo.kindergarten.id", self.item.childkindergartenID,@"childInfo.organizationBranch.id", self.item.classID, @"childInfo.parent.id", userInfoID,nil];
        
        return;
 
    }
    
    if (type == 2) {
        
        //自定义幼儿园
        [http thirdRequestWithUrl:dUrl_OSM_1_3_2 succeed:^(NSObject *obj, BOOL isFinished) {
            
        } failed:^(NSObject *obj, BOOL isFinished) {
            
        } andKeyValuePairs:@"D_ID", ddid , @"childInfo.id" ,@"", @"childInfo.name", self.item.babyName, @"childInfo.birthday", self.item.birthday, @"childInfo.gender", [NSString stringWithFormat:@"%d", self.item.gender],@"childInfo.zoneArea.id", self.item.areaID, @"childInfo.hospital.id",self.item.hospitalID,@"childInfo.organizationBranch.id", self.item.classID ,@"childInfo.customerKindergarten.name", self.item.customerKindergarten, nil];
    }
    
}
//General
-(void)navItemClick:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter]postNotificationName:dNoti_isHideKeyBoard object:@"1"];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark  -保存信息
-(void)savaInfo{
    
    [self saveHttpRequestWithType:1];
}

- (IBAction)selectSex:(UIButton *)sender {
    _rightBtn.hidden = NO;
    _selectBtn.selected = NO;
    sender.selected = YES;
    _selectBtn = sender;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    _rightBtn.hidden = NO;
    _tempView = textField.superview;
    _oldFrame = _tempView.frame;
    if ([textField isEqual:self.city]) {
        ChangeCityVC01 * changeCityVC = [[ChangeCityVC01 alloc]init];
        [self.navigationController pushViewController:changeCityVC animated:YES];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if ([textField isEqual:self.babyNick]) {
        self.item.babyName = self.babyNick.text;
    }
    if ([textField isEqual:self.birthday]) {
        self.item.birthday = [TimeTool getTimeWithDate:self.datePicker.date andFormatterString:@"YYYY-MM-dd"];
    }
    if ([textField isEqual:self.hospital]) {
        self.item.hospitalName = self.hospital.text;
    }
    if ([textField isEqual:self.kindergarten]) {
        self.item.mDescription = self.kindergarten.text;
    }
    if ([textField isEqual:self.babyClass]) {
        
        self.item.className = self.babyClass.text;
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.babyNick resignFirstResponder];
    [self.birthday resignFirstResponder];
    [self.city resignFirstResponder];
    [self.hospital resignFirstResponder];
    [self.kindergarten resignFirstResponder];
    [self.babyClass resignFirstResponder];
}

- (IBAction)endEdit:(id)sender {
}


-(void)changeHospitalWithCityID:(NSString *)cityID areaID:(NSString *)areaID hospitalID:(NSString *)hospitalID hospitalName:(NSString *)hospitalName
{
    self.item.cityID = cityID;
    self.item.areaID = areaID;
    self.item.hospitalID = hospitalID;
    
    NSLog(@"%@", hospitalName);
    
    self.item.hospitalName = hospitalName;
    self.hospital.text = self.item.hospitalName;
}
@end
