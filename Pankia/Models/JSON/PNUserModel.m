#import "PNUserModel.h"
#import "PNRelationshipModel.h"

//User
#define kPNDefaultUsername					@""
#define kPNDefaultFullName					@""
#define kPNDefaultCountry					@"--"
#define kPNDefaultIconURL					@""
#define kPNDefaultTwitterID					@""
#define kPNIsGuest							YES
#define PNIsSecured							NO
#define kPNIsFollowing						NO
#define kPNIsBlocking						NO

@implementation PNUserModel
@synthesize id = _id, username = _username, fullname = _fullname, country = _country, icon_url = _icon_url;
@synthesize install = _install;
@synthesize twitter = _twitter;
// BEGIN - lerry added code
@synthesize facebook = _facebook;
// END - lerry added code
@synthesize is_guest = _is_guest, is_secured = _is_secured, twitter_id = _twitter_id;
@synthesize is_following = _is_following, relationships = _relationships, installs = _installs, is_blocking = _is_blocking;
@synthesize icon_used;
@synthesize externalId;

- (id) init
{
	if (self = [super init]) {
		// 注意
		// self.でプロパティを設けているのであればプロパティを介して代入をしてください。
		// _country = @"";等すると、retainされず自前解放とオートリリースプールで二重解放が起こるので危険。
		// 後、クラスの組み立ての基礎概念で、継承関係にあるクラスを考慮し、
		// [super init](スーパークラスのコンストラクタ) -> 自分の処理.
		// 自分の処理. -> [super dealloc](スーパークラスのデストラクタ)
		// のようにスタック構造を必ず守る事。
		// クラスは、根底クラスー＞派生クラスという順番に作られるので、破棄される時も、派生クラスの破棄ー＞根底クラスの破棄
		// という処理にしなければならない。
		// あとNSStringクラスやNSMutableArray等オートリリースプール前提で作られているものと混同して使うことを想定して、
		// 出来うる限り、[[[Object alloc] init] autorelease]で管理するように。
		
		
		self.id = -1;
		self.username = kPNDefaultUsername;
		self.fullname = kPNDefaultFullName;
		self.country = kPNDefaultCountry;
		self.icon_url = kPNDefaultIconURL;
		self.install = nil;
		self.twitter = nil;
		// BEGIN - lerry added code
		self.facebook = nil;
		// END - lerry added code
		self.installs = [NSArray array];
		self.relationships = [NSArray array];
		self.is_guest = kPNIsGuest;
		self.is_secured = PNIsSecured;
		self.is_following = kPNIsFollowing;
		self.is_blocking = NO;
		self.icon_used = @"DEFAULT";
	}
	return self;
}


- (id)initWithDictionary:(NSDictionary *)aDictionary
{
	if (self = [self init]) {
		self.id = [[aDictionary objectForKey:@"id"] intValue];
		self.username = [aDictionary stringValueForKey:@"username" defaultValue:kPNDefaultUsername];
		self.fullname = [aDictionary stringValueForKey:@"fullname" defaultValue:kPNDefaultFullName];
		self.country = [aDictionary stringValueForKey:@"country" defaultValue:kPNDefaultCountry];
		self.icon_url = [aDictionary stringValueForKey:@"icon_url" defaultValue:kPNDefaultIconURL];
		self.is_guest = [aDictionary boolValueForKey:@"is_guest" defaultValue:kPNIsGuest];
		self.is_secured = [aDictionary boolValueForKey:@"is_secured" defaultValue:PNIsSecured];
		self.is_following = [aDictionary boolValueForKey:@"is_following" defaultValue:kPNIsFollowing];
		self.is_blocking = [aDictionary boolValueForKey:@"is_blocking" defaultValue:kPNIsBlocking];
		self.externalId = [aDictionary stringValueForKey:@"external_id" defaultValue:@""];
		
		if ([aDictionary hasObjectForKey:@"enrollment"]) {
			self.install = [[[PNInstallModel alloc] initWithDictionary:[aDictionary objectForKey:@"enrollment"]] autorelease];
		}
		if ([aDictionary hasObjectForKey:@"twitter"]) {
			self.twitter = [[[PNTwitterModel alloc] initWithDictionary:[aDictionary objectForKey:@"twitter"]] autorelease];
		}
		// BEGIN - lerry added code
		if ([aDictionary hasObjectForKey:@"facebook"]) {
			self.facebook = [PNFacebookAccountModel dataModelWithDictionary:[aDictionary objectForKey:@"facebook"]];
		}
		// END - lerry added code
		if ([aDictionary hasObjectForKey:@"relationships"]) {
			self.relationships = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
			for (NSDictionary *relationship in [aDictionary objectForKey:@"relationships"]) {
				[(NSMutableArray*)self.relationships addObject:
				 [[[PNRelationshipModel alloc] initWithDictionary:relationship] autorelease]];
			}
		}
		if ([aDictionary hasObjectForKey:@"enrollments"]) {
			self.installs = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
			for (NSDictionary *install in [aDictionary objectForKey:@"enrollments"]) {
				[(NSMutableArray*)self.installs addObject:
				 [[[PNInstallModel alloc] initWithDictionary:install] autorelease] ];
			}
		}
		self.icon_used = [aDictionary stringValueForKey:@"icon_used" defaultValue:@"DEFAULT"];
	}
	PNCLog(PNLOG_CAT_MODEL_PARSER, @"DATAMODEL-PARSE\n%@", self);	// FOR DEBUG
	return self;
}

- (void)dealloc
{
	// 注意
	// プログラムが動くスタック構造に合わせてdeallocを呼ぶ必要がある。
	// サブクラスの終了処理の前にdeallocを書くべきではない。
	// また、極力releaseは書かずretainの解放に頼るのがベスト。
	// でないと前に記述されたプログラムだと、自前で解放＋オートリリースされ二重解放されるため危険。
	self.username		= nil;
	self.fullname		= nil;
	self.country		= nil;
	self.icon_url		= nil;
	self.install		= nil;
	self.twitter        = nil;
	// BEGIN - lerry added code
	self.facebook		= nil;
	// END - lerry added code
	self.installs		= nil;
	self.relationships	= nil;
	self.twitter_id		= nil;
	self.icon_used		= nil;
	[super dealloc]; //必ず最後に書く事。
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<%@ :%p>\n id: %d\n username: %@\n fullname: %@\n country:%@\n icon_url:%@\n twitter_id:%@\n is_guest:%d\n is_secured:%d\n is_following:%d\n is_blocking:%d\n install:%p\n installs:%p\n relationships:%p",
			NSStringFromClass([self class]),self,_id, _username, _fullname, _country, _icon_url, _twitter_id, _is_guest, _is_secured, _is_following, _is_blocking, _install, _installs, _relationships];
}

@end
