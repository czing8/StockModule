//
//  StockRequest.m
//  HBStockView
//
//  Created by Vols on 2017/2/27.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "StockRequest.h"
#import "HttpHelper.h"

@implementation StockRequest

+ (void)getTimeStockData:(NSString *)stockCode success:(void (^)(VStockGroup *response))success {
    // sz002185
    NSString * urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/minute/query?p=1&code=%@", stockCode];
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        
        NSDictionary * resultDic    = flag[@"data"][stockCode];
        NSArray * stockStatusArray  = resultDic[@"qt"][stockCode];
        NSString * tradeString  = resultDic[@"mx_price"][@"mx"][@"data"][1];

        NSArray * tradeModels = [self tradeModelsFrom:tradeString];
        
        float curPrice = [stockStatusArray[3] floatValue];
        float closePrice = [stockStatusArray[4] floatValue];
        
        // ---- 股票各种参数模型
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray  isHK:NO];
    
        
        // ---- 股票五档竞价模型
        NSArray *buyPrices = @[stockStatusArray[9], stockStatusArray[11], stockStatusArray[13], stockStatusArray[15], stockStatusArray[17]];
        NSArray *sellPrices = @[stockStatusArray[27], stockStatusArray[25], stockStatusArray[23], stockStatusArray[21], stockStatusArray[19]];
        
        NSArray *buyVolumes = @[stockStatusArray[10], stockStatusArray[12], stockStatusArray[14], stockStatusArray[16], stockStatusArray[18]];
        NSArray *sellVolumes = @[stockStatusArray[28], stockStatusArray[26], stockStatusArray[24], stockStatusArray[22], stockStatusArray[20]];
        
        VBidPriceModel * bidPriceModel = [[VBidPriceModel alloc]init];
        bidPriceModel.buyPrices = buyPrices;
        bidPriceModel.buyVolumes = buyVolumes;
        bidPriceModel.sellPrices = sellPrices;
        bidPriceModel.sellVolumes = sellVolumes;


        // ---- 股票K线数组
        NSMutableArray * timeLineModels = [[NSMutableArray alloc] init];
        
        NSArray * data = resultDic[@"data"][@"data"];
        
        float maxPrice = 0.0, minPrice = 0.0, maxVolume = 0.0, minVolume = 0.0;
        float tmpVolume = 0.0;
        
        for (int i = 0; i < data.count; i ++) {
            NSString *timeStockData = data[i];
            NSArray * item = [timeStockData componentsSeparatedByString:@" "];
            
            float price = [item[1] floatValue];
            float volume = [item[2] floatValue];
            
            VStockPoint *model = [[VStockPoint alloc]init];
            model.price = price;
            model.volume = volume - tmpVolume;
            model.preClosePrice = closePrice;
            [timeLineModels addObject:model];
            
            if (i == 0) {
                maxPrice = [item[1] floatValue];
                minPrice = maxPrice;
                
                maxVolume = [item[2] floatValue];
                minVolume = maxVolume;
            }
            
            if (price > maxPrice) {
                maxPrice = price;
            }
            
            if (price < minPrice) {
                minPrice = price;
            }
            
            if (model.volume > maxVolume) {
                maxVolume = model.volume;
            }
            
            if (model.volume < minVolume) {
                minVolume = model.volume;
            }
            
            tmpVolume = volume;
        }
        
        VStockGroup * timeGroup = [[VStockGroup alloc] init];
        timeGroup.stockCode         = stockCode;
        
        timeGroup.tradeModels       = [NSMutableArray arrayWithArray:[[tradeModels reverseObjectEnumerator] allObjects]];
        timeGroup.stockStatusModel  = statusModel;
        timeGroup.bidPriceModel     = bidPriceModel;
        timeGroup.lineModels        = timeLineModels;
        
        timeGroup.maxPrice = maxPrice;
        timeGroup.minPrice = minPrice;
        timeGroup.maxVolume= maxVolume;
        timeGroup.minVolume= minVolume;
        timeGroup.preClosePrice = closePrice;
        timeGroup.price = curPrice;

        success(timeGroup);
        
    } failue:^(NSError *error) {
        
    }];
}


