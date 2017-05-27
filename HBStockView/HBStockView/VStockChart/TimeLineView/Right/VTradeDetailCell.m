//
//  VTradeDetailCell.m
//  HBStockView
//
//  Created by Vols on 2017/3/14.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VTradeDetailCell.h"
#import "Masonry.h"

@interface VTradeDetailCell ()

@property(nonatomic,strong) UILabel *timeLabel;
@property(nonatomic,strong) UILabel *priceLabel;
@property(nonatomic,strong) UILabel *volumeLabel;

@end

@implementation VTradeDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //        self.contentView.backgroundColor = kRGB(250, 251, 252);
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.priceLabel];
        [self.contentView addSubview:self.volumeLabel];
        
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(1);
            make.centerY.equalTo(self.contentView);
            make.width.equalTo(self.contentView).multipliedBy(0.3);
            make.height.equalTo(self.contentView);
        }];
        
        [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_timeLabel.mas_right).offset(2);
            make.centerY.equalTo(self.contentView);
            make.width.equalTo(self.contentView).multipliedBy(0.33);
            make.height.equalTo(self.contentView);
        }];
        
        [_volumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView);
            make.width.equalTo(self.contentView).multipliedBy(0.33);
            make.height.equalTo(self.contentView);
        }];
    }
    
    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    self.priceLabel.adjustsFontSizeToFitWidth = YES;
    self.volumeLabel.adjustsFontSizeToFitWidth = YES;
    
    return self;
}


- (void)setModel:(VTimeTradeModel *)model{
    if (_model != model) {
        _model = model;
    }
    
    [self refreshUI:model];
}

- (void)refreshUI:(VTimeTradeModel *)model {
    self.timeLabel.text     = model.tradeTime;
    self.priceLabel.text    = model.tradePrice;
    self.volumeLabel.attributedText = [self getVolumeString:model];
}


#pragma mark - getter


- (UILabel *)timeLabel{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.font = [UIFont boldSystemFontOfSize:12];
        _timeLabel.textColor = kRGB(60, 60, 60);
    }
    return _timeLabel;
}

- (UILabel *)priceLabel{
    if (_priceLabel == nil) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.font = [UIFont boldSystemFontOfSize:12];
        _priceLabel.textColor = kRGB(60, 60, 60);
    }
    return _priceLabel;
}


- (UILabel *)volumeLabel{
    if (_volumeLabel == nil) {
        _volumeLabel = [[UILabel alloc] init];
        _volumeLabel.textAlignment = NSTextAlignmentRight;
        _volumeLabel.font = [UIFont boldSystemFontOfSize:12];
        _volumeLabel.textColor = kRGB(60, 60, 60);
    }
    return _volumeLabel;
}



- (NSMutableAttributedString *)getVolumeString:(VTimeTradeModel *)model{
    NSString *fullStr;
    UIColor * color;

    if (model.tradeType == -1) {
        fullStr = [NSString stringWithFormat:@"%@S", model.tradeVolmue];
        color = kRGB(41, 253, 47);
    }
    else if (model.tradeType == 1) {
        fullStr = [NSString stringWithFormat:@"%@B", model.tradeVolmue];
        color = [UIColor redColor];
    }
    else if (model.tradeType == 0) {
        fullStr = [NSString stringWithFormat:@"%@-", model.tradeVolmue];
        color = [UIColor grayColor];
    }
    
    NSRange range = NSMakeRange(fullStr.length-1, 1);
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:fullStr];
    [attributedStr addAttributes:@{NSForegroundColorAttributeName:color} range:range];
    
    return attributedStr;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

@end
