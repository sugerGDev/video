//
// Created by suger on 2018/2/11.
// Copyright (c) 2018 suger. All rights reserved.
//

#import "GLESUntil.h"


@implementation GLESUntil {

}
+ (GLuint)loadShader:(GLenum)type withShaderString:(NSString *)shaderStr {

    //create the shader object

    GLuint shader = glCreateShader(type);
    if (shader == 0){
        NSLog(@"Error: failed to create shader.");
        return 0;
    }

    // load the shader source
    const  char *shaderStringUTF8 = shaderStr.UTF8String;
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);


    // compile the shader
    glCompileShader(shader);


    //check the compile status
    GLint compiled = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);

    if (!compiled) {

        //get error-info lenght
        GLint  infoLen = 0;
        glGetShaderiv(shader, GL_COMPILE_STATUS, &infoLen);

        if (infoLen > 1) {

            // get error-info string
            char *infoLog = malloc(sizeof(char) *infoLen);
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            NSLog(@"Error compiling shader:\n%s\n", infoLog);
            free(infoLog);
        }

        // delete shader
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

+ (GLuint)loadShader:(GLenum)type withFilePath:(NSString *)filePathStr {

    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:filePathStr encoding:NSUTF8StringEncoding error:&error];

    if (!shaderString){
        NSLog(@"Error: loading shader file %@  %@",filePathStr,error.localizedDescription);
        return 0;
    }
    return [self loadShader:type withShaderString:shaderString];
}

@end