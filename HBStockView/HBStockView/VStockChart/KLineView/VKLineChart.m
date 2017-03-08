//
//  VKLineChart.m
//  HBStockView
//
//  Created by Vols on 2017/3/6.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VKLineChart.h"
#import "VStockChartConfig.h"
#import "VStockConstant.h"
#import "UIColor+StockTheme.h"
#import "VKLinePosition.h"

@interface VKLineChart ()

@property (nonatomic, strong) NSMutableArray *drawPositionModels;


@property (nonatomic, strong) NSArray <VLineModel *> * lineModels;

@property (nonatomic, strong) NSMutableArray * MA5Positions;

@property (nonatomic, strong) NSMutableArray * MA10Positions;

@property (nonatomic, strong) NSMutableArray * MA20Positions;

@end


@implementation VKLineChart

- (NSArray *)drawViewWithXPosition:(CGFloat)xPosition lineModels:(NSArray <VLineModel *>*)lineModels maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue {
    NSAssert(lineModels, @"数据源不能为空");
    //转换为实际坐标
    [self convertToPositionsWithXPosition:xPosition drawLineModels:lineModels maxValue:maxValue minValue:minValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
    return [self.drawPositionModels copy];
}


- (NSArray *)convertToPositionsWithXPosition:(CGFloat)startX drawLineModels:(NSArray <VLineModel *>*)drawLineModels  maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue {
    
    NSLog(@"startX:%f, %f, %f", startX, maxValue, minValue);
    
    if (drawLineModels == nil) return nil;
    
    _lineModels = drawLineModels;
    [self.drawPositionModels removeAllObjects];
    [self.MA5Positions removeAllObjects];
    [self.MA10Positions removeAllObjects];
    [self.MA20Positions removeAllObjects];
    
    CGFloat minY = kStockLineMainViewMinY;
    CGFloat maxY = self.frame.size.height - kStockLineMainViewMinY;
    CGFloat unitValue = (maxValue - minValue)/(maxY - minY);
    if (unitValue == 0) unitValue = 0.01f;
    
    [drawLineModels enumerateObjectsUsingBlock:^(VLineModel * model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat xPosition = startX + idx * ([VStockChartConfig lineWidth] + [VStockChartConfig lineGap]);
        CGPoint highPoint = CGPointMake(xPosition, ABS(maxY - (model.highestPrice - minValue)/unitValue));
        CGPoint lowPoint = CGPointMake(xPosition, ABS(maxY - (model.lowestPrice - minValue)/unitValue));
        CGPoint openPoint = CGPointMake(xPosition, ABS(maxY - (model.openPrice - minValue)/unitValue));
        CGFloat closePointY = ABS(maxY - (model.closePrice - minValue)/unitValue);
        
        //格式化openPoint和closePointY
        if(ABS(closePointY - openPoint.y) < VStockLineMinThick) {
            NSLog(@"%f",closePointY);
            NSLog(@"%f",openPoint.y);
            //            if (openPoint.y == closePointY) {
            //
            //            }
            if(openPoint.y > closePointY) {
                openPoint.y = closePointY + VStockLineMinThick;
            } else if(openPoint.y < closePointY) {
                closePointY = openPoint.y + VStockLineMinThick;
            } else {
                if(idx > 0) {
                    VLineModel * preKLineModel = drawLineModels[idx-1];
                    if(model.openPrice > preKLineModel.closePrice) {
                        openPoint.y = closePointY + VStockLineMinThick;
                    } else {
                        closePointY = openPoint.y + VStockLineMinThick;
                    }
                } else if(idx+1 < drawLineModels.count) {
                    //idx==0即第一个时
                    VLineModel * subKLineModel = drawLineModels[idx+1];
                    if(model.closePrice < subKLineModel.openPrice) {
                        openPoint.y = closePointY + VStockLineMinThick;
                    } else {
                        closePointY = openPoint.y + VStockLineMinThick;
                    }
                } else {
                    openPoint.y = closePointY - VStockLineMinThick;
                }
            }
        }
        
        CGPoint closePoint = CGPointMake(xPosition, closePointY);
        VKLinePosition *positionModel = [VKLinePosition modelWith:openPoint :closePoint :highPoint :lowPoint];
        NSLog(@"positionModel:%@", positionModel);

        [self.drawPositionModels addObject:positionModel];
        
        if (model.ma5 > 0.f) {
            [self.MA5Positions addObject: [NSValue valueWithCGPoint:CGPointMake(xPosition, ABS(maxY - (model.ma5 - minValue)/unitValue))]];
        }
        if (model.ma10 > 0.f) {
            [self.MA10Positions addObject: [NSValue valueWithCGPoint:CGPointMake(xPosition, ABS(maxY - (model.ma10 - minValue)/unitValue))]];
        }
        if (model.ma20 > 0.f) {
            [self.MA20Positions addObject: [NSValue valueWithCGPoint:CGPointMake(xPosition, ABS(maxY - (model.ma20 - minValue)/unitValue))]];
        }
    }];
    
    return self.drawPositionModels ;
}

- (NSMutableArray *)drawPositionModels {
    if (_drawPositionModels == nil) {
        _drawPositionModels = [NSMutableArray array];
    }
    return _drawPositionModels;
}

- (NSMutableArray *)MA5Positions {
    if (_MA5Positions == nil) {
        _MA5Positions = [NSMutableArray array];
    }
    return _MA5Positions;
}

- (NSMutableArray *)MA10Positions {
    if (_MA10Positions == nil) {
        _MA10Positions = [NSMutableArray array];
    }
    return _MA10Positions;
}

- (NSMutableArray *)MA20Positions {
    if (_MA20Positions == nil) {
        _MA20Positions = [NSMutableArray array];
    }
    return _MA20Positions;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.drawPositionModels == nil) {
        return;
    }
    
    if (self.drawPositionModels.count > 0) {
        [self drawKLineOnContent:context];
    }
    
    if(self.MA5Positions.count > 0) {
        [self drawMALineOnContent:context positions:self.MA5Positions color:[UIColor ma5LineColor]];
    }

    if(self.MA10Positions.count > 0) {
        [self drawMALineOnContent:context positions:self.MA10Positions color:[UIColor ma10LineColor]];
    }
    
    if(self.MA20Positions.count > 0) {
        [self drawMALineOnContent:context positions:self.MA20Positions color:[UIColor ma20LineColor]];
    }
}


