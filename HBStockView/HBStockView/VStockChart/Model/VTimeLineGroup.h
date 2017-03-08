//
//  VTimeLineGroup.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTimeLineModel.h"
#import "VBidPriceModel.h"

@interface VTimeLineGroup : NSObject

@property (nonatomic, strong) NSMutableArray <VTimeLineModel *> *lineModels;
@property (nonatomic, strong) VBidPriceModel  *bidPriceModel;

@property (nonatomic, assign) float price;      // 当前价
@property (nonatomic, assign) float preClosePrice;  // 昨日收盘价
@property (nonatomic, assign) float openPrice;  // 开盘价
@property (nonatomic, assign) float volume;     // 成交量
@property (nonatomic, assign) float waiPan;     // 外盘
@property (nonatomic, assign) float neiPan;     // 内盘


@property (nonatomic, assign) float maxPrice;   // 最大价格
@property (nonatomic, assign) float minPrice;   // 最小价格

@property (nonatomic, assign) float maxVolume;  // 最大成交量
@property (nonatomic, assign) float minVolume;  // 最小成交量







@end
