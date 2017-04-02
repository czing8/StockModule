//
//  VTimeLineView.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//  分时图主类

#import <UIKit/UIKit.h>
#import "VStockGroup.h"
#import "VStockConstant.h"

@interface VTimeLineView : UIView

- (instancetype)initWithType:(VStockType)stockType;

- (void)reloadWithGroup:(VStockGroup *)stockGroup;

@end
