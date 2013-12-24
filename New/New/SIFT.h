//
//  SIFT.h
//  New
//
//  Created by Vineet Kosaraju on 12/23/13.
//  Copyright (c) 2013 Vineet Kosaraju. All rights reserved.
//

#import <Foundation/Foundation.h>

// OpenCV Imports
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/nonfree/features2d.hpp>

using namespace cv;

@interface MSIFT : NSObject 
{
    NSMutableArray *names;
    NSMutableArray *keypoints;
    NSMutableArray *colors;
}
@property(nonatomic, strong) NSMutableArray *names;
@property(nonatomic, strong) NSMutableArray *keypoints;
@property(nonatomic, strong) NSMutableArray *colors;

- (vector<KeyPoint>) getKeyPoints:(Mat *)img;

-(int) compare:(Mat)descriptors1 secondImage:(Mat*)img2;

- (void) compareFrame:(Mat *)img;

- (NSString*) calculateColor:(Mat *)img;

@end