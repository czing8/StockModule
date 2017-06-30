//
//  VStockScrollView.h
//  StockChart
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStockChartConfig.h"
#import "VStockConstant.h"

@interface VStockScrollView : UIScrollView

@property (nonatomic, strong) UIView    * contentView;

@property (nonatomic, assign) VStockChartType stockType;

@property (nonatomic, assign) BOOL  isShowBgLine;

@end
