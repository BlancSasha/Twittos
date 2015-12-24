//
//  FBTweet.m
//  Twittos
//
//  Created by François Blanc on 08/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBTweet.h"
#import "FBTweetLink.h"
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@implementation FBTweet

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"user":@"user.description",
             @"text":@"text",
             @"name":@"user.name",
             @"screenName":@"user.screen_name",
             @"coordinates":@"place.bounding_box.coordinates",
             @"retweetCount":@"retweet_count",
             @"likes":@"favorite_count",
             @"tweetLinks":@"entities.user_mentions",
             @"retweetedStatus":@"retweeted_status",
             @"tweetUser":@"user",
             @"retweetUser":@"retweeted_status.user"
             };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, text: %@, user: %@, retweetCount: %i, likes : %i, name: %@,  screenName: %@, tweetLinks : %@>",
            self.class, self, self.text, self.user, self.retweetCount, self.likes, self.name, self.screenName, self.tweetLinks];
}

+ (NSValueTransformer *)tweetLinksJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[FBTweetLink class]];
}

@end

