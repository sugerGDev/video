//
//  OpenGLView_02_CtrlLabel.m
//  OpenGL ES
//
//  Created by suger on 2018/2/19.
//  Copyright © 2018年 suger. All rights reserved.
//

#import "OpenGLView_02_CtrlLabel.h"

@interface OpenGLView_02_CtrlLabel()
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UISlider *valueSlider;

@end



@implementation OpenGLView_02_CtrlLabel

- (instancetype)init {
    return nil;
}

- (instancetype)initWithFrame {
    return nil;
}


- (void)dealloc {
    self.sliderActionBlock = nil;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)doSliderAction:(UISlider *)sender {
    if (self.sliderActionBlock) {
        self.sliderActionBlock(sender.value);
    }
}

- (void)setSliderValue:(CGFloat)value {
    self.valueSlider.value = value;
}

@end
