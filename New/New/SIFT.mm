//
//  SIFT.m
//  New
//
//  Created by Vineet Kosaraju on 12/23/13.
//  Copyright (c) 2013 Vineet Kosaraju. All rights reserved.
//

#import "SIFT.h"

@interface MSIFT ()

@end

@implementation MSIFT

@synthesize names, keypoints, colors;

- (vector<KeyPoint>) getKeyPoints:(Mat *)img {
    int minHessian = 400;
    SurfFeatureDetector detector(minHessian);
    vector<cv::KeyPoint> tmp;
    detector.detect(*img, tmp);
    return tmp;
}

-(int) compare:(Mat)descriptors1 secondImage:(Mat*)img2 {
    FlannBasedMatcher matcher;
    // matcher.match(descriptors_1, colormatchedmats[i], db_matches[i]);
    return 0;
}

- (void) compareFrame:(Mat *)img {
    
}

- (NSString*) calculateColor:(Mat *)img {
    return NULL;
}


@end
