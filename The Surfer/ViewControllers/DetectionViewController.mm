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
@synthesize imgDisplay, microphone, videoCamera, speechDetector, lblCurrent;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Speech to Text Methods

- (void)startVocalRecognition:(id)sender {
    if(![self.speechDetector recording]) {
        [self.speechDetector beginRecording];
        [lblCurrent setText:@"Speak Now!"];
        [microphone setHidden:false];
        NSLog(@"Beginning to recognize voice");
        
    } else {
        [self.speechDetector stopRecording:NO];
        NSLog(@"Ending recognizing voice");
    }
}

#pragma mark - 
#pragma mark - SpeechToText Delegate Methods

- (void) powerData:(float)power
{
    NSLog(@"Power Data: %f", power);
    // if -1 make label say analyzing
    if(power == -1.0f) {
        [lblCurrent setText:@"Analyzing Speech"];
        //[speech startSpeakingString:@"Analyzing Speech"];
    } else {
        if (0<power<=0.06) {
            [microphone setImage:[UIImage imageNamed:@"microphone_1.png"]];
        }else if (0.06<power<=0.1666) {
            [microphone setImage:[UIImage imageNamed:@"microphone_2.png"]];
        }else if (0.1666<power<=0.3333) {
            [microphone setImage:[UIImage imageNamed:@"microphone_3.png"]];
        }else if (0.3333<power<=0.5000) {
            [microphone setImage:[UIImage imageNamed:@"microphone_4.png"]];
        }else if (0.5000<power<=0.6666) {
            [microphone setImage:[UIImage imageNamed:@"microphone_5.png"]];
        }else if (0.6666<power<=0.8333) {
            [microphone setImage:[UIImage imageNamed:@"microphone_6.png"]];
        }else {
            [microphone setImage:[UIImage imageNamed:@"microphone_1.png"]];
        }
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
        //[speech startSpeakingString:@"Speak More Clearly!"];
        [speechDetector performSelector:@selector(beginRecording) withObject:nil afterDelay:1.0];
        return NO;
    }
    
    NSDictionary *voiceCommands = [json objectForKey:@"hypotheses"][0];
    
    CGFloat confidence = [[voiceCommands objectForKey:@"confidence"] floatValue];
    NSString *utterance = [voiceCommands objectForKey:@"utterance"];
    
    if(utterance == NULL || confidence < 0.5) {
        [lblCurrent setText:@"Speak More Clearly"];
        //[speech startSpeakingString:@"Speak More Clearly!"];
        [speechDetector performSelector:@selector(beginRecording) withObject:nil afterDelay:1.0];
        return NO;
    } else {
        NSString *content = [utterance capitalizedString];
        content = [NSString stringWithFormat:@"\"%@\"", content];
        [lblCurrent setText:content];
        
        CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
        
        CGSize expectedLabelSize = [content sizeWithFont:lblCurrent.font constrainedToSize:maximumLabelSize lineBreakMode:lblCurrent.lineBreakMode];
        
        CGRect newFrame = lblCurrent.frame;
        newFrame.size.height = expectedLabelSize.height;
        lblCurrent.frame = newFrame;
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


@end
