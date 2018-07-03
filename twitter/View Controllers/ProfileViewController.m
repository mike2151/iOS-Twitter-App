//
//  ProfileViewController.m
//  twitter
//
//  Created by Michael Abelar on 7/3/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "ProfileViewController.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "APIManager.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *tweetBody;
@property (weak, nonatomic) IBOutlet UILabel *postedTime;
@property (weak, nonatomic) IBOutlet UILabel *retweetCount;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCount;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    User *user = self.tweet.user;
    self.name.text = user.name;
    self.screenName.text = user.screenName;
    self.tweetBody.text = self.tweet.text;
    self.postedTime.text = self.tweet.formattedCreated;
    self.retweetCount.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
    self.favoriteCount.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
    
    NSString *profileURL = user.profilePicURL;
    NSURL *posterURL = [NSURL URLWithString:profileURL];
    [self.profileImage setImageWithURL:posterURL];
    
    [self refreshView];
}

-(void)refreshView {
    if (self.tweet.favorited) {
        UIImage *btnImage = [UIImage imageNamed:@"favor-icon-red.png"];
        [self.favoriteButton setImage:btnImage forState:UIControlStateNormal];
    }
    else {
        UIImage *btnImage = [UIImage imageNamed:@"favor-icon.png"];
        [self.favoriteButton setImage:btnImage forState:UIControlStateNormal];
    }
    
    if (self.tweet.retweeted) {
        UIImage *btnImage = [UIImage imageNamed:@"retweet-icon-green.png"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
    }
    else {
        UIImage *btnImage = [UIImage imageNamed:@"retweet-icon.png"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
    }
}

- (IBAction)didTapFavorite:(id)sender {
    [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
        if(error){}
        else{
            if (self.tweet.favorited) {
                self.tweet.favorited = NO;
                self.tweet.favoriteCount -= 1;
            }
            else {
                self.tweet.favorited = YES;
                self.tweet.favoriteCount += 1;
            }
            [self refreshView];
        }
    } isFavorite:self.tweet.favorited];
}

- (IBAction)didTapRetweet:(id)sender {
    [[APIManager shared] retweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
        if(error){}
        else{
            if (self.tweet.retweeted) {
                self.tweet.retweeted = NO;
                self.tweet.retweetCount -= 1;
            }
            else {
                self.tweet.retweeted = YES;
                self.tweet.retweetCount += 1;
            }
            [self refreshView];
        }
    } isRetweeted:self.tweet.retweeted tweetId:([NSString stringWithFormat:@"%ld",self.tweet.uid])];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
