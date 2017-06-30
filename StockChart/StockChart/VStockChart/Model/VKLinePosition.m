//
//  VKLinePositionModel.m
//  StockChart
//
//  Created by Vols on 2017/3/6.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VKLinePosition.h"

@implementation VKLinePosition

+ (instancetype) modelWith:(CGPoint)openPoint :(CGPoint)closePoint :(CGPoint)highPoint :(CGPoint)lowPoint {
    VKLinePosition * model = [VKLinePosition new];
    model.openPoint     = openPoint;
    model.closePoint    = closePoint;
    model.highPoint     = highPoint;
    model.lowPoint      = lowPoint;
    return model;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p> openPoint = %@, closePoint = %@, highPoint = %@, lowPoint = %@", [self class], self, NSStringFromCGPoint(self.openPoint), NSStringFromCGPoint(self.closePoint), NSStringFromCGPoint(self.highPoint), NSStringFromCGPoint(self.lowPoint)];
}


@end
