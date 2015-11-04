//
//  CKWeatherModel.h
//  CKWeather
//
//  Created by KevinCai on 15/10/23.
//  Copyright © 2015年 KevinCai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKWeatherModel : NSObject
// 城市的名字
// 图片的URL
// 当前天气的描述
// 当前天气的温度
// 最高、最低温度
// 针对每小时的时间
// 针对每天的日期
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSURL *iconURL;
@property (nonatomic, strong) NSString *weatherCondition;
@property (nonatomic, strong) NSString *temp_C;
@property (nonatomic, strong) NSString *maxtemp_C;
@property (nonatomic, strong) NSString *mintemp_C;
@property (nonatomic, strong) NSString *timeStr;
@property (nonatomic, strong) NSString *dateStr;

// 给定每小时的字典，返回解析好的模型对象
+ (id)weatherWithHourly:(NSDictionary *)hourlyDic;
// 给定每天的字典，返回解析好的模型对象
+ (id)weatherWithDaily:(NSDictionary *)dailyDic;

+ (id)weatherWithHeader:(NSDictionary *)headerDic;
@end