+ (void)get5DayStockDataSuccess:(void (^)(NSArray *resultArray))success {
    NSString * urlString = @"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/day/query?p=1&code=sz002185";

    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][@"sz002185"];
        NSArray * fiveDayData = resultDic[@"data"];
        NSLog(@"fiveDayData:%@", fiveDayData);
        
    } failue:^(NSError *error) {
        
    }];
}

+ (void)getDayStockData:(NSString *)stockCode success:(void (^)(VStockGroup *response))success {
    NSString * urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/fqkline/get?p=1&param=%@,day,,,320,qfq", stockCode];

    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][stockCode];
        
        NSArray * stockStatusArray = resultDic[@"qt"][stockCode];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray  isHK:NO];

        NSArray * stockData = resultDic[@"qfqday"];
        NSMutableArray* lineModels = [[NSMutableArray alloc] init];
        int MA5 = 5, MA10 = 10, MA20 = 20;  // 均线统计
        
        for (int i = 0; i < stockData.count; i ++) {
            NSArray *item = stockData[i];
            VLineModel * model = [[VLineModel alloc] init];
            model.day = item[0];
            model.openPrice = [item[1] floatValue];
            model.closePrice = [item[2] floatValue];
            model.highestPrice = [item[3] floatValue];
            model.lowestPrice = [item[4] floatValue];
            model.volume = [item[5] floatValue];
            
            if (i >= 5) {
                model.ma5 = [self averageWithData:stockData range:NSMakeRange(i-MA5+1, MA5)];
            }
            if (i >= 10) {
                model.ma10 = [self averageWithData:stockData range:NSMakeRange(i-MA10+1, MA10)];
            }
            if (i >= 20) {
                model.ma20 = [self averageWithData:stockData range:NSMakeRange(i-MA20+1, MA20)];
            }
            
            [lineModels addObject:model];
        }
        
        VStockGroup * stockGroup = [[VStockGroup alloc] init];
        stockGroup.stockCode         = stockCode;

        stockGroup.kLineModels = lineModels;
        stockGroup.stockStatusModel = statusModel;
        success(stockGroup);
        
    } failue:^(NSError *error) {
        
    }];

}


+ (void)getWeekStockData:(NSString *)stockCode success:(void (^)(VStockGroup *response))success {
    
    NSString * urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/fqkline/get?p=1&param=%@,week,,,320,qfq", stockCode];
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][stockCode];

        NSArray * stockData = resultDic[@"qfqweek"];
        NSArray * stockStatusArray = resultDic[@"qt"][stockCode];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray  isHK:NO];

        NSLog(@"WeekStockData:%@", stockData);

        NSMutableArray* lineModels = [[NSMutableArray alloc] init];
        int MA5 = 5, MA10 = 10, MA20 = 20;  // 均线统计
        
        for (int i = 0; i < stockData.count; i ++) {
            NSArray *item = stockData[i];
            VLineModel * model = [[VLineModel alloc] init];
            model.day = item[0];
            model.openPrice = [item[1] floatValue];
            model.closePrice = [item[2] floatValue];
            model.highestPrice = [item[3] floatValue];
            model.lowestPrice = [item[4] floatValue];
            model.volume = [item[5] floatValue];
            
            if (i >= 5) {
                model.ma5 = [self averageWithData:stockData range:NSMakeRange(i-MA5+1, MA5)];
            }
            if (i >= 10) {
                model.ma10 = [self averageWithData:stockData range:NSMakeRange(i-MA10+1, MA10)];
            }
            if (i >= 20) {
                model.ma20 = [self averageWithData:stockData range:NSMakeRange(i-MA20+1, MA20)];
            }
            
            [lineModels addObject:model];
        }
        
        VStockGroup * stockGroup = [[VStockGroup alloc] init];
        stockGroup.stockCode         = stockCode;

        stockGroup.kLineModels = lineModels;
        stockGroup.stockStatusModel = statusModel;
        success(stockGroup);
    } failue:^(NSError *error) {
        
    }];

}

