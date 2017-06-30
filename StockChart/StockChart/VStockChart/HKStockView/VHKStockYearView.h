//
//  VHKStockYearView.h
//  StockChart
//
//  Created by Vols on 2017/3/28.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStockGroup.h"
#import "VStockConstant.h"

@interface VHKStockYearView : UIView

//直接传全部数据，刷新UI
- (void)reloadWithGroup:(VStockGroup *)stockGroup;

//传入Code，内部从网络拉取数据
- (void)reloadData:(NSString *)stockCode fuQuan:(VStockFuQuanType)fuQuanType;

@end
