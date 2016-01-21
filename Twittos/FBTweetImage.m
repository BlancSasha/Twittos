//
//  FBTweetImage.m
//  Twittos
//
//  Created by François Blanc on 05/01/2016.
//  Copyright © 2016 François Blanc. All rights reserved.
//

#import "FBTweetImage.h"

@implementation FBTweetImage

//@dynamic tweetImageContentURL;

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"tweetImageContentURL":@"media_url_https",
             @"width":@"sizes.medium.w",
             @"height":@"sizes.medium.h",
             };
}

@end
