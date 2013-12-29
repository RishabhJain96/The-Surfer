//
//  TrainViewController.m
//  SIFTOpenCVSearcher
//
//  Created by Rishabh Jain on 8/12/13.
//  Copyright (c) 2013 Rishabh Jain. All rights reserved.
//

#import "TrainViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <fstream>
#import "UIImage+OpenCV.h"

using namespace std;

@interface TrainViewController ()

@end

@implementation TrainViewController
@synthesize captureButton, image, videoCamera, analyzer;

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
    
    self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.image];
    
    self.captureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.captureButton setUserInteractionEnabled:YES];
    [self.captureButton setTitle:@"" forState:UIControlStateNormal];
    [self.captureButton setBackgroundColor:[UIColor clearColor]];
    [self.captureButton addTarget:self action:@selector(captureFrame) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.captureButton];
    
	// Do any additional setup after loading the view.
    self.videoCamera = [[CvPhotoCamera alloc] initWithParentView:image];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.delegate = self;
    
    analyzer = [[ObjectAnalyzer alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.videoCamera start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)captureFrame {
    NSLog(@"Capturing Frame");
    
    /*
     NSData *data = UIImagePNGRepresentation(self.image.image);
     
     NSString *docsDirectory = [self applicationDocumentsDirectory];
     
     NSString *filePath = [docsDirectory stringByAppendingPathComponent:@"image.png"]; //Add the file name
     NSLog(@"Saving to Path: %@", filePath);
     [data writeToFile:filePath atomically:YES]; //Write the file
     */
    [self.videoCamera takePicture];
}

#pragma mark -
#pragma mark - CvVideoCamera Delegate

#ifdef __cplusplus

#endif

- (void)photoCamera:(CvPhotoCamera *)photoCamera capturedImage:(UIImage *)imager {
    // get proper data... first convert imager to cvMat
    img = imager;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tag" message:@"Tag the Image!" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *text = [[alertView textFieldAtIndex:0] text];
    
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""]; // remove spaces
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Analyzing..."];
    Mat mat = img.CVGrayscaleMat;
    //MSIFT *sift = new MSIFT();
    //Mat descriptors = sift->getDescriptors(mat);
    Mat descriptors = [analyzer getDescriptors:mat];
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(img.CGImage);
    CGFloat cols = img.size.width;
    CGFloat rows = img.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), img.CGImage);
    CGContextRelease(contextRef);
    
    // output
    NSString *output = [[self applicationDocumentsDirectory] stringByAppendingString:[NSString stringWithFormat:@"dbFinalF.yml"]];
    NSString *tagOutput = [[self applicationDocumentsDirectory] stringByAppendingString:@"tagsFinalF.yml"];
    
    ofstream myfilew;
    myfilew.open(tagOutput.UTF8String, ios::out | ios::app);
    
    // replace this with the user input to pick a color, for now its just the tag
    
    // then append
    NSString *outp = [NSString stringWithFormat:@"%@", text];
    //string colorstring = sift->getColor(cvMat, sift->getKeyPoints(cvMat)).c_str();
    string colorstring = [analyzer getColorFromImage:cvMat withKeypointsVector:[analyzer getKeyPoints:cvMat]].c_str();
    
    NSString *newcolorstring = [NSString stringWithUTF8String:colorstring.c_str()];
    NSString *outp2 = [NSString stringWithFormat:@"%@||%@", text, newcolorstring];
    printf("Color of thing added : %s\n", colorstring.c_str());
    FileStorage f;
    f.open(output.UTF8String, FileStorage::APPEND);
    f << outp.UTF8String << descriptors; // later replace db with the tag for l8er
    myfilew << outp2.UTF8String << "\n";
    [hud hide:YES afterDelay:1.0];
}

- (void)photoCameraCancel:(CvPhotoCamera *)photoCamera {
    
}

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [NSString stringWithFormat:@"%@/", basePath];
}


@end
