//
//  FBImageViewer.h
//  Twittos
//
//  Created by François Blanc on 31/01/2016.
//  Copyright © 2016 François Blanc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FBImageViewer : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIImage *image;

-(void) setImage:(UIImage *)imageToDisplay;

@end
