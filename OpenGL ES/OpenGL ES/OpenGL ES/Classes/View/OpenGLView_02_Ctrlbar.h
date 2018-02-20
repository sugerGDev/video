//
//  OpenGLView_02_Ctrlbar.h
//  OpenGL ES
//
//  Created by suger on 2018/2/19.
//  Copyright © 2018年 suger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView_02_CtrlLabel.h"

@protocol GL02TutorialViewProtocol;

@interface OpenGLView_02_Ctrlbar : UIView
@property (weak) id<GL02TutorialViewProtocol> gl02protocol;

@end
