//
//  FBImageViewer.h
//  Twittos
//
//  Created by François Blanc on 31/01/2016.
//  Copyright © 2016 François Blanc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FBScrollViewCentered.h"

@interface FBImageViewer : UIViewController <UIImagePickerControllerDelegate, UIScrollViewDelegate,  UINavigationControllerDelegate>

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) FBScrollViewCentered *scrollView;

-(void) setImage:(UIImage *)imageToDisplay;

@end
