//
//  VScrollMenuView.m
//  StockChart
//
//  Created by Vols on 2017/3/3.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VScrollMenuView.h"
#import "Masonry.h"
#import "UIColor+StockTheme.h"
#import "VStockConstant.h"
#import "VStockChartConfig.h"

#define kScrollMenuItemWidth    94      // 按钮默认宽度
#define kIndicatorViewHeight    2

@interface VScrollMenuView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView  * scrollView;
@property (nonatomic, strong) UIView        * indicatorView;    // 标题下方的指示器

@property (nonatomic, assign) VScrollMenuLayoutStyle itemLayoutStyle;   //  按钮排列样式

@property (nonatomic, copy  ) NSArray <NSString *>  * titleItems;   //  持有数据源
@property (nonatomic, strong) NSMutableArray        * btnArray;     // 持有按钮数组

@property (nonatomic, strong) UIButton          * lastSelectedBtn;  // 最后选中的按钮
@property (nonatomic, assign) NSUInteger        selectedIndex;      // 当前选中的index

@end

@implementation VScrollMenuView

#pragma mark - View Lifecycle

- (instancetype)initWithTitles:(NSArray <NSString *>*)titleItems layoutStyle:(VScrollMenuLayoutStyle)style {
    self = [super init];
    if (self) {
        //默认设置
        _bgColor            = [UIColor stockMainBgColor];
        _lineSelectedColor  = [UIColor topBarSelectedLineColor];
        _textNormalColor    = [UIColor topBarNormalTextColor];
        _textSelectedColor  = [UIColor topBarSelectedTextColor];
        _titleFont          = [UIFont systemFontOfSize:15];
        _titleItems         = titleItems;
        _itemLayoutStyle    = style;
        
        [self setupHeadView];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.itemLayoutStyle == VScrollMenuLayoutStyleInScreen) {
        self.scrollView.contentSize = self.scrollView.bounds.size;
    }
    else if (self.itemLayoutStyle == VScrollMenuLayoutStyleOutScreen) {
        self.scrollView.contentSize = CGSizeMake(self.titleItems.count * kScrollMenuItemWidth, self.scrollView.bounds.size.height);
    }
}


#pragma mark - Public

- (void)setBgColor:(UIColor *)bgColor{
    _bgColor = bgColor;
    
    self.scrollView.backgroundColor = _bgColor;
}

- (void)setLineSelectedColor:(UIColor *)lineSelectedColor{
    _lineSelectedColor = lineSelectedColor;
    
    self.indicatorView.backgroundColor = _lineSelectedColor;
}

- (void)setTextNormalColor:(UIColor *)textNormalColor {
    _textNormalColor = textNormalColor;
    
    for (UIButton * obj in self.btnArray) {
        [obj setTitleColor:_textNormalColor forState:UIControlStateNormal];
    }
}

- (void)setTextSelectedColor:(UIColor *)textSelectedColor {
    _textSelectedColor = textSelectedColor;
    
    for (UIButton * obj in self.btnArray) {
        [obj setTitleColor:_textSelectedColor forState:UIControlStateSelected];
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    
    for (UIButton * obj in self.btnArray) {
        obj.titleLabel.font = _titleFont;
    }
}

#pragma mark - UIs

- (void)setupHeadView {
    switch (self.itemLayoutStyle) {
        case VScrollMenuLayoutStyleInScreen:
            [self initTopBarInScreen];
            break;
        case VScrollMenuLayoutStyleOutScreen:
            [self initTopBarOutScreen];
            break;
        default:
            break;
    }
}

/**
 初始化顶部按钮在一屏内
 */
- (void)initTopBarInScreen {
    self.scrollView = ({
        UIScrollView *scrollView = [UIScrollView new];
        scrollView.backgroundColor = _bgColor;
        [self addSubview:scrollView];
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        //按钮组
        __block UIButton *lastBtn;
        __block UIButton *firstBtn;
        self.btnArray = @[].mutableCopy;
        [self.titleItems enumerateObjectsUsingBlock:^(NSString  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = [self createBtnWithTitle:obj tag:idx+100];
            [scrollView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(scrollView);
                make.width.equalTo(scrollView).multipliedBy(1.f/self.titleItems.count);
                make.left.equalTo(lastBtn == nil ? scrollView.mas_left : lastBtn.mas_right);
                make.height.equalTo(scrollView).offset(-2);
            }];
            if (!lastBtn) firstBtn = btn;
            lastBtn = btn;
            [self.btnArray addObject:btn];
        }];
        
        //指示器
        UIView *indicatorView = [UIView new];
        indicatorView.backgroundColor = _lineSelectedColor;
        [scrollView addSubview:indicatorView];
        self.indicatorView = indicatorView;
        
        [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@kIndicatorViewHeight);
            make.width.equalTo(@(lastBtn.titleLabel.frame.size.width));
            make.top.equalTo(lastBtn.mas_bottom);
            make.centerX.equalTo(firstBtn.mas_centerX);
        }];
        
        scrollView.contentSize = self.frame.size;
        scrollView;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateBtnUI:nil newBtn:[self.scrollView.subviews firstObject]];
    });
}

