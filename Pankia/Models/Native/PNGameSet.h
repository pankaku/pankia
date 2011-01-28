
@interface PNGameSet : NSObject {
	NSMutableDictionary* pointmap;
	NSMutableDictionary* scoremap;
}

-(void)setGradePoint:(NSString*)aUsername point:(int)aPoint;
-(void)setMatchScore:(NSString*)aUsername score:(int)score;
+(PNGameSet*)gameSet;

@property(readonly) NSDictionary* pointmap;
@property(readonly) NSDictionary* scoremap;
@end
