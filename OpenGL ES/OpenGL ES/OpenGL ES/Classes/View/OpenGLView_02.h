//
// Created by suger on 2018/2/8.
// Copyright (c) 2018 suger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <UIKit/UIKit.h>

@class CAEAGLLayer;


@interface OpenGLView_02 : UIView{
    CAEAGLLayer *_glLayer;
    EAGLContext *_glContext;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    
    
    GLuint _programHandle;
    GLuint _positionSlot;
    
}

- (void)setupLayer;
- (void)setupContext;
- (void)setupRenderBuffer;
- (void)setupFrameBuffer;
- (void)destoryRenderAndFrameBuffer;
- (void)render;
- (void)setupProgram;
- (void)drawTriCone;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)init __attribute__((deprecated("禁止调用，使用- initWithFrame:")));
@end
