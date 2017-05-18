//
//  VHKStockYearView.m
//  HBStockView
//
//  Created by Vols on 2017/3/28.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VHKStockYearView.h"
#import "VStockScrollView.h"
#import "VLineChart.h"
#import "VLineVolumeView.h"
#import "VLineMaskView.h"

#import "UIColor+StockTheme.h"
#import "VStockGroup.h"
#import "Masonry.h"

@interface VHKStockYearView ()

@property (nonatomic, strong) VStockScrollView  * stockScrollView;  // 背景
@property (nonatomic, strong) VLineChart        * lineChart;        // 年线图
@property (nonatomic, strong) VLineVolumeView   * volumeView;       // 成交量部分
@property (nonatomic, strong) VLineMaskView     * maskView;

@property (nonatomic, strong) VStockGroup    * stockGroup;        // 数据源

@property (nonatomic, copy  ) NSArray <NSValue *> * drawLinePoints; // 位置数组

@property (nonatomic, strong) VLineModel    * selectLineModel;      //长按选中的model

@end

@implementation VHKStockYearView{
    
    CGFloat _maxValue;          // 图表最大的价格
    CGFloat _minValue;          // 图表最小的价格
    
    CGFloat _volumeValue;       // 图表最大的成交量
}

#pragma mark - Lifecycle

- (instancetype)init{
    self = [super init];
    if (self) {
        [self configureViews];
        _stockScrollView.userInteractionEnabled = YES;
    }
    return self;
}

- (void)configureViews {
    
    [self addSubview:self.stockScrollView];
    [_stockScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self);
        make.left.equalTo(self).offset(kStockScrollViewLeftGap);
        make.right.equalTo(self).offset(-kStockScrollViewLeftGap);
    }];
    
    // 分时图View
    _lineChart = [[VLineChart alloc] init];
    _lineChart.backgroundColor = [UIColor clearColor];
    [_stockScrollView.contentView addSubview:_lineChart];
    [_lineChart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_stockScrollView.contentView);
        make.left.equalTo(_stockScrollView.contentView);
        make.height.equalTo(_stockScrollView.contentView).multipliedBy([VStockChartConfig lineChartRadio]);
        make.width.equalTo(_stockScrollView);
    }];
    
    // 成交量View
    _volumeView = [[VLineVolumeView alloc] init];
    _volumeView.backgroundColor = [UIColor clearColor];
    [_stockScrollView.contentView addSubview:_volumeView];
    
    [_volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lineChart.mas_bottom).offset(2);
        make.left.right.equalTo(_stockScrollView.contentView);
        make.height.equalTo(_stockScrollView.contentView).multipliedBy([VStockChartConfig volumeViewRadio]);
    }];
    
    //长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
    [_stockScrollView addGestureRecognizer:longPress];
}


- (void)reloadWithGroup:(VStockGroup *)stockGroup {
    _stockGroup = stockGroup;
    
    [self layoutIfNeeded];
    [self updateScrollViewContentWidth];
    [self setNeedsDisplay];
}

#pragma mark - Draw Func

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.stockGroup.kLineModels.count > 0) {
        if (!self.maskView || self.maskView.isHidden) {
            
            // 更新绘制的数据源
            [self updateDrawModels];
            
            //绘制K线上部分
            self.drawLinePoints = [self.lineChart drawViewWithXPosition:0 lineModels:_stockGroup.kLineModels maxValue:_maxValue minValue:_minValue];
            
            NSLog(@"drawLinePoints:%ld--%@", self.drawLinePoints.count, self.drawLinePoints);
            //绘制成交量
            [self.volumeView drawViewWithXPosition:0 stockGroup:_stockGroup];
            //更新背景线
            self.stockScrollView.isShowBgLine = YES;
            [self.stockScrollView setNeedsDisplay];
        }
    }
}


/**
 *  更新需要绘制的数据源,图标的最大值，最小值，非股价最大值最小值
 */
- (void)updateDrawModels {
    
    //更新最大值最小值-价格
    CGFloat midYPrice = (self.stockGroup.maxPrice + self.stockGroup.minPrice)/2;
    _maxValue = _stockGroup.maxPrice;
    _minValue = _stockGroup.minPrice;
    
    if (_maxValue == _minValue && _maxValue == midYPrice) {
        //处理特殊情况
        if (_maxValue == 0) {
            _maxValue = 0.00001;
            _minValue = -0.00001;
        } else {
            _maxValue = _maxValue * 2;
            _minValue = 0.01;
        }
    } else {
        if (ABS(_maxValue - midYPrice) >= ABS(midYPrice - _minValue)) {
            _minValue = 2 * midYPrice - _maxValue;
        }
        if (ABS(_maxValue - midYPrice) < ABS(midYPrice - _minValue)) {
            _maxValue = 2 * midYPrice - _minValue;
        }
    }
    
    //    if (ABS(maxValue - average) >= ABS(average - minValue)) {
    //        minValue = 2 * average - maxValue;
    //    } else {
    //        maxValue = 2 * average - minValue;
    //    }
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

#pragma mark - Helpers

- (void)updateScrollViewContentWidth {
    // 更新scrollview 的 contentsize
    self.stockScrollView.contentSize = self.stockScrollView.bounds.size;
    

    NSInteger minCount = 260;
    [VStockChartConfig setTimeLineVolumeWidth:((self.stockScrollView.bounds.size.width - (minCount - 1) * kStockTimeVolumeLineGap) / minCount)];
}


- (void)longPressGesture:(UILongPressGestureRecognizer *)longPress {
    NSLog(@"进入长按");
    
    NSLog(@"%f", [longPress locationInView:self.stockScrollView].x - self.stockScrollView.contentOffset.x);
    
    static CGFloat oldPositionX = 0;
    if(UIGestureRecognizerStateChanged == longPress.state || UIGestureRecognizerStateBegan == longPress.state) {
        
        CGPoint location = [longPress locationInView:self.stockScrollView];
        if (location.x < 0 || location.x > self.stockScrollView.contentSize.width) return;
        if(ABS(oldPositionX - location.x) < ([VStockChartConfig timeLineVolumeWidth] + kStockTimeVolumeLineGap)/2)    return;
        
        oldPositionX = location.x;
        NSInteger startIndex = (NSInteger)(oldPositionX / (kStockTimeVolumeLineGap + [VStockChartConfig timeLineVolumeWidth]));
        
        if (startIndex < 0) startIndex = 0;
        if (startIndex >= self.stockGroup.kLineModels.count) startIndex = self.stockGroup.kLineModels.count - 1;
        
        if (!self.maskView) {
            _maskView = [VLineMaskView new];
            _maskView.backgroundColor = [UIColor clearColor];
            [self addSubview:_maskView];
            [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        } else {
            self.maskView.hidden = NO;
        }
        
        _selectLineModel = self.stockGroup.kLineModels[startIndex];
        self.maskView.selectedModel = self.stockGroup.kLineModels[startIndex];
        self.maskView.selectedPoint = [self.drawLinePoints[startIndex] CGPointValue];
        self.maskView.stockScrollView = self.stockScrollView;
        [self setNeedsDisplay];
        [self.maskView setNeedsDisplay];
    }
    
    if(longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled || longPress.state == UIGestureRecognizerStateFailed) {
        _selectLineModel = self.stockGroup.kLineModels.lastObject;
        [self setNeedsDisplay];
        self.maskView.hidden = YES;
        oldPositionX = 0.f;
        [self setNeedsDisplay];
        self.maskView.hidden = YES;
    }
}

@end
