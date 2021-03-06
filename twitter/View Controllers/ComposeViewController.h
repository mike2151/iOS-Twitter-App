//
//  ComposeViewController.h
//  twitter
//
//  Created by Michael Abelar on 7/2/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol ComposeViewControllerDelegate
- (void)did:(Tweet *) post;
@end

@interface ComposeViewController : UIViewController
@property (nonatomic, weak) id<ComposeViewControllerDelegate> delegate;
@property (nonatomic, strong) Tweet *tweet;
@end
