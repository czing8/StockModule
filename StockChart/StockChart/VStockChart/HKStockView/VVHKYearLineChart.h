//
//  VLineChart.h
//  HBStockView
//
//  Created by Vols on 2017/3/29.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLineModel.h"

@interface VVHKYearLineChart : UIView

- (NSArray *)drawViewWithXPosition:(CGFloat)xPosition lineModels:(NSArray<VLineModel *> *)lineModels maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue;

@end
