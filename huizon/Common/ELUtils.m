//
//  ELUtils.m
//  ELBooks
//
//  Created by Eric on 12-8-25.
//  Copyright 2012 zhaopin. All rights reserved.
//

#import "ELUtils.h"
#import "CustomAlertView.h"
#import <sys/sysctl.h>


NSUInteger DeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion]
                                       componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    
    return _deviceSystemMajorVersion;
}




void showCustomAlertMessage(NSString *message)
{
    if (message==nil || [message length]<1) {
        return;
    }
    CustomAlertView *customAlartView = (CustomAlertView *)[theApp.window viewWithTag:980153];
    if (customAlartView) {
        [customAlartView removeFromSuperview];
        customAlartView = nil;
    }
    customAlartView = [[CustomAlertView alloc] initWithFrame:CGRectMake(80, (460 - 120) / 2, 161, 78)] ;
    customAlartView.titleLabel.text = message;
    customAlartView.tag = 980153;
    
    [theApp.window addSubview: customAlartView];
//    [customAlartView release];
}

void showFullScreen(BOOL flag)
{
    theApp.window.userInteractionEnabled = !flag;
}

void showIndicator(BOOL flag)
{
    UIView *activityView = (UIView *)[theApp.window viewWithTag:70021];
    if (flag) {
        if (activityView==nil) {
            activityView = [[UIView alloc] initWithFrame:CGRectMake(110, 120, 100, 100)];
            activityView.tag = 70021;
            activityView.backgroundColor = [UIColor clearColor];
            [activityView.layer setContents:(id)[[UIImage imageNamed:@"incativy.png"] CGImage]];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(3, 65, 95, 32)];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"努力加载中…";
            label.numberOfLines = 0;
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            [activityView addSubview:label];
//            [label release];
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityIndicator.frame = CGRectMake(9, 3, 20, 20); //26 = 32-3x2
            [activityView addSubview:activityIndicator];
            activityIndicator.tag = 794232;
            
            activityIndicator.center = CGPointMake(50,40);
            [activityIndicator startAnimating];
            activityView.center = theApp.window.center;
            
            [theApp.window addSubview:activityView];
//            [activityIndicator release];
//            [activityView release];
        }
        
    }
    else{
        if (activityView && [activityView superview]) {
            UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[activityView viewWithTag:794232];
            if (activityIndicator) {
                [activityIndicator stopAnimating];
            }
            [activityView removeFromSuperview];
        }
    }
    
}




//限制字数
float getTextLength(NSString *text)
{
    
    float num = 0;
    for (int i =0; i<[text length]; i++) {
        
        NSRange  range = {i,1};
        
        NSString  *str = [text substringWithRange:range];
        
        if (![str isEqualToString:@""] || str != nil)
        {
            int  charLenth = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            if (charLenth == 3) {
                num += 1;
            }
            if (charLenth == 1) {
                num += 0.5;
            }
        }
        else
        {
            num += 0.5;
        }
    }
    return num;
}


/*
 函数名:   IsValidEmail
 作者:     eric
 创建日期:  2012年8月10日
 描述:     用于判断主流邮箱的校验.若返回nil合法邮箱，否则不合法。
 */
NSString* IsValidEmail(const char* pszEmail)
{
    if(pszEmail == NULL)
    {
        return @"请输入邮箱";
    }
    int iAtPos = 0;
    //int iLastDotPos = 0;
    int i = 0;
    int iAtTimes = 0;
    while(*(pszEmail + i) != '\0')
    {
        char ch = *(pszEmail + i);
        if(!isprint(ch) || isspace(ch) || ch==',' || ch=='\'')  //空格和控制字符是非法的，限制得还比较宽松
        {
            iAtTimes = 0;
            break;
        }
        if(ch == '@')
        {
            iAtPos = i;
            iAtTimes++;
        }
        else if(ch == '.')
        {
            //iLastDotPos = i;
        }
        i++;
    }
    if (i<1) {
        return @"请输入邮箱";
    }
    else if(i > 64)//对@以及域名依靠位置来判断，限制长度为64
    {
        return @"邮箱的总长度不能超过64位";
    }
    else if(iAtPos < 1)//@不存在
    {
        return @"邮箱的格式错误";
    }
    /*else if((iLastDotPos - 2) < iAtPos) //@与.之间的之间间隔
     {
     return @"邮箱的格式错误";
     }
     else if((i - iLastDotPos) < 3)  //.后面的字符限制
     {
     return @"邮箱的格式错误";
     }
     else if((i - iLastDotPos) > 5)  //.后面的字符限制
     {
     return @"邮箱的格式错误";
     }*/
    else if(iAtTimes > 1)   //@个数大于1个
    {
        return @"邮箱格式错误，请重新输入";
    }
    else if(iAtTimes == 0)  //@没有出现
    {
        return @"邮箱中存在非法的或不可控制的字符";
    }
    return nil;
}

