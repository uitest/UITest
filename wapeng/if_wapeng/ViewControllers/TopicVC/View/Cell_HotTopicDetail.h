//
//  Cell_HotTopicDetail.h
//  if_wapeng
//
//  Created by 早上好 on 14-9-11.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQRichTextView.h"
#import "Item_HotTopicDetail.h"
@interface Cell_HotTopicDetail : UITableViewCell
//话题详细
@property (strong ,nonatomic)Item_HotTopicDetail * hotTopicDetail;

@property (weak, nonatomic) IBOutlet UILabel *day;
@property (weak, nonatomic) IBOutlet UILabel *isClose;
@property (weak, nonatomic) IBOutlet UILabel *petName;
@property (weak, nonatomic) IBOutlet UILabel *childAge;
@property (weak, nonatomic) IBOutlet UIImageView *authorPhotoIV;
@property (weak, nonatomic) IBOutlet UIButton *location;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *TopicNameLabel;
@property (weak, nonatomic) IBOutlet UIView *otherView;
@property (weak, nonatomic) IBOutlet UIImageView *clickGood;
@property (weak, nonatomic) IBOutlet UIImageView *commentIV;

@property (weak, nonatomic) IBOutlet UIView *imageGroupView;



@property (strong, nonatomic) TQRichTextView *TopicContent;

@property (strong, nonatomic) NSArray * imageGroup;
@property (weak, nonatomic) IBOutlet UIImageView *iv1;
@property (weak, nonatomic) IBOutlet UIImageView *iv2;

@property (weak, nonatomic) IBOutlet UIImageView *iv3;

@property (weak, nonatomic) IBOutlet UIImageView *iv4;

@property (weak, nonatomic) IBOutlet UIImageView *iv5;
@property (weak, nonatomic) IBOutlet UIImageView *iv6;
@property (weak, nonatomic) IBOutlet UIImageView *iv7;
@property (weak, nonatomic) IBOutlet UIImageView *iv8;
@property (weak, nonatomic) IBOutlet UIImageView *iv9;
@property (strong, nonatomic) NSMutableArray * ivArr;


@end
