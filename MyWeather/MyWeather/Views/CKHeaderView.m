//
//  CKHeaderView.m
//  CKWeather
//
//  Created by KevinCai on 15/10/23.
//  Copyright © 2015年 KevinCai. All rights reserved.
//

#import "CKHeaderView.h"
#import "UILabel+CKLabel.h"

@implementation CKHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
static CGFloat inset = 20; // 左右的边界
static CGFloat temperatureHeight = 110; // 当前温度label的高度
static CGFloat labelHeight = 40;
static CGFloat statusBarHeight = 20;

// 重写父类的初始化方法
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        // 添加5个控件
        CGRect cityFrame = CGRectMake(0, statusBarHeight, frame.size.width, labelHeight);
//        self.cityLabel = [[UILabel alloc]initWithFrame:cityFrame];
//        // 字体
//        self.cityLabel.font = [UIFont fontWithName:@"h" size:20];
//        self.cityLabel.textColor = [UIColor whiteColor];
//        self.cityLabel.textAlignment = NSTextAlignmentCenter;
        
        self.cityLabel = [UILabel labelWithFrameByCategory:cityFrame];
        self.cityLabel.text = @"Loading...";
        self.cityLabel.font = [UIFont fontWithName:@"Futura-MediumItalic" size:25];
        // 添加到视图上
        [self addSubview:self.cityLabel];
        // test
        self.cityLabel.backgroundColor = [UIColor lightGrayColor];
        
        // 最低最高温label
        CGRect hiloFrame = CGRectMake(inset, frame.size.height-labelHeight, frame.size.width-2*inset, labelHeight);
        self.hiloLabel = [UILabel labelWithFrameByCategory:hiloFrame];
        self.hiloLabel.text = @"15˚ / 27˚";
        self.hiloLabel.font = [UIFont fontWithName:@"Futura-MediumItalic" size:30];
        [self addSubview:self.hiloLabel];
        // test CH010652976 29242609
        self.hiloLabel.backgroundColor = [UIColor purpleColor];
        
        // 当前温度label
        CGRect tempFrame = CGRectMake(inset, frame.size.height-(labelHeight+temperatureHeight), frame.size.width-2*inset, temperatureHeight);
        self.temperatureLabel = [UILabel labelWithFrameByCategory:tempFrame];
        self.temperatureLabel.text = @"18˚";
        self.temperatureLabel.font = [UIFont fontWithName:@"Futura-MediumItalic" size:100];
        [self addSubview:self.temperatureLabel];
        // test
        self.temperatureLabel.backgroundColor = [UIColor blueColor];
        
        // 天气图标imageView
        CGRect iconFrame = CGRectMake(inset, tempFrame.origin.y-labelHeight, labelHeight, labelHeight);
        self.iconView = [[UIImageView alloc]initWithFrame:iconFrame];
        [self addSubview:self.iconView];
        
        // 天气描述label
        CGRect conditionFrame = CGRectMake(inset+labelHeight, iconFrame.origin.y, frame.size.width-2*inset-labelHeight, labelHeight);
        self.conditionLabel = [UILabel labelWithFrameByCategory:conditionFrame];
        self.conditionLabel.text = @"Sunny";
        self.conditionLabel.font = [UIFont fontWithName:@"Futura-MediumItalic" size:25];
        [self addSubview:self.conditionLabel];
        // test
        self.conditionLabel.backgroundColor = [UIColor redColor];
    }
    return self;
}


















@end
