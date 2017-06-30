//
//  VVWuDangView.h
//  HBStockView
//
//  Created by Vols on 2017/2/28.
//  Copyright © 2017年 vols. All rights reserved.
//  五档价格 View

#import <UIKit/UIKit.h>
#import "VVWuDangModel.h"


@interface VVWuDangView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) VVWuDangModel * wuDangModel;

- (void)reloadWithModel:(VVWuDangModel *)wuDangModel;

@end
