#import <Spotify/Spotify.h>
#import "AppDelegate.h"
#import "ViewController.h"
@import AVFoundation;

@interface AppDelegate ()
@property int playing;
@end

@implementation AppDelegate

@synthesize audioPlayer;
@synthesize player;

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *) dict {
    [application beginReceivingRemoteControlEvents];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    self.playing = 0;
    return YES;
}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            
            if (error != nil) {
                NSLog(@"*** Auth error: %@", error);
                return;
            }
            self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
            
            [self.player loginWithSession:[[SPTAuth defaultInstance]session] callback:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"*** Logging in got error: %@", error);
                    return;
                }
            }];
            
        }];
        return YES;
    }
    
    else if ([[[url absoluteString] substringToIndex:26] isEqual: returnURL]) {
        
        NSString *code =[url query];
        NSLog(@"If logging in does not work, please look for this log message and check if the code is being stored correctly");
        if([code hasSuffix:@"#"])code = [code substringToIndex:code.length-1];
        NSLog(@"Found login code for SoundCloud");
        [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"SC_CODE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSURL *url = [NSURL URLWithString:@"https://api.soundcloud.com/oauth2/token/"];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSString *postString =[NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&%@", SCclientID, SCsecret,returnURL, code];
        NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)postData.length] forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        NSURLSessionDataTask *postDataTask = [[NSURLSession sessionWithConfiguration:configuration] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSMutableDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *scToken = [resultJSON objectForKey:@"access_token"];
            NSString *rToken = [resultJSON objectForKey:@"refresh_token"];
            [[NSUserDefaults standardUserDefaults] setObject:scToken forKey:@"access_token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSUserDefaults standardUserDefaults] setObject:rToken forKey:@"refresh_token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
        [postDataTask resume];
        return YES;
    }
    
    return NO;
}

- (void) playSpotifyUsingTrack:(NSURL *)track {
    if (self.audioPlayer.rate > 0 && !self.audioPlayer.error) {
        [self.audioPlayer pause];
    }
    
    else if ([self.player isPlaying]) {
        [self.player stop:nil];
    }

    [self.player playURIs:@[ track ] fromIndex:0 callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Starting playback got error: %@", error);
                return;
            }
        }];
    self.playing = 1;
}

/*[self SoundcloudReferenceTrack:(track) blocker:^(NSString *url) {
    [self playUsingTrack: url]
 }];
*/
- (void) SoundcloudReferenceTrack:(NSURL *) track  blocker:(void (^)(NSString *url)) blocker{
    NSURLSessionDataTask *scTask = [[NSURLSession alloc] dataTaskWithURL:track completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSMutableDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *trackurl = [resultJSON objectForKey:@"hls_mp3_128_url"];
        blocker(trackurl);
    }];
    [scTask resume];
}

- (void) playUsingTrack:(NSURL *)track {
    if (self.audioPlayer.rate > 0 && !self.audioPlayer.error) {
        [self.audioPlayer pause];
    }
    
    else if ([self.player isPlaying]) {
        [self.player stop:nil];
    }
    
    self.audioPlayer = [[AVPlayer alloc] initWithURL:track];
    [self.audioPlayer play];

    self.playing = 2;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"prev");
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"next");
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                if (self.playing == 2)
                    [self.audioPlayer play];
                else if (self.playing == 1)
                    [self.player setIsPlaying:YES callback:nil];
                break;
                
            case UIEventSubtypeRemoteControlPause:
                if (self.playing == 2)
                    [self.audioPlayer pause];
                if (self.playing == 1)
                    [self.player setIsPlaying:NO callback:nil];
                break;
                
            default:
                break;
        }
    }
}



@end
