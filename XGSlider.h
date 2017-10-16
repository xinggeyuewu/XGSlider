//
//  XGSlider.h
//  
//
//  Created by 星歌 on 2017/2/11.
//  Copyright © 2017年 星歌. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XGSlider;

@protocol XGSliderDelegate <NSObject>

/// 开始滑动
- (void)XGSliderDidBeginMove:(XGSlider *)slider;

/// 滑动到指定位置结束
- (void)XGSliderDidMoveSuccessEnd:(XGSlider *)slider;

@end

/// 登陆界面向右滑动获取验证码界面
@interface XGSlider : UIView

/// 代理
@property (nonatomic, assign) id<XGSliderDelegate>delegate;
/// 已划过区域颜色
@property (nonatomic, strong) UIColor *crossedColor;
///// 滑块图片
//@property (nonatomic, strong) UIImage *sliderImage;
/// 重置滑块状态
- (void)resetSliderState;
@end
