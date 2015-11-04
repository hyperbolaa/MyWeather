//
//  CKMainViewController.m
//  CKWeather
//
//  Created by KevinCai on 15/10/22.
//  Copyright (c) 2015年 KevinCai. All rights reserved.
//

#import "CKMainViewController.h"
#import "CKHeaderView.h"
#import "CKWeatherModel.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"

@interface CKMainViewController ()<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>
// 背景视图snippet
// tableView
// 每小时数组(CKWeatherModel)
// 每天数组(CKWeather)
// 存储操作对象的队列
// 存储每个cell的图片
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *hourlyArray;
@property (nonatomic, strong) NSArray *dailyArray;
@property (nonatomic, strong) CKHeaderView *headerView;
@property (nonatomic, unsafe_unretained) BOOL hadLoad;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *cellImageDic;
@property (nonatomic, strong) NSFileManager *fileMgr;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *imagePath;
@end

@implementation CKMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建tableView
    [self setUpTableView];
    
    //创建头部视图
    [self setUpHeaderView];
    
    // 获取服务器的JSON格式数据(解析/模型类)
    [self getJSONData];
}

#pragma mark --- MemoryWarning
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // 将非主队列中的操作对象清除
    [self.queue cancelAllOperations];
    
    // 将字典中的对象清除
    [self.cellImageDic removeAllObjects];
}

- (void)getJSONData{
    // 创建NSURLRequest对象
    // 获取单例对象NSURLSession
    // 创建数据任务对象，发送请求
    // 手动启动任务
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.worldweatheronline.com/premium/v1/weather.ashx?q=nanjing&num_of_days=5&format=json&tp=6&key=12ed14639744d5bb00f329e250b37"]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 获取状态码
        // 解析JSON (NSData -> NSDictionary,NSArray)
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            NSLog(@"GetJSON");
            self.hadLoad = NO;
            NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            // 创建模型类 (头部视图/每小时/每天)
            // 将服务器返回的weatherDic解析，赋值给每小时数组、每天数组
            self.hourlyArray = [self weatherFromJSON:weatherDic isHourly:YES];
            self.dailyArray = [self weatherFromJSON:weatherDic isHourly:NO];
            
            // 回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                // 刷新tableView
                [self.tableView reloadData];
                // 解析头部视图需要的value；并更新头部视图
                [self updateHeaderView:weatherDic[@"data"]];
            });
        }
    }];
    // 执行任务
    [task resume];
}



#pragma mark --- ParseJSON
// 解析头部视图需要的数据
- (void)updateHeaderView:(NSDictionary *)JSONDic{
    // 使用JSONDic对象，调用模型类的方法解析
    // 将解析完的模型对象赋值给头部视图5个控件
    CKWeatherModel *weather = [CKWeatherModel weatherWithHeader:JSONDic];
    self.headerView.cityLabel.text = weather.cityName;
    NSData *iconData = [NSData dataWithContentsOfURL:weather.iconURL];
    self.headerView.iconView.image = [UIImage imageWithData:iconData];
    self.headerView.conditionLabel.text = weather.weatherCondition;
    self.headerView.temperatureLabel.text = [NSString stringWithFormat:@"%@˚",weather.temp_C];
    self.headerView.hiloLabel.text = [NSString stringWithFormat:@"%@˚ / %@˚",weather.mintemp_C,weather.maxtemp_C];
}

