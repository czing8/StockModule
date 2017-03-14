//
//  VStockManager.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VStockView.h"
#import "VScrollMenuView.h"
#import "VTimeLineView.h"
#import "VKLineView.h"
#import "StockRequest.h"

#import "VGCDTimer.h"

#import "Masonry.h"

@interface VStockView () <VScrollMenuViewDelegate>

@property (nonatomic, strong) VScrollMenuView * scrollMenu;      // 顶部选择菜单

@property (nonatomic, strong) VTimeLineView * timeLineView;    //分时图
@property (nonatomic, strong) VKLineView    * dayKLineView;    //日K图
@property (nonatomic, strong) VKLineView    * weekKLineView;    //日K图
@property (nonatomic, strong) VKLineView    * monthKLineView;    //日K图

@property (nonatomic, strong) VTimeLineGroup    * timeLineGroup;    //分时图数据源
@property (nonatomic, strong) VLineGroup        * dayLineGroup;     //日k线图数据源
@property (nonatomic, strong) VLineGroup        * weekLineGroup;    //周k线图数据源
@property (nonatomic, strong) VLineGroup        * monthLineGroup;   //月k线图数据源

@property (nonatomic, strong) VGCDTimer * gcdTimer;

@end

@implementation VStockView

#pragma mark - View Lifecycle

- (void)dealloc {
    [_gcdTimer invalidate];
}

- (instancetype)init {
    if (self = [super init]) {
        _stockChartType = VStockChartTypeTimeLine;

        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    
    _scrollMenu = [[VScrollMenuView alloc]initWithTitles:@[@"分时", @"日K", @"周K", @"月K"] layoutStyle:VScrollMenuLayoutStyleInScreen];
    [self addSubview:_scrollMenu];
    [_scrollMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@43);
    }];
    _scrollMenu.delegate = self;

    [self addSubview:self.timeLineView];
    [self addSubview:self.dayKLineView];
    [self addSubview:self.weekKLineView];
    [self addSubview:self.monthKLineView];
    
    _timeLineView.backgroundColor = [UIColor stockMainBgColor];
    _dayKLineView.backgroundColor = [UIColor stockMainBgColor];
    _weekKLineView.backgroundColor = [UIColor stockMainBgColor];
    _monthKLineView.backgroundColor = [UIColor stockMainBgColor];
    
    [_timeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(44);
        make.left.right.mas_equalTo(0);
        make.height.equalTo(self).offset(-46);
    }];
    
    [_dayKLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(44);
        make.left.right.mas_equalTo(0);
        make.height.equalTo(self).offset(-46);
    }];
    
    [_weekKLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(44);
        make.left.right.mas_equalTo(0);
        make.height.equalTo(self).offset(-46);
    }];
    
    [_monthKLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(44);
        make.left.right.mas_equalTo(0);
        make.height.equalTo(self).offset(-46);
    }];
    
//    _timeLineView.hidden = YES;
    _dayKLineView.hidden = YES;
    _weekKLineView.hidden = YES;
    _monthKLineView.hidden = YES;
    
    
    __weak typeof(self) weakSelf = self;
    
    _gcdTimer = [VGCDTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^{
        [weakSelf reloadDataCompletion:nil];
    }];

}


#pragma mark - Public

- (void)reloadDataCompletion:(void(^)(BOOL success))completion {
    
    if (_stockChartType == VStockChartTypeTimeLine) {
        _timeLineView.hidden = NO;
        
        [StockRequest getTimeStockDataSuccess:^(VTimeLineGroup *response) {
            _timeLineGroup = response;
            if (self.stockStatusBlock) {
                self.stockStatusBlock(_timeLineGroup.stockStatusModel);
            }
            [_timeLineView reloadWithGroup:_timeLineGroup];
//            completion(YES);
            if (completion) {
                completion(YES);
            }
        }];
    }
    else if (_stockChartType == VStockChartTypeDayLine) {
        _dayKLineView.hidden = NO;
        
        [StockRequest getDayStockDataSuccess:^(VLineGroup *response) {
            NSLog(@"count:%lu", (unsigned long)response.lineModels.count);
            _dayLineGroup = response;
            if (self.stockStatusBlock) {
                self.stockStatusBlock(_dayLineGroup.stockStatusModel);
            }
            if (completion) {
                completion(YES);
            }

//            [_dayKLineView reloadWithGroup:_dayLineGroup];
        }];
    }
    else if (_stockChartType == VStockChartTypeWeekLine) {
        _weekKLineView.hidden = NO;
        
        [StockRequest getWeekStockDataSuccess:^(VLineGroup *response) {
            NSLog(@"count:%lu", (unsigned long)response.lineModels.count);
            _weekLineGroup = response;
            if (self.stockStatusBlock) {
                self.stockStatusBlock(_weekLineGroup.stockStatusModel);
            }
            if (completion) {
                completion(YES);
            }

//            [_weekKLineView reloadWithGroup:_weekLineGroup];
        }];
    }
    else if (_stockChartType == VStockChartTypeMonthLine) {
        _monthKLineView.hidden = NO;
        
        [StockRequest getMonthStockDataSuccess:^(VLineGroup *response) {
            NSLog(@"count:%lu", (unsigned long)response.lineModels.count);
            _monthLineGroup = response;
            if (self.stockStatusBlock) {
                self.stockStatusBlock(_monthLineGroup.stockStatusModel);
            }
            if (completion) {
                completion(YES);
            }

//            [_monthKLineView reloadWithGroup:_monthLineGroup];
        }];
    }
}


#pragma mark - Actions


#pragma mark - Properties

//- (VScrollMenuView *)scrollMenu {
//    if (_scrollMenu == nil) {
//        _scrollMenu = [[VScrollMenuView alloc] init];
//    }
//    return _scrollMenu;
//}

- (VTimeLineView *)timeLineView {
    if (_timeLineView == nil) {
        _timeLineView = [[VTimeLineView alloc] init];
    }
    return _timeLineView;
}

- (VKLineView *)dayKLineView {
    if (_dayKLineView == nil) {
        _dayKLineView = [[VKLineView alloc] init];
    }
    return _dayKLineView;
}

- (VKLineView *)weekKLineView {
    if (_weekKLineView == nil) {
        _weekKLineView = [[VKLineView alloc] init];
    }
    return _weekKLineView;
}


- (VKLineView *)monthKLineView {
    if (_monthKLineView == nil) {
        _monthKLineView = [[VKLineView alloc] init];
    }
    return _monthKLineView;
}


- (void)setStockChartType:(VStockChartType)stockChartType {
    _stockChartType = stockChartType;
    
    _timeLineView.hidden = YES;
    _dayKLineView.hidden = YES;
    _weekKLineView.hidden = YES;
    _monthKLineView.hidden = YES;
    
    [self reloadDataCompletion:^(BOOL success) {
        if (success == YES) {
            if (_stockChartType == VStockChartTypeDayLine) {
                [_dayKLineView reloadWithGroup:_dayLineGroup];
            }
            else if (_stockChartType == VStockChartTypeWeekLine) {
                [_weekKLineView reloadWithGroup:_weekLineGroup];
            }
            else if (_stockChartType == VStockChartTypeMonthLine) {
                [_monthKLineView reloadWithGroup:_monthLineGroup];
            }
        }
    }];
}


#pragma mark - ScrollMenuDelegate

- (void)scrollMenu:(VScrollMenuView *)scrollMenu didSelectedIndex:(NSInteger)index {
    self.stockChartType = index;
}



#pragma mark - Helpers



#pragma mark - HttpRequest








@end
