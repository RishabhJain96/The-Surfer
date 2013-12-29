//
//  ObjectAnalyzer.h
//  The Surfer
//
//  Created by Rishabh Jain on 12/29/13.
//  Copyright (c) 2013 RJVK Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <opencv2/core/core.hpp>
#import <opencv2/features2d/features2d.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/nonfree/nonfree.hpp>

using namespace cv;
using namespace std;

@interface ObjectAnalyzer : NSObject {
    vector<Mat> mats;
    vector<string> tags;
    vector<string> colors;
}


- (id)initWithMats:(vector<Mat>)mats andColors:(vector<string>)colors andTags:(vector<string>)tags;
- (vector<KeyPoint>)getKeyPoints:(Mat)mat;
- (Mat)getDescriptors:(Mat)img;
- (string)getColorFromImage:(Mat)img withKeypointsVector:(vector<KeyPoint>)keypoints;
- (vector<string>)matchImage:(Mat)img;

@end
