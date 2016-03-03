//
//  FBTweetLink.h
//  Twittos
//
//  Created by François Blanc on 20/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Mantle.h"

@class FMResultSet;

@interface FBTweetLink : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSInteger userID;
@property (strong, nonatomic) NSMutableArray *indices;

-(NSString *)getUserID;

- (instancetype)initWithResultSet:(FMResultSet *)set;


@end
