//
// Created by suger on 2018/2/8.
// Copyright (c) 2018 suger. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OpenGLView_02.h"
#import "GLESUtils.h"

@implementation OpenGLView_02 {

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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self onCreateResource];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self onCreateResource];
    }

    return self;
}

- (void)onCreateResource {
    
    self.backgroundColor = UIColor.whiteColor;
    
    [self setupLayer];
    
    [self setupContext];
    
    [self setupProgram];
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

    
    // setup viewport
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);

    [self drawTriCone];
    
    
    [_glContext presentRenderbuffer:GL_RENDERBUFFER];
}



- (void)setupProgram {
    // load shaders
    NSString *vertexShaderPath = [[NSBundle mainBundle]pathForResource:@"VertexShader" ofType:@"glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"glsl"];
    
    _programHandle = [GLESUtils loadProgram:vertexShaderPath
                 withFragmentShaderFilepath:fragmentShaderPath];
    if (_programHandle == 0) {
        NSLog(@" >> Error: Failed to setup program.");
        return;
    }
    
    glUseProgram(_programHandle);
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
}

- (void)drawTriCone {
    GLfloat vertices[] = {
       0.5f,   0.5f,   0.f,
       0.5f,  -0.5f,   0.f,
      -0.5f,  -0.5f,   0.f,
      -0.5f,   0.5f,   0.f,
        0.f,    0.f,  -0.707f,
    };
    
    GLubyte indices[] = {
       0, 1, 1, 2, 2, 3, 3, 0,
       4, 0, 4, 1, 4, 2, 4, 3,
    };
    
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    // draw lines
    /**
     这次我们使用顶点索引数组结合 glDrawElements 来渲染，而在 Tutorial02 中，使用的是 glDrawArrays。使用顶点索引数组有什么好处呢？很明显，我们可以减少存储重复顶点的内存消耗。比如在本例的索引表中，我们重复利用了顶点 0，1，2，3，4，它们对应 vertices 数组中5个顶点（三个浮点数组成一个顶点）。
     
     第一个参数 mode 为描绘图元的模式，其有效值为：GL_POINTS, GL_LINES, GL_LINE_STRIP,  GL_LINE_LOOP,  GL_TRIANGLES,  GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN。这些模式具体含义下面有介绍。
     
     第二个参数 count 为顶点索引的个数也就是，type 是指顶点索引的数据类型，因为索引始终是正值，索引这里必须是无符号型的非浮点类型，因此只能是 GL_UNSIGNED_BYTE, GL_UNSIGNED_SHORT, GL_UNSIGNED_INT 之一，为了减少内存的消耗，尽量使用最小规格的类型如 GL_UNSIGNED_BYTE。
     
     第三个参数 indices 是存放顶点索引的数组。（indices 是 index 的复数形式，3D 里面很多单词的复数都挺特别的。）
     */
    glDrawElements(GL_LINES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
}
@end
