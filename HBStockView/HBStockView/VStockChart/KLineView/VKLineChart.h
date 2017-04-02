//
//  VKLineChart.h
//  HBStockView
//
//  Created by Vols on 2017/3/6.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStockGroup.h"

@interface VKLineChart : UIView

- (NSArray *)drawViewWithXPosition:(CGFloat)xPosition lineModels:(NSArray <VLineModel *>*)lineModels maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue;

@end
