//
//  ViewController.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "StockViewController.h"
#import "StockRequest.h"
#import "VStockGroup.h"
#import "VStockView.h"
#import "Masonry.h"

#import "VStockStatusView.h"
#import "VStockStatusView_HK.h"
#import "VFullScreenStockView.h"

#define kStatusViewHeight   168

@interface StockViewController ()

@property (nonatomic, strong) UIScrollView  * mainScrollView;
@property (nonatomic, strong) UIView        * containerView;    // scrollView的容器View

@property (nonatomic, strong) NSString      * stockCode;
@property (nonatomic, assign) VStockType    stockType;

@property (nonatomic, strong) VStockStatusView      * stockStatusView;
@property (nonatomic, strong) VStockStatusView_HK   * stockStatusView_HK;

@property (nonatomic, strong) VStockView            * stockView;

@property (nonatomic, strong) VFullScreenStockView  * fullScreenStockView;

@end

@implementation StockViewController

- (void)dealloc{
    NSLog(@"StockViewController release");
}

- (instancetype)initStockVC:(NSString *)stockCode type:(VStockType)stockType {
    if (self = [super init]) {
        
        self.stockCode = stockCode;
        self.stockType = stockType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureViews];
    
    [self fetchData];    
}


- (void)configureViews {
    self.view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.mainScrollView];
    self.mainScrollView.backgroundColor = [UIColor purpleColor];
    [_mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.title = _stockCode;

    [self.mainScrollView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.mainScrollView).with.insets(UIEdgeInsetsZero);
        make.width.equalTo(self.mainScrollView);
    }];

    if (_stockType == VStockTypeCN) {
        [self.containerView addSubview:self.stockStatusView];
        [_stockStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.mainScrollView);
            make.height.mas_equalTo(kStatusViewHeight);
        }];
    }
    else if (_stockType == VStockTypeHK) {
        [self.containerView addSubview:self.stockStatusView_HK];
        [_stockStatusView_HK mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(@0);
            make.height.mas_equalTo(kStatusViewHeight);
        }];
    }
    
    __weak typeof(self) weakSelf = self;
//    _stockStatusView.backgroundColor = [UIColor blackColor];

    _stockView = [[VStockView alloc] initWithStockCode:_stockCode stockType:_stockType];
    [_stockView setRefreshTime:_refreshTime];

    _stockView.stockStatusBlock = ^(VStockStatusModel * stockStatusModel){
        if (weakSelf.stockType == VStockTypeCN) {
            weakSelf.stockStatusView.stockStatusModel = stockStatusModel;
        }
        else if (weakSelf.stockType == VStockTypeHK) {
            weakSelf.stockStatusView_HK.stockStatusModel = stockStatusModel;
        }
    };
    
    [self.containerView addSubview:self.stockView];
    _stockView.backgroundColor = [UIColor stockMainBgColor];
    [_stockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kStatusViewHeight);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kStockChartHeight + 2*kStockScrollViewTopGap+44);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.stockView.mas_bottom);
    }];
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchData)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // 点击横屏
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(event_enterFullScreen:)];
//    tap.numberOfTapsRequired = 1;
//    [self.stockView addGestureRecognizer:tap];
//    [self.stock.containerView.subviews setValue:@0 forKey:@"userInteractionEnabled"];
}

- (void)fetchData {
    
    [self.stockView reloadDataCompletion:nil];
}


/*
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
        make.top.equalTo(_fullScreenStockView).offset(48);
    }];
    _fullScreenStockView.transform = CGAffineTransformMakeRotation(M_PI_2);
    [self.stockView reloadDataCompletion:nil];

    _fullScreenStockView.closeHandler = ^(){
        [weakSelf.view addSubview:weakSelf.stockView];
        weakSelf.stockView.backgroundColor = [UIColor stockMainBgColor];
        [weakSelf.stockView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(kStatusViewHeight);
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
*/
#pragma mark - Properties

- (UIScrollView *)mainScrollView {
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, kStatusViewHeight + kStockChartHeight + 2*kStockScrollViewTopGap+44);
    }
    return _mainScrollView;
}


- (UIView *)containerView {
    if (_containerView == nil) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}


- (VStockStatusView *)stockStatusView {
    if (_stockStatusView == nil) {
        _stockStatusView = [[NSBundle mainBundle] loadNibNamed:@"VStockStatusView" owner:self options:nil].lastObject;
    }
    return _stockStatusView;
}

- (VStockStatusView_HK *)stockStatusView_HK {
    if (_stockStatusView_HK == nil) {
        _stockStatusView_HK = [[NSBundle mainBundle] loadNibNamed:@"VStockStatusView_HK" owner:self options:nil].lastObject;
    }
    return _stockStatusView_HK;
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
