//
//  StockRequest.h
//  HBStockView
//
//  Created by Vols on 2017/2/27.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTimeLineGroup.h"
#import "VLineGroup.h"

@interface StockRequest : NSObject

+ (void)getTimeStockDataSuccess:(void (^)(VTimeLineGroup *response))success;

+ (void)get5DayStockDataSuccess:(void (^)(NSArray *resultArray))success;

+ (void)getDayStockDataSuccess:(void (^)(VLineGroup *response))success;

+ (void)getWeekStockDataSuccess:(void (^)(VLineGroup *response))success;

+ (void)getMonthStockDataSuccess:(void (^)(VLineGroup *response))success;

+ (void)getDaDanRequestSuccess:(void (^)(NSArray *resultArray))success;

//http://proxy.finance.qq.com/ifzqgtimg/appstock/app/HsDealinfo/getDadan?code=sz002185

+ (void)get:(NSString*) url params:(id)params success:(void (^)(NSDictionary *response))success fail:(void(^)(NSDictionary *info))fail;

@end
