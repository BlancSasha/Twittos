//
//  FBDetailsViewController.h
//  Twittos
//
//  Created by François Blanc on 26/10/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CLLocation;
@class FBTweet;
@class FBUser;

@interface FBDetailsViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) FBTweet *tweet;
@property (strong, nonatomic) FBUser *userDetails;

- (void)setTweet:(FBTweet *)tweet;

@end
