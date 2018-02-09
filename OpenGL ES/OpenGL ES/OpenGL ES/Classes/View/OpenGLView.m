//
// Created by suger on 2018/2/8.
// Copyright (c) 2018 suger. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OpenGLView.h"

@implementation OpenGLView {

}
- (void)dealloc {
    
    [self destoryRenderAndFrameBuffer];
    
    _glContext = nil;
    
    NSLog(@"%s",__func__);
}

+ (Class)layerClass{
    return CAEAGLLayer.class;
}

- (instancetype)init{
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = UIColor.whiteColor;
        
        [self setupLayer];
        
        [self setupContext];
    
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [EAGLContext setCurrentContext:_glContext];
    
    [self destoryRenderAndFrameBuffer];

    [self setupRenderBuffer];

    [self setupFrameBuffer];

    [self render];
}

#pragma mark - tool
- (void)setupLayer {
    _glLayer = (CAEAGLLayer *) self.layer;
    /*设置为不透明*/
    _glLayer.opaque = YES;

    _glLayer.drawableProperties = @{
            kEAGLDrawablePropertyRetainedBacking : @(NO),
            kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8
    };
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _glContext = [[EAGLContext alloc] initWithAPI:api];

    if (!_glContext){
        NSLog(@"failed to initialize opengles 2.0 context");
        abort();
    }

    if (![EAGLContext setCurrentContext:_glContext]){
        NSLog(@"failed to set context opengl context");
        abort();
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_glLayer];
}

- (void)setupFrameBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);

    /**
     * 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
     * 该函数是将相关 buffer（三大buffer之一）attach到framebuffer上（如果 renderbuffer不为 0，知道前面为什么说glGenRenderbuffers 返回的id 不会为 0 吧）或从 framebuffer上detach（如果 renderbuffer为 0）。
     * 参数 attachment 是指定 renderbuffer 被装配到那个装配点上，其值是GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT中的一个，分别对应 color，depth和 stencil三大buffer。
     */
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)destoryRenderAndFrameBuffer {
    glDeleteBuffers(1, &_frameBuffer);
    _frameBuffer = 0;

    glDeleteBuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}

- (void)render {

    glClearColor(0.f, 1.f, 0.f, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    [_glContext presentRenderbuffer:GL_RENDERBUFFER];
}


@end
