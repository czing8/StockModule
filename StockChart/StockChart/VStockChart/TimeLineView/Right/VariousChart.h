//
//  VariousChart.h
//  BZChart
//
//  Created by Vols on 2015/4/11.
//  Copyright © 2015年 vols. All rights reserved.
//  表格

#import <UIKit/UIKit.h>

@interface VariousChart : UIView

/**
 画饼状图

 @param keys 关键字数组
 @param values 关键字对应的值数组
 */
- (void)drawPieChart:(NSArray *)keys values:(NSArray *)values;


/**
 画柱状图
 */
- (void)drawBarChart:(NSArray *)keys values:(NSArray *)values;


/**
 画折线图
 */
- (void)drawLineChart:(NSArray *)keys values:(NSArray *)values;


@end
