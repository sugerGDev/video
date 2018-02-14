//
//  GLTutorial02Controller.m
//  OpenGL ES
//
//  Created by suger on 2018/2/14.
//  Copyright © 2018年 suger. All rights reserved.
//

#import "GLTutorial02Controller.h"
#import "OpenGLView_02.h"

@interface GLTutorial02Controller (){
    OpenGLView_02 *_openGLView;
}
@end

@implementation GLTutorial02Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"OpenGLView_02";
    
    _openGLView = [[OpenGLView_02 alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_openGLView];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
