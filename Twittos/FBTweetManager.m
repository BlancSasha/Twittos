//
//  FBTweetManager.m
//  Twittos
//
//  Created by François Blanc on 08/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBTweetManager.h"

#import "FBTweet.h"

#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"

#import "Mantle.h"

#define CONSUMER_KEY @"VFCRLhL28sUUEKcPgR6WJ6Sib"
#define CONSUMER_SECRET @"lAlkRvL3aZFJjgnzbDxLQPvOADy1ZGAs9ocFTnQSwIYFNKK112"
#define TWEETS_COUNT 20

@interface FBTweetManager ()

@property (nonatomic, strong) NSString *bearerToken;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end


@implementation FBTweetManager

- (instancetype)init
{
    self = [super init];
    
    self.manager = [AFHTTPRequestOperationManager manager];
    [self.manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [self.manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    return self;
}

- (void) fetchTweetswithBlock:(void(^)(NSArray *,NSError *))block
{
    
    NSString *authorizationHeader = [[NSString alloc] initWithFormat:@"%@:%@",CONSUMER_KEY,CONSUMER_SECRET];
    
    NSString *encoded64authorizationHeader = [[authorizationHeader dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];

    [self authenticationWithencoded64authorizationHeader:encoded64authorizationHeader
                                                andBlock:^(NSString *bearerToken, NSError *err) {
        if (err)
        {
            NSLog(@"Error : %@",err);
            block(nil,err);
        }
        else
        {
            //NSDictionary *getHeaders = @{ @"Authorization":[NSString stringWithFormat:@"Bearer %@", self.bearerToken]};
            NSString *getHeader = [[NSString alloc] initWithFormat:@"Bearer %@",self.bearerToken];
            
            NSDictionary *getParameters = @{@"screen_name":@"syan_me",
                                            @"count":@(TWEETS_COUNT),
                                            };
            
            //[[self.manager.requestSerializer HTTPRequestHeaders] setValuesForKeysWithDictionary:getHeaders];
            
            [self.manager.requestSerializer setValue:getHeader forHTTPHeaderField:@"Authorization"];

            
            [self.manager GET:@"https://api.twitter.com/1.1/statuses/user_timeline.json"
                   parameters:getParameters
                      success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                          
                          NSLog(@"JSON : %@",responseObject);
                          
                          NSError *err = nil;
                          
                          NSArray *tweets = [MTLJSONAdapter modelsOfClass:[FBTweet class] fromJSONArray:responseObject error:&err];
                          
                          if (err)
                              block(nil,err);
                          else
                              block(tweets,nil);
                          
                      } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                          NSLog(@"Error : %@",error);
                          block(nil,error);
                      }];
        }
    }];
}

- (void) authenticationWithencoded64authorizationHeader:(NSString *)encoded64authorizationHeader
                                               andBlock:(void(^)(NSString *,NSError *))authentBlock{

    NSString *postHeader = [[NSString alloc] initWithFormat:@"Basic %@",encoded64authorizationHeader];
    
    NSDictionary *postParameters = @{@"grant_type":@"client_credentials"};
    
   // [[self.manager.requestSerializer HTTPRequestHeaders] setValuesForKeysWithDictionary:postHeaders];
    
    [self.manager.requestSerializer setValue:postHeader forHTTPHeaderField:@"Authorization"];
    
    [self.manager POST:@"https://api.twitter.com/oauth2/token" parameters:postParameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSLog(@"JSON : %@",responseObject);
        
        
        if ([[responseObject valueForKey:@"token_type"] isEqual:@"bearer"]){
            self.bearerToken = [responseObject valueForKey:@"access_token"];
        }
        authentBlock(self.bearerToken,nil);

        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"Error : %@",error);
        authentBlock (nil,error);
    }];

    
}

@end
