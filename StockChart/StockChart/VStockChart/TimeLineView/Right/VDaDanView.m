//
//  DaDanView.m
//  HBStockView
//
//  Created by Vols on 2017/5/23.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VDaDanView.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "VariousChart.h"

#import "VTradeDetailCell.h"
#import "UIColor+StockTheme.h"
#import "StockRequest.h"


@interface VDaDanView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView       * tableView;
@property (nonatomic, strong) NSMutableArray    * dataSource;
@property (nonatomic, strong) UIView            * theHeaderView;
@property (nonatomic, strong) VariousChart      * pieChart;     //饼状图

@property (nonatomic, assign) float      buyVolume;
@property (nonatomic, assign) float      sellVolume;
@property (nonatomic, assign) float      otherVolume;     //中性盘

@property (nonatomic, strong) UILabel   * buyLabel;
@property (nonatomic, strong) UILabel   * sellLabel;
@property (nonatomic, strong) UILabel   * otherLabel;

@property (nonatomic, strong) UILabel   * noDataLabel;

@end


@implementation VDaDanView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configureViews];
    }
    return self;
}

- (void)reloadWithStockCode:(NSString *)stockCode {
    _stockCode = stockCode;
    
    [StockRequest getDaDanRequest:stockCode success:^(NSArray *resultArray) {
        if (resultArray != nil) {
            if (_noDataLabel) {
                [_noDataLabel removeFromSuperview];
            }

            [self reloadWithData:resultArray];
        }
        else if (resultArray == nil) {
            [self addSubview:self.noDataLabel];
            [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
    }];
}

- (void)reloadWithData:(NSArray <VTimeTradeModel *>*)tradeModels{
    _buyVolume = _sellVolume = _otherVolume = 0.f;

    _dataSource = [NSMutableArray arrayWithArray:tradeModels];
    [self.tableView reloadData];
    
    for (VTimeTradeModel *model in tradeModels) {
        if (model.tradeType == -1) {
            _sellVolume += [model.tradeVolmue floatValue];
        }
        else if (model.tradeType == 1) {
            _buyVolume += [model.tradeVolmue floatValue];
        }
        else if (model.tradeType == 0) {
            _otherVolume += [model.tradeVolmue floatValue];
        }
    }
    
    NSArray *keys = @[@"买", @"卖", @"中性"];
    NSArray *values = @[@(_buyVolume), @(_sellVolume), @(_otherVolume)];
    _buyLabel.text = [NSString stringWithFormat:@"%.0f手", _buyVolume];
    _sellLabel.text = [NSString stringWithFormat:@"%.0f手", _sellVolume];
    _otherLabel.text = [NSString stringWithFormat:@"%.0f手", _otherVolume];
    
    [_pieChart drawPieChart:keys values:values];
}

- (void)configureViews {
    [self addSubview:self.tableView];
    self.backgroundColor = [UIColor purpleColor];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    _tableView.tableHeaderView = self.theHeaderView;
    
    // MJRefresh 刷新设置
    MJRefreshNormalHeader *mjHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [StockRequest getDaDanRequest:_stockCode success:^(NSArray *resultArray) {
            [self.tableView.header endRefreshing];

            if (resultArray != nil) {
                if (_noDataLabel) {
                    [_noDataLabel removeFromSuperview];
                }
                
                [self reloadWithData:resultArray];
            }
            else if (resultArray == nil) {
                [self addSubview:self.noDataLabel];
                [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self);
                }];
            }            
        }];
    }];
    
    mjHeader.automaticallyChangeAlpha = YES;
    mjHeader.lastUpdatedTimeLabel.hidden = YES;
    mjHeader.stateLabel.hidden = YES;
    
    self.tableView.header = mjHeader;
}


#pragma mark - Properties

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor purpleColor];
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[VTradeDetailCell class] forCellReuseIdentifier:kTradeDetailCellIdentifier];
        _tableView.rowHeight = 24;      //预估行高 可以提高性能
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.sectionHeaderHeight = 14;
        
    }
    return _tableView;
}

