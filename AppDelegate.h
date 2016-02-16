//
//  AppDelegate.h
//  MusiX
//
//  Created by Rohin Bhargava on 12/7/15.
//  Copyright © 2015 Rohin Bhargava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>
#import "ViewController.h"
#include "Constants.h"
@import AVFoundation;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) AVPlayer *audioPlayer;
@property (nonatomic, strong) SPTAudioStreamingController *player;

@end

