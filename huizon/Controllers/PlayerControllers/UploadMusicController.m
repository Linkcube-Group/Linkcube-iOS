//
//  UploadMusicController.m
//  huizon
//
//  Created by yang Eric on 5/18/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "UploadMusicController.h"
#import "FtpServer.h"

#import <AVFoundation/AVFoundation.h>

#define FTP_PORT 2021

@interface UploadMusicController ()

@property (strong,nonatomic) IBOutlet UILabel *lbAddress;
@end

@implementation UploadMusicController
@synthesize theServer, baseDir;

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
    NSString *localIPAddress = [NetworkController localWifiIPAddress];
	self.lbAddress.text = _S(@"手机和电脑同时连接WIFI情况下，  请在电脑文件夹地址输入\nftp://%@:%d/，\n将歌曲文件拖入本文件夹即可",localIPAddress,FTP_PORT);
	

	NSArray *docFolders = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES );
	self.baseDir =  [docFolders lastObject];
    
	
	FtpServer *aServer = [[FtpServer alloc] initWithPort:FTP_PORT withDir:baseDir notifyObject:self ];
	self.theServer = aServer;

    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"导入歌曲"];
    self.navigationItem.leftBarButtonItem=[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(backAction:)];

}


- (void)backAction:(id)sender
{
    [self stopFtpServer];
    [self.navigationController popViewControllerAnimated:YES];
}



// This is a method that will shut down the server cleanly, it calles the stopFtpServer method of FtpServer class.
// ----------------------------------------------------------------------------------------------------------
- (void)stopFtpServer {
	NSLog(@"Stopping the FTP server");
	if(theServer)
	{
		[theServer stopFtpServer];
	}
}


- (void)loadMusicListFromLocal
{
    MusicList *musicArray = [[MusicList alloc] init];
    [musicArray addObject:[Config musicDefaul1]];
    [musicArray addObject:[Config musicDefaul2]];
    [musicArray addObject:[Config musicDefaul3]];
    [musicArray addObject:[Config musicDefaul4]];
    
    NSString* fullPathToFile = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents"];
    
    NSArray *ary = [self allFilesAtPath:fullPathToFile];
    for (int i=0; i<[ary count]; i++) {
        NSString *name = [ary objectAtIndex:i];
        
        MusicItem *mItem = [[MusicItem alloc] init];
        NSDictionary *dict = [self musicAlbum:name];
        if (dict!=nil) {
            mItem.musicName = [dict objectForKey:@"title"];
            mItem.musicPath = name;
            mItem.author = [dict objectForKey:@"artist"];
            [musicArray addObject:mItem];
        }
       
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:musicArray.arrayString forKey:kMusicLocalKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark -
#pragma mark files

- (NSMutableArray *)allFilesAtPath:(NSString *)direString
{
    NSMutableArray *pathArray = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *tempArray = [fileManager contentsOfDirectoryAtPath:direString error:nil];
    for (NSString *fileName in tempArray) {
        BOOL flag = YES;
        NSString *fullPath = [direString stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                // ignore .DS_Store
                if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                    [pathArray addObject:fullPath];
                }
            }
            else {
                [pathArray addObject:[self allFilesAtPath:fullPath]];
            }
        }
    }
    
    return pathArray;
}

- (NSDictionary *)musicAlbum:(NSString *)path
{
    NSMutableDictionary *albumDict = nil;
    
    
    NSURL * fileURL=[NSURL fileURLWithPath:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *fileExtension = [[fileURL path] pathExtension];
    
   
    
    if ([fileExtension isEqual:@"mp3"]||[fileExtension isEqual:@"m4a"])
    {
        albumDict = [[NSMutableDictionary alloc] init];
        
        NSString *songName = [path substringFromIndex:[self.baseDir length]+1];
        if ([songName length]>4) {
            songName = [songName substringToIndex:[songName length]-4];
        }
        [albumDict setObject:songName forKey:@"title"];
        [albumDict setObject:@"" forKey:@"artist"];
    
        
        AudioFileID fileID  = nil;
        OSStatus err        = noErr;
        
        err = AudioFileOpenURL( (__bridge CFURLRef) fileURL, kAudioFileReadPermission, 0, &fileID );
        if( err != noErr ) {
            NSLog( @"AudioFileOpenURL failed" );
            
            return albumDict;
        }
       
        
        UInt32 id3DataSize  = 0;
        err = AudioFileGetPropertyInfo( fileID,   kAudioFilePropertyID3Tag, &id3DataSize, NULL );
        
        if( err != noErr ) {
            NSLog( @"AudioFileGetPropertyInfo failed for ID3 tag" );
            return albumDict;
        }
        NSDictionary *piDict = nil;
        UInt32 piDataSize   = sizeof( piDict );
        err = AudioFileGetProperty( fileID, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict );
        if( err != noErr ) {
            NSLog( @"AudioFileGetProperty failed for property info dictionary" );
            return albumDict;
        }
//        CFDataRef AlbumPic= nil;
//        UInt32 picDataSize = sizeof(picDataSize);
//        err =AudioFileGetProperty( fileID,   kAudioFilePropertyAlbumArtwork, &picDataSize, &AlbumPic);
//        if( err != noErr ) {
//            NSLog( @"Get picture failed" );
//        }
        
        NSString * Album = [(NSDictionary*)piDict objectForKey:
                            [NSString stringWithUTF8String: kAFInfoDictionary_Album]];
        NSString * Artist = [(NSDictionary*)piDict objectForKey:
                             [NSString stringWithUTF8String: kAFInfoDictionary_Artist]];
        NSString * Title = [(NSDictionary*)piDict objectForKey:
                            [NSString stringWithUTF8String: kAFInfoDictionary_Title]];
        
        if (Album) {
            [albumDict setObject:Album forKey:@"album"];
        }
        if (Artist) {
            [albumDict setObject:Artist forKey:@"artist"];
        }
        if (Title) {
            [albumDict setObject:Title forKey:@"title"];
        }
        
        
    }
    return albumDict;
}
// ----------------------------------------------------------------------------------------------------------
-(void)didReceiveFileListChanged
{
    [self loadMusicListFromLocal];
	NSLog(@"didReceiveFileListChanged");
    showCustomAlertMessage(@"上传成功");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
