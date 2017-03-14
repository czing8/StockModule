//
//  VStockChartConfig.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VStockChartConfig.h"
#import "VStockConstant.h"

/**
 K线图中蜡烛的宽度
 */
static CGFloat kStockLineWidth = 6;

/**
 分时图成交量线宽度
 */
static CGFloat kStockTimeLineVolumeWidth = 6;

/**
 K线图的间隔，初始值为1
 */
static CGFloat kStockLineGap = 1;

/**
 KLineView的高度占比
 */
static CGFloat kStockChartViewRadio = 0.7;

/**
 成交量图的高度占比
 */
static CGFloat kVolumeViewRadio = 0.28;

/**
 设置K线宽度数组
 */
static NSMutableArray *kStockLineWidthArray;

/**
 设置当前从哪个K线宽度数组进行存取
 */
static NSInteger kStockLineWidthIndex;


@implementation VStockChartConfig

/**
 K线图中蜡烛的宽度
 */
+ (CGFloat)lineWidth {
    if (kStockLineWidthIndex >= 0 && kStockLineWidthArray && [kStockLineWidthArray count] > kStockLineWidthIndex) {
        return [kStockLineWidthArray[kStockLineWidthIndex] floatValue];
    } else {
        return kStockLineWidth;
    }
}

/**
 设置K线图中蜡烛的宽度
 
 @param lineWidth 宽度
 */
+ (void)setLineWith:(CGFloat)lineWidth {
    if (lineWidth > kStockLineMaxWidth) {
        lineWidth = kStockLineMaxWidth;
    }else if (lineWidth < kStockLineMinWidth){
        lineWidth = kStockLineMinWidth;
    }
    if (kStockLineWidthIndex >= 0 && kStockLineWidthArray && [kStockLineWidthArray count] > kStockLineWidthIndex) {
        kStockLineWidthArray[kStockLineWidthIndex] = [NSNumber numberWithFloat:lineWidth];
    } else {
        kStockLineWidth = lineWidth;
    }
}

/**
 分时线的成交量线的宽度
 */
+ (CGFloat)timeLineVolumeWidth {
    return kStockTimeLineVolumeWidth;
}

/**
 设置分时线的成交量线的宽度
 
 @param timeLineVolumeWidth 宽度
 */
+ (void)setTimeLineVolumeWidth:(CGFloat)timeLineVolumeWidth {
    kStockTimeLineVolumeWidth = timeLineVolumeWidth;
}

/**
 K线图的间隔，初始值为1
 */
+ (CGFloat)lineGap {
    return kStockLineGap;
}



+ (void)setLineGap:(CGFloat)lineGap {
    kStockLineGap = lineGap;
}

+ (CGFloat)lineChartRadio {
    return kStockChartViewRadio;
}


+ (void)setLineChartRadio:(CGFloat)radio {
    kStockChartViewRadio = radio;
}


+ (CGFloat)volumeViewRadio {
    return kVolumeViewRadio;
}

+ (void)setVolumeViewRadio:(CGFloat)radio {
    kVolumeViewRadio = radio;
}


+ (void)setStockLineWidthArray:(NSArray <NSNumber *>*)lineWidthArray {
    kStockLineWidthArray = lineWidthArray.mutableCopy;
}

+ (void)setStockLineWidthIndex:(NSInteger)lineWidthindex {
    kStockLineWidthIndex = lineWidthindex;
}

@end
