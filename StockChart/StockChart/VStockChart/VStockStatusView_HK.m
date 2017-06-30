//
//  VStockStatusView_HK.m
//  StockChart
//
//  Created by Vols on 2017/3/27.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VStockStatusView_HK.h"

@interface VStockStatusView_HK ()
@property (weak, nonatomic) IBOutlet UIView *colorBgView;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceChgLabel;
@property (weak, nonatomic) IBOutlet UILabel *pricePercentLabel;

@property (weak, nonatomic) IBOutlet UILabel *openPriceLb;
@property (weak, nonatomic) IBOutlet UILabel *volumeLb;

@property (weak, nonatomic) IBOutlet UILabel *closeLb;
@property (weak, nonatomic) IBOutlet UILabel *ZSZLb;

@property (weak, nonatomic) IBOutlet UILabel *maxPriceLb;
@property (weak, nonatomic) IBOutlet UILabel *minPriceLb;
@property (weak, nonatomic) IBOutlet UILabel *ZFLb;


@property (weak, nonatomic) IBOutlet UILabel *volumePriceLb;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *SYLLb;


@property (weak, nonatomic) IBOutlet UILabel *maxPrice52WeekLb;
@property (weak, nonatomic) IBOutlet UILabel *minPrice52WeekLb;
@property (weak, nonatomic) IBOutlet UILabel *ZXLLb;

@end

@implementation VStockStatusView_HK

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {

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
//        _colorBgView.backgroundColor = kRGB(55, 185, 130);

        _priceLabel.textColor = kRGB(7, 149, 12);
        _priceChgLabel.textColor = kRGB(7, 149, 12);
        _pricePercentLabel.textColor = kRGB(7, 149, 12);
    }
    else if (stockStatusModel.wavePrice > 0) {
//        _colorBgView.backgroundColor = kRGB(252, 80, 90);

                _priceLabel.textColor = kRGB(252, 63, 30);
                _priceChgLabel.textColor = kRGB(252, 63, 30);
                _pricePercentLabel.textColor = kRGB(252, 63, 30);
    }
    else{
//        _colorBgView.backgroundColor = kRGB(128, 128, 128);
        _priceLabel.textColor = [UIColor grayColor];
        _priceChgLabel.textColor = [UIColor grayColor];
        _pricePercentLabel.textColor = [UIColor grayColor];
    }
    
    _priceLabel.text    = [NSString stringWithFormat:@"%.3f", stockStatusModel.price];
    _priceChgLabel.text = [NSString stringWithFormat:@"%.2f", stockStatusModel.wavePrice];
    _pricePercentLabel.text = [NSString stringWithFormat:@"%.2f%%", stockStatusModel.wavePercent];
    
    _openPriceLb.text = [NSString stringWithFormat:@"%.2f", stockStatusModel.openPrice];
    _volumeLb.text  = [NSString stringWithFormat:@"%.2f万股", stockStatusModel.volume/10000.f];
    _closeLb.text   = [NSString stringWithFormat:@"%.2f", stockStatusModel.preClosePrice];
    _ZSZLb.text = [NSString stringWithFormat:@"%.0f亿", stockStatusModel.LTSZ];
    
    _maxPriceLb.text = [NSString stringWithFormat:@"%.2f", stockStatusModel.maxPrice];
    _minPriceLb.text = [NSString stringWithFormat:@"%.2f", stockStatusModel.minPrice];
    _ZFLb.text      = [NSString stringWithFormat:@"%@%%", stockStatusModel.ZF];
    
    _volumePriceLb.text = [NSString stringWithFormat:@"%.2f亿", stockStatusModel.volumePrice/(10000*10000.f)];
    _price.text  = [NSString stringWithFormat:@"%.2f", stockStatusModel.price];
    _SYLLb.text     = [NSString stringWithFormat:@"%@", stockStatusModel.PEG];

    _maxPrice52WeekLb.text  = [NSString stringWithFormat:@"%@", stockStatusModel.maxPrice_52Week];
    _minPrice52WeekLb.text  = [NSString stringWithFormat:@"%@", stockStatusModel.minPrice_52Week];
    
    _ZXLLb.text  = [NSString stringWithFormat:@"%@%%", stockStatusModel.ZXL];
    
    _priceLabel.adjustsFontSizeToFitWidth = YES;
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
