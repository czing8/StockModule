//
//  VStockManager.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VStockChartConfig.h"
#import "VStockConstant.h"
#import "UIColor+StockTheme.h"
#import "VStockGroup.h"
#import "VTimeLineView.h"
#import "VKLineView.h"
#import "VStockStatusModel.h"

typedef void (^StockStatusBlock)(VStockStatusModel * stockStatusModel);

@interface VStockView : UIView

@property (nonatomic, assign) VStockType        stockType;
@property (nonatomic, assign) VStockChartType   stockChartType;
@property (nonatomic, copy  ) StockStatusBlock  stockStatusBlock;


/**
 初始化函数
 
 @param stockType 股票类型，港股 or A股
 */
- (instancetype)initWithStockCode:(NSString *)stockCode stockType:(VStockType)stockType;

- (void)reloadStockData;


/**
 设置股票刷新时间
 */
- (void)setRefreshTime:(float)refreshTime;

@end
