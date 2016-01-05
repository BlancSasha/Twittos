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
             @"retweetUser":@"retweeted_status.user",
             @"tweetDate":@"created_at",
             //@"tweetImageContentURL":@"entities.media.media_url_https"
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

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss ZZZ yyyy"; //Wed Dec 23 15:52:46 +0000 2015
    return dateFormatter; 
}

+ (NSValueTransformer *)tweetDateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

@end

