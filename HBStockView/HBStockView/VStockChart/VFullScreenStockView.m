//
//  VFullScreenStockView.m
//  HBStockView
//
//  Created by Vols on 2017/3/9.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VFullScreenStockView.h"
#import "Masonry.h"

@interface VFullScreenStockView ()

@property (nonatomic, strong) UIButton * closeBtn;

@end

@implementation VFullScreenStockView

- (instancetype) init {
    if (self = [super init]) {
        
        [self addSubview:self.closeBtn];
        [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(2);
            make.right.mas_equalTo(20);
            make.size.mas_equalTo(CGSizeMake(100, 40));
        }];
    }
    return self;
}


- (UIButton *)closeBtn {
    if (_closeBtn == nil) {
        _closeBtn= [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.backgroundColor = [UIColor orangeColor];
        [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        _closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        _closeBtn.titleLabel.textColor = [UIColor whiteColor];
        _closeBtn.layer.cornerRadius = 1.0;
        [_closeBtn setTitleColor:[UIColor brownColor] forState:UIControlStateHighlighted];
        [_closeBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}


- (void)clickAction:(UIButton *)button{
    if (self.closeHandler) {
        self.closeHandler();
    }
}


@end
