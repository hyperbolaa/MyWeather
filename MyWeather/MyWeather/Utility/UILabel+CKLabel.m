//
//  UILabel+CKLabel.m
//  CKWeather
//
//  Created by KevinCai on 15/10/23.
//  Copyright © 2015年 KevinCai. All rights reserved.
//

#import "UILabel+CKLabel.h"

@implementation UILabel (CKLabel)
+ (UILabel *)labelWithFrameByCategory:(CGRect)frame{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    return label;
}
@end
