//
//  VStockManager.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VVStockView.h"
#import "VScrollMenuView.h"
#import "VTimeLineView.h"
#import "VKLineView.h"
#import "VHKStockYearView.h"

#import "StockRequest.h"

#import "VGCDTimer.h"
#import "VDateTool.h"
#import "Masonry.h"

@interface VVStockView () <VScrollMenuViewDelegate>

@property (nonatomic, strong) NSString  * stockCode;

@property (nonatomic, strong) VScrollMenuView * scrollMenu;      // 顶部选择菜单

@property (nonatomic, strong) VTimeLineView * timeLineView;     //分时图
@property (nonatomic, strong) VKLineView    * dayKLineView;     //日K图
@property (nonatomic, strong) VKLineView    * weekKLineView;    //日K图
@property (nonatomic, strong) VKLineView    * monthKLineView;   //日K图
@property (nonatomic, strong) VHKStockYearView  * hkStockYearView;  //港股年线图

@property (nonatomic, strong) VStockGroup   * timeLineGroup;    //分时图数据源
@property (nonatomic, strong) VStockGroup   * dayLineGroup;     //日k线图数据源
@property (nonatomic, strong) VStockGroup   * weekLineGroup;    //周k线图数据源
@property (nonatomic, strong) VStockGroup   * monthLineGroup;   //A股月k,HK年K 的数据源

@property (nonatomic, strong) VGCDTimer     * gcdTimer;
@property (nonatomic, assign) float         refreshTime;  //修改股票刷新时间

@property (nonatomic, assign) VStockFuQuanType  fuQuanType;

@end

@implementation VVStockView

#pragma mark - View Lifecycle

- (void)dealloc {
    [_gcdTimer invalidate];
}

- (instancetype)initWithStockCode:(NSString *)stockCode stockType:(VStockType)stockType {
    if (self = [super init]) {
        
        _stockChartType = VStockChartTypeTimeLine;      //默认 分时图
        _fuQuanType = VStockFuQuanTypeNone;
        _refreshTime    = 5.f;
        
        _stockCode  = stockCode;
        _stockType  = stockType;
        [self configureViews];
    }
    return self;
}


- (void)configureViews {
    
    NSArray * titles = @[@"分时", @"日K", @"周K", @"月K"];
    if (_stockType == VStockTypeHK) {
        titles = @[@"分时", @"日K", @"周K", @"1年"];
    }
    
    _scrollMenu = [[VScrollMenuView alloc]initWithTitles:titles layoutStyle:VScrollMenuLayoutStyleInScreen];
    [self addSubview:_scrollMenu];
    [_scrollMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@43);
    }];
    _scrollMenu.delegate = self;

    [self addSubview:self.timeLineView];
    [self addSubview:self.dayKLineView];
    [self addSubview:self.weekKLineView];
    
    _timeLineView.backgroundColor = [UIColor stockMainBgColor];
    _dayKLineView.backgroundColor = [UIColor stockMainBgColor];
    _weekKLineView.backgroundColor = [UIColor stockMainBgColor];
    
    [_timeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(44);
        make.left.right.mas_equalTo(0);
        make.height.equalTo(self).offset(-46);
    }];
    
    [_dayKLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_timeLineView);
    }];
    
    [_weekKLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_timeLineView);
    }];
    
    
    __weak typeof(self) weakSelf = self;
    _dayKLineView.fuQuanStatusBlock = ^(VStockFuQuanType fuQuanType){
        weakSelf.fuQuanType = fuQuanType;
    };
    
    _weekKLineView.fuQuanStatusBlock = ^(VStockFuQuanType fuQuanType){
        weakSelf.fuQuanType = fuQuanType;
    };
    
    if (_stockType == VStockTypeCN) {
        [self addSubview:self.monthKLineView];
        _monthKLineView.backgroundColor = [UIColor stockMainBgColor];
        _monthKLineView.hidden = YES;

        [_monthKLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_timeLineView);
        }];
        
        _monthKLineView.fuQuanStatusBlock = ^(VStockFuQuanType fuQuanType){
            weakSelf.fuQuanType = fuQuanType;
        };
    }
    else if (_stockType == VStockTypeHK) {
        [self addSubview:self.hkStockYearView];
        _hkStockYearView.backgroundColor = [UIColor stockMainBgColor];
        [_hkStockYearView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_timeLineView);
        }];
        _hkStockYearView.hidden = YES;
    }
    
