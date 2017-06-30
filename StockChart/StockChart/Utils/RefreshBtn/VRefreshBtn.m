//
//  VRefreshBtn.m
//  PopupViewExample
//
//  Created by Vols on 2017/6/23.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VRefreshBtn.h"
#import "Masonry.h"

@interface VRefreshBtn ()

@property (nonatomic, strong) UIButton * theButton;
@property (nonatomic, strong) UIActivityIndicatorView * indicator;

@end


@implementation VRefreshBtn

#pragma mark - Lifecycle

- (id)init{
    self = [super init];
    if (self) {
        
        [self configureViews];
    }
    return self;
}


- (void)configureViews{
    
    [self addSubview:self.indicator];
    [self addSubview:self.theButton];

    [_theButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    self.backgroundColor = [UIColor clearColor];
}


- (void)clickAction:(UIButton *)button {
    button.hidden = YES;
    [_indicator startAnimating];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_indicator stopAnimating];
        button.hidden = NO;
    });
    
    if (_clickHandler) {
        _clickHandler();
    }
}


#pragma mark - Properties

- (UIButton *)theButton {
    if (_theButton == nil) {
        _theButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_theButton setImage:[UIImage imageNamed:@"nav_refresh"] forState:UIControlStateNormal];
        [_theButton addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _theButton;
}


- (UIActivityIndicatorView * )indicator {
    if (_indicator == nil) {
        _indicator = [[UIActivityIndicatorView alloc] init];
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _indicator.backgroundColor = [UIColor clearColor];
        _indicator.alpha = 0.5;
        _indicator.layer.cornerRadius = 6;
    }
    return _indicator;
}



@end