+ (void)getMonthStockData:(NSString *)stockCode success:(void (^)(VStockGroup *response))success {
    NSString * urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/fqkline/get?p=1&param=%@,month,,,320,qfq", stockCode];
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][stockCode];
        NSArray * stockData = resultDic[@"qfqmonth"];
        
        NSArray * stockStatusArray = resultDic[@"qt"][stockCode];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray  isHK:NO];

        NSLog(@"MonthStockData:%@", stockData);
        
        NSMutableArray* lineModels = [[NSMutableArray alloc] init];
        int MA5 = 5, MA10 = 10, MA20 = 20;  // 均线统计
        
        for (int i = 0; i < stockData.count; i ++) {
            NSArray *item = stockData[i];
            VLineModel * model = [[VLineModel alloc] init];
            model.day = item[0];
            model.openPrice = [item[1] floatValue];
            model.closePrice = [item[2] floatValue];
            model.highestPrice = [item[3] floatValue];
            model.lowestPrice = [item[4] floatValue];
            model.volume = [item[5] floatValue];
            
            if (i >= 5) {
                model.ma5 = [self averageWithData:stockData range:NSMakeRange(i-MA5+1, MA5)];
            }
            if (i >= 10) {
                model.ma10 = [self averageWithData:stockData range:NSMakeRange(i-MA10+1, MA10)];
            }
            if (i >= 20) {
                model.ma20 = [self averageWithData:stockData range:NSMakeRange(i-MA20+1, MA20)];
            }
            
            [lineModels addObject:model];
        }
        
        VStockGroup * stockGroup = [[VStockGroup alloc] init];
        stockGroup.stockCode         = stockCode;

        stockGroup.kLineModels = lineModels;
        stockGroup.stockStatusModel = statusModel;
        success(stockGroup);
    } failue:^(NSError *error) {
        
    }];
}


+ (void)getDaDanRequest:(NSString *)stockCode success:(void (^)(NSArray *resultArray))success {
    NSString * urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/HsDealinfo/getDadan?code=%@", stockCode];

//    NSString * urlString = @"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/HsDealinfo/getDadan?code=sz002185";
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSArray * daDanData = flag[@"data"][@"detail"];
        NSLog(@"daDanData:%@", daDanData);
        
        NSMutableArray * array = [NSMutableArray new];
        
        for (int i = 0; i < daDanData.count; i ++) {
            NSArray *tmpArray = daDanData[i];

            VTimeTradeModel * model = [[VTimeTradeModel alloc] init];
            model.tradeTime = [tmpArray[0] substringToIndex:5];
            model.tradePrice = tmpArray[1];
            model.tradeVolmue = tmpArray[2];
            if ([tmpArray[3] isEqualToString:@"S"]) {
                model.tradeType = -1;
            }
            else if ([tmpArray[3] isEqualToString:@"B"]) {
                model.tradeType = 1;
            }
            else {
                model.tradeType = 0;
            }
            
            [array addObject:model];
        }
        success(array);
        
    } failue:^(NSError *error) {
        
    }];
}



