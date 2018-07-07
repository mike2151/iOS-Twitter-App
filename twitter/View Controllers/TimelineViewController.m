//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "APIManager.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "InfiniteScrollActivityView.h"
#import "ComposeViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TweetViewController.h"
#import "ProfileViewController.h"

@interface TimelineViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ComposeViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *tweetArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (nonatomic) int currTweetCount;
@property (nonatomic) int tappedReplyButtonIndex;
@property (nonatomic) int selectedTabIndex;
//variable used to keep track of already used images in feed. Seems to be an issue with images repeating
@property (nonatomic, strong) NSMutableArray* usedImages;
@property (nonatomic) int incrementValue;

@end

@implementation TimelineViewController

InfiniteScrollActivityView* loadingMoreView;

-(void)viewDidAppear:(BOOL)animated {
    UITabBarController *navVC = (UITabBarController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    self.selectedTabIndex = (int) ((unsigned long)navVC.selectedIndex);
    
    //reset images used
    self.usedImages = [[NSMutableArray alloc] init];
    
    // Get timeline
    if (self.selectedTabIndex == 0) {
        [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
            if (tweets) {
                self.tweetArray = [NSMutableArray new];
                for (Tweet *tweet in tweets) {
                    [self.tweetArray addObject:tweet];
                }
                [self.tableView reloadData];
            }
            else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    }
    else if (self.selectedTabIndex == 2) {
        [[APIManager shared] getMentionsTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
            if (tweets) {
                self.tweetArray = [NSMutableArray new];
                for (Tweet *tweet in tweets) {
                    [self.tweetArray addObject:tweet];
                }
                [self.tableView reloadData];
            }
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.incrementValue = 10;
    
    //init variables for infinite scrolling
    self.currTweetCount = 20;
    self.isMoreDataLoading = false;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    // Set up Infinite Scroll loading indicator
    CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    loadingMoreView.hidden = true;
    [self.tableView addSubview:loadingMoreView];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
    
    //init variable for keeping track of which row the reply button was pressed
    self.tappedReplyButtonIndex = -1;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tweetArray = [[NSMutableArray alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self setMediaImage:cell];
    [cell refreshView];
    [cell setTimeStamp];
    cell.profileImage.layer.cornerRadius =  cell.profileImage.frame.size.height/2;
    cell.profileImage.layer.masksToBounds = YES;
    [cell.tweetText sizeToFit];
    cell.replyButton.tag = indexPath.row;
    [cell.replyButton addTarget:self action:@selector(onTapReply:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

-(void)setMediaImage:(TweetCell*)cell {
    NSArray *media = cell.tweet.entities[@"media"];
    NSString *firstUrl = media[0][@"media_url_https"];
    NSURL *picURL = [NSURL URLWithString:firstUrl];
    [cell.tweetImage setImageWithURL:picURL];
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.tweetArray = [NSMutableArray new];
            for (Tweet *tweet in tweets) {
                [self.tweetArray addObject:tweet];
            }
            [self.tableView reloadData];
            
        }
        [refreshControl endRefreshing];
    }];
}

-(void)loadMoreData{
    NSString* stringofInt = [NSString stringWithFormat:@"%d", self.currTweetCount];
    [[APIManager shared] loadMore:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            for (Tweet *tweet in tweets) {
                [self.tweetArray addObject:tweet];
            }
            
            [self.tableView reloadData];
        }
    }  numTweets:stringofInt];
    self.isMoreDataLoading = false;
    // Stop the loading indicator
    [loadingMoreView stopAnimating];
    self.currTweetCount = self.currTweetCount + self.incrementValue;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!self.isMoreDataLoading){
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = true;
            
            // Update position of loadingMoreView, and start loading indicator
            CGRect frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
            loadingMoreView.frame = frame;
            [loadingMoreView startAnimating];
            
            // Code to load more results
            [self loadMoreData];
        }
    }
}

- (void)did:(Tweet *) post {
    //refresh the ui
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.tweetArray = [NSMutableArray new];
            for (Tweet *tweet in tweets) {
                [self.tweetArray addObject:tweet];
            }
            [self.tableView reloadData];
            
        }
    }];
}

- (void)logout {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
}

- (IBAction)tapLogout:(id)sender {
    [[APIManager shared] logout];
    [self logout];
}

#pragma mark - Navigation

//tapping the tweet
- (IBAction)onTap:(id)sender {
    [self performSegueWithIdentifier:@"timelineToProfile" sender:self];
}
- (IBAction)onTapReply:(UIButton *)sender {
    self.tappedReplyButtonIndex = (int) sender.tag;
    [self performSegueWithIdentifier:@"toComposeSegue" sender:self];
}



//tapping the reply button

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[TweetViewController class]]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        TweetViewController *tweetViewController = [segue destinationViewController];
        tweetViewController.tweet = self.tweetArray[indexPath.row];
    }
    else if ([segue.destinationViewController isKindOfClass:[ProfileViewController class]]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        ProfileViewController *profileViewController = [segue destinationViewController];
        Tweet *tweet = self.tweetArray[indexPath.row];
        profileViewController.user = tweet.user;
    }
    else {
        //goes to compose controller
        //see if compose button
        if ([sender isMemberOfClass:[UIBarButtonItem class]]) {
            ComposeViewController *composeViewController = [segue destinationViewController];
            composeViewController.delegate = self;
        }
        //a tweet is getting pressed
        else {
            if (self.tappedReplyButtonIndex != -1) {
                UINavigationController *navController = [segue destinationViewController];
                ComposeViewController *composeViewController = navController.visibleViewController;
                composeViewController.tweet  = self.tweetArray[self.tappedReplyButtonIndex];
                composeViewController.delegate = self;
                self.tappedReplyButtonIndex = -1;
            }
        }
        
    }
}



@end
