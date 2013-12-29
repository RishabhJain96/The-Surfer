//
//  TrainViewController.h
//  SIFTOpenCVSearcher
//
//  Created by Rishabh Jain on 8/12/13.
//  Copyright (c) 2013 Rishabh Jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>

#import "ObjectAnalyzer.h"

using namespace cv;

@interface TrainViewController : UIViewController <CvPhotoCameraDelegate, UIAlertViewDelegate> {
    IBOutlet UIImageView *image;
    IBOutlet UIButton *captureButton;
    CvPhotoCamera *videoCamera;
    UIImage *img;
}

@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UIButton *captureButton;
@property (nonatomic, retain) CvPhotoCamera *videoCamera;
@property (nonatomic, retain) ObjectAnalyzer *analyzer;

- (IBAction)captureFrame;

@end
