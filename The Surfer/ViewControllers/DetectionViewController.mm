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
@synthesize imgDisplay, videoCamera, btnVoiceRecognize;

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
    
    self.imgDisplay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.imgDisplay];
    
    self.btnVoiceRecognize = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.btnVoiceRecognize setBackgroundColor:[UIColor clearColor]];
    [self.btnVoiceRecognize setAlpha:0.5f];
    [self.btnVoiceRecognize addTarget:self action:@selector(startVocalRecognition:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.btnVoiceRecognize];
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imgDisplay];
    [self.videoCamera setDelegate:self];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    [self.videoCamera start];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - Speech to Text Methods

- (void)startVocalRecognition:(id)sender {
    NSLog(@"Beginning to Recognize Voice");
    
}

#pragma mark - 
#pragma mark - OpenCV Delegate Methods

#ifdef __cplusplus
- (void)processImage:(Mat&)image {

}
#endif


@end
