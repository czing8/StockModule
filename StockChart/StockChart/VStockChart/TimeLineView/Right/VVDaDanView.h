//
//  VVDaDanView.h
//  HBStockView
//
//  Created by Vols on 2017/5/23.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTimeTradeModel.h"

@interface VVDaDanView : UIView

@property (nonatomic, strong) NSString * stockCode;

- (void)reloadWithStockCode:(NSString *)stockCode;

- (void)reloadWithData:(NSArray <VTimeTradeModel *>*)tradeModels;


@end
