//
//  FBImageViewer.m
//  Twittos
//
//  Created by François Blanc on 31/01/2016.
//  Copyright © 2016 François Blanc. All rights reserved.
//

#import "FBImageViewer.h"

@interface FBImageViewer ()

@property (strong, nonatomic) UIImageView *imageView;

@end


@implementation FBImageViewer

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    self.imageView = [[UIImageView alloc] init];
    [self.imageView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:self.imageView];
    
    [self.imageView setFrame:self.view.frame];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
}

-(void) setImage:(UIImage *)imageToDisplay
{
    [self.imageView setImage:imageToDisplay];
}


@end
