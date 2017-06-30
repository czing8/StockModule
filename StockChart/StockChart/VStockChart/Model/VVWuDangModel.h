//
//  VVWuDangModel.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//  五档竞价数据模型

#import <Foundation/Foundation.h>

@interface VVWuDangModel : NSObject

@property (nonatomic, strong) NSArray * buyPrices;    // 买价格数组 ，没有价格时 @"--"
@property (nonatomic, strong) NSArray * sellPrices;   // 卖价格数组

@property (nonatomic, strong) NSArray * buyVolumes;   // 买成交量数组
@property (nonatomic, strong) NSArray * sellVolumes;  // 卖成交量数组

@property (nonatomic, strong) NSArray * buyDescs;     //  买5文字描述
@property (nonatomic, strong) NSArray * sellDescs;    //  卖5文字描述

@end
