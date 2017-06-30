//
//  VKLineVolumeView.h
//  StockChart
//
//  Created by Vols on 2017/3/6.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLineModel.h"
#import "VKLinePosition.h"

@interface VKLineVolumeView : UIView

@property (nonatomic, weak) UIScrollView *parentScrollView;

- (void)drawViewWithXPosition:(CGFloat)xPosition drawModels:(NSArray <VLineModel *>*)drawLineModels linePositions:(NSArray <VKLinePosition *>*)linePositions;

@end
