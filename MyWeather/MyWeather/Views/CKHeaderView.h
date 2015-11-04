//
//  CKHeaderView.h
//  CKWeather
//
//  Created by KevinCai on 15/10/23.
//  Copyright © 2015年 KevinCai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKHeaderView : UIView
@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *conditionLabel;
@property (nonatomic, strong) UILabel *temperatureLabel;
@property (nonatomic, strong) UILabel *hiloLabel;
@end
