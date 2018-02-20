//
//  OpenGLView_02_Ctrlbar.m
//  OpenGL ES
//
//  Created by suger on 2018/2/19.
//  Copyright © 2018年 suger. All rights reserved.
//

#import "OpenGLView_02_Ctrlbar.h"
#import "GL02TutorialViewProtocol.h"

@interface OpenGLView_02_Ctrlbar(){

    __weak OpenGLView_02_Ctrlbar *_weakSelf;
}
@property (nonatomic , weak) IBOutlet OpenGLView_02_CtrlLabel* xPositionLabel;
@property (nonatomic , weak) IBOutlet OpenGLView_02_CtrlLabel* yPositionLabel;
@property (nonatomic , weak) IBOutlet OpenGLView_02_CtrlLabel* zPositionLabel;

@property (nonatomic , weak) IBOutlet OpenGLView_02_CtrlLabel* xRotateLabel;
@property (nonatomic , weak) IBOutlet OpenGLView_02_CtrlLabel* zScaleLabel;

@property (nonatomic , weak) IBOutlet UIButton* doAutoButton;

@end


@implementation OpenGLView_02_Ctrlbar

- (void)dealloc {

    _xPositionLabel.sliderActionBlock = nil;
    _yPositionLabel.sliderActionBlock = nil;
    _zPositionLabel.sliderActionBlock = nil;
    _xRotateLabel.sliderActionBlock = nil;
    _zScaleLabel.sliderActionBlock = nil;
    NSLog(@"%s",__func__);
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _weakSelf = self;
    }
    return self;
}


- (void)setXPositionLabel:(OpenGLView_02_CtrlLabel *)xPositionLabel {
    _xPositionLabel = xPositionLabel;

    _xPositionLabel.sliderActionBlock = ^(CGFloat value) {
       [_weakSelf.gl02protocol doXposValueChanged:value];
    };
    
}

- (void)setYPositionLabel:(OpenGLView_02_CtrlLabel *)yPositionLabel {
    _yPositionLabel = yPositionLabel;

    _yPositionLabel.sliderActionBlock = ^(CGFloat value) {
       [_weakSelf.gl02protocol doYposValueChanged:value];
    };
}

- (void)setZPositionLabel:(OpenGLView_02_CtrlLabel *)zPositionLabel {
    _zPositionLabel = zPositionLabel;

    _zPositionLabel.sliderActionBlock = ^(CGFloat value) {
         [_weakSelf.gl02protocol doZposValueChanged:value];
    };
}

- (void)setXRotateLabel:(OpenGLView_02_CtrlLabel *)xRotateLabel {
    _xRotateLabel = xRotateLabel;

    _xRotateLabel.sliderActionBlock = ^(CGFloat value) {
        [_weakSelf.gl02protocol doXrotateValueChanged:value];
    };
}

- (void)setZScaleLabel:(OpenGLView_02_CtrlLabel *)zScaleLabel {
    _zScaleLabel = zScaleLabel;

    _zScaleLabel.sliderActionBlock = ^(CGFloat value) {
        [_weakSelf.gl02protocol doZscaleValueChanged:value];
    };
}


- (IBAction)doAutoAction:(UIButton *)sender{
    
     [_weakSelf.gl02protocol doAutoBtnAction:sender];
    [self doHandlerXRotateWithButton:sender];
    
}

- (IBAction)doReastAction:(UIButton *)sender{
    
     [_weakSelf.gl02protocol doReastBtnAction:sender];
    
    NSDictionary *dict = [_weakSelf.gl02protocol defaultValues];
    
    [self.xPositionLabel setSliderValue: [[dict objectForKey:@"posx"] floatValue]];
    [self.yPositionLabel setSliderValue: [[dict objectForKey:@"posy"] floatValue]];
    [self.zPositionLabel setSliderValue: [[dict objectForKey:@"posz"] floatValue]];
    
    [self.zScaleLabel setSliderValue:  [[dict objectForKey:@"scalez"] floatValue]];
    [self.xRotateLabel setSliderValue: [[dict objectForKey:@"rotatex"] floatValue]];
    
    [self doHandlerXRotateWithButton:self.doAutoButton];

}

- (void)doHandlerXRotateWithButton:(UIButton *)sender {
    [sender setTitle:[_weakSelf.gl02protocol isXRotating] ? @"Stop" : @"Auto" forState:(UIControlStateNormal)];

}

@end
