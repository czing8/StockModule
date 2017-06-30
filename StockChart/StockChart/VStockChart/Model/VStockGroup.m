//
//  VStockGroup.m
//  StockChart
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VStockGroup.h"

@implementation VStockGroup

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p> price:%f, maxPrice:%f, minPrice:%f, maxVolume:%f, minVolume:%f", [self class], self, self.price, self.maxPrice, self.minPrice, self.maxVolume, self.minVolume];
}

@end
