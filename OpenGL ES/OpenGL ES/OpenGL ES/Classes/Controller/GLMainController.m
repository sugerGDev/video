//
// Created by suger on 2018/2/8.
// Copyright (c) 2018 suger. All rights reserved.
//

#import "GLMainController.h"
#import "OpenGLView.h"


static NSString *const kTableCellIdentifier = @"KMainTableCellIdentifier";
@implementation GLMainController {
    NSArray <NSString *>*_subContrls;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupProperties];
}

- (void)setupProperties {
    self.title = @"OpenGLES Tutorial";
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:kTableCellIdentifier];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    _subContrls = @[
            @"GLTutorial01Controller",
    ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _subContrls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableCellIdentifier];
    cell.textLabel.text = [_subContrls objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *viewCtrlIdentifier =  [_subContrls objectAtIndex:indexPath.row];
    UIViewController *viewController =  [[NSClassFromString(viewCtrlIdentifier) alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
