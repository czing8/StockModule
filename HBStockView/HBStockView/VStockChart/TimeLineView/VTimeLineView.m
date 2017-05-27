//
//  VTimeLineView.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VTimeLineView.h"

#import "VStockScrollView.h"
#import "VTimeLineChart.h"
#import "UIColor+StockTheme.h"
#import "VolumeView.h"
#import "VBidPriceView.h"
#import "VStockRightView.h"
#import "VTimeLineMaskView.h"

#import "VStockGroup.h"
#import "StockRequest.h"
#import "Masonry.h"

/*
 *  港股类型时，没有rightView
 */
@interface VTimeLineView ()

@property (nonatomic, assign) VStockType        stockType;

@property (nonatomic, strong) VStockScrollView  * stockScrollView;  // 背景
@property (nonatomic, strong) VTimeLineChart    * timeLineChart;    // 分时线图表
@property (nonatomic, strong) VolumeView        * volumeView;       // 成交量部分
@property (nonatomic, strong) VStockRightView   * theRightView;     // 右侧视图容器（五档，明细，大单）

@property (nonatomic, strong) VTimeLineMaskView * maskView;

@property (nonatomic, strong) VStockGroup    * stockGroup;    // 数据源

@property (nonatomic, copy  ) NSArray <NSValue *> * drawLinePoints; // 位置数组

@property (nonatomic, strong) VStockPoint    * selectLineModel;      //长按选中的model

@end


@implementation VTimeLineView {
    
    CGFloat _maxValue;      //图表最大的价格
    CGFloat _minValue;      //图表最小的价格

    CGFloat _volumeValue;       //图表最大的成交量
}

#pragma mark - Lifecycle

- (instancetype)initWithType:(VStockType)stockType{
    self = [super init];
    if (self) {
        _stockType = stockType;
        
        [self configureViews];
        _stockScrollView.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark - Public

- (void)reloadWithStockCode:(NSString *)stockCode success:(void(^)(VStockGroup * stockGroup))success {
    __weak typeof(self) weakSelf = self;
    [self getTimeStockData:stockCode success:^(VStockGroup *stockGroup) {
        if (success) {
            success(stockGroup);
        }
        [weakSelf reloadWithGroup:stockGroup];
    }];
}

- (void)reloadWithGroup:(VStockGroup *)stockGroup {
    _stockGroup = stockGroup;
    
    [self layoutIfNeeded];
    [self updateScrollViewContentWidth];
    [self setNeedsDisplay];
    
    if (_stockType == VStockTypeCN) {
        _theRightView.stockGroup = stockGroup;
    }
}


- (void)configureViews {
    
    if (_stockType == VStockTypeCN) {
        [self addSubview:self.theRightView];
        [_theRightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(self);
            make.right.equalTo(self).offset(-kStockScrollViewLeftGap);
            make.width.equalTo(self.mas_height).multipliedBy(0.5);
        }];
        _theRightView.backgroundColor = [UIColor stockMainBgColor];

    }
    
    [self addSubview:self.stockScrollView];
    [_stockScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self);
        make.left.equalTo(self).offset(kStockScrollViewLeftGap);
        if (_stockType == VStockTypeCN) {
            make.right.equalTo(self.theRightView.mas_left).offset(-kStockScrollViewLeftGap);
        }
        else if (_stockType == VStockTypeHK) {
            make.right.equalTo(self).offset(-kStockScrollViewLeftGap);
        }
    }];

    // 分时图View
    _timeLineChart = [[VTimeLineChart alloc] init];
    _timeLineChart.backgroundColor = [UIColor clearColor];
    [_stockScrollView.contentView addSubview:_timeLineChart];
    [_timeLineChart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_stockScrollView.contentView);
        make.left.equalTo(_stockScrollView.contentView);
        make.height.equalTo(_stockScrollView.contentView).multipliedBy([VStockChartConfig lineChartRadio]);
        make.width.equalTo(_stockScrollView);
    }];

    // 成交量View
    _volumeView = [[VolumeView alloc] init];
    _volumeView.backgroundColor = [UIColor clearColor];
    [_stockScrollView.contentView addSubview:_volumeView];
    
    [_volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeLineChart.mas_bottom).offset(2);
        make.left.equalTo(_stockScrollView.contentView);
        make.height.equalTo(_stockScrollView.contentView).multipliedBy([VStockChartConfig volumeViewRadio]);
        make.width.equalTo(_stockScrollView);
    }];

    
//    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(event_pinchAction:)];
//    [_stockScrollView addGestureRecognizer:pinch];
    //长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
    [_stockScrollView addGestureRecognizer:longPress];
}



