//
//  StockRequest.h
//  HBStockView
//
//  Created by Vols on 2017/2/27.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VStockGroup.h"
#import "VStockConstant.h"

@interface StockRequest : NSObject

+ (void)getTimeStockData:(NSString *)code success:(void (^)(VStockGroup *response))success;

+ (void)get5DayStockDataSuccess:(void (^)(NSArray *resultArray))success;

+ (void)getDayStockData:(NSString *)stockCode fuQuanType:(VStockFuQuanType)fuQuanType success:(void (^)(VStockGroup *response))success;

+ (void)getWeekStockData:(NSString *)stockCode fuQuanType:(VStockFuQuanType)fuQuanType success:(void (^)(VStockGroup *response))success;

+ (void)getMonthStockData:(NSString *)stockCode fuQuanType:(VStockFuQuanType)fuQuanType success:(void (^)(VStockGroup *response))success;


+ (void)getDaDanRequest:(NSString *)stockCode success:(void (^)(NSArray *resultArray))success;
+ (void)getMingxiRequest:(NSString *)stockCode index:(NSString *)index success:(void (^)(NSArray *resultArray, NSString * index))success;


+ (void)getHKTimeStockData:(NSString *)code success:(void (^)(VStockGroup *response))success;

+ (void)getHKDayStockData:(NSString *)code fuQuanType:(VStockFuQuanType)fuQuanType success:(void (^)(VStockGroup *response))success;

+ (void)getHKWeekStockCode:(NSString *)code fuQuanType:(VStockFuQuanType)fuQuanType success:(void (^)(VStockGroup *response))success;

+ (void)getHKYearStockCode:(NSString *)code fuQuanType:(VStockFuQuanType)fuQuanType success:(void (^)(VStockGroup *response))success;


@end
