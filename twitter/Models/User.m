//
//  User.m
//  twitter
//
//  Created by Michael Abelar on 7/2/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    //have to put in a super init with instanceType
    self = [super init];
    if (self) {
        self.name = dictionary[@"name"];
        self.screenName = dictionary[@"screen_name"];
        self.profilePicURL = dictionary[@"profile_image_url"];
        self.bgURL = dictionary[@"profile_banner_url"];
        self.bgTile = dictionary[@"profile_background_tile"];
        self.location = dictionary[@"location"];
        self.strId = dictionary[@"id_str"];
        self.followers = (int)[[dictionary valueForKey:@"followers_count"] integerValue];
        self.numFollowing = (int)[[dictionary valueForKey:@"friends_count"] integerValue];
    }
    return self;
}

@end
