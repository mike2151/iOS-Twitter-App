//
//  APIManager.h
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "BDBOAuth1SessionManager.h"
#import "BDBOAuth1SessionManager+SFAuthenticationSession.h"
#import "Tweet.h"

@interface APIManager : BDBOAuth1SessionManager

+ (instancetype)shared;

- (void)getHomeTimelineWithCompletion:(void(^)(NSArray *tweets, NSError *error))completion;
- (void)loadMore:(void(^)(NSArray *tweets, NSError *error))completion numTweets:(NSString*)num;
- (void)composeTweetWith:(NSString *)text completion:(void (^)(Tweet *, NSError *))completion;
- (void)favorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion isFavorite:(BOOL)fav;
- (void)retweet:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion isRetweeted:(BOOL)fav tweetId:(NSString*)id;
@end