#pragma mark - Draw Func

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.stockGroup.lineModels.count > 0) {
        if (!self.maskView || self.maskView.isHidden) {
            
            // 更新绘制的数据源
            [self updateDrawModels];
            
            //绘制K线上部分
            self.drawLinePoints = [self.timeLineChart drawViewWithXPosition:0 stockGroup:_stockGroup maxValue:_maxValue minValue:_minValue];
            
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
    CGFloat closeYPrice = [self.stockGroup preClosePrice];
    _maxValue = _stockGroup.maxPrice;
    _minValue = _stockGroup.minPrice;

    if (_maxValue == _minValue && _maxValue == closeYPrice) {
        //处理特殊情况
        if (_maxValue == 0) {
            _maxValue = 0.00001;
            _minValue = -0.00001;
        } else {
            _maxValue = _maxValue * 2;
            _minValue = 0.01;
        }
    } else {
        if (ABS(_maxValue - closeYPrice) >= ABS(closeYPrice - _minValue)) {
            _minValue = 2 * closeYPrice - _maxValue;
        }
        if (ABS(_maxValue - closeYPrice) < ABS(closeYPrice - _minValue)) {
            _maxValue = 2 * closeYPrice - _minValue;
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

- (VStockRightView *)theRightView {
    if (_theRightView == nil) {
        _theRightView = [VStockRightView new];
    }
    return _theRightView;
}

#pragma mark - Helpers

- (void)updateScrollViewContentWidth {
    // 更新scrollview 的 contentsize
    self.stockScrollView.contentSize = self.stockScrollView.bounds.size;
    
    // 9:30-11:30 / 12:00-15:00 一共240分钟
    NSInteger minCount = 240;
    if (_stockType == VStockTypeHK) {
        minCount = 330;
    }
    [VStockChartConfig setTimeLineVolumeWidth:((self.stockScrollView.bounds.size.width - (minCount - 1) * kStockTimeVolumeLineGap) / minCount)];
}

/*
#pragma mark - Touch Fuction
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self showStockTipView:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self showStockTipView:touches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideStockTipView];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideStockTipView];
}


- (void)showStockTipView:(NSSet<UITouch *> *)touches {
    static CGFloat oldPositionX = 0;
    CGPoint location = [touches.anyObject locationInView:self.stockScrollView];
    if (location.x < 0 || location.x > self.stockScrollView.contentSize.width) return;
    if(ABS(oldPositionX - location.x) < ([VStockChartConfig timeLineVolumeWidth] + kStockTimeVolumeLineGap)/2)    return;

    oldPositionX = location.x;
    NSInteger startIndex = (NSInteger)(oldPositionX / (kStockTimeVolumeLineGap + [VStockChartConfig timeLineVolumeWidth]));
    
    if (startIndex < 0) startIndex = 0;
    if (startIndex >= self.stockGroup.lineModels.count) startIndex = self.stockGroup.lineModels.count - 1;
    
    if (!self.maskView) {
        _maskView = [VTimeLineMaskView new];
        _maskView.backgroundColor = [UIColor clearColor];
        [self addSubview:_maskView];
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    } else {
        self.maskView.hidden = NO;
    }
    
    _selectLineModel = self.stockGroup.lineModels[startIndex];
    self.maskView.selectedModel = self.stockGroup.lineModels[startIndex];
    self.maskView.selectedPoint = [self.drawLinePoints[startIndex] CGPointValue];
    self.maskView.stockScrollView = self.stockScrollView;
    [self setNeedsDisplay];
    [self.maskView setNeedsDisplay];
}

- (void)hideStockTipView {
    _selectLineModel = self.stockGroup.lineModels.lastObject;
    [self setNeedsDisplay];
    self.maskView.hidden = YES;
}
*/

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
        if (startIndex >= self.stockGroup.lineModels.count) startIndex = self.stockGroup.lineModels.count - 1;
        
        if (!self.maskView) {
            _maskView = [VTimeLineMaskView new];
            _maskView.backgroundColor = [UIColor clearColor];
            [self addSubview:_maskView];
            [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        } else {
            self.maskView.hidden = NO;
        }
        
        _selectLineModel = self.stockGroup.lineModels[startIndex];
        self.maskView.selectedModel = self.stockGroup.lineModels[startIndex];
        self.maskView.selectedPoint = [self.drawLinePoints[startIndex] CGPointValue];
        self.maskView.stockScrollView = self.stockScrollView;
        [self setNeedsDisplay];
        [self.maskView setNeedsDisplay];
    }
    
    if(longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled || longPress.state == UIGestureRecognizerStateFailed) {
        _selectLineModel = self.stockGroup.lineModels.lastObject;
        [self setNeedsDisplay];
        self.maskView.hidden = YES;
        oldPositionX = 0.f;
        [self setNeedsDisplay];
        self.maskView.hidden = YES;
    }
}



- (void)getTimeStockData:(NSString *)stockCode success:(void (^)(VStockGroup *response))success {
    if (_stockType == VStockTypeCN) {
        [StockRequest getTimeStockData:stockCode success:success];
    }
    else if (_stockType == VStockTypeHK) {
        [StockRequest getHKTimeStockData:stockCode success:success];
    }
}
@end
