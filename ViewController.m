//
//  ViewController.m
//  MusiX
//
//  Created by Rohin Bhargava on 12/7/15.
//  Copyright © 2015 Rohin Bhargava. All rights reserved.
//

#import "ViewController.h"
#import <Spotify/Spotify.h>
@import AVFoundation;


@interface ViewController ()
@end

@implementation ViewController

@synthesize session;
@synthesize webView;

- (void)viewDidLoad {
     [super viewDidLoad];
     self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
     
     // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction) authenticateSpotify:(UIButton *)sender {
     self.session = [[SPTSession alloc] init];
     
    [[SPTAuth defaultInstance] setClientID:@"12176808344948fbb03f6227ae03638b"];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:@"musix://returnAfterLoginSP"]];
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope]];
    
    // Construct a login URL and open it
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    [[UIApplication sharedApplication] openURL:loginURL];
}

- (IBAction)authenticateSoundCloud:(id)sender {
     [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://soundcloud.com/connect?client_id=%@&redirect_uri=%@&response_type=code", SCclientID, returnURL]]]];
     [self.view addSubview:webView];
}

@end

