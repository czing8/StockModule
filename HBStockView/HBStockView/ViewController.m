//
//  ViewController.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "ViewController.h"
#import "StockRequest.h"
#import "VTimeLineGroup.h"
#import "VStockView.h"
#import "Masonry.h"

#import "VStockStatusView.h"
#import "VFullScreenStockView.h"

@interface ViewController ()

@property (nonatomic, strong) VStockStatusView      * stockStatusView;

@property (nonatomic, strong) VFullScreenStockView  * fullScreenStockView;

@property (nonatomic, strong) VStockView        * stockView;

@property (nonatomic, strong) NSMutableDictionary * stockDataSource;

@property (nonatomic, strong) VTimeLineGroup    * timeGroup;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureViews];
    
    [self fetchData];
}


- (void)configureViews {
    self.view.backgroundColor = [UIColor greenColor];
    self.title = @"华天科技(002185)";
    
    [self.view addSubview:self.stockStatusView];
    
    __weak typeof(self) weakSelf = self;
//    _stockStatusView.backgroundColor = [UIColor blackColor];
    [_stockStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(@0);
        make.height.mas_equalTo(168);
    }];

    _stockView = [[VStockView alloc] init];
    _stockView.stockStatusBlock = ^(VStockStatusModel * stockStatusModel){
        weakSelf.stockStatusView.stockStatusModel = stockStatusModel;
    };
    
    [self.view addSubview:self.stockView];
    _stockView.backgroundColor = [UIColor stockMainBgColor];
    [_stockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_stockStatusView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kStockChartHeight + 2*kStockScrollViewTopGap+44);
    }];
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchData)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(event_enterFullScreen:)];
    tap.numberOfTapsRequired = 1;
    [self.stockView addGestureRecognizer:tap];
//    [self.stock.containerView.subviews setValue:@0 forKey:@"userInteractionEnabled"];
}

- (void)fetchData {
    
    [self.stockView reloadDataCompletion:nil];
    
//    [StockRequest getDayStockDataSuccess:^(VLineGroup *response) {
//        NSLog(@"count:%lu", (unsigned long)response.lineModels.count);
//        [self.stockDataSource setObject:response forKey:@"daySource"];
//    }];
//
//    
//    [StockRequest getTimeStockDataSuccess:^(VTimeLineGroup *response) {
//        _timeGroup = response;
//        _stockStatusView.timeLineGroup = _timeGroup;
//        [self.stockDataSource setObject:_timeGroup forKey:@"minutes"];
//    }];
    
}


- (void)event_enterFullScreen:(UITapGestureRecognizer *)tap {
    __weak typeof(self) weakSelf = self;
    tap.enabled = NO;

    if([UIApplication sharedApplication].statusBarHidden == NO) {
        //iOS7，需要plist里设置View controller-based status bar appearance为NO
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.fullScreenStockView];
    
    [_fullScreenStockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(window.mas_height);
        make.height.equalTo(window.mas_width);
        make.center.equalTo(window);
    }];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    _fullScreenStockView.backgroundColor = [UIColor purpleColor];
    [_fullScreenStockView addSubview:self.stockView];
    [self.stockView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(_fullScreenStockView);
        make.top.equalTo(_fullScreenStockView).offset(66);
    }];
    _fullScreenStockView.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self.stockView reloadDataCompletion:nil];
    
    _fullScreenStockView.closeHandler = ^(){
        [weakSelf.view addSubview:weakSelf.stockView];
        weakSelf.stockView.backgroundColor = [UIColor orangeColor];
        [weakSelf.stockView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.stockStatusView.mas_bottom);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(kStockChartHeight + 2*kStockScrollViewTopGap+44);
        }];
        
        [weakSelf.stockView reloadDataCompletion:nil];
        
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.fullScreenStockView.alpha = 0.f;
        } completion:^(BOOL finished) {
            [weakSelf.fullScreenStockView removeFromSuperview];
            weakSelf.fullScreenStockView = nil;
        }];
        if([UIApplication sharedApplication].statusBarHidden == YES) {
            //iOS7，需要plist里设置View controller-based status bar appearance为NO
            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        }
        [weakSelf.stockView.gestureRecognizers.firstObject setEnabled:YES];
    };
}


#pragma mark - Properties
- (NSMutableDictionary *)stockDataSource{
    if (_stockDataSource == nil) {
        _stockDataSource = [[NSMutableDictionary alloc] init];
    }
    return _stockDataSource;
}

- (VStockStatusView *)stockStatusView {
    if (_stockStatusView == nil) {
        _stockStatusView = [[NSBundle mainBundle] loadNibNamed:@"VStockStatusView" owner:self options:nil].lastObject;
    }
    return _stockStatusView;
}

- (VFullScreenStockView *)fullScreenStockView {
    if (_fullScreenStockView == nil) {
        _fullScreenStockView = [[VFullScreenStockView alloc] init];
        _fullScreenStockView.backgroundColor = [UIColor stockMainBgColor];
    }
    return _fullScreenStockView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/**
 *  将若干view等宽布局于容器containerView中
 *
 *  @param views         viewArray
 *  @param containerView 容器view
 *  @param LRpadding     距容器的左右边距
 *  @param viewPadding   各view的左右边距
 */
-(void)makeEqualWidthViews:(NSArray *)views inView:(UIView *)containerView LRpadding:(CGFloat)LRpadding viewPadding :(CGFloat)viewPadding {
    UIView *lastView;
    for (UIView *view in views) {
        [containerView addSubview:view];
        if (lastView) {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(containerView);
                make.left.equalTo(lastView.mas_right).offset(viewPadding);
                make.width.equalTo(lastView);
            }];
        }
        else {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(containerView).offset(LRpadding);
                make.top.bottom.equalTo(containerView);
            }];
        }
        lastView = view;
    }
    
    [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(containerView).offset(-LRpadding);
    }];
}


@end
