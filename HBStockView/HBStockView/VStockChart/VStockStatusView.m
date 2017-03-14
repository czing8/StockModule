//
//  VStockStatusView.m
//  HBStockView
//
//  Created by Vols on 2017/3/8.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VStockStatusView.h"

@interface VStockStatusView ()

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceChgLabel;
@property (weak, nonatomic) IBOutlet UILabel *pricePercentLabel;

@property (weak, nonatomic) IBOutlet UILabel *openPriceLb;
@property (weak, nonatomic) IBOutlet UILabel *volumeLb;

@property (weak, nonatomic) IBOutlet UILabel *closeLb;
@property (weak, nonatomic) IBOutlet UILabel *turnoverRateLb;

@property (weak, nonatomic) IBOutlet UILabel *maxPriceLb;
@property (weak, nonatomic) IBOutlet UILabel *minPriceLb;
@property (weak, nonatomic) IBOutlet UILabel *volumePriceLb;

@property (weak, nonatomic) IBOutlet UILabel *neiPanLb;
@property (weak, nonatomic) IBOutlet UILabel *waiPanLb;
@property (weak, nonatomic) IBOutlet UILabel *ZSZLb;

@property (weak, nonatomic) IBOutlet UILabel *SYLLb;
@property (weak, nonatomic) IBOutlet UILabel *ZFLb;
@property (weak, nonatomic) IBOutlet UILabel *LTSZLb;


@end

@implementation VStockStatusView


- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
//        [[NSBundle mainBundle] loadNibNamed:@"VStockStatusView" owner:self options:nil];
//        [self addSubview:self.bgView];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        
        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    
    
}




#pragma mark - Properities

- (void)setStockStatusModel:(VStockStatusModel *)stockStatusModel {
    _stockStatusModel = stockStatusModel;
    if (stockStatusModel.wavePrice < 0) {
        _priceLabel.textColor = kRGB(41, 253, 47);
        _priceChgLabel.textColor = kRGB(41, 253, 47);
        _pricePercentLabel.textColor = kRGB(41, 253, 47);
    }
    else if (stockStatusModel.wavePrice > 0) {
        _priceLabel.textColor = kRGB(252, 63, 30);
        _priceChgLabel.textColor = kRGB(252, 63, 30);
        _pricePercentLabel.textColor = kRGB(252, 63, 30);
    }
    else{
        _priceLabel.textColor = [UIColor grayColor];
        _priceChgLabel.textColor = [UIColor grayColor];
        _pricePercentLabel.textColor = [UIColor grayColor];
    }

    _priceLabel.text    = [NSString stringWithFormat:@"%.2f", stockStatusModel.price];
    _priceChgLabel.text = [NSString stringWithFormat:@"%.2f", stockStatusModel.wavePrice];
    _pricePercentLabel.text = [NSString stringWithFormat:@"%.2f%%", stockStatusModel.wavePercent];

    _openPriceLb.text = [NSString stringWithFormat:@"%.2f", stockStatusModel.openPrice];
    _volumeLb.text  = [NSString stringWithFormat:@"%.2f万手", stockStatusModel.volume/10000.f];
    _closeLb.text   = [NSString stringWithFormat:@"%.2f", stockStatusModel.preClosePrice];
    _turnoverRateLb.text = [NSString stringWithFormat:@"%.2f%%", stockStatusModel.turnoverRate];
    
    _maxPriceLb.text = [NSString stringWithFormat:@"%.2f", stockStatusModel.maxPrice];
    _minPriceLb.text = [NSString stringWithFormat:@"%.2f", stockStatusModel.minPrice];
    _volumePriceLb.text = [NSString stringWithFormat:@"%.2f亿", stockStatusModel.volumePrice/10000.f];
    
    _neiPanLb.text  = [NSString stringWithFormat:@"%.2f万", stockStatusModel.neiPan/10000.f];
    _waiPanLb.text  = [NSString stringWithFormat:@"%.2f万", stockStatusModel.waiPan/10000.f];
    _ZSZLb.text     = [NSString stringWithFormat:@"%.0f亿", stockStatusModel.ZSZ];

    _SYLLb.text     = [NSString stringWithFormat:@"%@", stockStatusModel.PEG];
    _ZFLb.text      = [NSString stringWithFormat:@"%@%%", stockStatusModel.ZF];
    _LTSZLb.text    = [NSString stringWithFormat:@"%.0f亿", stockStatusModel.LTSZ];

}

#pragma mark - Helpers

- (UILabel *)labelWithText:(NSString *)text color:(UIColor *)color {
    UILabel * label = [UILabel new];
    label.text = text;
    label.textColor = color;
    label.font = [UIFont systemFontOfSize:14];
    
    return label;
}





@end
