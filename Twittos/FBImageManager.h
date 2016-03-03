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
@class FBUser;


typedef enum : NSUInteger {
    FBTweetImageUserForTableview,
    FBTweetImageContent,
    FBTweetBackgroundImageUser,
    FBTweetImageUser,
} FBTweetImageType;

@protocol FBImageManagerDelegate <NSObject>

-(void)didFinishDownloadingImage:(UIImage *)image forURL:(NSString *)URL;

@end



@interface FBImageManager : NSObject


+ (instancetype)sharedInstance;

- (void) addImageInCache:(UIImage *)image forURLkey:(NSString *)URL;

- (UIImage *)getImage:(FBTweetImageType)imageType inCacheForTweet:(FBTweet *)tweet orUser:(FBUser *)user;

- (void) addDelegate:(id <FBImageManagerDelegate>)delegate;

- (void) removeDelegate:(id <FBImageManagerDelegate>)delegate;


@end
