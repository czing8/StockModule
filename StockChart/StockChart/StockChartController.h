//
//  ViewController.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStockView.h"

@interface StockChartController : UIViewController

@property (nonatomic, assign) float   refreshTime;  //修改股票刷新时间

- (instancetype)initStockVC:(NSString *)stockCode type:(VStockType)stockType;

@end

