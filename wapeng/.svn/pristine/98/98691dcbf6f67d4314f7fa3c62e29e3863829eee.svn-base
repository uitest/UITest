

#import <Foundation/Foundation.h>

@interface MessageData : NSObject

@property (nonatomic, strong) NSString *msgId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSInteger messageType;
@property (nonatomic, assign) NSInteger mediaType;
@property (nonatomic, strong) NSString *img;
@property (nonatomic, assign) BOOL isSendSuccess;//是否发送成功
@property (nonatomic, assign) int isButtom;//是否有下一页
@property (nonatomic, strong) NSString * observePhotoUrl;//我的url
@property (nonatomic, strong) NSString * peerPhotoUrl;//对方的头像地址
@property (nonatomic, strong) NSString * peerPetName;//别人的昵称

- (instancetype)initWithMsgId:(NSString *)msgId text:(NSString *)text date:(NSDate *)date msgType:(NSInteger)msgType mediaType:(NSInteger)medType img:(NSString *)img;


@end
