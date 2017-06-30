//
//  VVMingxiCell.h
//  HBStockView
//
//  Created by Vols on 2017/3/14.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTimeTradeModel.h"

#define kMingXiCellIdentifier     @"kMingXiCellIdentifier"

@interface VVMingxiCell : UITableViewCell

@property (nonatomic, strong) VTimeTradeModel * model;

@end
