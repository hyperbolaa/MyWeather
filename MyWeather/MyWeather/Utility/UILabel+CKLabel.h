//
//  UILabel+CKLabel.h
//  CKWeather
//
//  Created by KevinCai on 15/10/23.
//  Copyright © 2015年 KevinCai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (CKLabel)

// 给定label的frame，返回一个已经创建好的UILabel
+ (UILabel *)labelWithFrameByCategory:(CGRect)frame;
@end
