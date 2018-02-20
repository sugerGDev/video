//
//  OpenGLView_02_Bak.m
//  OpenGL ES
//
//  Created by suger on 2018/2/20.
//  Copyright © 2018年 suger. All rights reserved.
//

#import "OpenGLView_02_Bak.h"
#import "GLESUtils.h"

@interface OpenGLView_02_Bak()
{
    CADisplayLink * _displayLink;
}

- (void)setupLayer;
- (void)setupContext;
- (void)setupBuffers;
- (void)destoryBuffers;

- (void)setupProgram;
- (void)setupProjection;

- (void)updateTransform;
- (void)resetTransform;

- (void)toggleDisplayLink;
- (void)displayLinkCallback:(CADisplayLink*)displayLink;

- (void)render;
- (void)cleanup;

@end

@implementation OpenGLView_02_Bak
@synthesize posX = _posX;
@synthesize posY = _posY;
@synthesize posZ = _posZ;
@synthesize scaleZ = _scaleZ;
@synthesize rotateX = _rotateX;

- (void)dealloc {
    [self cleanup];
    NSLog(@"%s",__func__);
}

+ (Class)layerClass {
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@" >> Error: Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:_context]) {
        _context = nil;
        NSLog(@" >> Error: Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupBuffers {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    // 设置为当前 renderbuffer
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    /**
     * 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
     * 该函数是将相关 buffer（三大buffer之一）attach到framebuffer上（如果 renderbuffer不为 0，知道前面为什么说glGenRenderbuffers 返回的id 不会为 0 吧）或从 framebuffer上detach（如果 renderbuffer为 0）。
     * 参数 attachment 是指定 renderbuffer 被装配到那个装配点上，其值是GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT中的一个，分别对应 color，depth和 stencil三大buffer。
     */
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)destoryBuffers
{
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
    
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
}

- (void)cleanup
{
    [self destoryBuffers];
    
    if (_programHandle != 0) {
        glDeleteProgram(_programHandle);
        _programHandle = 0;
    }
    
    if (_context && [EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
    
    _context = nil;
}

- (void)setupProgram
{
    // Load shaders
    //
    NSString * vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader"
                                                                  ofType:@"glsl"];
    NSString * fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader"
                                                                    ofType:@"glsl"];
    
    _programHandle = [GLESUtils loadProgram:vertexShaderPath
                 withFragmentShaderFilepath:fragmentShaderPath];
    if (_programHandle == 0) {
        NSLog(@" >> Error: Failed to setup program.");
        return;
    }
    
    glUseProgram(_programHandle);
    
    // Get the attribute position slot from program
    //
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    
    // Get the uniform model-view matrix slot from program
    //
    _modelViewSlot = glGetUniformLocation(_programHandle, "modelView");
    
    // Get the uniform projection matrix slot from program
    //
    _projectionSlot = glGetUniformLocation(_programHandle, "projection");
}

-(void)setupProjection
{
    
    /**
     * ksMatrixLoadIdentity 是 GLESMath 中的一个数学函数，用来将指定矩阵重置为单位矩阵，而 ksPerspective 与前文中讲到的 gluPersoective 作用一样。在这里，我们设置视锥体的近裁剪面到观察者的距离为 1， 远裁剪面到观察者的距离为 20，视角为 60度，
     * 然后装载投影矩阵。默认的观察者位置在原点，视线朝向 -Z 方向，因此近裁剪面其实就在 z = -1 这地方，远裁剪面在 z = -20 这地方，z 值不在(-1, -20) 之间的物体是看不到的
     */
    
    // Generate a perspective matrix with a 60 degree FOV
    //
    float aspect = self.frame.size.width / self.frame.size.height;
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 60.0, aspect, 1.0f, 20.0f);
    
    // Load projection matrix
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
}

- (void)updateTransform
{
    
    /**
     ksTranslate，ksRotate，ksScale 也是 GLESMath 中的数学函数，作用与 glTranslate，glRotate，glScale 相同，分别用于平移，绕轴旋绕以及缩放。在这里，设置在 x 方向上平移，平移量将由 self.posX 控制，而这个属性最终是由滑块控制的，从而达到用户移动物体的目的；将 z 设置为 -5.5 (介于 (-1, -20) 之间，前面有讲)；此外还设置绕 x 轴旋绕 0 度，在 x，y，z三个方向上缩放 1 倍，这两个函数的调用是为下一步的旋转和缩放控制准备的。最后，装载模型视图矩阵。
     */
    
    
    // Generate a model view matrix to rotate/translate/scale
    //
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    // Translate away from the viewer
    //
    ksMatrixTranslate(&_modelViewMatrix, self.posX, self.posY, self.posZ);
    
    // Rotate the triangle
    //
    ksMatrixRotate(&_modelViewMatrix, self.rotateX, 1.0, 0.0, 0.0);
    
    // Scale the triangle
    ksMatrixScale(&_modelViewMatrix, 1.0, 1.0, self.scaleZ);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}


