//
//  FBTweetCell.h
//  Twittos
//
//  Created by François Blanc on 20/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBTweet;

@interface FBTweetCell : UITableViewCell

-(void) setTweet:(FBTweet *)tweet;

@end
