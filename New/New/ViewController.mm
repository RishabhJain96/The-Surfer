//
//  ViewController.m
//  New
//
//  Created by Vineet Kosaraju on 12/23/13.
//  Copyright (c) 2013 Vineet Kosaraju. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize converter, microphone, display, lbl, speech, videoCamera;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    converter = [[SpeechToTextModule alloc] init];
    [converter setDelegate:self];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:50.0f/255.0f green:78.0f/255.0f blue:92.0f/255.0f alpha:1.0f]];
    
    display = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:display];
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:display];
    [self.videoCamera setDelegate:self];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = false;
    [self.videoCamera start];
    
    microphone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Microphone_0.png"]];
    [microphone setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2 + 90)];
    
    [self.view addSubview:microphone];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped)];
    singleTap.numberOfTapsRequired = 1;
    display.userInteractionEnabled = YES;
    [display addGestureRecognizer:singleTap];
    
    [microphone setHidden:YES];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 145, 10, self.view.bounds.size.width/2 + 145, 20)];
    
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setNumberOfLines:0];
    [lbl setLineBreakMode:NSLineBreakByWordWrapping];
    [lbl setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setFont:[UIFont fontWithName: @"Trebuchet MS" size: 15.0f]];

    [self.view addSubview:lbl];
    
    speech = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
    [speech setRate:(float)1.0];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) powerData:(float)power
{
    // if -1 make label say analyzing
    if(power == -1.0f) {
        [lbl setText:@"Analyzing Speech"];
        [speech startSpeakingString:@"Analyzing Speech"];
    } else {
        if (0<power<=0.06) {
            [microphone setImage:[UIImage imageNamed:@"Microphone_0.png"]];
        }else if (0.06<power<=0.13) {
            [microphone setImage:[UIImage imageNamed:@"Microphone_1.png"]];
        }else if (0.13<power<=0.20) {
            [microphone setImage:[UIImage imageNamed:@"Microphone_2.png"]];
        }else if (0.20<power<=0.27) {
            [microphone setImage:[UIImage imageNamed:@"Microphone_3.png"]];
        }else if (0.27<power<=0.34) {
            [microphone setImage:[UIImage imageNamed:@"Microphone_4.png"]];
        }else if (0.34<power<=0.41) {
            [microphone setImage:[UIImage imageNamed:@"Microphone_5.png"]];
        }else if (0.41<power<=0.48) {
            [microphone setImage:[UIImage imageNamed:@"Microphone_6.png"]];
        }else if (0.48<power<=0.55) {
            [microphone setImage:[UIImage imageNamed:@"Microphone_7.png"]];
        }else if (0.55<power<=0.62) {
            [microphone setImage:[UIImage imageNamed:@"Microphone_8.png"]];
        }else if (0.62<power<=0.69) {
            [microphone setImage:[UIImage imageNamed:@"Microphone_9.png"]];
        }else if (0.69<power<=0.76) {
            [microphone setImage:[UIImage imageNamed:@"Microphone_10.png"]];
        }else if (0.76<power<=0.83) {
            [microphone setImage:[UIImage imageNamed:@"Microphone_11.png"]];
        }else if (0.83<power<=0.9) {
            [microphone setImage:[UIImage imageNamed:@"Microphone_12.png"]];
        }else {
            [microphone setImage:[UIImage imageNamed:@"Microphone_13.png"]];
        }
    }
}

- (void) screenTapped
{
    // make label say recording
    [lbl setText:@"Speak Now!"];
    [display setHidden:YES];
    [microphone setHidden:NO];
    [speech startSpeakingString:@"Speak Now!"];
    [converter performSelector:@selector(beginRecording) withObject:nil afterDelay:1.0];
}

-(NSString*) stringWithSentenceCapitalization:(NSString *)tmp
{
    NSString *firstCharacterInString = [[tmp substringToIndex:1] capitalizedString];
    NSString *sentenceString = [tmp stringByReplacingCharactersInRange:NSMakeRange(0,1) withString: firstCharacterInString];
    return sentenceString;
}

- (BOOL)didReceiveVoiceResponse:(NSData *)data
{
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    NSDictionary *voiceCommands = [json objectForKey:@"hypotheses"][0];
    
    CGFloat confidence = [[voiceCommands objectForKey:@"confidence"] floatValue];
    NSString *utterance = [voiceCommands objectForKey:@"utterance"];
    
    if(utterance == NULL || confidence < 0.5) {
        [lbl setText:@"Speak More Clearly"];
        [speech startSpeakingString:@"Speak More Clearly!"];
        [converter performSelector:@selector(beginRecording) withObject:nil afterDelay:1.0];
    } else {
        NSString *content = [self stringWithSentenceCapitalization:utterance];
        content = [NSString stringWithFormat:@"\"%@\"", content];
        [lbl setText:content];
        
        CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
        
        CGSize expectedLabelSize = [content sizeWithFont:lbl.font constrainedToSize:maximumLabelSize lineBreakMode:lbl.lineBreakMode];
        
        CGRect newFrame = lbl.frame;
        newFrame.size.height = expectedLabelSize.height;
        lbl.frame = newFrame;
    }
    
    NSLog(@"Confidence: %f | Utterance: %@", confidence, utterance);
    return YES;
}

#pragma mark -
#pragma mark - OpenCV Delegate Methods

#ifdef __cplusplus
- (void)processImage:(Mat&)image {
    
}
#endif


@end
