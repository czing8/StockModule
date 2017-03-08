//
//  VBidPriceCell.h
//  HBStockView
//
//  Created by Vols on 2017/2/28.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBidPriceModel.h"

#define kBidPriceCellIdentifier     @"kBidPriceCellIdentifier"

@interface VBidPriceCell : UITableViewCell

@property(nonatomic,strong) UILabel *noteLabel;
@property(nonatomic,strong) UILabel *priceLabel;
@property(nonatomic,strong) UILabel *volumeLabel;

@property (nonatomic, strong) VBidPriceModel * model;

@end
