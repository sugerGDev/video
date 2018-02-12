//
// Created by suger on 2018/2/11.
// Copyright (c) 2018 suger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

/**
 * 加载 shader 工具类
 */
@interface GLESUntil : NSObject
+ (GLuint)loadShader:(GLenum)type withShaderString:(NSString *)shaderStr;
+ (GLuint)loadShader:(GLenum)type withFilePath:(NSString *)filePathStr;

@end