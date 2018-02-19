//
//  OpenGLView_02_CtrlLabel.h
//  OpenGL ES
//
//  Created by suger on 2018/2/19.
//  Copyright © 2018年 suger. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OpenGLView_02_CtrlLabelSliderActionBlock)(CGFloat);
@interface OpenGLView_02_CtrlLabel : UIView
@property (copy) OpenGLView_02_CtrlLabelSliderActionBlock sliderActionBlock;

- (instancetype)init __attribute__((deprecated("禁止调用,请调用-initWithTitleValue: SliderActionBlock:")));
- (instancetype)initWithFrame __attribute__((deprecated("禁止调用,请调用-initWithTitleValue: SliderActionBlock:")));

- (instancetype)initWithTitleValue:(NSString *)titleValue SliderActionBlock:(OpenGLView_02_CtrlLabelSliderActionBlock)sliderActionBlock ;

@end
