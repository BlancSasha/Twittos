//
//  FBTweetManager.m
//  Twittos
//
//  Created by François Blanc on 08/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBTweetManager.h"
#import "FBTweet.h"
#import "FBUser.h"

//#import "AFNetworking.h"

#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"

#import "Mantle.h"

#import <UIKit/UIKit.h>

#define CONSUMER_KEY @"VFCRLhL28sUUEKcPgR6WJ6Sib"
#define CONSUMER_SECRET @"lAlkRvL3aZFJjgnzbDxLQPvOADy1ZGAs9ocFTnQSwIYFNKK112"
#define TWEETS_COUNT 20

@interface FBTweetManager ()

@property (nonatomic, strong) NSString *bearerToken;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@property (nonatomic, strong) AFHTTPRequestOperationManager *imageManager;


@end


@implementation FBTweetManager

- (instancetype)init
{
    self = [super init];
    
    if(self){
        //NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        //self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        self.manager = [AFHTTPRequestOperationManager manager];
        [self.manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [self.manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        
        //NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        //self.imageManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        self.imageManager = [AFHTTPRequestOperationManager manager];
        [self.imageManager setResponseSerializer:[AFImageResponseSerializer serializer]];
        [self.imageManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    }
    return self;
}

+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static FBTweetManager *sharedTweetManager;
    dispatch_once(&onceToken, ^{
        sharedTweetManager = [[FBTweetManager alloc] init];
    });
    return sharedTweetManager;
}

- (void) fetchTweetswithBlock:(void(^)(NSArray *,NSError *))block
{
   /* if(!self.bearerToken)
    {
        
    [self authenticationWithencoded64authorizationHeader:encoded64authorizationHeader
                                                andBlock:^(NSString *bearerToken, NSError *err) {
                                                    
        if (err)
        {
            NSLog(@"Error : %@",err);
            block(nil,err);
        }
        else
        {

        */
    NSDictionary *getParameters = @{@"screen_name":@"syan_me",
                                    @"count":@(TWEETS_COUNT),
                                    };
    
    [self.manager GET:@"https://api.twitter.com/1.1/statuses/user_timeline.json"
           parameters:getParameters
              success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                  
                  NSLog(@"JSON : %@",operation.responseString);
                  
                  NSError *err = nil;
                  
                  NSArray *tweets = [MTLJSONAdapter modelsOfClass:[FBTweet class] fromJSONArray:responseObject error:&err];
                  
                  if (err)
                      block(nil,err);
                  else
                      block(tweets,nil);
                  
              } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                  
                  // pas authentifié
                  if (operation.response.statusCode == 400 || operation.response.statusCode == 401)
                  {
                      [self authenticationWithBlock:^(NSError *error) {
                          if (error)
                          {
                              block(nil, error);
                          }
                          else
                          {
                              [self fetchTweetswithBlock:block];
                          }
                      }];
                  }
                  else
                  {
                      block(nil, error);
                  }
              }];
}

- (void) authenticationWithBlock:(void(^)(NSError *))authentBlock{

    NSString *authorizationHeader = [[NSString alloc] initWithFormat:@"%@:%@",CONSUMER_KEY,CONSUMER_SECRET];
    NSString *encoded64authorizationHeader = [[authorizationHeader dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *postHeader = [[NSString alloc] initWithFormat:@"Basic %@",encoded64authorizationHeader];
    NSDictionary *postParameters = @{@"grant_type":@"client_credentials"};
    
    [self.manager.requestSerializer setValue:postHeader forHTTPHeaderField:@"Authorization"];
    
    [self.manager POST:@"https://api.twitter.com/oauth2/token" parameters:postParameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        //NSLog(@"JSON : %@",responseObject);
        
        
        if ([[responseObject valueForKey:@"token_type"] isEqual:@"bearer"])
        {
            
            NSString *getHeader = [[NSString alloc] initWithFormat:@"Bearer %@",[responseObject valueForKey:@"access_token"]];

            // header d'authentification
            [self.manager.requestSerializer setValue:getHeader forHTTPHeaderField:@"Authorization"];
        }
        authentBlock(nil);

        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"Error : %@",error);
        authentBlock (error);
    }];
}

-(void)getUserInfoFor:(NSString *)userID withBlock:(void(^)(FBUser *,NSError *))block
{
    NSDictionary *getParameters = @{@"user_id":userID};
    
    [self.manager GET:@"https://api.twitter.com/1.1/users/show.json"
           parameters:getParameters
              success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                  
                  NSLog(@"JSON : %@",operation.responseString);
                  
                  NSError *err = nil;
                  
                  FBUser *user = [MTLJSONAdapter modelOfClass:[FBUser class] fromJSONDictionary:responseObject error:&err];
                  
                  if (err)
                      block(nil,err);
                  else
                      block(user,nil);
                  
              } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                  NSLog(@"Error : %@",error);
                  block(nil,error);
              }];
}

- (void) downloadImageWithURL:(NSString *)imageURL withBlock:(void(^)(UIImage *,NSString *,NSError *))imageBlock{
    [self.imageManager GET:imageURL
                parameters:nil
                   success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
    {
        NSLog(@"%@",responseObject);
        imageBlock(responseObject,imageURL,nil);
                       
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error)
    {
        NSLog(@"%@",error);
        imageBlock(nil,nil,error);
    }];
}


@end