- (UIView *)theHeaderView {
    if (_theHeaderView == nil) {
        _theHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 160.0f)];
        _theHeaderView.backgroundColor = [UIColor whiteColor];
        
        [_theHeaderView addSubview:self.pieChart];
        //    _pieChart.backgroundColor = [UIColor orangeColor];
        [_pieChart mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(@(5));
            make.left.mas_equalTo(@(15));
            make.right.mas_equalTo(@(-15));
            make.height.equalTo(_pieChart.mas_width);
        }];

        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = [UIColor grayColor];
        [_theHeaderView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(_theHeaderView);
            make.height.mas_equalTo(@1);
        }];
        
        UIView * redView = [UIView new];     redView.backgroundColor = kRGB(228, 62, 62);
        UIView * greenView = [UIView new];   greenView.backgroundColor = kRGB(55, 185, 130);
        UIView * grayView = [UIView new];    grayView.backgroundColor = [UIColor grayColor];
        UILabel * redLabel  = [self labelWithText:@"买   盘:"];
        UILabel * greenLabel = [self labelWithText:@"卖   盘:"];
        UILabel * grayLabel = [self labelWithText:@"中性盘:"];
        UILabel * noteLabel = [self labelWithText:@"注:单笔成交额 > 100万"];
        noteLabel.textAlignment = NSTextAlignmentLeft;
        
        [_theHeaderView addSubview:redView];
        [_theHeaderView addSubview:greenView];
        [_theHeaderView addSubview:grayView];
        [_theHeaderView addSubview:redLabel];
        [_theHeaderView addSubview:greenLabel];
        [_theHeaderView addSubview:grayLabel];
        [_theHeaderView addSubview:self.buyLabel];
        [_theHeaderView addSubview:self.sellLabel];
        [_theHeaderView addSubview:self.otherLabel];
        [_theHeaderView addSubview:noteLabel];

        [redView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_pieChart.mas_bottom).offset(10);
            make.left.mas_equalTo(@(5));
            make.size.mas_equalTo(CGSizeMake(6, 6));
        }];
        
        [greenView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(redView.mas_bottom).offset(10);
            make.left.mas_equalTo(@(5));
            make.size.mas_equalTo(CGSizeMake(6, 6));
        }];
        
        [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(greenView.mas_bottom).offset(10);
            make.left.mas_equalTo(@(5));
            make.size.mas_equalTo(CGSizeMake(6, 6));
        }];
        
        [redLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(redView);
            make.left.equalTo(redView).offset(12);
            make.size.mas_equalTo(CGSizeMake(50, 20));
        }];
        
        [greenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(greenView);
            make.left.equalTo(greenView).offset(12);
            make.size.mas_equalTo(CGSizeMake(50, 20));
        }];
        
        [grayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(grayView);
            make.left.equalTo(grayView).offset(12);
            make.size.mas_equalTo(CGSizeMake(50, 20));
        }];
        
        [_buyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(redLabel);
            make.left.equalTo(redLabel).offset(12);
            make.size.mas_equalTo(CGSizeMake(80, 20));
        }];
        
        [_sellLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(greenLabel);
            make.left.equalTo(greenLabel).offset(12);
            make.size.mas_equalTo(CGSizeMake(80, 20));
        }];
        
        [_otherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(grayLabel);
            make.left.equalTo(grayLabel).offset(12);
            make.size.mas_equalTo(CGSizeMake(80, 20));
        }];
        
        [noteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(grayView).offset(12);
            make.left.equalTo(_theHeaderView).offset(2);
            make.right.equalTo(_theHeaderView);
            make.height.mas_equalTo(20);
        }];

    }
    return _theHeaderView;
}

- (VariousChart *)pieChart {
    if (_pieChart == nil) {
        _pieChart = [[VariousChart alloc] init];
    }
    return _pieChart;
}

- (UILabel *)buyLabel {
    if (_buyLabel == nil) {
        _buyLabel = [self labelWithText:nil];
        _buyLabel.textAlignment = NSTextAlignmentRight;
    }
    return _buyLabel;
}

- (UILabel *)sellLabel {
    if (_sellLabel == nil) {
        _sellLabel = [self labelWithText:nil];
        _sellLabel.textAlignment = NSTextAlignmentRight;
    }
    return _sellLabel;
}


- (UILabel *)otherLabel {
    if (_otherLabel == nil) {
        _otherLabel = [self labelWithText:nil];
        _otherLabel.textAlignment = NSTextAlignmentRight;
    }
    return _otherLabel;
}

- (UILabel *)noDataLabel {
    if (_noDataLabel == nil) {
        _noDataLabel = [self labelWithText:@"暂无大单概要数据"];
        _noDataLabel.numberOfLines = 0;
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.backgroundColor = [UIColor whiteColor];
        _noDataLabel.font = [UIFont systemFontOfSize:14];
        _noDataLabel.userInteractionEnabled = YES;
    }
    return _noDataLabel;
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VTradeDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:kTradeDetailCellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor colorWithWhite:0.293 alpha:1.000];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.model = _dataSource[indexPath.row];
    
    return cell;
}


//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    
//    UIView * headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 14)];
//    headView.backgroundColor = [UIColor stockMainBgColor];
//    
//    float width = (self.bounds.size.width-3)/3.0 ;
//    NSArray * titles = @[@"时间", @"价格", @"成交量"];
//    for (int i = 0; i < 3; i ++) {
//        UILabel * label = [[UILabel alloc] init];
//        label.frame = CGRectMake(2+i*width, 0, width, 14);
//        label.font = [UIFont systemFontOfSize:12];
//        label.text = titles[i];
//        [headView addSubview:label];
//        if (i == 2) {
//            label.textAlignment = NSTextAlignmentRight;
//            label.frame = CGRectMake(2+i*width, 0, width + 3, 14);
//        }
//    }
//    
//    return headView;
//}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSelector:@selector(deselect:) withObject:tableView afterDelay:0.2f];
}

- (void)deselect:(UITableView *)tableView {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - helper

- (UILabel *)labelWithText:(NSString *)title {
    UILabel * label = [UILabel new];
    if (title != nil) label.text = title;
    label.textColor = kRGB(60, 60, 60);
    label.font = [UIFont systemFontOfSize:10];
    return label;
}


@end
