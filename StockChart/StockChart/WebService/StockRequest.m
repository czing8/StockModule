//
//  StockRequest.m
//  StockChart
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
        
//        NSString * tradeString  = resultDic[@"mx_price"][@"mx"][@"data"][1];
//        NSArray * tradeModels = [self tradeModelsFrom:nil];
        NSArray * tradeModels = nil;
        
        float curPrice = [stockStatusArray[3] floatValue];
        float closePrice = [stockStatusArray[4] floatValue];
        
        // ---- 股票各种参数模型
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray  isHK:NO];
        
        // ---- 股票五档竞价模型
        NSArray *buyPrices = @[stockStatusArray[9], stockStatusArray[11], stockStatusArray[13], stockStatusArray[15], stockStatusArray[17]];
        NSArray *sellPrices = @[stockStatusArray[27], stockStatusArray[25], stockStatusArray[23], stockStatusArray[21], stockStatusArray[19]];
        
        NSArray *buyVolumes = @[stockStatusArray[10], stockStatusArray[12], stockStatusArray[14], stockStatusArray[16], stockStatusArray[18]];
        NSArray *sellVolumes = @[stockStatusArray[28], stockStatusArray[26], stockStatusArray[24], stockStatusArray[22], stockStatusArray[20]];
        
        VVWuDangModel * wuDangModel = [[VVWuDangModel alloc]init];
        wuDangModel.buyPrices = buyPrices;
        wuDangModel.buyVolumes = buyVolumes;
        wuDangModel.sellPrices = sellPrices;
        wuDangModel.sellVolumes = sellVolumes;

        // ---- 股票K线数组
        NSMutableArray * timeLineModels = [[NSMutableArray alloc] init];
        
        NSArray * data = resultDic[@"data"][@"data"];
        
        float maxPrice = 0.0, minPrice = 0.0, maxVolume = 0.0, minVolume = 0.0;
        float tmpVolume = 0.0;
        float tmpTotalPrice = 0.0;

        for (int i = 0; i < data.count; i ++) {
            NSString *timeStockData = data[i];
            NSArray * item = [timeStockData componentsSeparatedByString:@" "];
            
            float price = [item[1] floatValue];
            float volume = [item[2] floatValue];
            
            VStockPoint *model = [[VStockPoint alloc]init];
            model.price = price;
            model.volume = volume - tmpVolume;
            model.preClosePrice = closePrice;
            model.totalPrice = model.price * model.volume + tmpTotalPrice;
            if (volume > 0)
                model.avPrice = model.totalPrice/volume;
            else if (volume <= 0)
                model.avPrice = model.price;

            [timeLineModels addObject:model];
            
            if (i == 0) {
                maxPrice = [item[1] floatValue];
                minPrice = maxPrice;
                
                maxVolume = [item[2] floatValue];
                minVolume = maxVolume;
            }
            
            if (price > maxPrice) {     maxPrice = price;   }
            if (price < minPrice) {     minPrice = price;   }
            
            if (model.volume > maxVolume) {     maxVolume = model.volume;   }
            if (model.volume < minVolume) {     minVolume = model.volume;   }
            
            tmpVolume = volume;
            tmpTotalPrice   = model.totalPrice;
        }
        
        VStockGroup * timeGroup = [[VStockGroup alloc] init];
        timeGroup.stockCode     = stockCode;
        timeGroup.stockType     = VStockTypeCN;
        timeGroup.tradeModels   = [NSMutableArray arrayWithArray:[[tradeModels reverseObjectEnumerator] allObjects]];
        timeGroup.stockStatusModel  = statusModel;
        timeGroup.wuDangModel       = wuDangModel;
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
+ (void)getDayStockData:(NSString *)stockCode fuQuanType:(VStockFuQuanType)fuQuanType success:(void (^)(VStockGroup *response))success {
    
    NSArray * fuQuanTypes = @[@"", @"qfq", @"hfq"];
    NSArray * resultTypes = @[@"day", @"qfqday", @"hfqday"];

    NSString * urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/fqkline/get?p=1&param=%@,day,,,320,%@", stockCode, fuQuanTypes[fuQuanType]];

    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][stockCode];
        float preClosePrice = [resultDic[@"prec"] floatValue];

        NSArray * stockStatusArray = resultDic[@"qt"][stockCode];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray  isHK:NO];

        NSArray * stockData = resultDic[resultTypes[fuQuanType]];
        
        NSArray * lineModels = [self lineModelsFrom:stockData preClosePrice:preClosePrice];
        
        VStockGroup * stockGroup = [[VStockGroup alloc] init];
        stockGroup.stockCode    = stockCode;
        stockGroup.stockType    = VStockTypeCN;
        stockGroup.kLineModels  = lineModels;
        stockGroup.stockStatusModel = statusModel;
        success(stockGroup);
        
    } failue:^(NSError *error) {
        
    }];
}

