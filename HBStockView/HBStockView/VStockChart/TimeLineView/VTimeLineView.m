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

#import "VTimeLineGroup.h"
#import "Masonry.h"

@interface VTimeLineView ()

@property (nonatomic, strong) VStockScrollView  * stockScrollView;      // 背景

@property (nonatomic, strong) VTimeLineChart    * timeLineChart;        // 分时线图表

@property (nonatomic, strong) VolumeView        * volumeView;   // 成交量部分
@property (nonatomic, strong) VStockRightView   * theRightView;    // 右侧视图容器（五档，明细，大单）

//@property (nonatomic, strong) VBidPriceView     * bidPriceView; // 五档图

@property (nonatomic, strong) VTimeLineMaskView * maskView;


@property (nonatomic, strong) VTimeLineGroup    * timeLineGroup;        // 数据源

@property (nonatomic, copy) NSArray <NSValue *> * drawLinePoints;       // 位置数组

@property (nonatomic, strong) VTimeLineModel    * selectLineModel;      //长按选中的model

@end


@implementation VTimeLineView {
    
    CGFloat _maxValue;      //图表最大的价格
    CGFloat _minValue;      //图表最小的价格

    CGFloat _volumeValue;       //图表最大的成交量
}

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [self configureViews];
        _stockScrollView.userInteractionEnabled = YES;
    }
    return self;
}

- (void)configureViews {
    
    [self addSubview:self.theRightView];
    [_theRightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self).offset(-6);
        make.width.equalTo(self).multipliedBy(0.3);
        make.height.equalTo(self);
    }];

    _theRightView.backgroundColor = [UIColor stockMainBgColor];
    
    [self addSubview:self.stockScrollView];
    [_stockScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).offset(kStockScrollViewLeftGap);
        make.right.equalTo(self.theRightView.mas_left).offset(-kStockScrollViewLeftGap);
        make.height.equalTo(self);
    }];

//    _stockScrollView.backgroundColor = [UIColor lightGrayColor];
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
        make.left.right.equalTo(_stockScrollView.contentView);
        make.height.equalTo(_stockScrollView.contentView).multipliedBy([VStockChartConfig volumeViewRadio]);
    }];

    
//    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(event_pinchAction:)];
//    [_stockScrollView addGestureRecognizer:pinch];
    //长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
    [_stockScrollView addGestureRecognizer:longPress];
}


- (void)reloadWithGroup:(VTimeLineGroup *)timeLineGroup {
    _timeLineGroup = timeLineGroup;
    
    [self layoutIfNeeded];
    [self updateScrollViewContentWidth];
    [self setNeedsDisplay];
    
    _theRightView.timeLineGroup = timeLineGroup;
}


#pragma mark - Draw Func

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.timeLineGroup.lineModels.count > 0) {
        if (!self.maskView || self.maskView.isHidden) {
            
            //更新绘制的数据源
            [self updateDrawModels];
            
            //绘制K线上部分
            self.drawLinePoints = [self.timeLineChart drawViewWithXPosition:0 timeLineGroup:_timeLineGroup maxValue:_maxValue minValue:_minValue];
            
            //绘制成交量
            [self.volumeView drawViewWithXPosition:0 timeLineGroup:_timeLineGroup];
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
    CGFloat closeYPrice = [self.timeLineGroup preClosePrice];
    _maxValue = _timeLineGroup.maxPrice;
    _minValue = _timeLineGroup.minPrice;

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


#pragma mark - Public

#pragma mark - Actions


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
    if (startIndex >= self.timeLineGroup.lineModels.count) startIndex = self.timeLineGroup.lineModels.count - 1;
    
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
    
    _selectLineModel = self.timeLineGroup.lineModels[startIndex];
    self.maskView.selectedModel = self.timeLineGroup.lineModels[startIndex];
    self.maskView.selectedPoint = [self.drawLinePoints[startIndex] CGPointValue];
    self.maskView.stockScrollView = self.stockScrollView;
    [self setNeedsDisplay];
    [self.maskView setNeedsDisplay];
}

- (void)hideStockTipView {
    _selectLineModel = self.timeLineGroup.lineModels.lastObject;
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
        if (startIndex >= self.timeLineGroup.lineModels.count) startIndex = self.timeLineGroup.lineModels.count - 1;
        
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
        
        _selectLineModel = self.timeLineGroup.lineModels[startIndex];
        self.maskView.selectedModel = self.timeLineGroup.lineModels[startIndex];
        self.maskView.selectedPoint = [self.drawLinePoints[startIndex] CGPointValue];
        self.maskView.stockScrollView = self.stockScrollView;
        [self setNeedsDisplay];
        [self.maskView setNeedsDisplay];
    }
    
    if(longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled || longPress.state == UIGestureRecognizerStateFailed) {
        _selectLineModel = self.timeLineGroup.lineModels.lastObject;
        [self setNeedsDisplay];
        self.maskView.hidden = YES;
        oldPositionX = 0.f;
        [self setNeedsDisplay];
        self.maskView.hidden = YES;
    }
}
@end
