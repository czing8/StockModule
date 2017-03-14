//
//  VKLineView.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VKLineView.h"
#import "VStockScrollView.h"
#import "VKLineChart.h"
#import "VKLineVolumeView.h"
#import "VKLineMaskView.h"

#import "VKLinePosition.h"

#import "VStockChartConfig.h"
#import "UIColor+StockTheme.h"
#import "Masonry.h"

@interface VKLineView () <UIScrollViewDelegate>

@property (nonatomic, strong) VStockScrollView  * stockScrollView;      // 背景

@property (nonatomic, strong) VKLineChart       * kLineChart;           // k线图表
@property (nonatomic, strong) VKLineVolumeView  * volumeChart;          // 成交量

@property (nonatomic, strong) VKLineMaskView    * maskView;

@property (nonatomic, copy) NSArray <VKLinePosition *>*drawLinePositions;   // 位置数组

@property (nonatomic, strong) VLineGroup        * lineGroup;            // 数据源
@property (nonatomic, strong) NSMutableArray    * screenLineModels;           // 当前一屏幕数据源
@property (nonatomic, strong) VLineModel        * selectLineModel;      //长按选中的model

@end


@implementation VKLineView {
    
    CGFloat _maxValue;      //图表最大的价格
    CGFloat _minValue;      //图表最小的价格
    
    CGFloat _volumeValue;       //图表最大的成交量
}

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [self configureViews];
//        _stockScrollView.userInteractionEnabled = NO;
    }
    return self;
}

- (void)configureViews {
    
    [self addSubview:self.stockScrollView];
    [_stockScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(kStockScrollViewLeftGap);
        make.right.equalTo(self).offset(-kStockScrollViewLeftGap);
        make.height.equalTo(@kStockChartHeight);
    }];
    
    // k线图View
    _kLineChart = [[VKLineChart alloc] init];
    _kLineChart.backgroundColor = [UIColor clearColor];
    [_stockScrollView.contentView addSubview:_kLineChart];
    [_kLineChart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(_stockScrollView.contentView);
        make.height.equalTo(_stockScrollView.contentView).multipliedBy([VStockChartConfig lineChartRadio]);
    }];
    
    // 成交量View
    _volumeChart = [[VKLineVolumeView alloc] init];
    _volumeChart.backgroundColor = [UIColor clearColor];
//    _volumeChart.parentScrollView = _stockScrollView;
    [_stockScrollView.contentView addSubview:_volumeChart];
    
    [_volumeChart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(_stockScrollView.contentView);
        make.height.equalTo(_stockScrollView.contentView).multipliedBy([VStockChartConfig volumeViewRadio]);
    }];

    //缩放
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(event_pinchAction:)];
    [_stockScrollView addGestureRecognizer:pinch];
    //长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(event_longPressAction:)];
    [_stockScrollView addGestureRecognizer:longPress];

}

#pragma mark - Public

- (void)reloadWithGroup:(VLineGroup *)lineGroup {
    _lineGroup = lineGroup;
    
    [self layoutIfNeeded];
    [self updateScrollViewContentWidth];
    [self setNeedsDisplay];
    if (self.lineGroup.lineModels.count > 0) {
        self.stockScrollView.contentOffset = CGPointMake(self.stockScrollView.contentSize.width - self.stockScrollView.bounds.size.width, self.stockScrollView.contentOffset.y);
    }
}


#pragma mark - Actions

