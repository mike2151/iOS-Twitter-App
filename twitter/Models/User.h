//
//  User.h
//  twitter
//
//  Created by Michael Abelar on 7/2/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSString *profilePicURL;
@property (strong, nonatomic) NSString *bgURL;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *strId;
@property (nonatomic) BOOL bgTile;
@property (nonatomic) int followers;
@property (nonatomic) int numFollowing;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
