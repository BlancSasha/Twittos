//
//  FBImageManager.m
//  Twittos
//
//  Created by François Blanc on 30/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBImageManager.h"
#import "FBTweet.h"
#import "FBUser.h"
#import "FBTweetManager.h"
#import "FBTweetImage.h"

@interface FBImageManager ()

@property (strong, nonatomic) NSMutableDictionary *imageCache;
@property (strong, nonatomic) NSMutableArray <id <FBImageManagerDelegate>> *delegates;
@property (strong, nonatomic) NSMutableArray *downloadsInProgress;

@end


@implementation FBImageManager

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        self.imageCache = [[NSMutableDictionary alloc] init];
        self.delegates = [[NSMutableArray alloc] init];
        self.downloadsInProgress = [[NSMutableArray alloc] init];
    }
    return self;
    
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static FBImageManager *sharedImageManager;
    dispatch_once(&onceToken, ^{
        sharedImageManager = [[FBImageManager alloc] init];
    });
    
    return sharedImageManager;
}

- (void) addImageInCache:(UIImage *)image forURLkey:(NSString *)URL
{
    
    [self.imageCache setObject:image forKey:URL];
    
}

- (UIImage *) getImage:(FBTweetImageType)imageType inCacheForTweet:(FBTweet *)tweet
{
    NSString *key;
    FBTweetImage *tweetImage = tweet.tweetMedias[0];
    
    switch (imageType) {
        case FBTweetImageUserForTableview:
            key = tweet.tweetUser.userImageURL;
            break;
        case FBTweetImageContent:
            key = tweetImage.tweetImageContentURL;
            break;
        case FBTweetImageUser:
            if(tweet.retweetUser)
            {
                key = tweet.retweetUser.userImageURL;
            }else{
                key = tweet.tweetUser.userImageURL;
            }
            break;
        case FBTweetBackgroundImageUser:
            if(tweet.retweetUser)
            {
                key = tweet.retweetUser.userBackgroundImageURL;
            }else{
                key = tweet.tweetUser.userBackgroundImageURL;
            }
            break;

        default:
            break;
    }
    
    UIImage *imageToReturn = [self.imageCache objectForKey:key];
    
    // no image AND not downloading -> download it
    if(!imageToReturn && ![self.downloadsInProgress containsObject:key])
    {
        [self.downloadsInProgress addObject:key];
        
        [[FBTweetManager sharedManager] downloadImageWithURL:key
                                                   withBlock:^(UIImage *image, NSString *URL, NSError *error)
         {
             if(image){
                 [self.imageCache setObject:image forKey:URL];
                 
                 for(id delegate in self.delegates)
                 {
                     [delegate didFinishDownloadingImage:image forURL:URL];
                 }
                 
                 [self.downloadsInProgress removeObject:URL];
             }
             
         }];
    }
    
    return imageToReturn;
}

- (void) addDelegate:(id <FBImageManagerDelegate>)delegate
{
    [self.delegates addObject:delegate];
}

- (void) removeDelegate:(id <FBImageManagerDelegate>)delegate
{
    [self.delegates removeObject:delegate];
}


@end
