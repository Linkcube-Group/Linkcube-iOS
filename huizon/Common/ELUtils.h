//
//  ELUtils.h
//  ELBooks
//
//  Created by Xie Wei on 11-3-25.
//  Copyright 2011 e-linkway.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *htmlmd5( NSString *str);
NSString* ELBundlePath();
NSString* ELBundlePathForRelativePath(NSString* relativePath);

NSString* ELDocumentsPath();
NSString* ELDocumentsPathForRelativePath(NSString* relativePath);

UIImage* ELImageForAbsolutePath(NSString *imagePath);
UIImage* ELImageForBundlePath(NSString *imagePath);

void SetBackgroundImageForView(UIView *view, NSString *imageRelativePath);

UIButton* ELButtonForImage(NSString *normalImagePath, NSString *selectedImagePath);

#define ERR_SUCCESS           0
#define ERR_NETWORK_TIMEOUT   1
#define ERR_JSON_PARSE_FAILED 2
#define ERR_COMMENT_IS_NULL   3
#define ERR_GPS_UPDATE_FAILED 4
#define ERR_NO_CAMERA         5


#define SERVER_RESPONSE_ERROR @"服务器返回数据错误"

void showAlertByCode(int errorCode);

void showCustomAlertMessage(NSString *message);

void showIndicator(BOOL flag);
void showFullScreen(BOOL flag);

NSString* getFormatDate(NSString *string);
NSString* getFormatYear(NSString *string);
NSString* getFormatMonth(NSString *string);
NSString* getFormatMonthDay(NSString *string);
NSString* getFormatTime(NSString *string);

//NSData* Decode3DESWithKey(NSData *imgData);
UIImage* getImageByString(NSString *string);

NSString* getUID();
NSString* getNickName();

NSString* getUserDefaults(NSString *key);

BOOL isSinaWeiboUser();
NSString* URLEncodedString(NSString* input);

NSString* IsValidPWD(const char* passWord);
NSString* IsValidEmail(const char* pszEmail);
NSString* IsValidMobeilTel(const char* pszTel);
float getTextLength(NSString *text);
NSString* NumberToStr(int num);
NSString* MothMinuteDate(NSString *string);  //2012-08-09 00:00:00


NSUInteger DeviceSystemMajorVersion();