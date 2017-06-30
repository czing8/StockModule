//
//  VVWuDangModel.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VVWuDangModel.h"

@implementation VVWuDangModel

- (instancetype)init {
    if (self = [super init]) {

    }
    return self;
}

- (NSArray *)buyDescs {
    return @[@"买1",@"买2",@"买3",@"买4",@"买5"];
}

- (NSArray *)sellDescs {
    return @[@"卖5",@"卖4",@"卖3",@"卖2",@"卖1"];
}


@end
