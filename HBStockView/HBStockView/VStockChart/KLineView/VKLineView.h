//
//  VKLineView.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLineGroup.h"

@interface VKLineView : UIView

- (void)reloadWithGroup:(VLineGroup *)lineGroup;

@end