+ (void)getWeekStockData:(NSString *)stockCode fuQuanType:(VStockFuQuanType)fuQuanType success:(void (^)(VStockGroup *response))success {
    
    NSArray * fuQuanTypes = @[@"", @"qfq", @"hfq"];
    NSArray * resultTypes = @[@"week", @"qfqweek", @"hfqweek"];

    NSString * urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/fqkline/get?p=1&param=%@,week,,,320,%@", stockCode, fuQuanTypes[fuQuanType]];
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][stockCode];
        float preClosePrice = [resultDic[@"prec"] floatValue];

        NSArray * stockData = resultDic[resultTypes[fuQuanType]];
        NSArray * stockStatusArray = resultDic[@"qt"][stockCode];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray  isHK:NO];

        NSArray * lineModels = [self lineModelsFrom:stockData preClosePrice:preClosePrice];
        
        VStockGroup * stockGroup = [[VStockGroup alloc] init];
        stockGroup.stockCode    = stockCode;
        stockGroup.stockType    = VStockTypeCN;
        stockGroup.kLineModels  = lineModels;
        stockGroup.stockStatusModel = statusModel;
        success(stockGroup);
    } failue:^(NSError *error) {
        
    }];

}

+ (void)getMonthStockData:(NSString *)stockCode fuQuanType:(VStockFuQuanType)fuQuanType success:(void (^)(VStockGroup *response))success {
    NSArray * fuQuanTypes = @[@"", @"qfq", @"hfq"];
    NSArray * resultTypes = @[@"month", @"qfqmonth", @"hfqmonth"];

    NSString * urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/fqkline/get?p=1&param=%@,month,,,320,%@", stockCode, fuQuanTypes[fuQuanType]];
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][stockCode];
        float preClosePrice = [resultDic[@"prec"] floatValue];

        NSArray * stockData = resultDic[resultTypes[fuQuanType]];
        
        NSArray * stockStatusArray = resultDic[@"qt"][stockCode];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray  isHK:NO];

        NSArray * lineModels = [self lineModelsFrom:stockData preClosePrice:preClosePrice];
        
        VStockGroup * stockGroup = [[VStockGroup alloc] init];
        stockGroup.stockCode    = stockCode;
        stockGroup.stockType    = VStockTypeCN;
        stockGroup.kLineModels  = lineModels;
        stockGroup.stockStatusModel = statusModel;
        success(stockGroup);
    } failue:^(NSError *error) {
        
    }];
}

+ (void)getMingxiRequest:(NSString *)stockCode index:(NSString *)index success:(void (^)(NSArray *resultArray, NSString * index))success {
    NSString * urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/HsDealinfo/getMingxi?code=%@&index=%@", stockCode, index];
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        if ([flag[@"data"] count] == 0) {
            return ;
        }
        
        NSString * mingXiData = flag[@"data"][@"data"];
        NSString * index = flag[@"data"][@"index"];

        NSLog(@"股票明细:%@", mingXiData);
        NSArray * tradeModels = [self tradeModelsFrom:mingXiData];
        success(tradeModels, index);
        
    } failue:^(NSError *error) {
        
    }];
}


