//
//  VStockLineDataModel.m
//  StockChart
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VLineModel.h"

@implementation VLineModel


- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
//        _dict = dict;
//        Close = _dict[@"close"];
//        Open = _dict[@"open"];
//        High = _dict[@"high"];
//        Low = _dict[@"low"];
//        Volume = _dict[@"volume"];
    }
    return self;
}



- (void)updateMA:(NSArray *)parentDictArray {
//    _parentDictArray = parentDictArray;
//    NSInteger index = [_parentDictArray indexOfObject:_dict];
//    if (index >= 4) {
//        NSArray *array = [_parentDictArray subarrayWithRange:NSMakeRange(index-4, 5)];
//        CGFloat average = [[[array valueForKeyPath:@"close"] valueForKeyPath:@"@avg.floatValue"] floatValue];
//        MA5 = @(average);
//    } else {
//        MA5 = @0;
//    }
//    
//    if (index >= 9) {
//        NSArray *array = [_parentDictArray subarrayWithRange:NSMakeRange(index-9, 10)];
//        CGFloat average = [[[array valueForKeyPath:@"close"] valueForKeyPath:@"@avg.floatValue"] floatValue];
//        MA10 = @(average);
//    } else {
//        MA10 = @0;
//    }
//    
//    if (index >= 19) {
//        NSArray *array = [_parentDictArray subarrayWithRange:NSMakeRange(index-19, 20)];
//        CGFloat average = [[[array valueForKeyPath:@"close"] valueForKeyPath:@"@avg.floatValue"] floatValue];
//        MA20 = @(average);
//    } else {
//        MA20 = @0;
//    }
//    
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p> openPrice = %f, closePrice = %f, highestPrice = %f, lowestPrice = %f, volume = %f, ", [self class], self, self.openPrice, self.closePrice, self.highestPrice, self.lowestPrice, self.volume];
}

@end
