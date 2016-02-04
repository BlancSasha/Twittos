//
//  FBImageViewer.m
//  Twittos
//
//  Created by François Blanc on 31/01/2016.
//  Copyright © 2016 François Blanc. All rights reserved.
//

#import "FBImageViewer.h"
#import "Masonry.h"

@interface FBImageViewer ()

@property (strong, nonatomic) UIImageView *imageView;

@end


@implementation FBImageViewer

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    self.imageView = [[UIImageView alloc] init];
    [self.imageView setBackgroundColor:[UIColor blackColor]];
    [self.imageView setImage:self.image];
    [self.view addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
    }];
     
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;    
}

-(void) setImage:(UIImage *)imageToDisplay
{
    self->_image = [[UIImage alloc] init];
    self->_image = imageToDisplay;
    [self.imageView setImage:imageToDisplay];
}


@end
