//
//  UploadMusicController.h
//  huizon
//
//  Created by yang Eric on 5/18/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NetworkController.h"

@class FtpServer;

@interface UploadMusicController : UIViewController {
	FtpServer	*theServer;
	NSString *baseDir;
}

@property (nonatomic, retain) FtpServer *theServer;
@property (nonatomic, copy) NSString *baseDir;

-(void)didReceiveFileListChanged;
- (void)stopFtpServer;

@end
