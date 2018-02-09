//
// Created by suger on 2018/2/8.
// Copyright (c) 2018 suger. All rights reserved.
//

#import "GLTutorial01Controller.h"
#import "OpenGLView.h"


@implementation GLTutorial01Controller {
    OpenGLView *_openGLView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"OpenGLView";

    _openGLView = [[OpenGLView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_openGLView];
}
@end
