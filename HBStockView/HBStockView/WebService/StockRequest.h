//
//  StockRequest.h
//  HBStockView
//
//  Created by Vols on 2017/2/27.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VStockGroup.h"
//#import "VStockGroup.h"

@interface StockRequest : NSObject

+ (void)getTimeStockData:(NSString *)code success:(void (^)(VStockGroup *response))success;

+ (void)get5DayStockDataSuccess:(void (^)(NSArray *resultArray))success;

+ (void)getDayStockData:(NSString *)stockCode success:(void (^)(VStockGroup *response))success;

+ (void)getWeekStockData:(NSString *)stockCode success:(void (^)(VStockGroup *response))success;

+ (void)getMonthStockData:(NSString *)stockCode success:(void (^)(VStockGroup *response))success;

+ (void)getDaDanRequest:(NSString *)stockCode success:(void (^)(NSArray *resultArray))success;


+ (void)getHKTimeStockData:(NSString *)code success:(void (^)(VStockGroup *response))success;

+ (void)getHKDayStockData:(NSString *)code success:(void (^)(VStockGroup *response))success;

+ (void)getHKWeekStockCode:(NSString *)code success:(void (^)(VStockGroup *response))success;

+ (void)getHKYearStockCode:(NSString *)code success:(void (^)(VStockGroup *response))success;


+ (void)get:(NSString*) url params:(id)params success:(void (^)(NSDictionary *response))success fail:(void(^)(NSDictionary *info))fail;

@end