// 绘制蜡烛图
- (void)drawKLineOnContent:(CGContextRef)context {
    if (!self.drawPositionModels || !context) return;

    [self.drawPositionModels enumerateObjectsUsingBlock:^(VKLinePosition * _Nonnull linePositionModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIColor *strokeColor;
        if (self.lineModels[idx].openPrice < self.lineModels[idx].closePrice) {
            strokeColor = [UIColor stock_increaseColor];
        } else if (self.lineModels[idx].openPrice > self.lineModels[idx].closePrice) {
            strokeColor = [UIColor stock_decreaseColor];
        } else {
//            if ([self.lineModels[idx] openPrice] >= [[self.lineModels[idx] preDataModel] closePrice]) {
//                strokeColor = [UIColor stock_increaseColor];
//            } else {
//                strokeColor = [UIColor stock_decreaseColor];
//            }
            strokeColor = [UIColor stock_decreaseColor];
        }
        
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
        
        CGContextSetLineWidth(context, [VStockChartConfig lineWidth]);
        const CGPoint solidPoints[] = {linePositionModel.openPoint, linePositionModel.closePoint};
        CGContextStrokeLineSegments(context, solidPoints, 2);
        
        CGContextSetLineWidth(context, VStockShadowLineWidth);
        const CGPoint shadowPoints[] = {linePositionModel.highPoint, linePositionModel.lowPoint};
        CGContextStrokeLineSegments(context, shadowPoints, 2);
    }];
}


- (void)drawMALineOnContent:(CGContextRef)context positions:(NSArray *)positions color:(UIColor *)lineColor{
    
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    
    CGContextSetLineWidth(context, 1);
    
    CGPoint firstPoint = [positions.firstObject CGPointValue];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    for (NSInteger idx = 1; idx < positions.count ; idx++) {
        CGPoint point = [positions[idx] CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    
    CGContextStrokePath(context);
}

@end
