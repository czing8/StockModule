//
//  VBidPriceView.m
//  HBStockView
//
//  Created by Vols on 2017/2/28.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VBidPriceView.h"
#import "VBidPriceCell.h"
#import "VStockChartConfig.h"
#import "UIColor+StockTheme.h"
#import "Masonry.h"

@interface VBidPriceView ()

@end

@implementation VBidPriceView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.rowHeight = 17;
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.bounces = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (void)reloadWithModel:(VBidPriceModel *)bidPriceModel {
    _bidPriceModel = bidPriceModel;
    
    [self reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self dequeueReusableCellWithIdentifier:kBidPriceCellIdentifier]) {
        [self registerClass:[VBidPriceCell class] forCellReuseIdentifier:kBidPriceCellIdentifier];
    }
    VBidPriceCell *cell = [self dequeueReusableCellWithIdentifier:kBidPriceCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.noteLabel.text = [self.bidPriceModel sellDescs][indexPath.row];
        cell.priceLabel.text = [self.bidPriceModel sellPrices][indexPath.row];
        cell.volumeLabel.text = [self.bidPriceModel sellVolumes][indexPath.row];
    } else {
        cell.noteLabel.text = [self.bidPriceModel buyDescs][indexPath.row];
        cell.priceLabel.text = [self.bidPriceModel buyPrices][indexPath.row];
        cell.volumeLabel.text = [self.bidPriceModel buyVolumes][indexPath.row];
    }
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 1 ? 5:0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        UIView *view = [UIView new];
        UIView *lineView = [UIView new];
        lineView.backgroundColor = [UIColor bgLineColor];
        [view addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view).insets(UIEdgeInsetsMake(2, 0, 2, 0));
        }];
        return view;
    } else {
        return nil;
    }
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.rowHeight = (self.bounds.size.height-5)/10.f;
    [self.layer setBorderWidth:0.5];
    [self.layer setBorderColor:[UIColor borderLineColor].CGColor];
}

@end