- (NSArray *)weatherFromJSON:(NSDictionary *)JSONDic isHourly:(BOOL)isHourly{
    // 循环解析(每小时/每天)
    NSDictionary *dataDic = JSONDic[@"data"];
    NSArray *dailyArray = dataDic[@"weather"];
    NSArray *hourlyArray = dailyArray[0][@"hourly"];
    // 声明两个临时的可变数组
    NSMutableArray *hourlyMutableArray = [NSMutableArray array];
    NSMutableArray *dailyMutableArray = [NSMutableArray array];
    if (isHourly) {
        // 每小时数据解析
        for (NSDictionary *hourlyDic in hourlyArray) {
            CKWeatherModel *weather = [CKWeatherModel weatherWithHourly:hourlyDic];
            [hourlyMutableArray addObject:weather];
        }
    }else{
        // 每天解析
        for (NSDictionary *dailyDic in dailyArray) {
            CKWeatherModel *weather = [CKWeatherModel weatherWithDaily:dailyDic];
            [dailyMutableArray addObject:weather];
        }
    }
    // 返回解析后的数组(三目运算符)
    return isHourly ? [hourlyMutableArray copy] : [dailyMutableArray copy];
}


#pragma mark --- HeaderView/TableView
- (void)setUpHeaderView{
    // 创建自定义头部视图
    self.headerView = [[CKHeaderView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    // 设置成tableView的headerView
    self.tableView.tableHeaderView = self.headerView;
}

- (void)setUpTableView {
    //创建显示背景图片的UIImageView
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.image = [UIImage imageNamed:@"bg.png"];
    //添加到view上
    [self.view addSubview:self.imageView];
    //创建tableView; 设置代理等
    self.tableView = [UITableView new];
    self.tableView.frame = self.view.bounds;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //设置tableView的分割线
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    //设置tableView的分页属性
    self.tableView.pagingEnabled = YES;
    //添加到view上
    [self.view addSubview:self.tableView];
}

#pragma mark --- UITableViewDataSource/UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.hourlyArray.count + 1 : self.dailyArray.count + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //创建静态标识
    static NSString *identifier = @"cell";
    //从缓存池中获取tableViewCell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //没有就创建
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    //设置cell的背景颜色
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    //设置cell无法点中
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //设置cell的文本颜色
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"Futura-MediumItalic" size:28];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Futura-MediumItalic" size:28];
    //设置cell一些属性
    // 加载数据
    [self tableViewCell:cell andIndexPath:indexPath];
    //返回cell
    return cell;
}

#pragma mark --- DisplayData
- (void)tableViewCell:(UITableViewCell *)cell andIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //每小时的天气
        if (indexPath.row == 0) {
            // 简单设置第0行的文本
            cell.imageView.image = nil;
            cell.textLabel.text = @"Hourly Forecast Info.";
            cell.detailTextLabel.text = nil;
        }else{
            // 设置每小时的数据(hourlyArray)
            CKWeatherModel *weather = self.hourlyArray[indexPath.row - 1];
            // 设置每小时图片
            //[self configCellImage:cell withWeather:weather];
            [cell.imageView sd_setImageWithURL:weather.iconURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
            
            // 设置图片、textLabel、detailLabel
            cell.textLabel.text = weather.timeStr;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@˚",weather.temp_C];
        }
    } else {
        //每天的天气
        if (indexPath.row == 0) {
            cell.imageView.image = nil;
            cell.detailTextLabel.text = nil;
            cell.textLabel.text = @"Daily Forecast Info.";
        }else{
            CKWeatherModel *weather = self.dailyArray[indexPath.row - 1];
            // 设置每天的图片
            //[self configCellImage:cell withWeather:weather];
            
            // 使用SDWebImage下载图片(缓存)
            [cell.imageView sd_setImageWithURL:weather.iconURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
            
            // 获取模型对象
            // 图片URL、日期、最高温度、最低温度
            cell.textLabel.text = [weather.dateStr substringFromIndex:5];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@˚ / %@˚",weather.mintemp_C,weather.maxtemp_C];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 获取不同section对应的行数
    
    //
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return [UIScreen mainScreen].bounds.size.height / cellCount;
}


#pragma mark ---ConfigCellImage
- (void)configCellImage:(UITableViewCell *)cell withWeather:(CKWeatherModel *)weather{
    // 造成主线程阻塞
    //cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:weather.iconURL]];
    /*
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        // 下载图片
        NSData  *imageData = [NSData dataWithContentsOfURL:weather.iconURL];
        // 回到主线程更新UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            cell.imageView.image = [UIImage imageWithData:imageData];
        }];
    }];
    // 添加操作对象到非主队列中
    [self.queue addOperation:operation];
     */
    
    // 图片缓存
    
    // 从内存字典中读取
    NSData *MorData = self.cellImageDic[weather.iconURL];
    if (MorData) {
        // 设置cellImage
        cell.imageView.image = [UIImage imageWithData:MorData];
    }else{
        // 从沙盒中取
        NSString *filePath = [self getFilePath:weather];
        NSData *sanBoxData = [NSData dataWithContentsOfFile:filePath];
        if (sanBoxData) {
            // 设置cellImage
            cell.imageView.image = [UIImage imageWithData:sanBoxData];
        }else{
            // 设置cell的占位图片
            cell.imageView.image = [UIImage imageNamed:@"placeholder"];
            // 下载图片
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                // 下载图片
                NSData  *imageData = [NSData dataWithContentsOfURL:weather.iconURL];
                // 回到主线程更新UI
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    cell.imageView.image = [UIImage imageWithData:imageData];
                    // 存储已经下载好的图片(内存字典/沙盒)
                    self.cellImageDic[weather.iconURL] = imageData;
                    NSString *filePath = [self getFilePath:weather];
                    [imageData writeToFile:filePath atomically:YES];
                }];
            }];
            // 添加操作对象到非主队列中
            [self.queue addOperation:operation];
        }
    }
}

