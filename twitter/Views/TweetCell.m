//
//  TweetCell.m
//  twitter
//
//  Created by Michael Abelar on 7/2/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TweetCell.h"
#import "APIManager.h"

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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


@end