- (void)event_longPressAction:(UILongPressGestureRecognizer *)longPress {
    NSLog(@"%f", [longPress locationInView:self.stockScrollView].x - self.stockScrollView.contentOffset.x);
    
    static CGFloat oldPositionX = 0;
    if(UIGestureRecognizerStateChanged == longPress.state || UIGestureRecognizerStateBegan == longPress.state) {
        
        CGPoint location = [longPress locationInView:self.stockScrollView];
        if (location.x < 0 || location.x > self.stockScrollView.contentSize.width) return;
        
        //暂停滑动
        oldPositionX = location.x;
        NSInteger startIndex = (NSInteger)((oldPositionX - [self xPosition] + ([VStockChartConfig lineGap] + [VStockChartConfig lineWidth])/2.f) / ([VStockChartConfig lineGap] + [VStockChartConfig lineWidth]));
        
        if (startIndex < 0) startIndex = 0;
        if (startIndex >= self.screenLineModels.count) startIndex = self.screenLineModels.count - 1;
        
        //长按位置没有数据则退出
        if (startIndex < 0) {
            return;
        }
        
        if (self.maskView == nil) {
            _maskView = [VKLineMaskView new];
            _maskView.backgroundColor = [UIColor clearColor];
            [self addSubview:_maskView];
            [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        } else {
            self.maskView.hidden = NO;
        }
        
        _selectLineModel = self.screenLineModels[startIndex];
        self.maskView.selectedModel = self.screenLineModels[startIndex];
        self.maskView.selectedPosition = self.drawLinePositions[startIndex];
        self.maskView.stockScrollView = self.stockScrollView;
        [self setNeedsDisplay];
    }
    
    if(longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled || longPress.state == UIGestureRecognizerStateFailed)
    {
        //恢复scrollView的滑动
        _selectLineModel = self.screenLineModels.lastObject;
        oldPositionX = 0.f;
        [self setNeedsDisplay];
        self.maskView.hidden = YES;
    }
}

- (void)event_pinchAction:(UIPinchGestureRecognizer *)pinch {
    //1.获取缩放倍数
    static CGFloat oldScale = 1.0f;
    CGFloat difValue = pinch.scale - oldScale;
    
    if(ABS(difValue) > VStockLineScaleBound) {
        if( pinch.numberOfTouches == 2 ) {
            
            //2.获取捏合中心点 -> 捏合中心点距离scrollviewcontent左侧的距离
            CGPoint p1 = [pinch locationOfTouch:0 inView:self.stockScrollView];
            CGPoint p2 = [pinch locationOfTouch:1 inView:self.stockScrollView];
            CGFloat centerX = (p1.x+p2.x)/2;
            
            //3.拿到中心点数据源的index
            CGFloat oldLeftArrCount = ABS(centerX + [VStockChartConfig lineGap]) / ([VStockChartConfig lineGap] + [VStockChartConfig lineWidth]);
            
            //4.缩放重绘
            CGFloat newLineWidth = [VStockChartConfig lineWidth] * (difValue > 0 ? (1 + VStockLineScaleFactor) : (1 - VStockLineScaleFactor));
            [VStockChartConfig setLineWith:newLineWidth];
            [self updateScrollViewContentWidth];
            
            //5.计算更新宽度后捏合中心点距离klineView左侧的距离
            CGFloat newLeftDistance = oldLeftArrCount * [VStockChartConfig lineWidth] + (oldLeftArrCount - 1) * [VStockChartConfig lineGap];
            
            //6.设置scrollview的contentoffset = (5) - (2);
            if ( self.screenLineModels.count * newLineWidth + (self.screenLineModels.count + 1) * [VStockChartConfig lineGap] > self.stockScrollView.bounds.size.width ) {
                CGFloat newOffsetX = newLeftDistance - (centerX - self.stockScrollView.contentOffset.x);
                self.stockScrollView.contentOffset = CGPointMake(newOffsetX > 0 ? newOffsetX : 0 , self.stockScrollView.contentOffset.y);
            } else {
                self.stockScrollView.contentOffset = CGPointMake(0 , self.stockScrollView.contentOffset.y);
            }
            //更新contentsize
            [self updateScrollViewContentWidth];
            [self setNeedsDisplay];
        }
    }
}


#pragma mark - Properties

- (NSMutableArray *)screenLineModels {
    if (_screenLineModels == nil) {
        _screenLineModels = [NSMutableArray array];
    }
    return _screenLineModels;
}


- (VStockScrollView *)stockScrollView {
    if (_stockScrollView == nil) {
        _stockScrollView = [VStockScrollView new];
        _stockScrollView.stockType = VStockChartTypeDayLine;
        _stockScrollView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        _stockScrollView.showsHorizontalScrollIndicator = NO;
        _stockScrollView.delegate = self;
    }
    return _stockScrollView;
}


- (CGFloat)updateScrollViewContentWidth {
    //根据stockModels的个数和间隔和K线的宽度计算出self的宽度，并设置contentsize
    CGFloat kLineViewWidth = self.lineGroup.lineModels.count * [VStockChartConfig lineWidth] + (self.lineGroup.lineModels.count + 1) * [VStockChartConfig lineGap];
    
    if(kLineViewWidth < self.stockScrollView.bounds.size.width) {
        kLineViewWidth = self.stockScrollView.bounds.size.width;
    }
    
    //更新scrollview的contentsize
    self.stockScrollView.contentSize = CGSizeMake(kLineViewWidth, self.stockScrollView.contentSize.height);
    return kLineViewWidth;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setNeedsDisplay];
}


