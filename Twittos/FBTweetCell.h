//
//  FBTweetCell.h
//  Twittos
//
//  Created by François Blanc on 20/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBTweet;
@class FBUser;

@interface FBTweetCell : UITableViewCell <UITextViewDelegate>

@property (strong, nonatomic) FBTweet *tweet;

@property (copy) void (^imageTappedBlock)(UIImage *);
@property (copy) void (^linkTappedBlockFOrUser)(FBUser *);

-(void) setTweet:(FBTweet *)tweet;

+ (CGFloat)cellHeightForTweet:(FBTweet *)tweet andWidth:(CGFloat)width;

@end