#pragma mark --- RefreshTableView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(getJSONData)];
    // 设置普通状态的动画图片
    [header setImages:@[[UIImage imageNamed:@"weather-broken"]] forState:MJRefreshStateIdle];
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    [header setImages:@[[UIImage imageNamed:@"weather-clear"]] forState:MJRefreshStatePulling];
    // 设置正在刷新状态的动画图片
    [header setImages:@[[UIImage imageNamed:@"weather-few-night"]] forState:MJRefreshStateRefreshing];
    // 设置header
    self.tableView.header = header;
}

//// 点击状态栏刷新
//- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
//    [self getJSONData];
//}
//
//// 下拉刷新
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    scrollView.delegate = self;
//    if (!self.hadLoad && scrollView.contentOffset.y <= -50) {
//        [self getJSONData];
//        self.hadLoad = YES;
//        
//    }
//}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    scrollView.contentInset = UIEdgeInsetsMake(90, 0, 0, 0);
//    scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(90, 0, 0, 0);
//    if (scrollView.contentOffset.y <= -40) {
//        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
//            scrollView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
//        } completion:^(BOOL finished) {
//            //scrollView.contentInset = UIEdgeInsetsZero;
//        }];
//    }
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    scrollView.contentInset = UIEdgeInsetsZero;
//}

#pragma mark --- GetFilePath
- (NSString *)getFilePath:(CKWeatherModel *)weather{
    NSString *imagePath = [self.filePath stringByAppendingPathComponent:[weather.iconURL lastPathComponent]];
    return imagePath;
}

#pragma mark --- LazyInstantiate
- (NSOperationQueue *)queue{
    if (!_queue) {
        _queue = [NSOperationQueue new];
    }
    return _queue;
}

- (NSMutableDictionary *)cellImageDic{
    if (!_cellImageDic) {
        _cellImageDic = [NSMutableDictionary dictionary];
    }
    return _cellImageDic;
}

- (NSFileManager *)fileMgr{
    if (!_fileMgr) {
        _fileMgr = [NSFileManager defaultManager];
    }
    return _fileMgr;
}

- (NSString *)filePath{
    if (!_filePath) {
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        [self.fileMgr createDirectoryAtPath:[cachesPath stringByAppendingString:@"images"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return _filePath;
}
@end
