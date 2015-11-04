//
//  CKWeatherModel.m
//  CKWeather
//
//  Created by KevinCai on 15/10/23.
//  Copyright © 2015年 KevinCai. All rights reserved.
//

#import "CKWeatherModel.h"

@implementation CKWeatherModel

- (instancetype)initWithHourly:(NSDictionary *)hourlyDic{
    if (self = [super init]) {
        // 图片的URL
        // 时间
        // 当前时间的温度
        self.temp_C = hourlyDic[@"tempC"];
        NSInteger time = [hourlyDic[@"time"] integerValue]/100;
        self.timeStr = [NSString stringWithFormat:@"%ld:00",(long)time];
        self.iconURL = [NSURL URLWithString:hourlyDic[@"weatherIconUrl"][0][@"value"]];
    }
    return self;
}

- (instancetype)initWithDaily:(NSDictionary *)dailyDic{
    if (self = [super init]) {
        // 日期
        // 最高温度
        // 最低温度
        // 图片URL(从hourly对应的第一项获取)
        self.dateStr = dailyDic[@"date"];
        self.maxtemp_C = dailyDic[@"maxtempC"];
        self.mintemp_C = dailyDic[@"mintempC"];
        self.iconURL = [NSURL URLWithString:dailyDic[@"hourly"][1][@"weatherIconUrl"][0][@"value"]];
    }
    return self;
}

- (instancetype)initWithHeader:(NSDictionary *)headerDic{
    if (self = [super init]) {
        // 城市名字、iconURL、天气描述、天气温度、最高/最低温度
        self.cityName = headerDic[@"request"][0][@"query"];
        
        self.iconURL = [NSURL URLWithString:headerDic[@"current_condition"][0][@"weatherIconUrl"][0][@"value"]];
        self.weatherCondition = headerDic[@"current_condition"][0][@"weatherDesc"][0][@"value"];
        self.temp_C = headerDic[@"current_condition"][0][@"temp_C"];
        self.maxtemp_C = headerDic[@"weather"][0][@"maxtempC"];
        self.mintemp_C = headerDic[@"weather"][0][@"mintempC"];
    }
    return self;
}

+ (id)weatherWithHeader:(NSDictionary *)headerDic{
    return [[self alloc]initWithHeader:headerDic];
}

+ (id)weatherWithHourly:(NSDictionary *)hourlyDic{
    return [[self alloc]initWithHourly:hourlyDic];
}

+ (id)weatherWithDaily:(NSDictionary *)dailyDic{
    return [[self alloc]initWithDaily:dailyDic];
}

@end
