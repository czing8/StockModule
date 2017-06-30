//
//  VLineMaskView.h
//  HBStockView
//
//  Created by Vols on 2017/3/29.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLineModel.h"

@interface VLineMaskView : UIView

//当前长按选中的model
@property (nonatomic, strong) VLineModel    * selectedModel;
@property (nonatomic, assign) CGPoint       selectedPoint;

// 当前的滑动scrollview
@property (nonatomic, strong) UIScrollView *stockScrollView;

@end
