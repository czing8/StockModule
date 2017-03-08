//
//  VTimeLineModel.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VTimeLineModel.h"

@implementation VTimeLineModel

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p> price = %@, volume = %f", [self class], self, self.price, self.volume];
}

@end
