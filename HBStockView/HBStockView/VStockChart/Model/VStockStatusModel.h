//
//  StockStatusModel.h
//  HBStockView
//
//  Created by Vols on 2017/3/9.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VStockStatusModel : NSObject

@property (nonatomic, assign) float price;          // 当前价
@property (nonatomic, assign) float wavePrice;      // 点数波动
@property (nonatomic, assign) float wavePercent;    // 当前涨跌幅

@property (nonatomic, assign) float openPrice;      // 开盘价
@property (nonatomic, assign) float preClosePrice;  // 昨日收盘价
@property (nonatomic, assign) float volume;         // 总成交量（单位手）
@property (nonatomic, assign) float turnoverRate;   // 换手率

@property (nonatomic, assign) float maxPrice;       // 最大价格
@property (nonatomic, assign) float minPrice;       // 最小价格
@property (nonatomic, assign) float volumePrice;    // 总成交量（价格）

@property (nonatomic, assign) float waiPan;         // 外盘
@property (nonatomic, assign) float neiPan;         // 内盘
@property (nonatomic, assign) float ZSZ;            // 总市值（价格）

@property (nonatomic, assign) float     LTSZ;       // 流通市值（价格）
@property (nonatomic, strong) NSString  * PEG;      // 市盈率
@property (nonatomic, strong) NSString  * ZF;       // 振幅

@property (nonatomic, assign) float maxVolume;      // 最大成交量
@property (nonatomic, assign) float minVolume;      // 最小成交量


// 港股独有参数
@property (nonatomic, strong) NSString  * maxPrice_52Week;      // 52周最大价格
@property (nonatomic, strong) NSString  * minPrice_52Week;      // 52周最小价格
@property (nonatomic, strong) NSString  * ZXL;      // 周息率

@end
