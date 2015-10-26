//
//  FBDetailsViewController.m
//  Twittos
//
//  Created by François Blanc on 26/10/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBDetailsViewController.h"

@interface FBDetailsViewController ()

@end

@implementation FBDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// Lorsque le tweet à afficher est défini/mis à jour on veut que le titre de notre VC reflete le tweet en question
- (void)setTweet:(NSString *)tweet
{
    self->_tweet = tweet;
    [self setTitle:tweet];
}

@end
