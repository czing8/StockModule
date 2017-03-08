//
//  VTimeLineView.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//  分时图主类

#import <UIKit/UIKit.h>
#import "VTimeLineGroup.h"

@interface VTimeLineView : UIView

- (void)reloadWithGroup:(VTimeLineGroup *)timeLineGroup;

@end
