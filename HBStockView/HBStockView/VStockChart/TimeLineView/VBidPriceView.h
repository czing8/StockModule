//
//  VBidPriceView.h
//  HBStockView
//
//  Created by Vols on 2017/2/28.
//  Copyright © 2017年 vols. All rights reserved.
//  五档价格 View

#import <UIKit/UIKit.h>
#import "VBidPriceModel.h"


@interface VBidPriceView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) VBidPriceModel * bidPriceModel;

- (void)reloadWithModel:(VBidPriceModel *)bidPriceModel;

@end
