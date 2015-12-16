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

@interface FBTweetManager () // pourquoi a-t-on besoin des parenthèses?

@property (nonatomic, strong) NSString *bearerToken;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end


@implementation FBTweetManager

- (instancetype)init
{
    self = [super init];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
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
            NSDictionary *getHeaders = @{ @"Authorization":[NSString stringWithFormat:@"Bearer %@", self.bearerToken]};
            
            
            NSDictionary *getParameters = @{@"screen_name":@"syan_me",
                                            @"count":@(TWEETS_COUNT),
                                            };
            
            [[self.manager.requestSerializer HTTPRequestHeaders] setValuesForKeysWithDictionary:getHeaders];
            
            [self.manager GET:@"https://api.twitter.com/1.1/statuses/user_timeline.json"
                   parameters:getParameters
                      success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                          
                          NSLog(@"JSON : %@",responseObject);
                          
                          NSArray *tweets = [[NSArray alloc]init];
                          NSError *err = nil;
                          
                          NSArray *results = responseObject[@"results"]; // Nécessaire? Afficher un résultat JSON pour savoir
                          NSLog(@"Count %d", (int)results.count);
                          
                          tweets = [MTLJSONAdapter modelsOfClass:[FBTweet class] fromJSONArray:results error:&err];
                          
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

    NSDictionary *postHeaders = @{@"Authorization":[NSString stringWithFormat:@"Basic %@", encoded64authorizationHeader]};
    
    NSDictionary *postParameters = @{@"grant_type":@"client_credentials"};
    
    [[self.manager.requestSerializer HTTPRequestHeaders] setValuesForKeysWithDictionary:postHeaders];
    
    [self.manager POST:@"https://api.twitter.com/oauth2/token" parameters:postParameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSLog(@"JSON : %@",responseObject);
        
        if ([[responseObject valueForKey:@"token_type"] isEqual:@"bearer"]){
            self.bearerToken = [responseObject valueForKey:@"access_token"];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"Error : %@",error);
        
    }];

    
}

@end