//    _timeLineView.hidden = YES;
    _dayKLineView.hidden = YES;
    _weekKLineView.hidden = YES;
    
    _gcdTimer = [VGCDTimer scheduledTimerWithTimeInterval:_refreshTime repeats:YES block:^{
        [weakSelf reloadStockData];
    }];
}


#pragma mark - Public

- (void)reloadStockData{
    
    if (_stockChartType == VStockChartTypeTimeLine) {
        _timeLineView.hidden = NO;
        
        [_timeLineView reloadWithStockCode:_stockCode success:^(VStockGroup *stockGroup) {
            _timeLineGroup = stockGroup;
            if (self.stockStatusBlock) {
                self.stockStatusBlock(_timeLineGroup.stockStatusModel);
            }
        }];
    }
    
    if (![self checkDate]) {
        [_gcdTimer invalidate];
        _gcdTimer = nil;
    }
}


#pragma mark - Actions


#pragma mark - Properties

- (VTimeLineView *)timeLineView {
    if (_timeLineView == nil) {
        _timeLineView = [[VTimeLineView alloc] initWithType:_stockType];
    }
    return _timeLineView;
}

- (VKLineView *)dayKLineView {
    if (_dayKLineView == nil) {
        _dayKLineView = [[VKLineView alloc] initWithChartType:VStockChartTypeDayLine];
    }
    return _dayKLineView;
}

- (VKLineView *)weekKLineView {
    if (_weekKLineView == nil) {
        _weekKLineView = [[VKLineView alloc] initWithChartType:VStockChartTypeWeekLine];
    }
    return _weekKLineView;
}


- (VKLineView *)monthKLineView {
    if (_monthKLineView == nil) {
        _monthKLineView = [[VKLineView alloc] initWithChartType:VStockChartTypeMonthLine];
    }
    return _monthKLineView;
}

- (VHKStockYearView *)hkStockYearView {
    if (_hkStockYearView == nil) {
        _hkStockYearView = [[VHKStockYearView alloc] init];
    }
    return _hkStockYearView;
}


- (void)setRefreshTime:(float)refreshTime {
    if (refreshTime > 0) {
        _refreshTime = refreshTime;
        
        [_gcdTimer setTimeInterval:refreshTime];
    }
}


- (void)setStockChartType:(VStockChartType)stockChartType {
    _stockChartType = stockChartType;
    
    _timeLineView.hidden = YES;
    _dayKLineView.hidden = YES;
    _weekKLineView.hidden = YES;
    if (_monthKLineView != nil)     _monthKLineView.hidden = YES;
    if (_hkStockYearView != nil)    _hkStockYearView.hidden = YES;
    
//    if (_stockChartType == VStockChartTypeTimeLine) {
//        _timeLineView.hidden = NO;
//        [_timeLineView reloadWithGroup:_timeLineGroup];
//    }
//    else
    
    if (_stockChartType == VStockChartTypeDayLine) {
        _dayKLineView.hidden = NO;
        [_dayKLineView reloadData:_stockCode fuQuan:_fuQuanType];
    }
    else if (_stockChartType == VStockChartTypeWeekLine) {
        _weekKLineView.hidden = NO;
        [_weekKLineView reloadData:_stockCode fuQuan:_fuQuanType];
    }
    else if (_stockChartType == VStockChartTypeMonthLine) {
        _monthKLineView.hidden = NO;
        [_monthKLineView reloadData:_stockCode fuQuan:_fuQuanType];
    }
    else if (_stockChartType == VStockChartTypeYearLine) {
        _hkStockYearView.hidden = NO;
        [_hkStockYearView reloadData:_stockCode fuQuan:_fuQuanType];
    }
    
    [self reloadStockData];
}

#pragma mark - ScrollMenuDelegate

- (void)scrollMenu:(VScrollMenuView *)scrollMenu didSelectedIndex:(NSInteger)index {
    if (_stockType == VStockTypeCN) {
        self.stockChartType = index;
    }
    else if (_stockType == VStockTypeHK) {
        if (index < 3) {
            self.stockChartType = index;
        }
        else if (index == 3) {
            self.stockChartType = VStockChartTypeYearLine;
        }
    }
}

#pragma mark - Helpers

- (BOOL)checkDate {
//    return YES;

    if ([VDateTool getNowWeekday] == 1 || [VDateTool getNowWeekday] == 7) {
        return NO;
    }
    
    return ([VDateTool isBetweenFromHour:9 :20 toHour:12 :1] || [VDateTool isBetweenFromHour:13 :0 toHour:16 :20]);
}

@end
