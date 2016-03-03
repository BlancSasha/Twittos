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
//@property (strong, nonatomic) UIScrollView *scrollView;

@end


@implementation FBImageViewer

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    self.imageView = [[UIImageView alloc] init];
    [self.imageView setBackgroundColor:[UIColor blackColor]];
    [self.imageView setImage:self.image];
    self.imageView.frame = (CGRect){CGPointZero, self.image.size};
    //[self.imageView setUserInteractionEnabled:YES];
    //[self.imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    //[self.view addSubview:self.imageView];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;

    self.scrollView = [[FBScrollViewCentered alloc] init];
    //self.scrollView.contentSize = self.imageView.frame.size;
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setClipsToBounds:YES];
    [self.scrollView addSubview:self.imageView];
    [self.scrollView setBackgroundColor:[UIColor blueColor]];
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = self.imageView.frame.size;
    [self.view addSubview:self.scrollView];
    
    [self configureZoomScale];
}

-(void) setImage:(UIImage *)imageToDisplay
{
    self->_image = [[UIImage alloc] init];
    self->_image = imageToDisplay;
    [self.imageView setImage:imageToDisplay];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
}

-(void)viewWillLayoutSubviews
{
    [self configureZoomScale];
}

-(void)configureZoomScale
{
    CGFloat xZoomScale = self.scrollView.bounds.size.width/self.imageView.bounds.size.width;
    CGFloat yZoomScale = self.scrollView.bounds.size.height/self.imageView.bounds.size.height;
    CGFloat minZoomScale = MIN(xZoomScale,yZoomScale);
    
    [self.scrollView setMinimumZoomScale:minZoomScale];
    [self.scrollView setMaximumZoomScale:4.0f];
    self.scrollView.zoomScale = minZoomScale;

}

@end
