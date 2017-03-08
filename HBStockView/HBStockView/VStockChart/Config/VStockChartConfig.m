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
static CGFloat VStockLineWidth = 6;

/**
 分时图成交量线宽度
 */
static CGFloat VStockTimeLineVolumeWidth = 6;

/**
 K线图的间隔，初始值为1
 */
static CGFloat VStockLineGap = 1;

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
static NSMutableArray *VStockLineWidthArray;

/**
 设置当前从哪个K线宽度数组进行存取
 */
static NSInteger VStockLineWidthIndex;


@implementation VStockChartConfig

/**
 K线图中蜡烛的宽度
 */
+ (CGFloat)lineWidth {
    if (VStockLineWidthIndex >= 0 && VStockLineWidthArray && [VStockLineWidthArray count] > VStockLineWidthIndex) {
        return [VStockLineWidthArray[VStockLineWidthIndex] floatValue];
    } else {
        return VStockLineWidth;
    }
}

/**
 设置K线图中蜡烛的宽度
 
 @param lineWidth 宽度
 */
+ (void)setLineWith:(CGFloat)lineWidth {
    if (lineWidth > VStockLineMaxWidth) {
        lineWidth = VStockLineMaxWidth;
    }else if (lineWidth < VStockLineMinWidth){
        lineWidth = VStockLineMinWidth;
    }
    if (VStockLineWidthIndex >= 0 && VStockLineWidthArray && [VStockLineWidthArray count] > VStockLineWidthIndex) {
        VStockLineWidthArray[VStockLineWidthIndex] = [NSNumber numberWithFloat:lineWidth];
    } else {
        VStockLineWidth = lineWidth;
    }
}

/**
 分时线的成交量线的宽度
 */
+ (CGFloat)timeLineVolumeWidth {
    return VStockTimeLineVolumeWidth;
}

/**
 设置分时线的成交量线的宽度
 
 @param timeLineVolumeWidth 宽度
 */
+(void)setTimeLineVolumeWidth:(CGFloat)timeLineVolumeWidth {
    VStockTimeLineVolumeWidth = timeLineVolumeWidth;
}

/**
 K线图的间隔，初始值为1
 */
+ (CGFloat)lineGap {
    return VStockLineGap;
}



+ (void)setLineGap:(CGFloat)lineGap {
    VStockLineGap = lineGap;
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
    VStockLineWidthArray = lineWidthArray.mutableCopy;
}

+ (void)setStockLineWidthIndex:(NSInteger)lineWidthindex {
    VStockLineWidthIndex = lineWidthindex;
}

@end
