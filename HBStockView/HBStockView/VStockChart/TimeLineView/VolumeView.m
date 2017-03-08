//
//  VolumeView.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VolumeView.h"
#import "VStockChartConfig.h"
#import "VStockConstant.h"
#import "UIColor+StockTheme.h"
#import "VolumePositionModel.h"

@interface VolumeView ()

@property (nonatomic, strong) NSMutableArray *drawPoints;

@end

@implementation VolumeView


- (void)drawViewWithXPosition:(CGFloat)xPosition timeLineGroup:(VTimeLineGroup *)timeLineGroup{
    NSAssert(timeLineGroup, @"数据源不能为空");
    //转换为实际坐标
    [self convertToPositionModelsWithXPosition:xPosition timeLineGroup:timeLineGroup];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}


- (void)convertToPositionModelsWithXPosition:(CGFloat)startX timeLineGroup:(VTimeLineGroup *)timeLineGroup  {
    if (!timeLineGroup) return;
    
    [self.drawPoints removeAllObjects];
    
    CGFloat minValue =  timeLineGroup.minVolume;
    CGFloat maxValue =  timeLineGroup.maxVolume;
    CGFloat minY = VStockLineVolumeViewMinY;
    CGFloat maxY = self.frame.size.height - VStockLineVolumeViewMinY;
    
    CGFloat unitValue = (maxValue - minValue)/(maxY - minY);
    
    [timeLineGroup.lineModels enumerateObjectsUsingBlock:^(VTimeLineModel * model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat xPosition = startX + idx * ([VStockChartConfig timeLineVolumeWidth] + kStockTimeVolumeLineGap);
        CGFloat yPosition = ABS(maxY - (model.volume - minValue)/unitValue);
        
        CGPoint startPoint = CGPointMake(xPosition, ABS(yPosition - maxY) > 1 ? yPosition : maxY );
        CGPoint endPoint = CGPointMake(xPosition, maxY);
        NSString *dayDesc = model.timeDesc;
        
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
    
    CGFloat lineMaxY = self.frame.size.height - VStockLineVolumeViewMinY;
    
    //绘制背景色
    VolumePositionModel *lastModel = self.drawPoints.lastObject;
    CGContextSetFillColorWithColor(context, [UIColor timeLineBgColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, lastModel.endPoint.x, lineMaxY));
    
    [self.drawPoints enumerateObjectsUsingBlock:^(VolumePositionModel  *_Nonnull pModel, NSUInteger idx, BOOL * _Nonnull stop) {

        CGContextSetStrokeColorWithColor(context, [UIColor timeLineColor].CGColor);
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
