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

+ (void)get:(NSString*) url params:(id)params success:(void (^)(NSDictionary *response))success fail:(void(^)(NSDictionary *info))fail {
    if ([url isEqualToString:@"minute"]) {
        success([NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"minuteData" ofType:@"plist"]]);
    }
    if ([url isEqualToString:@"day"]) {
        success([NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dayData" ofType:@"plist"]]);
    }
    if ([url isEqualToString:@"five"]) {
        success([NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fiveData" ofType:@"plist"]]);
    }
}


+ (void)getTimeStockDataSuccess:(void (^)(VTimeLineGroup *response))success {
    NSString * urlString = @"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/minute/query?p=1&code=sz002185&_rndtime=1474955377&_appName=ios&_dev=iPod7,1&_devId=cca43cc6683821c1e2556251a62e0dd2038a76e5&_appver=5.1.0&_ifChId=&_isChId=1&_osVer=9.2.1&_uin=10000&_wxuin=20000";
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        
        VTimeLineGroup * timeGroup = [[VTimeLineGroup alloc] init];

        NSDictionary * resultDic    = flag[@"data"][@"sz002185"];
        NSArray * stockStatusArray  = resultDic[@"qt"][@"sz002185"];
        NSString * tradeString  = resultDic[@"mx_price"][@"mx"][@"data"][1];

        NSArray * tradeModels = [self tradeModelsFrom:tradeString];
        timeGroup.tradeModels = tradeModels;
        
        float curPrice = [stockStatusArray[3] floatValue];
        float closePrice = [stockStatusArray[4] floatValue];
        float openPrice = [stockStatusArray[5] floatValue];
        float volume = [stockStatusArray[6] floatValue];        //今天的总成交量
        float waiPan = [stockStatusArray[7] floatValue];
        float neiPan = [stockStatusArray[8] floatValue];
        
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray];
        
        NSArray *buyPrices = @[stockStatusArray[9], stockStatusArray[11], stockStatusArray[13], stockStatusArray[15], stockStatusArray[17]];
        NSArray *sellPrices = @[stockStatusArray[27], stockStatusArray[25], stockStatusArray[23], stockStatusArray[21], stockStatusArray[19]];
        
        NSArray *buyVolumes = @[stockStatusArray[10], stockStatusArray[12], stockStatusArray[14], stockStatusArray[16], stockStatusArray[18]];
        NSArray *sellVolumes = @[stockStatusArray[28], stockStatusArray[26], stockStatusArray[24], stockStatusArray[22], stockStatusArray[20]];
        
        timeGroup.stockStatusModel = statusModel;
        NSMutableArray * timeLineModels = [[NSMutableArray alloc] init];
        
        NSArray * data = resultDic[@"data"][@"data"];
        
        float maxPrice = 0.0, minPrice = 0.0, maxVolume = 0.0, minVolume = 0.0;
        float tmpVolume = 0.0;
        
        for (int i = 0; i < data.count; i ++) {
            NSString *timeStockData = data[i];
            NSArray * item = [timeStockData componentsSeparatedByString:@" "];
            
            float price = [item[1] floatValue];
            float volume = [item[2] floatValue];
            
            VTimeLineModel *model = [[VTimeLineModel alloc]init];
            model.price = @(price);
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
        
        VBidPriceModel * bidPriceModel = [[VBidPriceModel alloc]init];
        bidPriceModel.buyPrices = buyPrices;
        bidPriceModel.buyVolumes = buyVolumes;
        bidPriceModel.sellPrices = sellPrices;
        bidPriceModel.sellVolumes = sellVolumes;
        
        timeGroup.lineModels = timeLineModels;
        timeGroup.maxPrice = maxPrice;
        timeGroup.minPrice = minPrice;
        timeGroup.maxVolume= maxVolume;
        timeGroup.minVolume= minVolume;
        timeGroup.preClosePrice = closePrice;
        timeGroup.price = curPrice;
        timeGroup.openPrice = openPrice;
        timeGroup.volume = volume;
        timeGroup.waiPan = waiPan;
        timeGroup.neiPan = neiPan;
        
        timeGroup.bidPriceModel = bidPriceModel;

        success(timeGroup);
        
    } failue:^(NSError *error) {
        
    }];
}


+ (void)get5DayStockDataSuccess:(void (^)(NSArray *resultArray))success {
    NSString * urlString = @"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/day/query?p=1&code=sz002185&_rndtime=1473489077&_appName=ios&_dev=iPod5,1&_devId=d66caf3263cd7633ae0cd7ab69be2887b960c9aa&_appver=5.1.0&_ifChId=&_isChId=1&_osVer=7.1.1&_uin=10000&_wxuin=20000";

    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][@"sz002185"];
        NSArray * fiveDayData = resultDic[@"data"];
        NSLog(@"fiveDayData:%@", fiveDayData);
        
    } failue:^(NSError *error) {
        
    }];
}

