//
//  VKLineView.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStockGroup.h"
#import "VStockChartConfig.h"
#import "UIColor+StockTheme.h"
#import "VStockConstant.h"


typedef void (^StockFuQuanStatusBlock)(VStockFuQuanType fuQuanType);

@interface VKLineView : UIView

@property (nonatomic, copy  ) StockFuQuanStatusBlock  fuQuanStatusBlock;

- (instancetype)initWithChartType:(VStockChartType)chartType;


/**
 传入Code，内部从网络请求数据
 */
- (void)reloadData:(NSString *)stockCode fuQuan:(VStockFuQuanType)fuQuanType;
- (void)reloadData:(NSString *)stockCode fuQuan:(VStockFuQuanType)fuQuanType success:(void(^)(VStockGroup * stockGroup))success;


/**
 传入全部数据，只需要刷新UI
 */
- (void)reloadWithGroup:(VStockGroup *)stockGroup fuQuan:(VStockFuQuanType)fuQuanType;


@end
