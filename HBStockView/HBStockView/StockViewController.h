//
//  ViewController.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStockView.h"

@interface StockViewController : UIViewController

- (instancetype)initStockVC:(NSString *)stockCode type:(VStockType)stockType;

@end

