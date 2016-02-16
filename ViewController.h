//
//  ViewController.h
//  MusiX
//
//  Created by Rohin Bhargava on 12/7/15.
//  Copyright © 2015 Rohin Bhargava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>
#include "Constants.h"

@interface ViewController : UIViewController
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end