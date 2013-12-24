//
//  DetectionViewController.h
//  The Surfer
//
//  Created by Rishabh Jain on 12/21/13.
//  Copyright (c) 2013 RJVK Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// OpenCV Imports
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>

//SpeechToText Imports
#import "SpeechToTextModule.h"
#import <AVFoundation/AVFoundation.h>
#import <RJGoogleTTS/GoogleTTS.h>

using namespace cv;

@interface DetectionViewController : UIViewController <CvVideoCameraDelegate, SpeechToTextModuleDelegate> {
    
    IBOutlet UIImageView *imgDisplay;
    
    CvVideoCamera *videoCamera;
    SpeechToTextModule *speechDetector;
    AVAudioPlayer *player;
    GoogleTTS *tts;
    
    UIImageView *microphone;
    UILabel *lblCurrent;
}

@property (nonatomic, retain) IBOutlet UIImageView *imgDisplay, *microphone;
@property (nonatomic, retain) UILabel *lblCurrent;
@property (nonatomic, retain) CvVideoCamera *videoCamera;
@property (nonatomic, retain) SpeechToTextModule *speechDetector;
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, retain) GoogleTTS *tts;

@end
