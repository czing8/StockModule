//
//  VFiveDayLineView.m
//  HBStockView
//
//  Created by Vols on 2017/3/8.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VFiveDayLineView.h"
#import "VFiveDayChart.h"
#import "VFiveDayVolumeView.h"
#import "VStockScrollView.h"

#import "VTimeLineGroup.h"


@interface VFiveDayLineView ()

@property (nonatomic, strong) VStockScrollView      * stockScrollView;      // 背景
@property (nonatomic, strong) VFiveDayChart         * timeLineChart;        // 分时线图表

@property (nonatomic, strong) VFiveDayVolumeView    * volumeView;           // 成交量部分


@end


@implementation VFiveDayLineView{
    
    CGFloat _maxValue;      //图表最大的价格
    CGFloat _minValue;      //图表最小的价格
    
    CGFloat _volumeValue;       //图表最大的成交量
}


- (void)reloadWithGroup:(NSArray *)fiveDayDataArray {
    
}


#pragma mark - Properties

- (VStockScrollView *)stockScrollView {
    if (_stockScrollView == nil) {
        _stockScrollView = [VStockScrollView new];
        _stockScrollView.stockType = VStockChartTypeTimeLine;
        _stockScrollView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        _stockScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _stockScrollView;
}


@end
