//
//  Tweet.h
//  twitter
//
//  Created by Michael Abelar on 7/2/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *idStr;
@property (nonatomic) long uid;
@property (strong, nonatomic) NSString *text;
@property (nonatomic) int favoriteCount;
@property (nonatomic) BOOL favorited;
@property (nonatomic) BOOL retweeted;
@property (nonatomic) int retweetCount;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSString *createdAtString;
@property (strong, nonatomic) NSString *formattedCreated;
@property (strong, nonatomic) User *retweetedByUser;
+ (NSMutableArray *)tweetsWithArray:(NSArray *)dictionaries;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
