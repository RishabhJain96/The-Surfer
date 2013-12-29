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
@synthesize imgDisplay, microphone, videoCamera, speechDetector, lblCurrent, player, tts, objectAnalyzer;

/**
 * Method: initWithNibName
 * Description: Called once iOS framework initiates the class with the given nib
 * Purpose: Doesn't really do anything in this program
 *
 * @param nibNameOrNil   - The nib name that was used to launch the controller
 * @param nibBundleOrNil - The bundle of which the nib was launched
 * @return returns an instance of this class given the nib and the bundle
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/**
 * Method: viewDidLoad
 * Description: Called once the view has been loaded into memory but before the view has been displayed
 * Purpose: Sets up the view by creating the image display, the video camera, the speech detector, the descriptor label, the microphone, and the text to speech
 */
- (void)viewDidLoad {
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
    
    matchImage = false;
}

/**
 * Method: didReceiveMemoryWarning
 * Description: Called once the iOS operating system receives a memory warning
 * Purpose: Doesn't really do anything but call the UIView's method for freeing up memory. Became obsolete with ARC.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Speech to Text Methods

/**
 * Method: startVocalRecognition
 * Description: Called once the vocal recognition has been started
 * Purpose: If the speech detector is not recording then the assistant will use TTS to say "Speak Now" and then will begin recording. Otherwise, stops recording and does not process the data further.
 *
 * @param sender - the sender of the vocal recognition, not really used for anything.
 */
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

/**
 * Method: powerData
 * Description: Called everytime the power data from the microphone is received from the speech to text module
 * Purpose: Used to change microphone image
 *
 * TODO: Add more intervals for the microphone to make the change in microphone size more detectable
 *
 * @param power - the power of the microphone between [0~1]
 */
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

/**
 * Method: didReceiveVoiceResponse
 * Description: Called once the Speech to Text module returns data containing the hypothesis and the confidence level.
 * Purpose: Used to take in the user speech and determine what needs to be done. Currently, if the phrase contains the word "what" and "front" then SIFT will be used to determine what is in front of the user.
 *
 * @param data - the data that is received from the speech to text module. The data is formatted as an array with a dictionary inside. The dictionary contains the keys "confidence" and "utterance" where utterance is the hypothesized speech and confidence is the confidence level of the speech.
 * @return     - If no is returned then calls the speech to text module again, but if yes is returned then stops the speech to text analysis.
 */
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
            // We need to see what is in front of us
            NSLog(@"Using SIFT");
            
        }
    }
    
    return YES;
}

/**
 * Method: showSineWaveView
 * Description: Called once the sine wave view must be displayed from the speech to text module
 * Usage: Used so that no alert is shown from the speech to text module. Doesn't do anything else.
 */
- (void)showSineWaveView:(SineWaveViewController *)view {
    
}

/**
 * Method: showLoadingView
 * Description: Called once the loading view must be displayed from the speech to text module
 * Usage: Used so that no loading view from the speech to text module is shown. Doesn't do anything else.
 */
- (void)showLoadingView {

}

/**
 * Method: requestFailedWithError
 * Description: Called once the speech to text module request has failed with the given error.
 * Usage: Logs the error and doesn't do anything else.
 *
 * @param error - The error that the speech to text module received
 */
- (void)requestFailedWithError:(NSError *)error {
    NSLog(@"error: %@",error);
}

#pragma mark - 
#pragma mark - OpenCV Delegate Methods

#ifdef __cplusplus

/**
 * Method: processImage
 * Description: Called once the video camera has an image that needs to be processed
 * Usage: Used to process sift if necessary, otherwise doesn't do anything.
 *
 * @param image - the image that the video camera received that should be analyzed if necessary
 */
- (void)processImage:(Mat&)image {
    if (matchImage) {
        
    }
}

#endif

#pragma mark - 
#pragma mark - GoogleTTS Methods

/**
 * Method: playText
 * Description: Called if text needs to be spoken out loud to the user
 * Usage: Used to inform the user of an event via TTS
 *
 * @param text - the text that needs to be spoken
 */
- (void)playText:(NSString *)text {
    [tts convertTextToSpeech:text withCompletion:^(NSMutableData *response) {
        player = [[AVAudioPlayer alloc] initWithData:response error:nil];
        [player play];
    }];
}


@end
