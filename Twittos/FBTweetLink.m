//
//  FBTweetLink.m
//  Twittos
//
//  Created by François Blanc on 20/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBTweetLink.h"
#import "FMResultSet.h"

@implementation FBTweetLink

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userID":@"id",
             @"indices":@"indices",
             };
}

-(NSString *)getUserID
{
    return [@(self.userID) stringValue];
}


- (instancetype)initWithResultSet:(FMResultSet *)set
{
    self = [super init];
    if (self)
    {
        self.userID = [[set stringForColumn:@"userID"] integerValue];
        self.indices[0] = [set stringForColumn:@"startIndice"];
        self.indices[1] = [set stringForColumn:@"endIndice"];
    }
    return self;
}

@end
