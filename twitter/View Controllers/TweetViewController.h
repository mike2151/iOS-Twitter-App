//
//  TweetViewController.h
//  twitter
//
//  Created by Michael Abelar on 7/3/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Tweet.h"
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"

@interface TweetViewController : UIViewController
@property (strong, nonatomic) Tweet *tweet;
@end
