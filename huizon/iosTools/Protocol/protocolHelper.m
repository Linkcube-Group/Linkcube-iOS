//
//  protocolHelper.m
//  huizon
//
//  Created by Yang on 13-11-8.
//  Copyright (c) 2013年 zhaopin. All rights reserved.
//

#import "protocolHelper.h"
#import "iosTools.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation protocolHelper


static Byte iv[] = {1,2,3,4,5,6,7,8};

+ (NSString *)encryptUseDES:(NSString *)plainText WithKey:(NSString *)key
{
    
    NSString *ciphertext = nil;
    const char *textBytes = [plainText UTF8String];
    NSUInteger dataLength = [plainText length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithm3DES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [key UTF8String], kCCKeySize3DES,
                                          iv,
                                          textBytes, dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        
        ciphertext = [data base64EncodedString];
    }
    if (ciphertext==nil) {
        return @"";
    }
    return ciphertext;
    
}

+ (NSString *)URLEncodedString:(NSString *)aUrl
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)aUrl,
                                                                           NULL,
                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8));
    if (result) {
        return result;
    }
    return @"";
    
    
}

@end
