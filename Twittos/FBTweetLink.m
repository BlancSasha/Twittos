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
             @"userID":@"id_str",
             @"indices":@"indices",
             };
}

-(NSString *)getUserID
{
    return self.userID;
}


- (instancetype)initWithResultSet:(FMResultSet *)set
{
    self = [super init];
    if (self)
    {
        self.indices = [[NSMutableArray alloc] init];
        
        self.userID = [set stringForColumn:@"userID"];
        self.indices[0] = @([set intForColumn:@"startIndice"]);
        self.indices[1] = @([set intForColumn:@"endIndice"]);
    }
    return self;
}

@end
