//
//  VLineVolumeView.m
//  HBStockView
//
//  Created by Vols on 2017/3/29.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VLineVolumeView.h"

#import "VStockChartConfig.h"
#import "VStockConstant.h"
#import "UIColor+StockTheme.h"
#import "VolumePositionModel.h"

@interface VLineVolumeView ()

@property (nonatomic, strong) NSMutableArray <VolumePositionModel *>    *drawPoints;
@property (nonatomic, strong) NSArray <VLineModel *>    *drawLineModels;

@end

@implementation VLineVolumeView

- (void)drawViewWithXPosition:(CGFloat)xPosition stockGroup:(VStockGroup *)stockGroup {
    NSAssert(stockGroup, @"数据源不能为空");
    //转换为实际坐标
    [self convertToPositionModelsWithXPosition:xPosition stockGroup:stockGroup];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}


- (void)convertToPositionModelsWithXPosition:(CGFloat)startX stockGroup:(VStockGroup *)stockGroup  {
    if (!stockGroup) return;
    
    self.drawLineModels = stockGroup.kLineModels;
    [self.drawPoints removeAllObjects];
    
    CGFloat minValue =  stockGroup.minVolume;
    CGFloat maxValue =  stockGroup.maxVolume;
    CGFloat minY = kStockLineVolumeViewMinY;
    CGFloat maxY = self.frame.size.height - kStockLineVolumeViewMinY;
    
    CGFloat unitValue = (maxValue - minValue)/(maxY - minY);
    
    [stockGroup.kLineModels enumerateObjectsUsingBlock:^(VLineModel * model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat xPosition = startX + idx * ([VStockChartConfig timeLineVolumeWidth] + kStockTimeVolumeLineGap);
        CGFloat yPosition = ABS(maxY - (model.volume - minValue)/unitValue);
        
        CGPoint startPoint = CGPointMake(xPosition, ABS(yPosition - maxY) > 1 ? yPosition : maxY );
        CGPoint endPoint = CGPointMake(xPosition, maxY);
        NSString *dayDesc = model.dayDatail;
        
        VolumePositionModel *positionModel = [VolumePositionModel modelWithStartPoint:startPoint endPoint:endPoint dayDesc:dayDesc];
        [self.drawPoints addObject:positionModel];
    }];
}


#pragma mark - Properties

- (NSMutableArray *)drawPoints {
    if (_drawPoints == nil) {
        _drawPoints = [NSMutableArray array];
    }
    return _drawPoints;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!self.drawPoints) {
        return;
    }
    
    CGFloat lineMaxY = self.frame.size.height - kStockLineVolumeViewMinY;
    
    //绘制背景色
    VolumePositionModel *lastModel = self.drawPoints.lastObject;
    CGContextSetFillColorWithColor(context, [UIColor timeLineBgColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, lastModel.endPoint.x, lineMaxY));
    
    [self.drawPoints enumerateObjectsUsingBlock:^(VolumePositionModel  *_Nonnull pModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIColor *strokeColor;
        if (self.drawLineModels[idx].openPrice < self.drawLineModels[idx].closePrice) {
            strokeColor = [UIColor stock_increaseColor];
        } else if (self.drawLineModels[idx].openPrice > self.drawLineModels[idx].closePrice) {
            strokeColor = [UIColor stock_decreaseColor];
        } else {
            //            if (self.drawLineModels[idx].openPrice >= [[[self.drawLineModels[idx] preDataModel] Close] floatValue]) {
            strokeColor = [UIColor stock_increaseColor];
            //            } else {
            //                strokeColor = [UIColor YYStock_decreaseColor];
            //            }
        }
        
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
        CGContextSetLineWidth(context, [VStockChartConfig timeLineVolumeWidth]);
        const CGPoint solidPoints[] = {pModel.startPoint, pModel.endPoint};
        CGContextStrokeLineSegments(context, solidPoints, 2);
    }];
    
    // 画边框
    CGContextSetStrokeColorWithColor(context, [UIColor borderLineColor].CGColor);
    CGRect rectangle = self.bounds;
    CGContextAddRect(context, rectangle);
    CGContextStrokePath(context);
}

@end
