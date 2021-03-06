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
- (void)getCurrUser:(void(^)(User *user, NSError *error))completion;
- (void)getTimelineById: (void(^)(NSArray *tweets, NSError *error))completion userId:(NSString*)uid;
- (void)replyTweetWith:(NSString*)id_str text:(NSString *)text  completion:(void (^)(Tweet *, NSError *))completion;
- (void)getMentionsTimelineWithCompletion:(void(^)(NSArray *tweets, NSError *error))completion;
@end
