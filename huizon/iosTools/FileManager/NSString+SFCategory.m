//
//  NSString+SFCategory.m
//  SFExpress
//
//  Created by tixa tixa on 14-1-8.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "NSString+SFCategory.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (SFCategory)

/*转换为沙箱Documents文件夹下的路径*/
- (NSString *)documentFilePath
{
    NSString *tempPath = [self hasPrefix:@"Documents/"] ? self : [NSString stringWithFormat:@"Documents/%@", self];
    return [self hasPrefix:NSHomeDirectory()] ? self : [NSHomeDirectory() stringByAppendingPathComponent:tempPath];
}

/*是否为沙箱Documents文件夹下的路径*/
- (BOOL)isDocumentFilePath
{
    return [self hasPrefix:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"]];
}

/*创建在沙箱Documents文件夹下的指定目录*/
- (BOOL)createDocumentFileDirectory
{
    if (!self.length) {
        return NO;
    }
    
	NSString *filePath = self.documentFilePath;
    NSString *directoryPath = [filePath substringToIndex:filePath.length - [(NSString *)filePath.pathComponents.lastObject length]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:directoryPath]) {
		return [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
    return YES;
}

/*删除在沙箱Documents文件夹下得指定文件*/
- (BOOL)deleteDocumentFile
{
    NSString *filePath = self.documentFilePath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:filePath]) {
		return [fileManager removeItemAtPath:filePath error:nil];
	}
	return NO;
}

/*是否在沙箱Documents文件夹下存在指定文件*/
- (BOOL)isExistsDocumentFile
{
    NSString *filePath = self.documentFilePath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:filePath];
}

/*转换为沙箱Library/Cache文件夹下的路径*/
- (NSString *)cacheFilePath
{
    NSString *tempPath = [self hasPrefix:@"Library/Caches/"] ? self : [NSString stringWithFormat:@"Library/Caches/%@", self];
    return [self hasPrefix:NSHomeDirectory()] ? self : [NSHomeDirectory() stringByAppendingPathComponent:tempPath];
}

/*是否为沙箱Library/Cache文件夹下的路径*/
- (BOOL)isCacheFilePath
{
    return [self hasPrefix:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/"]];
}

//非空字符串
- (NSString *)nonemptyString
{
    if (!self.length) {
        return @"";
    } else if ([self isEqualToString:@"<null>"]) {
        return @"";
    }
    return self;
}

/*去除空格、换行和\r\n*/
- (NSString *)trimmedString
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/*截取小于指定长度的子串，结尾处拼接"..."*/
- (NSString *)substringWithMaxLength:(NSUInteger)maxLength
{
    if (self.length > maxLength) {//内容多于阈值
        return [NSString stringWithFormat:@"%@...", [self substringToIndex:maxLength]];
    }
    return self;
}

/*编码GBK字符串，并处理常见URL特殊字符*/
- (NSString *)GBKEncodedString
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingGB_18030_2000));
}

/*编码UTF8字符串*/
- (NSString *)UTF8EncodedString
{
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString*)encodeURL
{
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

/*编码MD5字符串*/
- (NSString *)MD5EncodedString
{
    if (self.length == 0) return nil;
    
    const char *value = self.UTF8String;
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *encodedString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [encodedString appendFormat:@"%02x", outputBuffer[count]];
    }
    return encodedString;
}

/*转换为T9数字键盘对应的数字串*/
- (NSString *)numberString
{
	NSMutableString *numberString = [NSMutableString stringWithString:@""];
	for (NSInteger i = 0; i < self.length; i++) {
		switch ([self characterAtIndex:i]) {
			case '0':
				[numberString appendString:@"0"];
				break;
                
			case '1':
				[numberString appendString:@"1"];
				break;
                
			case 'a':case 'b':case 'c':case 'A':case 'B':case 'C':case '2':
				[numberString appendString:@"2"];
				break;
                
			case 'd':case 'e':case 'f':case 'D':case 'E':case 'F':case '3':
				[numberString appendString:@"3"];
				break;
                
			case 'g':case 'h':case 'i':case 'G':case 'H':case 'I':case '4':
				[numberString appendString:@"4"];
				break;
                
			case 'j':case 'k':case 'l':case 'J':case 'K':case 'L':case '5':
				[numberString appendString:@"5"];
				break;
                
			case 'm':case 'n':case 'o':case 'M':case 'N':case 'O':case '6':
				[numberString appendString:@"6"];
				break;
                
			case 'p':case 'q':case 'r':case 's':case 'P':case 'Q':case 'R':case 'S':case '7':
				[numberString appendString:@"7"];
				break;
                
			case 't':case 'u':case 'v':case 'T':case 'U':case 'V':case '8':
				[numberString appendString:@"8"];
				break;
                
			case 'w':case 'x':case 'y':case 'z':case 'W':case 'X':case 'Y':case 'Z':case '9':
				[numberString appendString:@"9"];
				break;
                
			default:
				break;
		}
	}
	return numberString;
}

