//
//  MusicListController.m
//  huizon
//
//  Created by yang Eric on 5/18/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "MusicListController.h"
#import "UploadMusicController.h"
#import "MusicListCell.h"

#import <AVFoundation/AVFoundation.h>

@interface MusicListController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) MusicList *musicArray;
@property (strong,nonatomic) IBOutlet UITableView *tbMusic;
@end

@implementation MusicListController

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
    
    self.musicArray = [[MusicList alloc] init];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)loadMusicListFromLocal
{
    NSArray *ary = [[NSUserDefaults standardUserDefaults] objectForKey:kMusicLocalKey];
    if (ary) {
        self.musicArray = [[MusicList alloc] initWithArray:ary];
    }
    else{
        self.musicArray = [[MusicList alloc] init];
        [self.musicArray addObject:[Config musicDefaul1]];
        [self.musicArray addObject:[Config musicDefaul2]];
        
        NSString* fullPathToFile = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents"];
        
        NSArray *ary = [self allFilesAtPath:fullPathToFile];
        for (int i=0; i<[ary count]; i++) {
            NSString *name = [ary objectAtIndex:i];
            
            MusicItem *mItem = [[MusicItem alloc] init];
            
            mItem.musicName = [[self musicAlbum:name] objectForKey:@"title"];
            mItem.musicPath = name;
            mItem.author = [[self musicAlbum:name] objectForKey:@"artist"];
            [self.musicArray addObject:mItem];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:self.musicArray.arrayString forKey:kMusicLocalKey];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
        [self.tbMusic reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"歌曲列表"];
    self.navigationItem.leftBarButtonItem=[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(backAction:)];
	self.navigationItem.rightBarButtonItem=[[Theam currentTheam] navigationBarRightButtonItemWithImage:nil Title:@"导入" Target:self Selector:@selector(uploadAction:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadMusicListFromLocal];
}



- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)uploadAction:(id)sender
{
    UploadMusicController *uvc = [[UploadMusicController alloc]
                                  init];
    [self.navigationController pushViewController:uvc animated:YES];
}

#pragma mark -
#pragma mark TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.musicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cellIdentifier = @"MusicListCell";
    
    MusicListCell *cell = (MusicListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [cell setMusiceCell:[[self.musicArray objectAtIndex:indexPath.row] musicName] Author:[[self.musicArray objectAtIndex:indexPath.row] author]];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BlockCallWithOneArg(self.musicHandler,@(indexPath.row))
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<2){
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete){
        
        if (self.musicArray && indexPath.row<[self.musicArray count]) {
            
            MusicItem *mItem = [self.musicArray objectAtIndex:indexPath.row];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:mItem.musicPath]) {
                [fileManager removeItemAtPath:mItem.musicPath error:nil];
            }
            [self.musicArray removeObjectAtIndex:indexPath.row];
            [tableView setEditing:NO animated:YES];
            
            [[NSUserDefaults standardUserDefaults] setObject:self.musicArray.arrayString forKey:kMusicLocalKey];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
	}
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
    NSMutableDictionary *albumDict = [[NSMutableDictionary alloc] init];
    
    NSArray *docFolders = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES );
	NSString *baseDir =  [docFolders lastObject];
    
    NSString *songName = [path substringFromIndex:[baseDir length]+1];
    if ([songName length]>4) {
        songName = [songName substringToIndex:[songName length]-4];
    }
    [albumDict setObject:songName forKey:@"title"];
    [albumDict setObject:@"" forKey:@"artist"];
    
    
    
    NSURL * fileURL=[NSURL fileURLWithPath:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *fileExtension = [[fileURL path] pathExtension];
    
    
    
    if ([fileExtension isEqual:@"mp3"]||[fileExtension isEqual:@"m4a"])
    {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
