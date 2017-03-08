//
//  VKLineVolumeView.m
//  HBStockView
//
//  Created by Vols on 2017/3/6.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VKLineVolumeView.h"
#import "VStockChartConfig.h"
#import "VStockConstant.h"
#import "VolumePositionModel.h"
#import "UIColor+StockTheme.h"

@interface VKLineVolumeView()

@property (nonatomic, strong) NSMutableArray *drawPositionModels;

@property (nonatomic, strong) NSArray *linePositionModels;

@property (nonatomic, strong) NSArray <VLineModel *> *drawLineModels;

@end


@implementation VKLineVolumeView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!self.drawPositionModels) {
        return;
    }
    
    NSAssert(self.linePositionModels.count == self.drawPositionModels.count, @"K线图和成交量的个数不相等");
    
    __block CGFloat lastRecontext = 0;
    
    [self.drawPositionModels enumerateObjectsUsingBlock:^(VolumePositionModel  *_Nonnull pModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
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
        CGContextSetLineWidth(context, [VStockChartConfig lineWidth]);
        const CGPoint solidPoints[] = {pModel.startPoint, pModel.endPoint};
        CGContextStrokeLineSegments(context, solidPoints, 2);
    }];
    
    __block BOOL firstFlag = YES;
    [[[self.drawPositionModels reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^(VolumePositionModel  *_Nonnull pModel, NSUInteger idx, BOOL * _Nonnull stop) {
        //绘制日期
        if (pModel.dayDesc.length > 0) {
            NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor VStock_topBarNormalTextColor]};
            CGRect rect1 = [pModel.dayDesc boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                                        options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin |
                            NSStringDrawingUsesFontLeading
                                                     attributes:attribute
                                                        context:nil];
            
            CGFloat width = rect1.size.width;
            
            if (firstFlag) {
                firstFlag = NO;
                
                if (pModel.startPoint.x - width/2.f < 0) {
                    lastRecontext = 0;
                    [pModel.dayDesc drawAtPoint:CGPointMake(0, pModel.endPoint.y) withAttributes:attribute];
                } else {
                    if (pModel.startPoint.x + width/2.f - MIN(self.parentScrollView.contentOffset.x,self.parentScrollView.contentSize.width - self.bounds.size.width) < self.parentScrollView.bounds.size.width) {
                        lastRecontext = pModel.startPoint.x - width/2.f;
                        [pModel.dayDesc drawAtPoint:CGPointMake(pModel.startPoint.x - width/2, pModel.endPoint.y) withAttributes:attribute];
                    } else {
                        lastRecontext = pModel.startPoint.x + [VStockChartConfig lineWidth]/2.f - width;
                        [pModel.dayDesc drawAtPoint:CGPointMake(pModel.startPoint.x  + [VStockChartConfig lineWidth]/2.f - width, pModel.endPoint.y) withAttributes:attribute];
                    }
                }
            } else if ( pModel.startPoint.x + width/2.f < lastRecontext - 50 ) {
                lastRecontext = pModel.startPoint.x - width/2.f;
                [pModel.dayDesc drawAtPoint:CGPointMake(pModel.startPoint.x - width/2, pModel.endPoint.y) withAttributes:attribute];
            }
        }
    }];
    
}
- (void)drawViewWithXPosition:(CGFloat)xPosition drawModels:(NSArray <VLineModel *>*)drawLineModels linePositions:(NSArray <VKLinePosition *>*)linePositions{
    NSAssert(drawLineModels, @"数据源不能为空");
    _linePositionModels = linePositions;
    //转换为实际坐标
    [self convertToPositionModelsWithXPosition:xPosition drawLineModels:drawLineModels];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (NSArray *)convertToPositionModelsWithXPosition:(CGFloat)startX drawLineModels:(NSArray <VLineModel *>*)drawLineModels {
    if (!drawLineModels) return nil;
    self.drawLineModels = drawLineModels;
    [self.drawPositionModels removeAllObjects];
    
    CGFloat minValue =  0;
    CGFloat maxValue =  [[[drawLineModels valueForKeyPath:@"volume"] valueForKeyPath:@"@max.floatValue"] floatValue];
    
    CGFloat minY = VStockLineVolumeViewMinY;
    CGFloat maxY = self.frame.size.height - VStockLineDayHeight;
    
    CGFloat unitValue = (maxValue - minValue)/(maxY - minY);
    
    [drawLineModels enumerateObjectsUsingBlock:^(VLineModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat xPosition = startX + idx * ([VStockChartConfig lineWidth] + [VStockChartConfig lineGap]);
        CGFloat yPosition = ABS(maxY - (model.volume - minValue)/unitValue);
        CGPoint startPoint = CGPointMake(xPosition, (ABS(yPosition - maxY) > 0 && ABS(yPosition - maxY) < 0.5) ? maxY - 0.5 : yPosition);
        CGPoint endPoint = CGPointMake(xPosition, maxY);
        
        VolumePositionModel *positionModel = [VolumePositionModel modelWithStartPoint:startPoint endPoint:endPoint dayDesc:model.day];
        [self.drawPositionModels addObject:positionModel];
    }];
    
    return self.drawPositionModels;
}

- (NSMutableArray *)drawPositionModels {
    if (!_drawPositionModels) {
        _drawPositionModels = [NSMutableArray array];
    }
    return _drawPositionModels;
}

@end
