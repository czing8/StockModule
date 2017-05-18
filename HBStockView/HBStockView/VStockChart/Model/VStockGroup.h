//
//  VStockGroup.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//  股票模型

#import <Foundation/Foundation.h>

#import "VStockPoint.h"
#import "VLineModel.h"

#import "VBidPriceModel.h"
#import "VStockStatusModel.h"
#import "VTimeTradeModel.h"

@interface VStockGroup : NSObject

// ------- 股票参数 --------
@property (nonatomic, strong) VStockStatusModel     * stockStatusModel;
@property (nonatomic, strong) NSString  * stockCode;    // 股票代码

@property (nonatomic, assign) float price;              // 当前价
@property (nonatomic, assign) float preClosePrice;      // 昨日收盘价

@property (nonatomic, assign) float maxPrice;   // 最大价格
@property (nonatomic, assign) float minPrice;   // 最小价格
@property (nonatomic, assign) float maxVolume;  // 最大成交量
@property (nonatomic, assign) float minVolume;  // 最小成交量


// -------分时图模型数据 --------
@property (nonatomic, strong) NSMutableArray <VStockPoint *>    * lineModels;
@property (nonatomic, strong) NSMutableArray <VTimeTradeModel *>* tradeModels;
@property (nonatomic, strong) VBidPriceModel                    * bidPriceModel;


// -------K线图模型数据 --------
@property (nonatomic, strong) NSMutableArray <VLineModel *>     * kLineModels;

@end
