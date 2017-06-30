//
//  VStockPoint.h
//  StockChart
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//  数据模型：分时图中每个点

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface VStockPoint : NSObject

@property (nonatomic, assign) CGFloat   price;              // 价格
@property (nonatomic, assign) CGFloat   volume;             // 成交量
@property (nonatomic, assign) CGFloat   preClosePrice;      // 前一天的收盘价

@property (nonatomic, assign) BOOL      isShowTimeDesc;     // 是否绘制在View上

@property (nonatomic, strong) NSString  * timeDesc;         // 日期
@property (nonatomic, strong) NSString  * dayDatail;        // 长按时显示的详细日期

@property (nonatomic, assign) CGFloat  totalPrice;          // 当天总成交价
@property (nonatomic, assign) CGFloat  totalVolume;         // 当天总成交量

@property (nonatomic, assign) CGFloat  avPrice;         // 均价

@end