+ (void)getDaDanRequest:(NSString *)stockCode success:(void (^)(NSArray *resultArray))success {
    NSString * urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/HsDealinfo/getDadan?code=%@", stockCode];
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSArray * daDanData = flag[@"data"][@"detail"];
        NSLog(@"daDanData:%@", daDanData);
        
        if (daDanData == nil || daDanData.count == 0) {
            if(success) success(nil);
            return ;
        }
        
        NSMutableArray * array = [NSMutableArray new];
        
        for (int i = 0; i < daDanData.count; i ++) {
            NSArray *tmpArray = daDanData[i];

            VTimeTradeModel * model = [[VTimeTradeModel alloc] init];
            NSArray * tmpArr2 = [tmpArray[0] componentsSeparatedByString:@":"];
            model.tradeTime = [NSString stringWithFormat:@"%@:%@", tmpArr2[0], tmpArr2[1]];
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
        float tmpTotalPrice = 0.0;

        for (int i = 0; i < data.count; i ++) {
            NSString *timeStockData = data[i];
            NSArray * item = [timeStockData componentsSeparatedByString:@" "];
            
            float price = [item[1] floatValue];
            float volume = [item[2] floatValue];
            
            VStockPoint *model = [[VStockPoint alloc]init];
            model.price = price;
            model.volume = volume - tmpVolume;
            model.preClosePrice = [stockStatusArray[4] floatValue];
            model.totalPrice = model.price * model.volume + tmpTotalPrice;
            if (volume > 0)     model.avPrice = model.totalPrice/volume;
            else if (volume <= 0)   model.avPrice = model.price;

            [timeLineModels addObject:model];
            
            if (i == 0) {
                maxPrice = [item[1] floatValue];
                minPrice = maxPrice;
                
                maxVolume = [item[2] floatValue];
                minVolume = maxVolume;
            }
            
            if (price > maxPrice) {     maxPrice = price;   }
            if (price < minPrice) {     minPrice = price;   }
            
            if (model.volume > maxVolume) {     maxVolume = model.volume;   }
            if (model.volume < minVolume) {     minVolume = model.volume;   }
            
            tmpVolume = volume;
            tmpTotalPrice   = model.totalPrice;
        }
        
        VStockGroup * timeGroup = [[VStockGroup alloc] init];
        timeGroup.stockCode = stockCode;
        timeGroup.stockType = VStockTypeHK;
        timeGroup.maxPrice = maxPrice;
        timeGroup.minPrice = minPrice;
        timeGroup.maxVolume= maxVolume;
        timeGroup.minVolume= minVolume;
        timeGroup.preClosePrice = [stockStatusArray[4] floatValue];
        
        timeGroup.stockStatusModel  = statusModel;
        timeGroup.lineModels        = timeLineModels;

        success(timeGroup);
        
    } failue:^(NSError *error) {
        
    }];
}


+ (void)getHKDayStockData:(NSString *)stockCode fuQuanType:(VStockFuQuanType)fuQuanType success:(void (^)(VStockGroup *response))success {
    
    NSArray * fuQuanTypes = @[@"", @"qfq", @"hfq"];
    NSArray * resultTypes = @[@"day", @"qfqday", @"hfqday"];

    NSString * urlString;

    if (fuQuanType == VStockFuQuanTypeNone) {
        urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/fqkline/get?p=1&param=%@,day,,,320,", stockCode];
    }
    else{
        urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/hkfqkline/get?param=%@,day,,,320,%@", stockCode, fuQuanTypes[fuQuanType]];
    }


    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        if ([flag[@"code"] integerValue] == 1) {
            return ;
        }
        
        NSDictionary * resultDic = flag[@"data"][stockCode];
        float preClosePrice = [resultDic[@"prec"] floatValue];

        NSArray * stockStatusArray = resultDic[@"qt"][stockCode];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray  isHK:YES];
        NSArray * stockData = resultDic[resultTypes[fuQuanType]];
        
        NSArray * lineModels = [self lineModelsFrom:stockData preClosePrice:preClosePrice];
        
        VStockGroup * stockGroup = [[VStockGroup alloc] init];
        stockGroup.stockCode    = stockCode;
        stockGroup.stockType    = VStockTypeHK;
        stockGroup.kLineModels  = lineModels;
        stockGroup.stockStatusModel = statusModel;
        success(stockGroup);
        
    } failue:^(NSError *error) {
        
    }];
}


