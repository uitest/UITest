//
//  Cell_ActivityDetail.m
//  if_wapeng
//
//  Created by 心 猿 on 14-9-1.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import "Cell_ActivityDetail.h"
#import "MyParserTool.h"
@implementation Cell_ActivityDetail

- (void)awakeFromNib
{
    // Initialization code
    self.headerImage.layer.masksToBounds = YES;
    self.headerImage.layer.cornerRadius = 4;
    self.headerImage.layer.borderWidth = 1;
    
//    self.detailLabel.numberOfLines = 0;
    
    self.detailLabel = [[TQRichTextView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.headerImage.frame) + 10, CGRectGetMaxY(self.contentLabel.frame) + 10, kMainScreenWidth - CGRectGetMaxX(self.headerImage.frame) - 10 - 20, 40)];
    
    self.detailLabel.textColor = [UIColor grayColor];
    
    [self addSubview:self.detailLabel];
    
    self.detailTextLabel.text = @"TQRichTextView";
    
//    self.detailLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.detailLabel.font = [UIFont systemFontOfSize:13];
    self.detailLabel.backgroundColor = [UIColor whiteColor];
    self.detailLabel.text = @"【海上生明月，天涯共此时。情人怨遥夜，竟夕起相思！海上生明月，天涯共此时。情人怨遥夜，竟夕起相思！海上生明月，天涯共此时。情人怨遥夜，竟夕起相思！】";
    self.headerImage.image = [UIImage imageNamed:@"saga.jpg"];
    
    self.cNameLabel.textColor = [UIColor redColor];
    
    self.discussLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.discussLabel.frame = CGRectMake(kMainScreenWidth - 100, CGRectGetMaxY(self.detailLabel.frame) + 5, 90, 35);
//    [self.discussLabel setImage:[UIImage imageNamed:@"pinglun2.png"] forState:UIControlStateNormal];
    
    [self addSubview:self.discussLabel];
    
    
    [self.discussLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.praiseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.praiseBtn.frame = CGRectMake(kMainScreenWidth -200, CGRectGetMaxY(self.detailLabel.frame) + 5, 90, 35);
    
    [self addSubview:self.praiseBtn];

}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