///*转换为国际化字符串*/
//- (NSString *)international
//{
//    NSBundle* bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/zh-Hans.lproj",[[NSBundle mainBundle] bundlePath]]];
//    SFLanguage *lan = [DataCenter defaultCenter].config.currentLanguage;
//    NSString *language = lan.code;
//    if ([language isEqualToString:@"zh_TW"]) {
//        bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/zh-Hant.lproj",[[NSBundle mainBundle] bundlePath]]];
//    }
//    else if ([language isEqualToString:@"en_US"]) {
//        bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/en.lproj",[[NSBundle mainBundle] bundlePath]]];
//    }
//    else if ([language isEqualToString:@"zh_JP"]) {
//        bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/ja.lproj",[[NSBundle mainBundle] bundlePath]]];
//    }
//    else if ([language isEqualToString:@"zh_KR"]) {
//        bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/ko.lproj",[[NSBundle mainBundle] bundlePath]]];
//    }
//    
//    return [bundle localizedStringForKey:self value:@"" table:nil];
//}

/* 格式化手机号码
 对于非中国大陆的地区，号码中有可能出现一些符号，搜索时可做特殊处理
 1、排除号码中'-'、'('、')'和空格的干扰。
 2、字符'+'、'*'和'#'由用户输入决定，不用处理。
 3、字符','及';'不考虑。
 */
- (NSString *)formattedPhone
{
    NSString *formattedPhone = self.numberString;
    if ([formattedPhone hasPrefix:@"86"]) {
        formattedPhone = [formattedPhone substringFromIndex:2];
    } else if ([formattedPhone hasPrefix:@"086"]) {
        formattedPhone = [formattedPhone substringFromIndex:3];
    } else if ([formattedPhone hasPrefix:@"010"]) {
        formattedPhone = [formattedPhone substringFromIndex:3];
    }
    return formattedPhone;
}

/*是否为合法手机号(规则待完善)*/
- (BOOL)isValidPhone
{
    NSString *formattedPhone = self.formattedPhone;
   
    if ([formattedPhone hasPrefix:@"13"] || [formattedPhone hasPrefix:@"14"] || [formattedPhone hasPrefix:@"15"] || [formattedPhone hasPrefix:@"18"]) {
        return YES;
    }
    return NO;
}

/*是否为合法邮箱地址(规则待完善)*/
- (BOOL)isValidEmail
{
    NSRange matchRange = [self rangeOfString:@"@"];
    if (matchRange.length) {
        return YES;
    }
    return NO;
}

/*是否为一个图片路径*/
- (BOOL)isValidImageURL
{
    NSString *extension = [[self componentsSeparatedByString:@"."] lastObject];
    NSArray *imageExtensions = @[@"BMP", @"JPG", @"JPEG", @"PNG", @"GIF", @"PCX", @"TIFF", @"TGA", @"EXIF", @"FPX", @"SVG", @"CDR", @"PCD", @"DXF", @"UFO", @"EPS", @"HDRI", @"AI", @"RAW"];
    if ([imageExtensions containsObject:extension.uppercaseString]) {
        return YES;
    }
    return NO;
}

//是否为合法视频路径
- (BOOL)isValidVideoURL
{
    NSString *extension = [[self componentsSeparatedByString:@"."] lastObject];
    NSArray *imageExtensions = @[@"MOV", @"MP4", @"AVI", @"MKV", @"M4V", @"FLV", @"3G2", @"3GP", @"DV", @"VOB", @"DAT", @"MPE", @"MPEG", @"MPG", @"RMVB", @"RM", @"ASX", @"ASF", @"WMV"];
    if ([imageExtensions containsObject:extension.uppercaseString]) {
        return YES;
    }
    return NO;
}

//是否为合法音频路径
- (BOOL)isValidAudioURL
{
    NSString *extension = [[self componentsSeparatedByString:@"."] lastObject];
    NSArray *imageExtensions = @[@"AMR", @"MP3", @"WAV", @"WMA", @"CAF", @"MIDI"];
    if ([imageExtensions containsObject:extension.uppercaseString]) {
        return YES;
    }
    return NO;
}

//是否为合法用webview打开路径
- (BOOL)isValidBrowseURL
{
    NSString *extension = [[self componentsSeparatedByString:@"."] lastObject];
    NSArray *browseExtensions = @[@"DOCX", @"DOC"];
    if([self isValidWebURL])
    {
        if ([browseExtensions containsObject:extension.uppercaseString]) {
            return YES;
        }
    }
    
    return NO;
}


/*是否为合法web链接*/
- (BOOL)isValidWebURL
{
    NSURL *url = [NSURL URLWithString:self];
    return (url.scheme.length > 0);
    
    //    NSString *regexString = @"[a-zA-Z]+://[^\\s]+";
    //    return [self isMatchedByRegex:regexString];
}

//xss防护
-(NSString *)protectXssString
{
    NSMutableString * mStr = [[NSMutableString alloc] initWithString:self];
    [self clearMessageWithMessage:mStr string:@"<"];
    [self clearMessageWithMessage:mStr string:@">"];
    [self clearMessageWithMessage:mStr string:@"'"];
    [self clearMessageWithMessage:mStr string:@"/"];
    [self clearMessageWithMessage:mStr string:@"%"];
    return mStr;
}

-(void)clearMessageWithMessage:(NSMutableString *)message string:(NSString *)string
{
    NSRange range = [message rangeOfString:string];
    if (range.length >0)
    {
        [message replaceCharactersInRange:range withString:@""];
        [self clearMessageWithMessage:message string:string];
    }
}

@end
