//
//  VTimeLineView.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//  分时图主类

#import <UIKit/UIKit.h>
#import "VStockGroup.h"
#import "VStockConstant.h"

typedef void (^StockStatusBlock)(VStockStatusModel * stockStatusModel);

@interface VTimeLineView : UIView

- (instancetype)initWithType:(VStockType)stockType;

/**
 传入Code，内部从网络请求数据
 */
- (void)reloadWithStockCode:(NSString *)stockCode success:(void(^)(VStockGroup * stockGroup))success;


/**
 传入全部数据，只需要刷新UI
 */
- (void)reloadWithGroup:(VStockGroup *)stockGroup;

@end
