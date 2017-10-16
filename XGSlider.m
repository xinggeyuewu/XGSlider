//
//  XGSlider.m
//
//
//  Created by 星歌 on 2017/2/11.
//  Copyright © 2017年 星歌. All rights reserved.
//

#import "XGSlider.h"

#import "masonry.h"

typedef NS_ENUM(NSInteger,XGSliderState){
    XGSliderStateBegin,
    XGSliderStateMoving,
    XGSliderStateEnd,
    XGSliderStateFaild
} ;

#define kBackgroundColor    RGB_COLOR(221, 221, 221)    // 背景色
#define kCrossedColor       RGB_COLOR(38, 146, 42)      // 已划过区域的颜色
#define kSliderViewX        0.f                         // 滑块初始X值
#define kSliderViewY        0.f                         // 滑块初始Y值

@interface XGSlider ()
/// 当前状态
@property (nonatomic, assign) XGSliderState state;
/// 滑块
@property (nonatomic, strong) UIImageView *sliderView;
/// 已划过区域
@property (nonatomic, strong) UIView *crossedView;

@end

@implementation XGSlider

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = kBackgroundColor;
    
    // 已划过区域图片
    _crossedView = [[UIView alloc] initWithFrame:CGRectZero];
    _crossedView.backgroundColor = kCrossedColor;
    [self addSubview:_crossedView];
    // 提示文字
    UILabel *promptLab = [[UILabel alloc] initWithFrame:CGRectZero];
    promptLab.text = @"向右滑动获取验证码";
    promptLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:promptLab];
    // 滑块
    _sliderView = [[UIImageView alloc] initWithFrame:CGRectMake(kSliderViewX, kSliderViewY, self.frame.size.height, self.frame.size.height)];
    _sliderView.image = [UIImage imageNamed:@"XGSlider"];
    _sliderView.userInteractionEnabled = YES;
    _sliderView.layer.borderColor = kBackgroundColor.CGColor;
    _sliderView.layer.borderWidth = 1.f;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [_sliderView addGestureRecognizer:pan];
    [self addSubview:_sliderView];
    
    [_crossedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.bottom.equalTo(_crossedView.superview);
        make.right.equalTo(_sliderView.mas_centerX);
    }];
    [promptLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(promptLab.superview);
    }];
    
    
}


/// 滑块滑动事件
- (void)panGesture:(UIPanGestureRecognizer *)pan {
    
    CGPoint touchPoint = [pan locationInView:self.superview];
    if (CGRectContainsPoint(self.frame, touchPoint)) { // 接触点在本控件上
        if (pan.state == UIGestureRecognizerStateBegan) { // 开始
            self.state = XGSliderStateMoving;
            if ([_delegate respondsToSelector:@selector(XGSliderDidBeginMove:)]) {
                [_delegate XGSliderDidBeginMove:self];
            }
        }else if (pan.state == UIGestureRecognizerStateEnded) { // 结束
//            NSLog(@"手势识别，结束状态");
            self.state = XGSliderStateEnd;
            [self checkSlierPosition];
        }else if (pan.state == UIGestureRecognizerStateChanged) { // 运动中
//            NSLog(@"手势识别，运动中状态");
            if (self.state == XGSliderStateMoving) {
                CGPoint trans = [pan translationInView:pan.view];
                CGPoint center = _sliderView.center;
                center.x += trans.x;
                _sliderView.center = center;
            }
            [self checkSlierPosition];
            
        }else { // 其他
//            NSLog(@"手势识别，其他状态");
            self.state = XGSliderStateFaild;
            [self sliderReturnsToInitialPosition];
        }
    }else { // 返回
//        NSLog(@"手势识别，手势不在控件上状态");
        if (self.state != XGSliderStateEnd) {
            self.state = XGSliderStateFaild;
            [self sliderReturnsToInitialPosition];
        }
        
    }
    // 清除累计
    [pan setTranslation:CGPointZero inView:pan.view];
    
    
}

/// 检查滑块当前位置
- (void)checkSlierPosition {
    CGRect rect = _sliderView.frame;
    if (rect.origin.x < kSliderViewX) { // 超过左边限制
        rect.origin.x = kSliderViewX;
        _sliderView.frame = rect;
//        NSLog(@"超过左边限制");
    }else if (rect.origin.x > CGRectGetWidth(self.frame) - CGRectGetWidth(rect) - 2.f) { // 超过右边限制
        if (self.state == XGSliderStateMoving) {
//            NSLog(@"超过右边限制,运动中");
            self.state = XGSliderStateEnd;
            rect.origin.x = CGRectGetWidth(self.frame) - CGRectGetWidth(rect);
            _sliderView.frame = rect;
            _sliderView.userInteractionEnabled = NO;
            if ([_delegate respondsToSelector:@selector(XGSliderDidMoveSuccessEnd:)]) {
                [_delegate XGSliderDidMoveSuccessEnd:self];
            }
        }else if (self.state == XGSliderStateEnd){
//            NSLog(@"超过右边限制,已结束状态");
        }else {
//            NSLog(@"超过右边限制,其他状态");
            [self sliderReturnsToInitialPosition];
        }
        
    }else { // 合理范围内移动
        if (self.state != XGSliderStateMoving) {
//            NSLog(@"合理范围内移动,非移动状态");
            [self sliderReturnsToInitialPosition];
        }else {
//            NSLog(@"合理范围内移动,移动中状态");
        }
    }
}

/// 滑块自动返回初始位置
- (void)sliderReturnsToInitialPosition {
    CGRect rect = _sliderView.frame;
    rect.origin.x = kSliderViewX;
    [UIView animateWithDuration:0.5 animations:^{
        _sliderView.frame = rect;
        _crossedView.frame = CGRectMake(0, 0, self.frame.size.height *0.5, self.frame.size.height);
    }];
    
}

/// 重置滑块状态
- (void)resetSliderState {
    CGRect rect = _sliderView.frame;
    rect.origin.x = kSliderViewX;
    _sliderView.frame = rect;
    
    _sliderView.userInteractionEnabled = YES;
    
}



- (void)setCrossedColor:(UIColor *)crossedColor {
    _crossedColor = crossedColor;
    _crossedView.backgroundColor = crossedColor;
}


@end
