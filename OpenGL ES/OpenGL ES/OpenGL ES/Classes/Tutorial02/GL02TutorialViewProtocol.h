//
// Created by suger on 2018/2/20.
// Copyright (c) 2018 suger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * 教程02 View 协议
 */
@protocol GL02TutorialViewProtocol <NSObject>
/**
 * x轴平移
 * @param value 平移值
 */
- (void)doXposValueChanged:(CGFloat)value;
/**
 * y轴平移
 * @param value 平移值
 */
- (void)doYposValueChanged:(CGFloat)value;
/**
 * z轴变化
 * @param value 平移值
 */
- (void)doZposValueChanged:(CGFloat)value;

/**
 * x轴旋转
 * @param value 旋转值
 */
- (void)doXrotateValueChanged:(CGFloat)value;
/**
 * z轴缩放
 * @param value 缩放值
 */
- (void)doZscaleValueChanged:(CGFloat)value;

/**
 * 自动滚动事件
 * @param button 按钮
 */
- (void)doAutoBtnAction:(UIButton *)button;

/**
 * 重置事件
 * @param button 按钮
 */
- (void)doReastBtnAction:(UIButton *)button;


/**
 * 是否物体绕X轴旋转
 * @return YES是旋转中 NO静止中
 */
- (BOOL)isXRotating;

/**
 * 获取默认值
 * @return 字典
 */
- (NSDictionary *)defaultValues;
@end
