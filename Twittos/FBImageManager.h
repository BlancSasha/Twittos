//
//  FBImageManager.h
//  Twittos
//
//  Created by François Blanc on 30/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;
@class FBTweet;


typedef enum : NSUInteger {
    FBTweetImageUserForTableview,
    //FBTweetImageContent,
    FBTweetBackgroundImageUser,
    FBTweetImageUser,
} FBTweetImage;

@protocol FBImageManagerDelegate <NSObject>

-(void)didFinishDownloadingImage:(UIImage *)image forURL:(NSString *)URL;

@end



@interface FBImageManager : NSObject


+ (instancetype)sharedInstance;

- (void) addImageInCache:(UIImage *)image forURLkey:(NSString *)URL;

- (UIImage *)getImage:(FBTweetImage)image inCacheForTweet:(FBTweet *)tweet;

- (void) addDelegate:(id <FBImageManagerDelegate>)delegate;

- (void) removeDelegate:(id <FBImageManagerDelegate>)delegate;


@end
