//
//  FBTweetLink.m
//  Twittos
//
//  Created by François Blanc on 20/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBTweetLink.h"

@implementation FBTweetLink

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userID":@"id",
             @"indices":@"indices",

             };
}

@end