#pragma mark - draw function

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.lineGroup.lineModels.count > 0) {
        if (self.maskView == nil || self.maskView.isHidden) {
            // 更新绘制的数据源
            [self updateDrawModels];
            // 更新背景线
            self.stockScrollView.isShowBgLine = YES;
            [self.stockScrollView setNeedsDisplay];
            // 绘制K线上部分
            self.drawLinePositions = [self.kLineChart drawViewWithXPosition:[self xPosition] lineModels:self.screenLineModels maxValue:_maxValue minValue:_minValue];
            // 绘制成交量
            [self.volumeChart drawViewWithXPosition:[self xPosition] drawModels:_screenLineModels linePositions:self.drawLinePositions];
        } else {
            [self.maskView setNeedsDisplay];
        }
        //绘制左侧文字部分
        [self drawLeftDesc];
//        //绘制顶部的MA数据
//        [self drawTopDesc];
    }
}

/**
 绘制左边的价格部分
 */
- (void)drawLeftDesc {
    
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:9],NSForegroundColorAttributeName:[UIColor topBarNormalTextColor]};
    CGSize textSize = [self rectOfNSString:[NSString stringWithFormat:@"%.2f", (_maxValue + _minValue)/2.f] attribute:attribute].size;
    CGFloat unit = self.stockScrollView.frame.size.height * [VStockChartConfig lineChartRadio] / 4.f;
    CGFloat unitValue = (_maxValue - _minValue)/4.f;
    //顶部间距
    for (int i = 0; i < 5; i++) {
        NSString *text = [NSString stringWithFormat:@"%.2f",_maxValue - unitValue * i];
        CGPoint drawPoint = CGPointMake((VStockScrollViewLeftGap - textSize.width)/2, unit * i + kStockScrollViewTopGap - textSize.height/2.f);
        [text drawAtPoint:drawPoint withAttributes:attribute];
    }
    
    CGFloat volume =  [[[self.screenLineModels valueForKeyPath:@"volume"] valueForKeyPath:@"@max.floatValue"] floatValue];
    _volumeValue = volume;
    
    //尝试转为万手
    CGFloat wVolume = volume/10000.f;
    if (wVolume > 1) {
        //尝试转为亿手
        CGFloat yVolume = wVolume/10000.f;
        if (yVolume > 1) {
            NSString *text = [NSString stringWithFormat:@"%.2f",yVolume];
            CGSize textSize = [self rectOfNSString:text attribute:attribute].size;
            [text drawInRect:CGRectMake(VStockScrollViewLeftGap - textSize.width - 5, kStockScrollViewTopGap + self.stockScrollView.frame.size.height * (1 - [VStockChartConfig volumeViewRadio]), 60, 20) withAttributes:attribute];
            
            NSString *descText = @"亿手";
            CGSize textSize1 = [self rectOfNSString:descText attribute:attribute].size;
            [descText drawInRect:CGRectMake(VStockScrollViewLeftGap - textSize1.width - 5, kStockScrollViewTopGap + 15 + self.stockScrollView.frame.size.height * (1 - [VStockChartConfig volumeViewRadio]), 60, 20) withAttributes:attribute];
        } else {
            NSString *text = [NSString stringWithFormat:@"%.2f",wVolume];
            CGSize textSize = [self rectOfNSString:text attribute:attribute].size;
            [text drawInRect:CGRectMake(VStockScrollViewLeftGap - textSize.width - 5, kStockScrollViewTopGap + self.stockScrollView.frame.size.height * (1 - [VStockChartConfig volumeViewRadio]), 60, 20) withAttributes:attribute];
            NSString *descText = @"万手";
            CGSize textSize1 = [self rectOfNSString:descText attribute:attribute].size;
            [descText drawInRect:CGRectMake(VStockScrollViewLeftGap - textSize1.width - 5, kStockScrollViewTopGap + 15 + self.stockScrollView.frame.size.height * (1 - [VStockChartConfig volumeViewRadio]), 60, 20) withAttributes:attribute];
        }
    } else {
        NSString *text = [NSString stringWithFormat:@"%.0f",volume];
        CGSize textSize = [self rectOfNSString:text attribute:attribute].size;
        [text drawInRect:CGRectMake(VStockScrollViewLeftGap - textSize.width - 5, kStockScrollViewTopGap + self.stockScrollView.frame.size.height * (1 - [VStockChartConfig volumeViewRadio]), 60, 20) withAttributes:attribute];
        NSString *descText = @"手";
        CGSize textSize1 = [self rectOfNSString:descText attribute:attribute].size;
        [descText drawInRect:CGRectMake(VStockScrollViewLeftGap - textSize1.width - 5, kStockScrollViewTopGap + 15 + self.stockScrollView.frame.size.height * (1 - [VStockChartConfig volumeViewRadio]), 60, 20) withAttributes:attribute];
    }
}


