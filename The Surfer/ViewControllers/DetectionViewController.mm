//
//  DetectionViewController.m
//  The Surfer
//
//  Created by Rishabh Jain on 12/21/13.
//  Copyright (c) 2013 RJVK Productions. All rights reserved.
//

#import "DetectionViewController.h"

@interface DetectionViewController ()

@end

@implementation DetectionViewController
@synthesize imgDisplay, microphone, videoCamera, speechDetector, lblCurrent, player, tts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup Image Display
    self.imgDisplay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.imgDisplay addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startVocalRecognition:)]];
    [self.imgDisplay setUserInteractionEnabled:YES];
    [self.view addSubview:self.imgDisplay];
    
    // Link Image Display with Camera
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imgDisplay];
    [self.videoCamera setDelegate:self];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    [self.videoCamera start];
    
    // Setup Speech Detector
    self.speechDetector = [[SpeechToTextModule alloc] initWithCustomDisplay:@"SineWaveViewController"];
    [self.speechDetector setDelegate:self];
    
    // Setup Descriptor Label
    self.lblCurrent = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-145, 10, self.view.frame.size.width, 20)];
    [self.lblCurrent setTextAlignment:NSTextAlignmentCenter];
    [self.lblCurrent setTextColor:[UIColor whiteColor]];
    [self.lblCurrent setBackgroundColor:[UIColor clearColor]];
    [self.lblCurrent setFont:[UIFont fontWithName:@"Times New Roman" size:15.0f]];
    [self.view addSubview:self.lblCurrent];
    
    // Setup microphone
    self.microphone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"microphone_1.png"]];
    [microphone setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2 + 90)];
    [self.view addSubview:self.microphone];
    [self.microphone setHidden:YES];
    
    // Setup GoogleTTS
    tts = [[GoogleTTS alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Speech to Text Methods

- (void)startVocalRecognition:(id)sender {
    if(![self.speechDetector recording]) {
        [self playText:@"Speak Now"];
        [self.speechDetector performSelector:@selector(beginRecording) withObject:nil afterDelay:1.0];
        [lblCurrent setText:@"Speak Now!"];
        [microphone setHidden:false];
    } else {
        [self.speechDetector stopRecording:NO];
        NSLog(@"Ending recognizing voice");
    }
}

#pragma mark - 
#pragma mark - SpeechToText Delegate Methods

- (void)powerData:(float)power {
    // if -1 make label say analyzing
    if(power == -1.0f) {
        [lblCurrent setText:@"Analyzing Speech"];
        [self playText:@"Analyzing Speech"];
        lastPower = -1;
        lastMicrophone = 1;
    } else {
        if (lastPower == -1) {
            if (0.0f < lastPower <= 1/6.) {
                lastMicrophone = 1;
            } else if (1/6. < lastPower <= 2/6.) {
                lastMicrophone = 2;
            } else if (2/6. < lastPower <= 3/6.) {
                lastMicrophone = 3;
            } else if (3/6. < lastPower <= 4/6.) {
                lastMicrophone = 4;
            } else if (4/6. < lastPower <= 5/6.) {
                lastMicrophone = 5;
            } else {
                lastMicrophone = 6;
            }
        }
        if (power - lastPower > 0.005) {
            if (lastMicrophone != 6) {
                lastMicrophone++;
            }
        } else if (power - lastPower < -0.005) {
            if (lastMicrophone != 1) {
                lastMicrophone--;
            }
        } else {
            return;
        }
        NSString *mike = [NSString stringWithFormat:@"microphone_%i", lastMicrophone];
        [microphone setImage:[UIImage imageNamed:mike]];
        lastPower = power;
    }
}

- (BOOL)didReceiveVoiceResponse:(NSData *)data {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    if([[json objectForKey:@"hypotheses"] count] <= 0) {
        [self.lblCurrent setText:@"Speak More Clearly"];
        [speechDetector performSelector:@selector(beginRecording) withObject:nil afterDelay:1.0];
        return NO;
    }
    
    NSDictionary *voiceCommands = [json objectForKey:@"hypotheses"][0];
    
    CGFloat confidence = [[voiceCommands objectForKey:@"confidence"] floatValue];
    NSString *utterance = [voiceCommands objectForKey:@"utterance"];
    
    if(utterance == NULL || confidence < 0.5) {
        [lblCurrent setText:@"Speak More Clearly"];
        [self playText:@"Speak More Clearly"];
        [speechDetector performSelector:@selector(beginRecording) withObject:nil afterDelay:1.0];
        return NO;
    } else {
        NSString *content = [utterance capitalizedString];
        content = [NSString stringWithFormat:@"\"%@\"", content];
        [lblCurrent setText:content];
        [self playText:content];
        
        CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
        
        CGSize expectedLabelSize = [content sizeWithFont:lblCurrent.font constrainedToSize:maximumLabelSize lineBreakMode:lblCurrent.lineBreakMode];
        
        CGRect newFrame = lblCurrent.frame;
        newFrame.size.height = expectedLabelSize.height;
        lblCurrent.frame = newFrame;
        
        if ([content rangeOfString:@"what"].location != NSNotFound) {
            // We need to see what is in front of us!
            NSLog(@"Using SIFT");
            
        }
    }
    
    return YES;
}

- (void)showSineWaveView:(SineWaveViewController *)view {
    
}

- (void)showLoadingView {
    NSLog(@"show loadingView");
}
- (void)requestFailedWithError:(NSError *)error {
    NSLog(@"error: %@",error);
}

#pragma mark - 
#pragma mark - OpenCV Delegate Methods

#ifdef __cplusplus
- (void)processImage:(Mat&)image {

}
#endif

#pragma mark - 
#pragma mark - GoogleTTS Methods

- (void)playText:(NSString *)text {
    [tts convertTextToSpeech:text withCompletion:^(NSMutableData *response) {
        player = [[AVAudioPlayer alloc] initWithData:response error:nil];
        [player play];
    }];
}


@end