- (void)drawTriCone
{
    GLfloat vertices[] = {
        0.7f, 0.7f, 0.0f,
        0.7f, -0.7f, 0.0f,
        -0.7f, -0.7f, 0.0f,
        -0.7f, 0.7f, 0.0f,
        0.0f, 0.0f, -1.0f,
    };
    
    GLubyte indices[] = {
        0, 1, 1, 2, 2, 3, 3, 0,
        4, 0, 4, 1, 4, 2, 4, 3
    };
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    glEnableVertexAttribArray(_positionSlot);
    
    // Draw lines
    //
    
    /**
     这次我们使用顶点索引数组结合 glDrawElements 来渲染，而在 Tutorial02 中，使用的是 glDrawArrays。使用顶点索引数组有什么好处呢？很明显，我们可以减少存储重复顶点的内存消耗。比如在本例的索引表中，我们重复利用了顶点 0，1，2，3，4，它们对应 vertices 数组中5个顶点（三个浮点数组成一个顶点）。
     
     第一个参数 mode 为描绘图元的模式，其有效值为：GL_POINTS, GL_LINES, GL_LINE_STRIP,  GL_LINE_LOOP,  GL_TRIANGLES,  GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN。这些模式具体含义下面有介绍。
     
     第二个参数 count 为顶点索引的个数也就是，type 是指顶点索引的数据类型，因为索引始终是正值，索引这里必须是无符号型的非浮点类型，因此只能是 GL_UNSIGNED_BYTE, GL_UNSIGNED_SHORT, GL_UNSIGNED_INT 之一，为了减少内存的消耗，尽量使用最小规格的类型如 GL_UNSIGNED_BYTE。
     
     第三个参数 indices 是存放顶点索引的数组。（indices 是 index 的复数形式，3D 里面很多单词的复数都挺特别的。）
     */
    
    glDrawElements(GL_LINES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
}

- (void)render
{
    if (_context == nil)
        return;
    
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Setup viewport
    //
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    //[self drawTriangle];
    [self drawTriCone];
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupProgram];
        [self setupProjection];
        
        [self resetTransform];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    glUseProgram(_programHandle);
    
    [self destoryBuffers];
    
    [self setupBuffers];
    
    [self updateTransform];
    
    [self render];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark - Transform properties

- (void)toggleDisplayLink
{
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else {
        
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_displayLink invalidate];
         _displayLink = nil;
    }
}

- (void)displayLinkCallback:(CADisplayLink*)displayLink
{
    self.rotateX += displayLink.duration * 90;
}

- (void)resetTransform
{
    if (_displayLink != nil) {
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink = nil;
    }

    NSDictionary *dict = [self defaultValues];

    _posX = [[dict objectForKey:@"posx"] floatValue];
    _posY = [[dict objectForKey:@"posy"] floatValue];
    _posZ = [[dict objectForKey:@"posz"] floatValue];

    _scaleZ = [[dict objectForKey:@"scalez"] floatValue];
    _rotateX = [[dict objectForKey:@"rotatex"] floatValue];

    [self updateTransform];
}

- (void)setPosX:(float)x
{
    _posX = x;
    
    [self updateTransform];
    [self render];
}

- (float)posX
{
    return _posX;
}

- (void)setPosY:(float)y
{
    _posY = y;
    
    [self updateTransform];
    [self render];
}

- (float)posY
{
    return _posY;
}

- (void)setPosZ:(float)z
{
    _posZ = z;
    
    [self updateTransform];
    [self render];
}

- (float)posZ
{
    return _posZ;
}

- (void)setScaleZ:(float)scaleZ
{
    _scaleZ = scaleZ;
    
    [self updateTransform];
    [self render];
}

- (float)scaleZ
{
    return _scaleZ;
}

- (void)setRotateX:(float)rotateX
{
    _rotateX = rotateX;
    
    [self updateTransform];
    [self render];
}

- (float)rotateX
{
    return _rotateX;
}

#pragma mark - GL02TutorialViewProtocol


- (void)doXposValueChanged:(CGFloat)value {
    self.posX = value;
}

- (void)doYposValueChanged:(CGFloat)value {
    self.posY = value;
}

- (void)doZposValueChanged:(CGFloat)value {
    self.posZ = value;
}

- (void)doXrotateValueChanged:(CGFloat)value {
    self.rotateX = value;
}

- (void)doZscaleValueChanged:(CGFloat)value {
    self.scaleZ = value;
}

- (void)doAutoBtnAction:(UIButton *)button {
    [self toggleDisplayLink];
}

- (void)doReastBtnAction:(UIButton *)button {
    [self resetTransform];
    [self render];
}

- (BOOL)isXRotating {
    return (_displayLink != nil);
}

- (NSDictionary *)defaultValues {

    return @{

            @"posx" : @(0.f),
            @"posy" : @(0.f),
            @"posz" : @(-5.5f),
            @"scalez" : @(1.f),
            @"rotatex" : @(0.f),
    };
}

@end
