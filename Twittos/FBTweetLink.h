//
//  FBTweetLink.h
//  Twittos
//
//  Created by François Blanc on 20/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Mantle.h"

@interface FBTweetLink : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSInteger userID;
@property (strong,nonatomic) NSArray *indices;

@end