+ (void)getHKWeekStockCode:(NSString *)stockCode fuQuanType:(VStockFuQuanType)fuQuanType success:(void (^)(VStockGroup *response))success {
    
    NSArray * fuQuanTypes = @[@"", @"qfq", @"hfq"];
    
    NSString * urlString = [NSString stringWithFormat:@"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/fqkline/get?p=1&param=%@,week,,,320,%@", stockCode, fuQuanTypes[fuQuanType]];
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][stockCode];
        float preClosePrice = [resultDic[@"prec"] floatValue];

        NSArray * stockData = resultDic[@"week"];
        NSArray * stockStatusArray = resultDic[@"qt"][stockCode];

        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray  isHK:YES];
        
        NSArray * lineModels = [self lineModelsFrom:stockData preClosePrice:preClosePrice];
        
        VStockGroup * stockGroup = [[VStockGroup alloc] init];
        stockGroup.stockCode    = stockCode;
        stockGroup.stockType    = VStockTypeHK;
        stockGroup.kLineModels  = lineModels;
        stockGroup.stockStatusModel = statusModel;
        success(stockGroup);
        
    } failue:^(NSError *error) {
        
    }];
}

+ (void)getHKYearStockCode:(NSString *)stockCode fuQuanType:(VStockFuQuanType)fuQuanType success:(void (^)(VStockGroup *response))success {
    NSString * urlString = [NSString stringWithFormat:@"http://123.126.122.40/ifzqgtimg/appstock/app/newkline/newkline?p=1&param=%@,day,,,260", stockCode];
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][stockCode];
        float preClosePrice = [resultDic[@"prec"] floatValue];

        NSArray * stockStatusArray = resultDic[@"qt"][stockCode];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray isHK:YES];
        
        NSArray * stockData = resultDic[@"day"];
        NSArray * lineModels = [self lineModelsFrom:stockData preClosePrice:preClosePrice];
        
        //更新最大值最小值-价格
        float maxPrice =  [[[lineModels valueForKeyPath:@"highestPrice"] valueForKeyPath:@"@max.floatValue"] floatValue];
        float minPrice =  [[[lineModels valueForKeyPath:@"lowestPrice"] valueForKeyPath:@"@min.floatValue"] floatValue];
        float maxVolume =  [[[lineModels valueForKeyPath:@"volume"] valueForKeyPath:@"@max.floatValue"] floatValue];
        float minVolume =  [[[lineModels valueForKeyPath:@"volume"] valueForKeyPath:@"@min.floatValue"] floatValue];
        
        VStockGroup * stockGroup  = [[VStockGroup alloc] init];
        stockGroup.stockCode    = stockCode;
        stockGroup.stockType    = VStockTypeHK;

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

+ (void)getDayStockData:(NSString *)stockCode stockType:(VStockType)stockType fuQuanType:(VStockFuQuanType)fuQuanType success:(void (^)(VStockGroup *response))success {
    
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

// 股票明细
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
        
        NSArray * tmpArr2 = [tmpArray[1] componentsSeparatedByString:@":"];
        model.tradeTime = [NSString stringWithFormat:@"%@:%@", tmpArr2[0], tmpArr2[1]];
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


+ (NSArray *)lineModelsFrom:(NSArray *)stockData preClosePrice:(float)preClosePrice{
    
    if (stockData == nil)   return nil;
    
    NSMutableArray * lineModels = [[NSMutableArray alloc] init];
    int MA5 = 5, MA10 = 10, MA20 = 20;  // 均线统计
    
    for (int i = 0; i < stockData.count; i ++) {
        NSArray *item = stockData[i];
        VLineModel * model = [[VLineModel alloc] init];
        model.day = item[0];
        model.openPrice = [item[1] floatValue];
        model.closePrice = [item[2] floatValue];
        model.highestPrice = [item[3] floatValue];
        model.lowestPrice = [item[4] floatValue];
        model.preClosePrice = preClosePrice;
        model.volume = [item[5] floatValue];
        preClosePrice = model.closePrice;
        
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

    return lineModels;
}

@end
