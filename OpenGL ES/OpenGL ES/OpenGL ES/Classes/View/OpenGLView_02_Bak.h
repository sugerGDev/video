//
//  OpenGLView_02_Bak.h
//  OpenGL ES
//
//  Created by suger on 2018/2/20.
//  Copyright © 2018年 suger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include "ksMatrix.h"

#import "GL02TutorialViewProtocol.h"

@interface OpenGLView_02_Bak : UIView  <GL02TutorialViewProtocol>{
    
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    
    GLuint _programHandle;
    GLuint _positionSlot;
    GLint _modelViewSlot;
    GLint _projectionSlot;
    
    ksMatrix4 _modelViewMatrix;
    ksMatrix4 _projectionMatrix;
    
    float _posX;
    float _posY;
    float _posZ;
    
    float _rotateX;
    float _scaleZ;
}

@property (nonatomic, assign) float posX;
@property (nonatomic, assign) float posY;
@property (nonatomic, assign) float posZ;

@property (nonatomic, assign) float scaleZ;
@property (nonatomic, assign) float rotateX;


@end
