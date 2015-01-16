//
//  NavItem.m
//  if_wapeng
//
//  Created by 心 猿 on 14-12-12.
//  Copyright (c) 2014年 funeral. All rights reserved.
//

#import "NavItem.h"

@implementation NavItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
//        self.titleLabel.backgroundColor = [UIColor greenColor];
        self.titleLabel.textColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
    }
    return self;
}
-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageWidth = self.frame.size.width / 2;
    CGFloat imageHeight = self.frame.size.height;
    return CGRectMake(imageX, imageY, imageWidth, imageHeight);
}
-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = CGRectGetWidth(self.frame) / 2;
    CGFloat titleY = 0;
    CGFloat titleWidth = CGRectGetWidth(self.frame) / 2;
    CGFloat titleHeight = self.frame.size.height;
    
    return CGRectMake(titleX, titleY, titleWidth, titleHeight);
}

@end