/**
 初始化顶部按钮，无一屏限制
 */
- (void)initTopBarOutScreen {
    self.scrollView = ({
        UIScrollView *scrollView = [UIScrollView new];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        //按钮组
        __block UIButton *lastBtn;
        __block UIButton *firstBtn;
        self.btnArray = @[].mutableCopy;
        [self.titleItems enumerateObjectsUsingBlock:^(NSString  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = [self createBtnWithTitle:obj tag:idx+100];
            [scrollView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(scrollView.mas_top);
                make.width.equalTo(@kScrollMenuItemWidth);
                make.left.equalTo(scrollView).offset(kScrollMenuItemWidth * idx);
                make.height.equalTo(scrollView).offset(-kIndicatorViewHeight);
            }];
            if (!lastBtn) firstBtn = btn;
            lastBtn = btn;
            [self.btnArray addObject:btn];
        }];
        
        //指示器
        UIView *indicatorView = [UIView new];
        indicatorView.backgroundColor = _lineSelectedColor;
        [scrollView addSubview:indicatorView];
        self.indicatorView = indicatorView;
        
        
        [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor orangeColor]};
            CGSize textSize = [self rectOfNSString:lastBtn.titleLabel.text attribute:attribute].size;
            make.height.equalTo(@kIndicatorViewHeight);
            make.width.equalTo(@(textSize.width));
            make.top.equalTo(lastBtn.mas_bottom);
            make.centerX.equalTo(firstBtn.mas_centerX);
        }];
        
        scrollView.contentSize = CGSizeMake(self.titleItems.count * kScrollMenuItemWidth, self.frame.size.height);
        scrollView;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateBtnUI:nil newBtn:[self.scrollView.subviews firstObject]];
    });
}


/**
 按钮点击事件
 
 @param btn 被点击的按钮
 */
- (void)didClickBtnAction:(UIButton *)btn {
    if (self.selectedIndex != btn.tag-100) {
        self.userInteractionEnabled= NO;
        [self updateBtnUI:[self.scrollView viewWithTag:self.selectedIndex+100] newBtn:btn];
        
        //滚动scrollview
        CGFloat willOffsetX = ((btn.frame.origin.x + btn.frame.size.width/2.f) - self.bounds.size.width/2.f);
        [UIView animateWithDuration:.5f animations:^{
            if (willOffsetX < 0) {
                self.scrollView.contentOffset = CGPointZero;
            } else if(willOffsetX + self.scrollView.bounds.size.width > self.scrollView.contentSize.width) {
                self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.bounds.size.width, 0);
            } else {
                self.scrollView.contentOffset = CGPointMake(willOffsetX, 0);
            }
        }];
        
        if ([self.delegate respondsToSelector:@selector(scrollMenu:didSelectedIndex:)]) {
            [self.delegate scrollMenu:self didSelectedIndex:btn.tag-100];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.userInteractionEnabled= YES;
        });
    }
}


/**
 选中按钮
 
 @param index 按钮index
 */
- (void)selectIndex:(NSInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self didClickBtnAction:[self.scrollView viewWithTag:index + 100]];
    });
}

/**
 更新UI
 
 @param oldBtn 原按钮
 @param newBtn 新按钮
 */
- (void)updateBtnUI: (UIButton *)oldBtn newBtn:(UIButton *)newBtn {
    
    oldBtn.selected = NO;
    [newBtn setSelected:YES];
    
    [self.indicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(newBtn.mas_centerX);
        make.height.equalTo(@kIndicatorViewHeight);
        make.width.equalTo(@(newBtn.titleLabel.frame.size.width));
        make.top.equalTo(newBtn.mas_bottom);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
    
    self.selectedIndex = newBtn.tag-100;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y != 0) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
}


#pragma mark - Helpers
/**
 创建按钮
 
 @param title 标题
 @param tag tag
 */
- (UIButton *)createBtnWithTitle:(NSString *)title tag:(NSInteger)tag {
    UIButton *btn = [UIButton new];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = self.titleFont;
    [btn setTitleColor:self.textNormalColor forState:UIControlStateNormal];
    [btn setTitleColor:self.textSelectedColor forState:UIControlStateSelected];
    btn.tag = tag;
    [btn addTarget:self action:@selector(didClickBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (CGRect)rectOfNSString:(NSString *)string attribute:(NSDictionary *)attribute {
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                       options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading
                                    attributes:attribute
                                       context:nil];
    return rect;
}

@end
