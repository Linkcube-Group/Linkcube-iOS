//
//  MediaViewController.m
//  huizon
//
//  Created by yang Eric on 3/6/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "MediaViewController.h"

@interface MediaViewController ()
{
    BOOL isSelectingAssetOne;
    AVAsset *firstAsset;
    AVAsset *secondAsset;
    AVAsset *audioAsset;
    CFStringRef *kUTTypeMovie;
}
@end

@implementation MediaViewController

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
    // Do any additional setup after loading the view from its nib.
}

//选择第一个asset
- (IBAction)loadAssetOne:(UIButton *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Saved Album Found"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        isSelectingAssetOne = TRUE;
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}

//选择第二个asset
- (IBAction)loadAssetTwo:(UIButton *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Saved Album Found"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        isSelectingAssetOne = FALSE;
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}


- (IBAction)mergeAndSave:(UIButton *)sender {
    
    if (firstAsset !=nil && secondAsset!=nil) {
        
        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        //创建一个AVMutableComposition实例
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        
        // 2 - Video track
        //创建一个轨道,类型是AVMediaTypeAudio
        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        
        //获取firstAsset中的音频,插入轨道
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration)
                            ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        
        //获取secondAsset中的音频,插入轨道
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration)
                            ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:firstAsset.duration error:nil];
        
        // 4 - Get path
        //创建输出路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];
        NSURL *url = [NSURL fileURLWithPath:myPathDocs];
        
        // 5 - Create exporter
        //创建输出对象
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL=url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        //        @"com.apple.quicktime-movie";
        exporter.shouldOptimizeForNetworkUse = YES;
        
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self exportDidFinish:exporter];
            });
        }];
    }
    
}

-(void)exportDidFinish:(AVAssetExportSession*)session {
    NSLog(@"%ld",session.status);
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        
        MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc]
                                                 initWithContentURL:outputURL];
        
        [self presentMoviePlayerViewControllerAnimated:theMovie];
        
    }
    audioAsset = nil;
    firstAsset = nil;
    secondAsset = nil;
}

-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate {
    // 1 - Validation
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    // 2 - Create image picker
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
     //[[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = delegate;
    // 3 - Display image picker
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 1 - Get media type
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    // 2 - Dismiss image picker
    [self dismissModalViewControllerAnimated:NO];
    
    // 3 - Handle video selection
    //判断是不是选中的第一个asset,分别加载到2个asset
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, *(kUTTypeMovie), 0) == kCFCompareEqualTo) {
        if (isSelectingAssetOne){
            NSLog(@"Video One  Loaded");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video One Loaded"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            firstAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        } else {
            NSLog(@"Video two Loaded");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video Two Loaded"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            secondAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
