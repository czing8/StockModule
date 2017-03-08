//
//  VLineGroup.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLineModel.h"

@interface VLineGroup : NSObject

@property (nonatomic, strong) NSMutableArray <VLineModel *> *lineModels;

@property (nonatomic, assign) float maxPrice;   // 最大价格
@property (nonatomic, assign) float minPrice;   // 最小价格

@property (nonatomic, assign) float maxVolume;  // 最大成交量
@property (nonatomic, assign) float minVolume;  // 最小成交量

@end
