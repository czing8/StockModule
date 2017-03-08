//
//  UIColor+StockTheme.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "UIColor+StockTheme.h"

@implementation UIColor (StockTheme)

+ (UIColor *)colorWithHex:(UInt32)hex {
    return [UIColor colorWithHex:hex alpha:1.f];
}

+ (UIColor *)colorWithHex:(UInt32)hex alpha:(CGFloat)alpha {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

/************************************K线颜色配置***************************************/

+ (UIColor *)borderLineColor {
    return [UIColor grayColor];
}

/**
 *  整体背景颜色
 */
+ (UIColor *)stockMainBgColor {
    return [UIColor colorWithHex:0xffffff];
//    return [UIColor greenColor];
}

/**
 *  K线图背景辅助线颜色
 */
+ (UIColor *)VStock_bgLineColor {
    return [UIColor colorWithHex:0xEDEDED];
}

/**
 *  主文字颜色
 */
+ (UIColor *)VStock_textColor {
    return [UIColor colorWithHex:0xAFAFB3];
}


/**
 *  MA5线颜色
 */
+ (UIColor *)ma5LineColor {
    return [UIColor colorWithHex:0xFEB911];
}

/**
 *  MA10线颜色
 */
+ (UIColor *)ma10LineColor {
    return [UIColor colorWithHex:0x60CFFF];
}

/**
 *  MA20线颜色
 */
+ (UIColor *)ma20LineColor {
    return [UIColor colorWithHex:0xF184F5];
}

/**
 *  长按线颜色
 */
+ (UIColor *)selectedLineColor {
    return [UIColor colorWithHex:0xACAAA9];
}

/**
 *  长按出现的圆点的颜色
 */
+ (UIColor *)selectedPointColor {
    return [UIColor stock_increaseColor                                                                                  ];
}

/**
 *  长按出现的方块背景颜色
 */
+ (UIColor *)selectedRectBgColor {
    return [UIColor colorWithHex:0x659EE0];
}

/**
 *  长按出现的方块文字颜色
 */
+ (UIColor *)selectedRectTextColor {
    return [UIColor colorWithHex:0xffffff];
}

/**
 *  分时线颜色
 */
+ (UIColor *)timeLineColor {
//    return [UIColor colorWithHex:0x60CFFF];
    return [UIColor orangeColor];
}

/**
 *  昨日收盘价线颜色
 */
+ (UIColor *)midTimeLineColor {
    return [UIColor colorWithHex:0x60CFFF];
}

/**
 *  分时线下方背景色
 */
+ (UIColor *)timeLineBgColor {
    return [UIColor colorWithHex:0x60CFFF alpha:0.1f];
}

/**
 *  涨的颜色
 */
+ (UIColor *)stock_increaseColor {
    return [UIColor colorWithHex:0xE74C3C];
}

/**
 *  跌的颜色
 */
+ (UIColor *)stock_decreaseColor {
    return [UIColor colorWithHex:0x41CB47];
}


/************************************TopBar颜色配置***************************************/

/**
 *  顶部TopBar文字默认颜色
 */
+ (UIColor *)VStock_topBarNormalTextColor {
    return [UIColor colorWithHex:0xAFAFB3];
}

/**
 *  顶部TopBar文字选中颜色
 */
+ (UIColor *)VStock_topBarSelectedTextColor {
    return [UIColor colorWithHex:0x4A90E2];
}

/**
 *  顶部TopBar选中块辅助线颜色
 */
+ (UIColor *)VStock_topBarSelectedLineColor {
    return [UIColor colorWithHex:0x4A90E2];
}


@end
