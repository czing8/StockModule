//
//  VStockConstant.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#ifndef VStockConstant_h
#define VStockConstant_h

//股票图表数据类型
typedef NS_ENUM(NSInteger, VStockChartType) {
    VStockChartTypeTimeLine,
    VStockChartTypeDayLine,
    VStockChartTypeWeekLine,
    VStockChartTypeMonthLine,
    VStockChartTypeYearLine,        // 港股的年线图
};

//
typedef NS_ENUM(NSInteger, VStockFuQuanType) {
    VStockFuQuanTypeNone = 0,   // 不复权
    VStockFuQuanTypeQian,   // 前复权
    VStockFuQuanTypeHou,    // 后复权
};

/**
 *  股票类型（A股，港股）
 */
typedef NS_ENUM(NSInteger, VStockType) {
    VStockTypeCN = 1,       //A股
    VStockTypeHK,           //港股
};


/**
 *  图标总高度
 */
#define     kStockChartHeight   210


/**
 *  K线最小的厚度
 */
#define     kStockLineMinThick 0.5


/**
 *  K线最大的宽度
 */
#define     kStockLineMaxWidth 20

/**
 *  K线图最小的宽度
 */
#define     kStockLineMinWidth 3

/**
 *  时分线的宽度
 */
#define     kStockTimeLineWidth 1

/**
 *  上下影线宽度
 */
#define     kStockShadowLineWidth 1.2

/**
 *  MA线宽度
 */
#define     kStockMALineLineWidth   1.2

/**
 * 圆点的半径
 */
#define     kStockPointRadius   3

/**
 *  K线图上可画区域最小的Y
 */
#define     kStockLineMainViewMinY  5

/**
 *  K线图的成交量上最小的Y
 */
#define     kStockLineVolumeViewMinY 2

/**
 *  K线图的成交量下面日期高度
 */
#define     kStockLineDayHeight     12


/**
 *  TopBar的高度
 */
#define     kStockTopBarViewHeight  40

/**
 *  TopBar的按钮宽度
 */
#define     kStockTopBarViewWidth   94

/**
 *  TopBar和StockView的间距
 */
#define     kStockViewGap   1


/**
 *  K线ScrollView距离顶部的距离
 */
#define     kStockScrollViewTopGap 5

/**
 *  K线ScrollView距离左边的距离
 */
#define     VStockScrollViewLeftGap 40

/**
 *  K线ScrollView距离左部的距离
 */
#define     kStockScrollViewLeftGap 5

/**
 *  分时图成交量线的间距
 */
#define     kStockTimeVolumeLineGap 0.1

/**
 *  五档图宽度
 */
#define     kStockBidPriceViewWidth 100



/**
 *  K线图缩放界限
 */
#define  kStockLineScaleBound 0.03

/**
 *  K线的缩放因子
 */
#define kStockLineScaleFactor 0.06


//Accessory指标种类
typedef NS_ENUM(NSInteger, VStockTargetLineStatus) {
    VStockTargetLineStatusMACD = 100,       //MACD线
    VStockTargetLineStatusKDJ,              //KDJ线
    VStockTargetLineStatusAccessoryClose,   //关闭Accessory线
    VStockTargetLineStatusMA ,              //MA线
    VStockTargetLineStatusEMA,              //EMA线
    VStockTargetLineStatusCloseMA           //MA关闭线
};


#endif /* VStockConstant_h */
