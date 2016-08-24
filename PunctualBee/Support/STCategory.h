//
//  STCategory.h
//  SvpplyTable
//
//  Created by Anonymous on 13-8-13.
//  Copyright (c) 2013年 Minqian Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface STCategory : NSObject
{
  NSString* name;
	NSString* URLString;
	NSString* colorHex;
	NSString* borderColorHex;
  NSString* uid;
  CLLocationDegrees longitude;
  CLLocationDegrees latitude;
}

@property(strong, nonatomic) NSString* borderColorHex;
@property(strong, nonatomic) NSString* colorHex;
@property(strong, nonatomic) NSString* URLString;
@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic) NSString* uid;
@property(assign, nonatomic) CLLocationDegrees longitude;
@property(assign, nonatomic) CLLocationDegrees latitude;

-(id)initWithJSON:(id)json;

@end
