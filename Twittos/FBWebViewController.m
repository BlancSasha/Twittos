//
//  FBWebViewController.m
//  Twittos
//
//  Created by François Blanc on 03/03/2016.
//  Copyright © 2016 François Blanc. All rights reserved.
//

#import "FBWebViewController.h"

@interface FBWebViewController ()

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation FBWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] init];
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
