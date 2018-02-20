//
//  OpenGLView_02_Surface.m
//  OpenGL ES
//
//  Created by suger on 2018/2/20.
//  Copyright © 2018年 suger. All rights reserved.
//

#import "OpenGLView_02_Surface.h"
//#import "OpenGLView_02.h"
#import "OpenGLView_02_Bak.h"

#import "OpenGLView_02_Ctrlbar.h"



@interface OpenGLView_02_Surface()
@property (weak, nonatomic) IBOutlet OpenGLView_02_Bak *renderView;
@property (weak, nonatomic) IBOutlet OpenGLView_02_Ctrlbar *ctrlBar;


@end



@implementation OpenGLView_02_Surface

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];
    // build bridge
    self.ctrlBar.gl02protocol = (id<GL02TutorialViewProtocol>)self.renderView;
}

@end
