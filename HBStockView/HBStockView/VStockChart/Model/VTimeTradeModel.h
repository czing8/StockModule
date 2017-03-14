//
//  VTimeTradeModel.h
//  HBStockView
//
//  Created by Vols on 2017/3/13.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTimeTradeModel : NSObject

@property (nonatomic, strong) NSString  * tradeTime;       // 日期
@property (nonatomic, strong) NSString  * tradePrice;       // 日期
@property (nonatomic, strong) NSString  * tradeVolmue;       // 日期
@property (nonatomic, assign) NSInteger   tradeType;       // -1:卖,0:中性盘,1:买

@end
