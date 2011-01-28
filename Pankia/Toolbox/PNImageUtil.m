//
//  PNImageUtil.m
//  PankakuNet
//
//  Created by pankaku on 10/08/05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNImageUtil.h"
#import "NSString+encode.h"

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

@interface PNImageFileDownloader : NSObject
{
	NSURLConnection*			conn;
	NSMutableData*				data;
	NSString*					imageUrl;
}
@property (retain) NSURLConnection*	conn;
@property (retain) NSMutableData*	data;
@property (retain) NSString*		imageUrl;
- (void)start;
@end

@implementation PNImageFileDownloader
@synthesize conn, data, imageUrl;
- (void)start
{
	NSURLRequest *req = [NSURLRequest 
						 requestWithURL:[NSURL URLWithString:self.imageUrl] 
						 cachePolicy:NSURLRequestUseProtocolCachePolicy
						 timeoutInterval:30.0];
	self.data = [[[NSMutableData alloc] initWithCapacity:0] autorelease];
	self.conn = [[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	[self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)nsdata{
	[self.data appendData:nsdata];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[self autorelease];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSString* cachePath = [PNImageUtil cacheFilePathForURL:self.imageUrl];
	UIImage *img = [UIImage imageWithData:data];
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
	} else{
		[UIImagePNGRepresentation(img) writeToFile:cachePath atomically:YES];
	}
	[self autorelease];	
}
- (void)dealloc
{
	self.conn = nil;
	self.imageUrl = nil;
	self.data = nil;
	[super dealloc];
}
@end



@implementation PNImageUtil

#pragma mark Private methods
+ (NSString*)cacheDirectoryPath
{
	// キャッシュ用のディレクトリのパスを生成します
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* cacheDir = [documentsDirectory stringByAppendingPathComponent:@"caches"];
	
	BOOL success = [fileManager fileExistsAtPath:cacheDir];
	if (!success)
	{
		[fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	
	return cacheDir;
}
+ (NSString*)cacheFilePathForURL:(NSString*)url
{
	NSString* cacheDir = [self cacheDirectoryPath];
	NSString* encodeUrl = [url encodeEscape]; 
	return [NSString stringWithFormat:@"%@/%@",cacheDir,encodeUrl];
}
#pragma mark Public methods
+ (UIImage*)roundCorneredImage:(UIImage*)sourceImage width:(float)width height:(float)height
{
	int w = (int)round(width) * [UIScreen mainScreen].scale;
    int h = (int)round(height) * [UIScreen mainScreen].scale;
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, width * [UIScreen mainScreen].scale, height * [UIScreen mainScreen].scale);
    addRoundedRectToPath(context, rect, 5 * [UIScreen mainScreen].scale, 5 * [UIScreen mainScreen].scale);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), sourceImage.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
	UIImage* image;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
		image = [UIImage imageWithCGImage:imageMasked scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    } else {
		image = [UIImage imageWithCGImage:imageMasked];
	}
	return image;
}
+ (UIImage*)imageWithPadding:(UIImage*)sourceImage left:(float)left top:(float)top right:(float)right bottom:(float)bottom
{
	return [self imageWithPadding:sourceImage left:left top:top right:right bottom:bottom width:sourceImage.size.width height:sourceImage.size.height];
}

+ (UIImage*)imageWithPadding:(UIImage*)sourceImage left:(float)left top:(float)top right:(float)right bottom:(float)bottom width:(float)width height:(float)height
{
	int w = (int)round(width + left + right) * [UIScreen mainScreen].scale;
    int h = (int)round(height + top + bottom) * [UIScreen mainScreen].scale;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
	CGContextBeginPath(context);
    CGRect rect = CGRectMake(left * [UIScreen mainScreen].scale, top * [UIScreen mainScreen].scale, width * [UIScreen mainScreen].scale, height * [UIScreen mainScreen].scale);
    addRoundedRectToPath(context, rect, 5 * [UIScreen mainScreen].scale, 5 * [UIScreen mainScreen].scale);
    CGContextClosePath(context);
    CGContextClip(context);
	
    CGContextDrawImage(context, CGRectMake(left * [UIScreen mainScreen].scale, top * [UIScreen mainScreen].scale, width * [UIScreen mainScreen].scale, height * [UIScreen mainScreen].scale), sourceImage.CGImage);
    
    CGImageRef imageWithPadding = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	
	UIImage* image;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
		image = [UIImage imageWithCGImage:imageWithPadding scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    } else {
		image = [UIImage imageWithCGImage:imageWithPadding];
	}
	return image;
}

+ (BOOL)hasCacheForUrl:(NSString*)url
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:[self cacheFilePathForURL:url]];
}

+ (void)createCacheForUrl:(NSString *)url
{
	// ダウンローダはダウンロードが完了／失敗すると自動的に解放されます
	PNImageFileDownloader* downloader = [[PNImageFileDownloader alloc] init];
	downloader.imageUrl = url;
	[downloader start];
}
@end
