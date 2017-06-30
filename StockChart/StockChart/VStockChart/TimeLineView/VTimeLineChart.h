//
//  VTimeLineSubView.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//  分时图模块里的分时图表格

#import <UIKit/UIKit.h>
#import "VStockGroup.h"

@interface VTimeLineChart : UIView

- (NSArray *)drawViewWithXPosition:(CGFloat)xPosition stockGroup:(VStockGroup *)stockGroup maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue;

@end