+ (void)getDayStockDataSuccess:(void (^)(VLineGroup *response))success {
    NSString * urlString = @"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/fqkline/get?p=1&param=sz002185,day,,,320,qfq&_rndtime=1473240957&_appName=ios&_dev=iPod7,1&_devId=cca43cc6683821c1e2556251a62e0dd2038a76e5&_appver=5.1.0&_ifChId=&_isChId=1&_osVer=9.2.1&_uin=10000&_wxuin=20000";
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][@"sz002185"];
        
        NSArray * stockStatusArray = resultDic[@"qt"][@"sz002185"];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray];

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
        
        VLineGroup * lineGroup = [[VLineGroup alloc] init];
        lineGroup.lineModels = lineModels;
        lineGroup.stockStatusModel = statusModel;
        success(lineGroup);
    } failue:^(NSError *error) {
        
    }];

}


+ (void)getWeekStockDataSuccess:(void (^)(VLineGroup *response))success {
    
    NSString * urlString = @"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/fqkline/get?p=1&param=sz002185,week,,,320,qfq&_rndtime=1473486948&_appName=ios&_dev=iPod5,1&_devId=d66caf3263cd7633ae0cd7ab69be2887b960c9aa&_appver=5.1.0&_ifChId=&_isChId=1&_osVer=7.1.1&_uin=10000&_wxuin=20000";
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][@"sz002185"];

        NSArray * stockData = resultDic[@"qfqweek"];
        NSArray * stockStatusArray = resultDic[@"qt"][@"sz002185"];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray];

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
        
        VLineGroup * lineGroup = [[VLineGroup alloc] init];
        lineGroup.lineModels = lineModels;
        lineGroup.stockStatusModel = statusModel;
        success(lineGroup);
    } failue:^(NSError *error) {
        
    }];

}

+ (void)getMonthStockDataSuccess:(void (^)(VLineGroup *response))success {
    NSString * urlString = @"http://proxy.finance.qq.com/ifzqgtimg/appstock/app/fqkline/get?p=1&param=sz002185,month,,,320,qfq&_rndtime=1473488888&_appName=ios&_dev=iPod5,1&_devId=d66caf3263cd7633ae0cd7ab69be2887b960c9aa&_appver=5.1.0&_ifChId=&_isChId=1&_osVer=7.1.1&_uin=10000&_wxuin=20000";
    
    [[HttpHelper shared] get:nil path:urlString success:^(NSDictionary * flag) {
        NSDictionary * resultDic = flag[@"data"][@"sz002185"];
        NSArray * stockData = resultDic[@"qfqmonth"];
        
        NSArray * stockStatusArray = resultDic[@"qt"][@"sz002185"];
        VStockStatusModel * statusModel = [self stockStatusModelFromArray:stockStatusArray];

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
        
        VLineGroup * lineGroup = [[VLineGroup alloc] init];
        lineGroup.lineModels = lineModels;
        lineGroup.stockStatusModel = statusModel;
        success(lineGroup);
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


+ (VStockStatusModel *)stockStatusModelFromArray:(NSArray *)stockStatusArray {

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
    statusModel.ZF = stockStatusArray[43];          // 振幅
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
