//
//  ProfileViewController.m
//  twitter
//
//  Created by Michael Abelar on 7/3/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "ProfileViewController.h"
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"
#import "TweetCell.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *bg;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *followersCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *innerView;
@property (nonatomic, strong) NSMutableArray *tweetArray;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(blurProfile)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [[self innerView] addGestureRecognizer: swipeGesture];
    
    if (self.user == nil) {
        //get the currently logged in user
        //get the current user
        [[APIManager shared] getCurrUser:^(User *user, NSError *error){
            if (user) {
                self.user = user;
                [self displayUserInfo];
            } else {
                NSLog(@"😫😫😫 Error getting user: %@", error.localizedDescription);
            }
        }];
    }
    else {
        [self displayUserInfo];
    }
}

- (UIImage *)blurredImageWithImage:(UIImage *)sourceImage{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    UIImage *retVal = [UIImage imageWithCGImage:cgImage];
    if (cgImage) {
        CGImageRelease(cgImage);
    }
    return retVal;
}

-(void)blurProfile {
    UIImage *image = [self blurredImageWithImage:self.bg.image];
    [self.bg setImage:image];
}

     



-(void)displayUserInfo {
    NSURL *bgURL = [NSURL URLWithString:self.user.bgURL];
    [self.bg setImageWithURL:bgURL];
    NSURL *profilePic = [NSURL URLWithString:self.user.profilePicURL];
    [self.profilePic setImageWithURL:profilePic];
    self.profilePic.layer.zPosition = 5;
    self.bg.layer.zPosition = -5;
    
    self.name.text = self.user.name;
    self.screenName.text = [NSString stringWithFormat:@"%@%@", @"@", self.user.screenName];
    self.location.text = self.user.location;
    self.followersCount.text = [NSString stringWithFormat:@"%d", self.user.followers];
    self.followingCount.text = [NSString stringWithFormat:@"%d", self.user.numFollowing];
    
    //get user tweets
    [[APIManager shared] getTimelineById:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.tweetArray = [NSMutableArray arrayWithArray:tweets];
            [self.tableView reloadData];
        }
    } userId:self.user.strId];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    Tweet *currTweet = self.tweetArray[indexPath.row];
    User *owner = currTweet.user;
    
    //TODO make in model
    cell.name.text = owner.name;
    cell.tweetText.text = currTweet.text;
    cell.screenName.text = [NSString stringWithFormat:@"%@%@", @"@", owner.screenName];
    [cell.favoriteButton setTitle:([NSString stringWithFormat:@"%d", currTweet.favoriteCount]) forState:UIControlStateNormal];
    [cell.retweetButton setTitle:([NSString stringWithFormat:@"%d", currTweet.retweetCount]) forState:UIControlStateNormal];
    NSString *profileURL = owner.profilePicURL;
    NSURL *posterURL = [NSURL URLWithString:profileURL];
    [cell.profileImage setImageWithURL:posterURL];
    cell.tweet = currTweet;
    [cell refreshView];
    [cell setTimeStamp];
    cell.profileImage.layer.cornerRadius =  cell.profileImage.frame.size.height/2;
    cell.profileImage.layer.masksToBounds = YES;
    
    //resize according to tweettext
    
    return cell;
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
