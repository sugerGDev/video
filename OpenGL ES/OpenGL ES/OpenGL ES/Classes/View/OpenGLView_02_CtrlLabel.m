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

- (instancetype)initWithTitleValue:(NSString *)titleValue SliderActionBlock:(OpenGLView_02_CtrlLabelSliderActionBlock)sliderActionBlock {
    self = [super init];
    if (self) {
        self.titleLbl.text = titleValue;
        self.sliderActionBlock = sliderActionBlock;
    }

    return self;
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

@end