- (void)updateDrawModels {
    
    NSInteger startIndex = [self startIndex];
    NSInteger drawLineCount = (self.stockScrollView.frame.size.width) / ([VStockChartConfig lineGap] +  [VStockChartConfig lineWidth]);
    
    [self.screenLineModels removeAllObjects];
    NSInteger length = startIndex+drawLineCount < self.lineGroup.lineModels.count ? drawLineCount+1 : self.lineGroup.lineModels.count - startIndex;
    [self.screenLineModels addObjectsFromArray:[self.lineGroup.lineModels subarrayWithRange:NSMakeRange(startIndex, length)]];
    
    //更新顶部ma数据
    _selectLineModel = self.screenLineModels.lastObject;
    
    //更新最大值最小值-价格
    CGFloat max =  [[[self.screenLineModels valueForKeyPath:@"highestPrice"] valueForKeyPath:@"@max.floatValue"] floatValue];
    
//    CGFloat ma5max = [[[self.drawLineModels valueForKeyPath:@"MA5"] valueForKeyPath:@"@max.floatValue"] floatValue];
//    CGFloat ma10max = [[[self.drawLineModels valueForKeyPath:@"MA10"] valueForKeyPath:@"@max.floatValue"] floatValue];
//    CGFloat ma20max = [[[self.drawLineModels valueForKeyPath:@"MA20"] valueForKeyPath:@"@max.floatValue"] floatValue];
    
    __block CGFloat min =  [[[self.screenLineModels valueForKeyPath:@"lowestPrice"] valueForKeyPath:@"@min.floatValue"] floatValue];
//    [self.screenLineModels enumerateObjectsUsingBlock:^(VLineModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        CGFloat ma5value = obj.ma5;
//        CGFloat ma10value = obj.ma10;
//        CGFloat ma20value = obj.ma20;
//        if ( ma5value > 0 && ma5value < min ) min = ma5value;
//        if ( ma10value > 0 && ma10value < min ) min = ma10value;
//        if ( ma20value > 0 && ma20value < min ) min = ma20value;
//    }];
//    
//    max = MAX(MAX(MAX(ma5max, ma10max), ma20max), max);
    
    CGFloat average = (min+max) / 2;
    _maxValue = max;
    _minValue = average * 2 - _maxValue;
}


- (NSInteger)startIndex {
    CGFloat offsetX = self.stockScrollView.contentOffset.x < 0 ? 0 : self.stockScrollView.contentOffset.x;
    NSUInteger leftCount = ABS(offsetX) / ([VStockChartConfig lineGap] + [VStockChartConfig lineWidth]);
    
    if (leftCount > self.lineGroup.lineModels.count) {
        leftCount = self.lineGroup.lineModels.count - 1;
    }
    return leftCount;
}

- (NSInteger)xPosition {
    NSInteger leftArrCount = [self startIndex];
    CGFloat startXPosition = (leftArrCount + 1) * [VStockChartConfig lineGap] + leftArrCount * [VStockChartConfig lineWidth] + [VStockChartConfig lineWidth]/2;
    return startXPosition;
}

- (CGRect)rectOfNSString:(NSString *)string attribute:(NSDictionary *)attribute {
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                       options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading
                                    attributes:attribute
                                       context:nil];
    return rect;
}


@end
