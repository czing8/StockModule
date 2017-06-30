//
//  UIColor+StockTheme.h
//  StockChart
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (StockTheme)

/***************    K线颜色配置  ***************/


// 整体背景颜色
+ (UIColor *)stockMainBgColor;


// 股票图标边框颜色
+ (UIColor *)borderLineColor;


// 分时线颜色
+ (UIColor *)timeLineColor;


// 分时线下方背景色
+ (UIColor *)timeLineBgColor;


// 昨日收盘价线颜色
+ (UIColor *)midTimeLineColor;



/**
 *  K线图背景辅助线颜色
 */
+ (UIColor *)bgLineColor;

/**
 *  主文字颜色
 */
+ (UIColor *)stockTextColor;


/**
 *  MA5线颜色
 */
+ (UIColor *)ma5LineColor;

/**
 *  MA10线颜色
 */
+ (UIColor *)ma10LineColor;

/**
 *  MA20线颜色
 */
+ (UIColor *)ma20LineColor;


/**
 *  长按线颜色
 */
+ (UIColor *)selectedLineColor;


/**
 *  长按出现的圆点的颜色
 */
+ (UIColor *)selectedPointColor;

/**
 *  长按出现的方块背景颜色
 */
+ (UIColor *)selectedRectBgColor;

/**
 *  长按出现的方块文字颜色
 */
+ (UIColor *)selectedRectTextColor;






/**
 *  涨的颜色
 */
+ (UIColor *)stock_increaseColor;

/**
 *  跌的颜色
 */
+ (UIColor *)stock_decreaseColor;


/***************    TopBar颜色配置  ****************/

/**
 *  顶部TopBar文字默认颜色
 */
+ (UIColor *)topBarNormalTextColor;

/**
 *  顶部TopBar文字选中颜色
 */
+ (UIColor *)topBarSelectedTextColor;

/**
 *  顶部TopBar选中块辅助线颜色
 */
+ (UIColor *)topBarSelectedLineColor;


@end
