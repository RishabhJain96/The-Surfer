//
//  ViewController.h
//  New
//
//  Created by Vineet Kosaraju on 12/23/13.
//  Copyright (c) 2013 Vineet Kosaraju. All rights reserved.
//

#import <UIKit/UIKit.h>

//SpeechToText and TextToSpeech Imports
#import "SpeechToTextModule.h"
#import "VSSpeechSynthesizer.h"

// OpenCV Imports
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>

using namespace cv;

@interface ViewController : UIViewController <CvVideoCameraDelegate, SpeechToTextModuleDelegate>
{
    SpeechToTextModule *converter;
    UIImageView *microphone;
    CvVideoCamera *videoCamera;
    UIImageView *display;
    UILabel *lbl;
    VSSpeechSynthesizer *speech;

}
@property(nonatomic, strong) SpeechToTextModule *converter;
@property(nonatomic, strong) UIImageView *microphone;
@property(nonatomic, strong) UIImageView *display;
@property(nonatomic, strong) UILabel *lbl;
@property(nonatomic, strong) VSSpeechSynthesizer *speech;
@property (nonatomic, retain) CvVideoCamera *videoCamera;

@end