/*
 函数名:   IsValidMobeilTel
 作者:     eric
 创建日期:  2012年8月10日
 描述:     用于判断目前中华人民共和国三大运营商的手机号码合法性校验，若返回0，1，2表示合法，否则不合法
 */
NSString* IsValidMobeilTel(const char* pszTel)
{
    NSString* tyle = @"-1";
    int len = strlen(pszTel);
    
    if(pszTel == NULL || len<1)
    {
        return @"请填写手机号";
    }
    
    
    if(len != 11)
    {
        return @"手机号码的长度不合要求";
    }
    int i = 0;
    while (i < len)
    {
        if(!isdigit(pszTel[i]))
        {
            return @"手机号码中包含不合法的数字";
        }
        
        if(i == 0)
        {
            if(pszTel[i] != '1')
            {
                return @"手机号码格式不合要求";
            }
        }
        else if(i == 1)
        {
            if(pszTel[i] != '3' && pszTel[i] != '4' && pszTel[i] != '5' && pszTel[i] != '8')
            {
                return @"手机号码格式不合要求";
            }
        }
        else if(i == 2)
        {
            if(( pszTel[i-1] == '3' && (pszTel[i] == '0' || pszTel[i] == '1' || pszTel[i] == '2')) ||
               (pszTel[i-1] == '4' && pszTel[i] == '5') ||
               (pszTel[i-1] == '5' && (pszTel[i] == '5' || pszTel[i] == '6'))||
               (pszTel[i-1] == '8' && (pszTel[i] == '5' || pszTel[i] == '6')))
            {
                tyle = @"0";
            }
            else if((pszTel[i-1] == '3' && (pszTel[i] == '4' || pszTel[i] == '5' || pszTel[i] == '6' || pszTel[i] == '7' || pszTel[i] == '8' || pszTel[i] == '9')) ||
                    (pszTel[i-1] == '4' && pszTel[i] == '7') ||
                    (pszTel[i-1] == '5' && (pszTel[i] == '0' || pszTel[i] == '1' || pszTel[i] == '2' || pszTel[i] == '7' || pszTel[i] == '8' || pszTel[i] == '9'))||
                    (pszTel[i-1] == '8' && (pszTel[i] == '2' || pszTel[i] == '3' || pszTel[i] == '7' || pszTel[i] == '8')))
            {
                tyle = @"1";
            }
            else if((pszTel[i-1] == '3' && pszTel[i] == '3') ||
                    (pszTel[i-1] == '5' && pszTel[i] == '3') ||
                    (pszTel[i-1] == '8' && (pszTel[i] == '9' || pszTel[i] == '0')))
            {
                tyle = @"2";
            }
            else
            {
                return @"手机号码不存在该号段.";
            }
        }
        i++;
    }
    return tyle;
}
NSString* IsValidPWD(const char* passWord)
{
    if(passWord == NULL)
    {
        return @"请输入密码";
    }
    int i = 0;
    
    while(*(passWord + i) != '\0')
    {
        char ch = *(passWord + i);
        if(!isdigit(ch) && !isalnum(ch) && ch!='_')
        {
            return @"6-25位的字母、数字或下划线";
        }
        i++;
    }
    return nil;
}





