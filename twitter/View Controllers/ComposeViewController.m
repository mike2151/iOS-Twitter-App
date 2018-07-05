//
//  ComposeViewController.m
//  twitter
//
//  Created by Michael Abelar on 7/2/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "User.h"


@interface ComposeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *remainingCharsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (strong, nonatomic) NSString *tweetId;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self.textView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.textView layer] setBorderWidth:2];
    self.textView.delegate = self;
    
    if (self.tweet == nil) {
        //get the profile picture
        [[APIManager shared] getCurrUser:^(User *user, NSError *error){
            if (user) {
                NSURL *profilePic = [NSURL URLWithString:user.profilePicURL];
                [self.profileImage setImageWithURL:profilePic];
                self.nameLabel.text = user.name;
                self.screenName.text = [NSString stringWithFormat:@"%@%@", @"@", user.screenName];
                self.tweetId = @"";
            }
        }];
    }
    
    else {
        User *user = self.tweet.user;
        NSURL *profilePic = [NSURL URLWithString:user.profilePicURL];
        [self.profileImage setImageWithURL:profilePic];
        self.nameLabel.text = user.name;
        self.screenName.text = [NSString stringWithFormat:@"%@%@", @"@", user.screenName];
        self.tweetId = self.tweet.idStr;
        self.textView.text =[NSString stringWithFormat:@"%@%@", @"@", user.screenName];
        [self updateCharsLeft];
    }
    
    
    
}

- (IBAction)onTapPost:(id)sender {
    
    if (self.tweetId.length == 0) {
    [[APIManager shared]composeTweetWith:self.textView.text completion:^(Tweet *tweet, NSError *error) {
        if(error){
            NSLog(@"Error composing Tweet: %@", error.localizedDescription);
        }
        else{
            [self dismissModalViewControllerAnimated:YES];
            [self.delegate did:tweet];
            
            NSLog(@"Compose Tweet Success!");
        }
    }];
    }
    else {
        [[APIManager shared] replyTweetWith:self.tweetId text:self.textView.text completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error composing Tweet: %@", error.localizedDescription);
            }
            else{
                [self dismissModalViewControllerAnimated:YES];
                [self.delegate did:tweet];
                NSLog(@"Compose Tweet Success!");
            }
        }];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateCharsLeft];
}

-(void)updateCharsLeft {
    int currLength = (140 - ((int) [self.textView.text length]));
    self.remainingCharsLabel.text = [NSString stringWithFormat:@"%@%d", @"Remaining Characters: ", currLength];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= 140;
}

- (IBAction)onTapCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)onTapAway:(id)sender {
    [self.textView resignFirstResponder];
}



@end
