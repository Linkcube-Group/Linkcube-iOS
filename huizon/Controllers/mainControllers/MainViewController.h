//
//  MainViewController.h
//  huizon
//
//  Created by Yang on 14-2-26.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VoiceControls.h"


@interface MainViewController : UIViewController<MPMediaPickerControllerDelegate>

- (IBAction)openBluetooth:(id)sender;
@end
