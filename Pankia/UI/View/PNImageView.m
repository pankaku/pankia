//
//  PNImageView.mm
//  PankiaNet
//
//  Created by Kazuto Maruoka on 2/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNImageView.h"
#import "PankiaNetworkLibrary+Package.h"
#import "NSString+encode.h"

#import "PNUser.h"
#import "PNSocialServiceConnector.h"

#define kPNIconSizeWidth		36
#define kPNIconSizeHeight		36

@interface UIScreen (scale)
- (CGFloat)scale;
@end

@implementation PNImageView
@synthesize imageUrl;
@synthesize cachePath;
@synthesize data;
@synthesize conn;

- (void)awakeFromNib
{
	//nothing to do;
}

+(void)removeAllCaches
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* cacheDir = [documentsDirectory stringByAppendingPathComponent:@"caches"];
	NSDirectoryEnumerator *enume = [fileManager enumeratorAtPath:cacheDir];
	NSError* error;
	NSString *filename;
	while ((filename = [enume nextObject])) {
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		NSString* removePath = [NSString stringWithFormat:@"%@/%@", cacheDir, filename];
		
		[fileManager removeItemAtPath:removePath error:&error];
		
		[pool release];
	}
}

- (void)setDefaultSelfIcon
{
	[self setImage:[UIImage imageNamed:@"PNDefaultSelfIcon.png"]];
}
- (void)loadImageOfUser:(PNUser*)user{
	if (user.iconType == PNUserIconTypeTwitter) {
		PNSocialServiceConnector* connector = [[[PNSocialServiceConnector alloc] init] autorelease];
		connector.delegate = self;
		[connector getIconURLFromTwitterWithId:user.twitterId];
	}
}
- (void)loadImageOfFriend:(PNFriend*)user{
	if (user.iconType == PNUserIconTypeTwitter) {
		PNSocialServiceConnector* connector = [[[PNSocialServiceConnector alloc] init] autorelease];
		connector.delegate = self;
		[connector getIconURLFromTwitterWithId:user.twitterId];
	}
}
- (void)socialServiceConnectorDidReceiveTwitterIconURL:(NSString*)twitterIconURL
{
	[self loadImageWithUrl:twitterIconURL];
}

- (void)loadImageWithUrl:(NSString*)url
{
	[self abort];
	self.imageUrl = url;
	self.data = [[[NSMutableData alloc] initWithCapacity:0] autorelease];
		
	if ([url rangeOfString:kPNDefaultImageName options:NSBackwardsSearch].location != NSNotFound) {
		PNCLog(PNLOG_CAT_UI, @"self.image: %x", self.image);
		return;
	}
		
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* cacheDir = [documentsDirectory stringByAppendingPathComponent:@"caches"];

	PNCLog(PNLOG_CAT_UI, @"cacheDir:%@",cacheDir);

	BOOL success = [fileManager fileExistsAtPath:cacheDir];
	if (!success)
	{
		success = [fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
	}
		
	NSString* encodeUrl = [url encodeEscape]; 
							
	PNCLog(PNLOG_CAT_UI, @"encodeUrl:%@",encodeUrl);

	self.cachePath = [NSString stringWithFormat:@"%@/%@",cacheDir,encodeUrl];
	
	PNCLog(PNLOG_CAT_UI, @"cachePath:%@",self.cachePath);

	BOOL isCachAvaiable = [fileManager fileExistsAtPath:cachePath];

	if(!isCachAvaiable || url == nil || [url isEqualToString:@""]) {
		PNCLog(PNLOG_CAT_UI, @"No caches found.");
		if (url) {
			PNCLog(PNLOG_CAT_UI, @"Url:%@", url);
			NSURLRequest *req = [NSURLRequest 
								 requestWithURL:[NSURL URLWithString:url] 
								 cachePolicy:NSURLRequestUseProtocolCachePolicy
								 timeoutInterval:30.0];
			self.conn = [[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];			
			PNCLog(PNLOG_CAT_UI, @"Download image from web.");
		}
		//when not exist cache and not reachable internet, show defualt image on xib. 
	}
	else {
		UIImage *img = [UIImage imageWithContentsOfFile:cachePath];
		[self setImage:[self roundCorners:img width:kPNIconSizeWidth height:kPNIconSizeHeight]];
		PNCLog(PNLOG_CAT_UI, @"img.size.width:%f img.size.height:%f",img.size.width,img.size.height);
		self.hidden = false;
	}

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	PNCLog(PNLOG_CAT_UI, @"connection didRecieveResponse");
	[self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)nsdata{
	PNCLog(PNLOG_CAT_UI, @"connection didReceiveData len=%d", [nsdata length]);
	[self.data appendData:nsdata];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[self abort];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	PNCLog(PNLOG_CAT_UI, @"connection connectionDidFinishLoading");	
	self.contentMode = UIViewContentModeScaleAspectFit;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth || UIViewAutoresizingFlexibleHeight;		
	
	UIImage* img = [self roundCorners:[UIImage imageWithData:data] width:kPNIconSizeWidth height:kPNIconSizeHeight];
	
	PNCLog(PNLOG_CAT_UI, @"imageUrl2::%@",self.imageUrl);
	PNCLog(PNLOG_CAT_UI, @"cachePath2::%@",self.cachePath);

	if([self.imageUrl rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound)
	{
		[UIImagePNGRepresentation(img) writeToFile:cachePath atomically:YES];
	}
	else if(
			[self.imageUrl rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound || 
			[self.imageUrl rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound
			)
	{
		[UIImageJPEGRepresentation(img, 100) writeToFile:cachePath atomically:YES];
	}

	self.image = img;

	[self abort];
}

-(void)abort{
	if(self.conn != nil){
		[self.conn cancel];
		self.conn = nil;
	}
	self.data		= nil;
	self.cachePath	= nil;
	self.imageUrl	= nil;
}


static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (UIImage *)roundCorners:(UIImage*)img width:(int)imageWidth height:(int)imageHeight
{
	
	CGFloat scale = 1.0f;
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		scale = [[UIScreen mainScreen] scale];
	}
	
	int w = imageWidth * scale;
    int h = imageHeight * scale;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, w, h);
	int oval = 5 * scale;
    addRoundedRectToPath(context, rect, oval, oval);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
		return [UIImage imageWithCGImage:imageMasked scale:scale orientation:UIImageOrientationUp];
	} else {
		return [UIImage imageWithCGImage:imageMasked];
	}
}


- (void)dealloc
{
	if(self.conn != nil){
		[self.conn cancel];
		self.conn		= nil;
	}
	self.data		= nil;
	self.cachePath	= nil;
	self.imageUrl	= nil;
	
	[super dealloc];

}

@end
