//
//  FBTweet.m
//  Twittos
//
//  Created by François Blanc on 08/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBTweet.h"

@implementation FBTweet

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"user":@"user.description",
             @"text":@"text",
             };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, text: %@, user: %@>",
            self.class, self, self.text, self.user];
}

@end