+ (void)getHKTimeStockData:(NSString *)stockCode success:(void (^)(VStockGroup *response))success {
//    hk01211
    NSString * urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/HkMinute/query?p=1&code=%@", stockCode];
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
   
        NSDictionary * resultDic = flag[@"data"][stockCode];

        
        // ---- 股票各种参数
        NSArray * stockStatusArray  = resultDic[@"qt"][stockCode];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray isHK:YES];
        
        // ---- 股票K线点数组
        NSArray * data = resultDic[@"data"][@"data"];

        NSMutableArray * timeLineModels = [[NSMutableArray alloc] init];
        float maxPrice = 0.0, minPrice = 0.0, maxVolume = 0.0, minVolume = 0.0;
        float tmpVolume = 0.0;
        
        for (int i = 0; i < data.count; i ++) {
            NSString *timeStockData = data[i];
            NSArray * item = [timeStockData componentsSeparatedByString:@" "];
            
            float price = [item[1] floatValue];
            float volume = [item[2] floatValue];
            
            VStockPoint *model = [[VStockPoint alloc]init];
            model.price = price;
            model.volume = volume - tmpVolume;
            model.preClosePrice = [stockStatusArray[4] floatValue];
            [timeLineModels addObject:model];
            
            if (i == 0) {
                maxPrice = [item[1] floatValue];
                minPrice = maxPrice;
                
                maxVolume = [item[2] floatValue];
                minVolume = maxVolume;
            }
            
            if (price > maxPrice) {
                maxPrice = price;
            }
            
            if (price < minPrice) {
                minPrice = price;
            }
            
            if (model.volume > maxVolume) {
                maxVolume = model.volume;
            }
            
            if (model.volume < minVolume) {
                minVolume = model.volume;
            }
            
            tmpVolume = volume;
        }
        
        VStockGroup * timeGroup = [[VStockGroup alloc] init];
        timeGroup.stockCode         = stockCode;

        timeGroup.stockStatusModel  = statusModel;
        timeGroup.lineModels        = timeLineModels;
        
        timeGroup.maxPrice = maxPrice;
        timeGroup.minPrice = minPrice;
        timeGroup.maxVolume= maxVolume;
        timeGroup.minVolume= minVolume;
        timeGroup.preClosePrice = [stockStatusArray[4] floatValue];
        
        success(timeGroup);
        
    } failue:^(NSError *error) {
        
    }];
}


+ (void)getHKDayStockData:(NSString *)stockCode success:(void (^)(VStockGroup *response))success {
    NSString * urlString = [NSString stringWithFormat:@"http://123.126.122.40/ifzqgtimg/appstock/app/newkline/newkline?p=1&param=%@,day,,,320", stockCode];

    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][stockCode];
        
        NSArray * stockStatusArray = resultDic[@"qt"][stockCode];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray  isHK:YES];
        
        NSArray * stockData = resultDic[@"day"];
        NSMutableArray* lineModels = [[NSMutableArray alloc] init];
        int MA5 = 5, MA10 = 10, MA20 = 20;  // 均线统计
        
        for (int i = 0; i < stockData.count; i ++) {
            NSArray *item = stockData[i];
            VLineModel * model = [[VLineModel alloc] init];
            model.day = item[0];
            model.openPrice = [item[1] floatValue];
            model.closePrice = [item[2] floatValue];
            model.highestPrice = [item[3] floatValue];
            model.lowestPrice = [item[4] floatValue];
            model.volume = [item[5] floatValue];
            
            if (i >= 5) {
                model.ma5 = [self averageWithData:stockData range:NSMakeRange(i-MA5+1, MA5)];
            }
            if (i >= 10) {
                model.ma10 = [self averageWithData:stockData range:NSMakeRange(i-MA10+1, MA10)];
            }
            if (i >= 20) {
                model.ma20 = [self averageWithData:stockData range:NSMakeRange(i-MA20+1, MA20)];
            }
            
            [lineModels addObject:model];
        }
        
        VStockGroup * stockGroup = [[VStockGroup alloc] init];
        stockGroup.stockCode    = stockCode;

        stockGroup.kLineModels  = lineModels;
        stockGroup.stockStatusModel = statusModel;
        success(stockGroup);

    } failue:^(NSError *error) {
        
    }];
}


