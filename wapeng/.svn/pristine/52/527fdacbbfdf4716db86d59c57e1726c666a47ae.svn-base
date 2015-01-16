

#import "ASIVC03.h"
#import "MessageData.h"
#import "WUDemoKeyboardBuilder.h"

#import "PublicStringTool.h"
@interface ASIVC03 () <JSMessagesViewDelegate, JSMessagesViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) NSMutableArray *messageArray;
@property (nonatomic,strong) UIImage *willSendImage;

@property (nonatomic, strong) NSMutableArray * dataArray;

@property (nonatomic, strong) UITextView * textView;

@property (nonatomic, strong) TQRichTextView * tv;

@end

@implementation ASIVC03

@synthesize messageArray;


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
   
    [btn setTitle:@"娟娟我爱你" forState: UIControlStateNormal];
    btn.frame = CGRectMake(100, 100, 200, 100);
    
    btn.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:btn];
    
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    TQRichTextView * tv = [[TQRichTextView alloc]initWithFrame:CGRectMake(0, 250, kMainScreenWidth, 200)];
    tv.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:tv];
    
    self.tv = tv;
}

-(void)btnClick
{
    NSString * str = @"[干杯][干杯][干杯][干杯][干杯][干杯][干杯][干杯][干杯][干杯]";
    
    NSString * pubStr = [PublicStringTool unifyStringWithAndiordString:str];
    
    NSLog(@"%@", pubStr);
    
    self.tv.text = pubStr;
}

-(void)createWeChatKeyBoard
{
    self.title = @"ChatMessage";
    
    
    self.textView = self.inputToolBarView.textView;
    
    self.dataArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < 100; i++) {
        
        NSString * str = [NSString stringWithFormat:@"%d", i];
        
        [self.dataArray addObject:str];
    }
    
    self.delegate = self;
}

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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    
    static NSString * strID = @"ID";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:strID];
    
    if (strID) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strID];
    }
    
    NSString * item = self.dataArray[indexPath.row];
    
    cell.textLabel.text = item;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return self.dataArray.count;
}


@end
