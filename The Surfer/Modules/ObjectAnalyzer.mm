//
//  ObjectAnalyzer.m
//  The Surfer
//
//  Created by Rishabh Jain on 12/29/13.
//  Copyright (c) 2013 RJVK Productions. All rights reserved.
//

#import "ObjectAnalyzer.h"

@implementation ObjectAnalyzer

- (id)initWithMats:(vector<Mat>)db {
    if ((self = [super init])) {
        mats = db;
    }
    return self;
}

- (vector<KeyPoint>)getKeyPoints:(Mat)mat {
    int minHessian = 400;
    cv::SurfFeatureDetector detector(minHessian);
    vector<cv::KeyPoint> tmp;
    detector.detect(mat, tmp);
    return tmp;
}

- (Mat)getDescriptors:(Mat)img {
    int minHessian = 400;
    cv::SurfFeatureDetector detector(minHessian);
    cv::SurfDescriptorExtractor extractor;
    vector<cv::KeyPoint> tmp;
    cv::Mat tmp2;
    detector.detect(img, tmp);
    extractor.compute(img, tmp, tmp2);
    
    return tmp2;
}

- (string)getColorFromImage:(cv::Mat)img withKeypointsVector:(vector<cv::KeyPoint>)keypoints {
    int red = 0;
    int green = 0;
    int blue = 0;
    int bSize = 2;
    int count = 0;
    for(int i = 0; i < keypoints.size(); i++) {
        int x = keypoints[i].pt.x;
        int y = keypoints[i].pt.y;
        for(int j = x-bSize; j <= x+bSize; j++) {
            for(int k = y-bSize; k <= y+bSize; k++) {
                if(j >= 0 && j < img.rows && k >= 0 && k < img.cols) {
                    red += img.at<Vec3b>(j, k)[2];
                    green += img.at<Vec3b>(j, k)[1];
                    blue += img.at<Vec3b>(j, k)[0];
                    count++;
                }
            }
        }
    }
    // printf("Final colors : red %d, green %d, blue %d\n", red, green, blue);
    red /= count;
    green /= count;
    blue /= count;
    //  printf("Final colors (2) : red %d, green %d, blue %d\n", red, green, blue);
    
    int bins = 5;
    
    for(int i = 1; i <= bins; i++) {
        if(red < (255/bins * i) && red > (255/bins * (i-1))) red = (i-1);
        if(green < (255/bins * i) && green > (255/bins * (i-1))) green = (i-1);
        if(blue < (255/bins * i) && blue > (255/bins * (i-1))) blue = (i-1);
    }
    
    return std::to_string(red) + std::to_string(green) + std::to_string(blue);
}

- (vector<string>)matchImage:(cv::Mat)img withTags:(vector<string>)tags andColors:(vector<string>)colors {
    clock_t start = clock();
    vector<vector<cv::DMatch>> db_matches;
    vector<vector<cv::DMatch>> good_matches;
    cv::SurfFeatureDetector detector(400);
    cv::SurfDescriptorExtractor extractor;
    
    std::vector<cv::KeyPoint> keypoints_1; // image's keypoints
    detector.detect(img, keypoints_1 );
    cv::FlannBasedMatcher matcher;
    cv::Mat descriptors_1;
    extractor.compute(img, keypoints_1, descriptors_1 );
    double total_min = 100;
    double total_max = 0;
    vector<double> min_distances;
    vector<double> max_distances;
    
    
    // color is now "012"
    string color = [self getColorFromImage:img withKeypointsVector:keypoints_1];
    
    
    vector<cv::Mat> colormatchedmats;
    vector<string> colormatchedtags;
    for(int i = 0; i < colors.size(); i++) {
        int count = 0;
        if(color.at(0) == colors[i].at(0)) count++;
        if(color.at(1) == colors[i].at(1)) count++;
        if(color.at(2) == colors[i].at(2)) count++;
        if(count >= 2) {
            colormatchedmats.push_back(mats[i]);
            colormatchedtags.push_back(tags[i]);
        }
    }
    
    for(unsigned i = 0; i < colormatchedmats.size(); i++) {
        vector<cv::DMatch> tmp;
        db_matches.push_back(tmp);
        vector<cv::DMatch> tmp2;
        good_matches.push_back(tmp2);
        
        // colormatchedmats[i]
        // cout << "M = "<< endl << " "  << colormatchedmats[i] << endl << endl;
        
        matcher.match(descriptors_1, colormatchedmats[i], db_matches[i]);
        
        double max_dist = 0; double min_dist = 100;
        
        for(int j = 0; j < descriptors_1.rows; j++) {
            double dist = db_matches[i][j].distance;
            if(dist < min_dist) min_dist = dist;
            if(dist > max_dist) max_dist = dist;
        }
        min_distances.push_back(min_dist);
        max_distances.push_back(max_dist);
        
        if (min_dist < total_min) total_min = min_dist;
        if (max_dist > total_max) total_max = max_dist;
    }
    
    vector<string> ret;
    for(unsigned i = 0; i < min_distances.size(); i++) {
        //    printf("Total Min: %f | Min Distance: %f \n", total_min, min_distances[i]);
        //     printf("Total Max: %f | Max Distance: %f \n", total_max, max_distances[i]);
        //     printf("Good Matches Size: %lu \n", good_matches[i].size());
        if(abs(total_min - min_distances[i]) <= .03 && min_distances[i] <= 0.075) { // we need some sort of check here to ensure that bogus images aren't being thrown our way
            printf("%s is a good image with distance %f\n", colormatchedtags[i].c_str(), min_distances[i]);
            ret.push_back(colormatchedtags[i]);
        }
    }
    
    clock_t end = clock();
    double elapsed_seconds = double(end-start) / CLOCKS_PER_SEC;
    printf("Took %f time to run\n", elapsed_seconds);
    
    return ret;
}


@end