+ (void)getHKWeekStockCode:(NSString *)stockCode success:(void (^)(VStockGroup *response))success {
    NSString * urlString = [NSString stringWithFormat:@"http://123.126.122.40/ifzqgtimg/appstock/app/newkline/newkline?p=1&param=%@,week,,,320", stockCode];
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][stockCode];
        
        NSArray * stockData = resultDic[@"week"];
        NSArray * stockStatusArray = resultDic[@"qt"][stockCode];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray  isHK:YES];
        
        NSMutableArray* lineModels = [[NSMutableArray alloc] init];
        int MA5 = 5, MA10 = 10, MA20 = 20;  // 均线统计
        
        for (int i = 0; i < stockData.count; i ++) {
            NSArray *item = stockData[i];
            VLineModel * model = [[VLineModel alloc] init];
            model.day = item[0];
            model.openPrice = [item[1] floatValue];
            model.closePrice = [item[2] floatValue];
            model.highestPrice = [item[3] floatValue];
            model.lowestPrice = [item[4] floatValue];
            model.volume = [item[5] floatValue];
            
            if (i >= 5) {
                model.ma5 = [self averageWithData:stockData range:NSMakeRange(i-MA5+1, MA5)];
            }
            if (i >= 10) {
                model.ma10 = [self averageWithData:stockData range:NSMakeRange(i-MA10+1, MA10)];
            }
            if (i >= 20) {
                model.ma20 = [self averageWithData:stockData range:NSMakeRange(i-MA20+1, MA20)];
            }
            
            [lineModels addObject:model];
        }
        
        VStockGroup * stockGroup = [[VStockGroup alloc] init];
        stockGroup.stockCode    = stockCode;
        stockGroup.kLineModels  = lineModels;
        stockGroup.stockStatusModel = statusModel;
        success(stockGroup);
        
    } failue:^(NSError *error) {
        
    }];
}

+ (void)getHKYearStockCode:(NSString *)stockCode success:(void (^)(VStockGroup *response))success {
    NSString * urlString = [NSString stringWithFormat:@"http://123.126.122.40/ifzqgtimg/appstock/app/newkline/newkline?p=1&param=%@,day,,,260", stockCode];
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][stockCode];
        
        NSArray * stockStatusArray = resultDic[@"qt"][stockCode];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray  isHK:YES];
        
        NSArray * stockData = resultDic[@"day"];
        NSMutableArray* lineModels = [[NSMutableArray alloc] init];
        int MA5 = 5, MA10 = 10, MA20 = 20;  // 均线统计
        
        float maxPrice = 0.0, minPrice = 0.0, maxVolume = 0.0, minVolume = 0.0;
        
        for (int i = 0; i < stockData.count; i ++) {
            NSArray *item = stockData[i];
            VLineModel * model = [[VLineModel alloc] init];
            model.day = item[0];
            model.openPrice = [item[1] floatValue];
            model.closePrice = [item[2] floatValue];
            model.highestPrice = [item[3] floatValue];
            model.lowestPrice = [item[4] floatValue];
            model.volume = [item[5] floatValue];
            
            if (i >= 5) {
                model.ma5 = [self averageWithData:stockData range:NSMakeRange(i-MA5+1, MA5)];
            }
            if (i >= 10) {
                model.ma10 = [self averageWithData:stockData range:NSMakeRange(i-MA10+1, MA10)];
            }
            if (i >= 20) {
                model.ma20 = [self averageWithData:stockData range:NSMakeRange(i-MA20+1, MA20)];
            }
            
            [lineModels addObject:model];
            
            if (i == 0) {
                maxPrice = model.highestPrice;
                minPrice = model.lowestPrice;
                
                maxVolume = model.volume;
                minVolume = maxVolume;
            }
            
            if (model.highestPrice > maxPrice) {
                maxPrice = model.highestPrice;
            }
            
            if (model.lowestPrice < minPrice) {
                minPrice = model.lowestPrice;
            }
            
            if (model.volume > maxVolume) {
                maxVolume = model.volume;
            }
            
            if (model.volume < minVolume) {
                minVolume = model.volume;
            }
            
        }
        
        VStockGroup * stockGroup  = [[VStockGroup alloc] init];
        stockGroup.stockCode        = stockCode;

        stockGroup.stockStatusModel = statusModel;
        stockGroup.kLineModels      = lineModels;
        
        stockGroup.maxPrice = maxPrice;
        stockGroup.minPrice = minPrice;
        stockGroup.maxVolume = maxVolume;
        stockGroup.minVolume = minVolume;
        
        success(stockGroup);
        
    } failue:^(NSError *error) {
        
    }];
}



