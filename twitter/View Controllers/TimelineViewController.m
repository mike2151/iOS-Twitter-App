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
#import "ProfileViewController.h"

@interface TimelineViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ComposeViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *tweetArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (nonatomic) int currTweetCount;

@end

@implementation TimelineViewController

InfiniteScrollActivityView* loadingMoreView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tweetArray = [[NSMutableArray alloc] init];
    
    // Get timeline
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            for (Tweet *tweet in tweets) {
                [self.tweetArray addObject:tweet];
            }
            [self.tableView reloadData];
        
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
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
    cell.screenName.text = owner.screenName;
    NSString *profileURL = owner.profilePicURL;
    NSURL *posterURL = [NSURL URLWithString:profileURL];
    [cell.profileImage setImageWithURL:posterURL];
    cell.tweet = currTweet;
    [cell refreshView];
    [cell setTimeStamp];
    
    return cell;
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
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
    self.currTweetCount = self.currTweetCount + 10;
    
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[ProfileViewController class]]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.tweet = self.tweetArray[indexPath.row];
    }
    else {
        ComposeViewController *composeViewController = [segue destinationViewController];
        composeViewController.delegate = self;
    }
}



@end
