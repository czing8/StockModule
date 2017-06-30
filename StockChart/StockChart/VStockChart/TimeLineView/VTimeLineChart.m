//
//  VTimeLineSubView.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VTimeLineChart.h"
#import "VStockConstant.h"
#import "UIColor+StockTheme.h"
#import "VStockChartConfig.h"

#import "UIColor+VAdd.h"

@interface VTimeLineChart() <CAAnimationDelegate>

@property (nonatomic, strong) NSMutableArray *drawPoints;

@end

@implementation VTimeLineChart {
    CGFloat _maxValue;  // 不是股价的最大值，是表格区域表示的最大值
    CGFloat _minValue;  // 不是股价的最小值，是表格区域表示的最小值
}

- (NSArray *)drawViewWithXPosition:(CGFloat)xPosition stockGroup:(VStockGroup *)stockGroup maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue {
    
    NSAssert(stockGroup, @"数据源不能为空");
    _maxValue = maxValue;
    _minValue = minValue;
    
    // 转换为实际坐标
    [self convertToPositionsWithXPosition:xPosition drawLineModels:stockGroup.lineModels maxValue:maxValue minValue:minValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
    return [self.drawPoints copy];
}

#pragma mark - Helpers

- (NSArray *)convertToPositionsWithXPosition:(CGFloat)startX drawLineModels:(NSArray <VStockPoint *>*)drawLineModels  maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue {
    if (drawLineModels == nil) return nil;
    
    [self.drawPoints removeAllObjects];
    
    CGFloat minY = kStockLineMainViewMinY;
    CGFloat maxY = self.frame.size.height - kStockLineMainViewMinY;
    CGFloat unitValue = (maxValue - minValue)/(maxY - minY);
    NSLog(@"minY:%f,%f,%f,%f,%f", minY, maxY, unitValue, maxValue, minValue);

    [drawLineModels enumerateObjectsUsingBlock:^(VStockPoint * model, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat xPosition = startX + idx * ([VStockChartConfig timeLineVolumeWidth] + kStockTimeVolumeLineGap);
        CGPoint pricePoint = CGPointMake(xPosition, ABS(maxY - (model.price - minValue)/unitValue));
        [self.drawPoints addObject:[NSValue valueWithCGPoint:pricePoint]];
    }];
    
    return self.drawPoints;
}

- (NSMutableArray *)drawPoints {
    if (_drawPoints == nil) {
        _drawPoints = [NSMutableArray array];
    }
    return _drawPoints;
}


#pragma mark - DrawRect

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_drawPoints == nil)  return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, kStockTimeLineWidth);
    CGPoint firstPoint = [self.drawPoints.firstObject CGPointValue];    
    if (isnan(firstPoint.x) || isnan(firstPoint.y)) {
        return;
    }
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    //画分时线
    CGContextSetStrokeColorWithColor(context, [UIColor timeLineColor].CGColor);
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);

    for (NSInteger idx = 1; idx < self.drawPoints.count ; idx++) {
        CGPoint point = [self.drawPoints[idx] CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextStrokePath(context);
    
    // 画背景色
    CGContextSetFillColorWithColor(context, [UIColor timeLineBgColor].CGColor);
    CGPoint lastPoint = [self.drawPoints.lastObject CGPointValue];
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    for (NSInteger idx = 1; idx < self.drawPoints.count ; idx++) {
        CGPoint point = [self.drawPoints[idx] CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextAddLineToPoint(context, lastPoint.x, CGRectGetMaxY(self.frame));
    CGContextAddLineToPoint(context, firstPoint.x, CGRectGetMaxY(self.frame));
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    // 画边框
    CGContextSetStrokeColorWithColor(context, [UIColor borderLineColor].CGColor);
    CGRect rectangle = self.bounds;
    CGContextAddRect(context, rectangle);
    CGContextStrokePath(context);
    
    
    // 纵横网格 辅助线
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetStrokeColorWithColor(context, [UIColor bgLineColor].CGColor);
    CGContextSetLineWidth(context, .5f);
    
    const CGPoint v_line[] = {CGPointMake(self.frame.size.width/4, 0), CGPointMake(self.frame.size.width/4, self.frame.size.height), CGPointMake(self.frame.size.width/2, 0), CGPointMake(self.frame.size.width/2, self.frame.size.height), CGPointMake(self.frame.size.width/4*3, 0), CGPointMake(self.frame.size.width/4*3, self.frame.size.height)};
    CGContextStrokeLineSegments(context, v_line, 6);
    
    const CGPoint h_line[] = {CGPointMake(0, self.frame.size.height/4), CGPointMake(self.frame.size.width, self.frame.size.height/4), CGPointMake(0, self.frame.size.height/4*3), CGPointMake(self.frame.size.width, self.frame.size.height/4*3)};
    CGContextStrokeLineSegments(context, h_line, 4);
    
    // 股票昨日收盘价线
    CGContextSetStrokeColorWithColor(context, [UIColor midTimeLineColor].CGColor);
    CGFloat lengths[] = {3, 3};
    CGContextSetLineDash(context, 0, lengths, 2);      // 画虚线
    CGContextSetLineWidth(context, 1.5);
    CGFloat unitHeight = (self.frame.size.height)/2;
    const CGPoint line1[] = {CGPointMake(0, unitHeight),CGPointMake(self.frame.size.width, unitHeight)};
    CGContextStrokeLineSegments(context, line1, 2);
    
    [self drawLeftText];
//    [self sparkView:lastPoint];
}


- (void)sparkView:(CGPoint)spartPoint {

    CALayer *layer = [[CALayer alloc] init];
    layer.cornerRadius = 10;
    layer.frame = CGRectMake(0, 0, layer.cornerRadius * 2, layer.cornerRadius * 2);
    layer.position = spartPoint;
    UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
    layer.backgroundColor = color.CGColor;
    [self.layer addSublayer:layer];
    
    CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    CAAnimationGroup *animaTionGroup = [CAAnimationGroup animation];
    animaTionGroup.delegate = self;
    animaTionGroup.duration = 2;
    animaTionGroup.removedOnCompletion = YES;
    animaTionGroup.timingFunction = defaultCurve;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    scaleAnimation.fromValue = @0.0;
    scaleAnimation.toValue = @1.0;
    scaleAnimation.duration = 2;
    
    CAKeyframeAnimation *opencityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opencityAnimation.duration = 2;
    opencityAnimation.values = @[@0.8,@0.4,@0];
    opencityAnimation.keyTimes = @[@0,@0.5,@1];
    opencityAnimation.removedOnCompletion = YES;
    
    NSArray *animations = @[scaleAnimation,opencityAnimation];
    animaTionGroup.animations = animations;
    [layer addAnimation:animaTionGroup forKey:nil];
    
    [self performSelector:@selector(removeLayer:) withObject:layer afterDelay:2.0];
}

- (void)removeLayer:(CALayer *)layer {
    [layer removeFromSuperlayer];
}


/**
 * 绘制左边的价格部分
 */
- (void)drawLeftText {
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:9],NSForegroundColorAttributeName:[UIColor topBarNormalTextColor]};
    CGSize textSize = [self rectOfString:[NSString stringWithFormat:@"%.2f",(_maxValue + _minValue)/2.f] attribute:attribute].size;
    
    CGFloat unitValue = (_maxValue - _minValue)/2.f;
    CGFloat unit = self.frame.size.height / 2.f;
    CGFloat leftGap = 3;
    CGFloat topOffset = 3;
    CGFloat creasePercent = (_maxValue / ((_maxValue + _minValue)/2.f)) * 100 - 100;
    if (isnan(creasePercent) || creasePercent == INFINITY) {
        creasePercent = 0.000001;
    }
    
    // 顶部间距
    for (int i = 0; i < 3; i++) {
        NSString *priceText = [NSString stringWithFormat:@"%.2f",_maxValue - unitValue * i];
        CGPoint leftDrawPoint = CGPointMake(leftGap , unit * i + kStockScrollViewTopGap - textSize.height/2.f + topOffset);
        
        NSString *percentText = [NSString stringWithFormat:@"%.2f%%",creasePercent - creasePercent * i];
        CGSize textSize2 = [self rectOfString:percentText attribute:attribute].size;
        CGPoint rightDrawPoint = CGPointMake(CGRectGetMaxX(self.frame) - textSize2.width - 3, unit * i + kStockScrollViewTopGap - textSize.height/2.f + topOffset);
        
        if (i == 1) {
            leftDrawPoint = CGPointMake(leftGap , unit * i - textSize.height/2.f);
            rightDrawPoint = CGPointMake(CGRectGetMaxX(self.frame) - textSize2.width - 3, unit * i - textSize2.height/2.f);
        }
        else if (i == 2) {
            leftDrawPoint = CGPointMake(leftGap , unit * i - textSize.height);
            rightDrawPoint = CGPointMake(CGRectGetMaxX(self.frame) - textSize2.width - 3, unit * i - textSize2.height);
        }
        
        [priceText drawAtPoint:leftDrawPoint withAttributes:attribute];
      
        if (i == 1) continue;       // 忽略 0.0%
        [percentText drawAtPoint:rightDrawPoint withAttributes:attribute];
    }
    NSLog(@"_maxValue:%f, %f, %f, %f", _maxValue, _minValue, (_maxValue + _minValue)/2.f, unitValue);
}

- (CGRect)rectOfString:(NSString *)string attribute:(NSDictionary *)attribute {
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                       options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading
                                    attributes:attribute
                                       context:nil];
    return rect;
}





@end