#pragma mark --均值计算
+ (CGFloat)averageWithData:(NSArray *)data range:(NSRange)range{
    
    CGFloat value = 0;
    if (data.count - range.location >= range.length) {
        NSArray *newArray = [data objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:range]];
        for (NSArray *arr in newArray) {
            value += [[arr objectAtIndex:2] floatValue];
        }
        if (value > 0) {
            value = value / newArray.count;
        }
    }

    return value;
}


+ (VStockStatusModel *)stockStatusModelFromArray:(NSArray *)stockStatusArray isHK:(BOOL)isHK{

    VStockStatusModel * statusModel = [[VStockStatusModel alloc] init];
    statusModel.price = [stockStatusArray[3] floatValue];
    statusModel.wavePrice = [stockStatusArray[31] floatValue];
    statusModel.wavePercent = [stockStatusArray[32] floatValue];
    statusModel.openPrice = [stockStatusArray[5] floatValue];
    statusModel.preClosePrice = [stockStatusArray[4] floatValue];
    statusModel.volume = [stockStatusArray[6] floatValue];                                    // 今日成交量
    statusModel.turnoverRate = [stockStatusArray[38] floatValue];   // 换手率
    statusModel.maxPrice = [stockStatusArray[33] floatValue];
    statusModel.minPrice = [stockStatusArray[34] floatValue];
    statusModel.volumePrice = [stockStatusArray[37] floatValue];    // 成交额
    statusModel.waiPan = [stockStatusArray[7] floatValue];
    statusModel.neiPan = [stockStatusArray[8] floatValue];
    statusModel.ZSZ = [stockStatusArray[45] floatValue];
    statusModel.LTSZ = [stockStatusArray[44] floatValue];
    statusModel.PEG = stockStatusArray[39];                // 市盈率
    statusModel.ZF = stockStatusArray[43];                 // 振幅
    
    if (isHK == YES) {
        statusModel.ZXL = stockStatusArray[47];
        statusModel.maxPrice_52Week = stockStatusArray[48];
        statusModel.minPrice_52Week = stockStatusArray[49];
    }
    
    return statusModel;
}


+ (NSArray *)tradeModelsFrom:(NSString *)tradeString {
    NSMutableArray * array = [NSMutableArray new];
    
    NSArray *items = [tradeString componentsSeparatedByString:@"|"];
    if (items.count <= 0) {
        return nil;
    }
    
    for (int i = 0; i < items.count; i ++) {
        NSLog(@"items:%@", items[i]);
        NSArray *tmpArray = [items[i] componentsSeparatedByString:@"/"];
        
        VTimeTradeModel * model = [[VTimeTradeModel alloc] init];
        model.tradeTime = [tmpArray[1] substringToIndex:5];
        model.tradePrice = tmpArray[2];
        model.tradeVolmue = tmpArray[4];
        if ([tmpArray[6] isEqualToString:@"S"]) {
            model.tradeType = -1;
        }
        else if ([tmpArray[6] isEqualToString:@"B"]) {
            model.tradeType = 1;
        }
        else {
            model.tradeType = 0;
        }

        [array addObject:model];
    }
    
    return array;
}



@end
