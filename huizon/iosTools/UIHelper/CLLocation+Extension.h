//
//  CLLocation+Extension.h
//  iOSShare
//
//  Created by wujin on 13-6-23.
//  Copyright (c) 2013年 wujin. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "JSONKit.h"
#import <math.h>

@interface CLLocation (Extension)

@end


UIKIT_STATIC_INLINE CLLocationDistance CLLocationDistanceBetweenLocation(CLLocationCoordinate2D loc1,CLLocationCoordinate2D loc2)
{
    CLLocationDegrees lat1=loc1.latitude,lat2=loc2.latitude,lon1=loc1.longitude,lon2=loc2.longitude;
    double er = 6378137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double radlat1 = M_PI*lat1/180.0f;
    double radlat2 = M_PI*lat2/180.0f;
    //now long.
    double radlong1 = M_PI*lon1/180.0f;
    double radlong2 = M_PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = M_PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = M_PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = M_PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = M_PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = M_PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = M_PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    return dist;
}

UIKIT_STATIC_INLINE NSString *NSStringFromCLLocationCoordinate2D(CLLocationCoordinate2D coordinate)
{
    return [NSString stringWithFormat:@"{\"lat\":%f,\"lng\":%f}",coordinate.latitude,coordinate.longitude];
}

UIKIT_STATIC_INLINE CLLocationCoordinate2D CLLocationCoordinate2DFromString(NSString* string)
{
    if ([string respondsToSelector:@selector(objectFromJSONString)]) {
        NSDictionary *dic=[string performSelector:@selector(objectFromJSONString)];
        
        return CLLocationCoordinate2DMake([[dic objectForKey:@"lat"] doubleValue], [[dic objectForKey:@"lng"] doubleValue]);
    }
    NSLog(@"error string");
    return CLLocationCoordinate2DMake(0, 0);
}