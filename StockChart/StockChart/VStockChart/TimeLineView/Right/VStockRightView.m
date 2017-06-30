//
//  VStockRightView.m
//  StockChart
//
//  Created by Vols on 2017/3/13.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VStockRightView.h"
#import "VScrollMenuView.h"
#import "VVWuDangView.h"
#import "VVMingxiView.h"
#import "VVDaDanView.h"

#import "StockRequest.h"

#import "Masonry.h"

@interface VStockRightView () <VScrollMenuViewDelegate>

@property (nonatomic, strong) VScrollMenuView   * scrollMenu;      // 顶部选择菜单

@property (nonatomic, strong) VVWuDangView  * wuDangView;     // 五档图
@property (nonatomic, strong) VVMingxiView  * mingxiView;  // 交易明细
@property (nonatomic, strong) VVDaDanView   * daDanView;     // 大单视图


@end

@implementation VStockRightView

#pragma mark - View Lifecycle

- (void)dealloc {

}

- (instancetype)init {
    if (self = [super init]) {

        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    
    _scrollMenu = [[VScrollMenuView alloc]initWithTitles:@[@"五档", @"明细", @"大单"] layoutStyle:VScrollMenuLayoutStyleInScreen];
    _scrollMenu.titleFont = [UIFont systemFontOfSize:13];
    [self addSubview:_scrollMenu];
    [_scrollMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.equalTo(@24);
    }];
    _scrollMenu.delegate = self;
    
    [self addSubview:self.wuDangView];
    [self addSubview:self.mingxiView];
    [self addSubview:self.daDanView];

    [_wuDangView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(_scrollMenu.mas_top);
    }];
    
    [_mingxiView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(_scrollMenu.mas_top);
    }];

    [_daDanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(_scrollMenu.mas_top);
    }];

    _wuDangView.backgroundColor = [UIColor clearColor];
    _mingxiView.backgroundColor = [UIColor clearColor];
    _daDanView.backgroundColor = [UIColor orangeColor];
}

#pragma mark - Properties

- (VVWuDangView *)wuDangView {
    if (_wuDangView == nil) {
        _wuDangView = [VVWuDangView new];
    }
    return _wuDangView;
}

- (VVMingxiView *)mingxiView {
    if (_mingxiView == nil) {
        _mingxiView = [VVMingxiView new];
        _mingxiView.hidden = YES;
    }
    return _mingxiView;
}

- (VVDaDanView *)daDanView {
    if (_daDanView == nil) {
        _daDanView = [VVDaDanView new];
        _daDanView.hidden = YES;
    }
    return _daDanView;
}


- (void)setStockGroup:(VStockGroup *)stockGroup{
    _stockGroup = stockGroup;
    
    [self.wuDangView reloadWithModel:_stockGroup.wuDangModel];
//    [self.tradeDetailView reloadWithData:_stockGroup.tradeModels];
//    self.tradeDetailView.stockCode = _stockGroup.stockCode;
}

#pragma mark - ScrollMenuDelegate

- (void)scrollMenu:(VScrollMenuView *)scrollMenu didSelectedIndex:(NSInteger)index {
    _wuDangView.hidden = YES;
    _mingxiView.hidden = YES;
    _daDanView.hidden = YES;

    if (index == 0) {
        _wuDangView.hidden = NO;
    }
    else if (index == 1) {
        _mingxiView.hidden = NO;
        [_mingxiView reloadWithStockCode:_stockGroup.stockCode];
    }
    else if (index == 2) {
        _daDanView.hidden = NO;
        [_daDanView reloadWithStockCode:_stockGroup.stockCode];
    }
}

@end
