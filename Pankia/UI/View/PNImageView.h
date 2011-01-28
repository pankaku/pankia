
#define kPNDefaultImageName	@"missing.png"

@class PNUser;
@class PNFriend;
/**
 @brief キャッシュ有り画像のクラスです。
 
 指定されたURLから非同期に画像を取得、表示します。
 同時にキャッシュも行います。
 */
@interface PNImageView : UIImageView {
	NSURLConnection*			conn;
	NSMutableData*				data;
	NSString*					cachePath;
	NSString*					imageUrl;
}

@property (retain) NSURLConnection*	conn;
@property (retain) NSMutableData*	data;
@property (retain) NSString*		cachePath;
@property (retain) NSString*		imageUrl;

/**
 *	@brief urlを元に画像を取得します。
 */
-(void)loadImageWithUrl:(NSString*)url;

- (void)loadImageOfUser:(PNUser*)user;
- (void)loadImageOfFriend:(PNFriend*)user;
/**
 *	@brief Defaultで表示される画像をセットします。
 */
-(void)setDefaultSelfIcon;

/**
 *	@brief キャッシュを全て削除します。
 */
+(void)removeAllCaches;

/**
 *	@brief URLからの画像取得処理を中断します。
 */
-(void)abort;

/**
 *	@brief UIImageの角を丸めます。
 * @return 角丸の画像を返す。
 */
- (UIImage *)roundCorners:(UIImage*)img width:(int)imageWidth height:(int)imageHeight;

@end
