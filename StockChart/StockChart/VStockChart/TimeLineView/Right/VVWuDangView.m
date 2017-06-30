//
//  VVWuDangView.m
//  HBStockView
//
//  Created by Vols on 2017/2/28.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VVWuDangView.h"
#import "VVWuDangCell.h"
#import "VStockChartConfig.h"
#import "UIColor+StockTheme.h"
#import "Masonry.h"

@interface VVWuDangView ()

@end

@implementation VVWuDangView

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

- (void)reloadWithModel:(VVWuDangModel *)wuDangModel {
    _wuDangModel = wuDangModel;
    
    [self reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self dequeueReusableCellWithIdentifier:kWuDangCellIdentifier]) {
        [self registerClass:[VVWuDangCell class] forCellReuseIdentifier:kWuDangCellIdentifier];
    }
    VVWuDangCell *cell = [self dequeueReusableCellWithIdentifier:kWuDangCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.noteLabel.text = [self.wuDangModel sellDescs][indexPath.row];
        cell.priceLabel.text = [self.wuDangModel sellPrices][indexPath.row];
        cell.volumeLabel.text = [self.wuDangModel sellVolumes][indexPath.row];
    } else {
        cell.noteLabel.text = [self.wuDangModel buyDescs][indexPath.row];
        cell.priceLabel.text = [self.wuDangModel buyPrices][indexPath.row];
        cell.volumeLabel.text = [self.wuDangModel buyVolumes][indexPath.row];
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
