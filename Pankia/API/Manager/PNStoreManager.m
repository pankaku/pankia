//
//  PNStoreManager.m
//  PankakuNet
//
//  Created by sota on 10/08/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PNStoreManager.h"

#import "PNGameManager.h"
#import "PNStoreObserver.h"
#import "PNRequestKeyManager.h"
#import "NSObject+PostEvent.h"
#import "PNStoreRequestHelper.h"
#import "PNLogger+Package.h"
#import "PNItemOwnershipModel.h"
#import "PNMerchandiseModel.h"
#import "JsonHelper.h"
#import "NSData+Base64.h"
#import "PNPurchaseModel.h"
#import "PNItemCategory.h"
#import "PNSettingManager.h"
#import "PNItemManager.h"
#import "PNItemHistory.h"
#import "PNArchiveManager.h"
#import "PNSKProduct.h"
#import "PNMerchandise.h"
#import "PNError.h"
#import "PNItem.h"
#import "PNUser.h"
#import "PNUser+Package.h"
#import "PNGlobalManager.h"

static PNStoreManager* _sharedInstance;

@interface PNStoreManager ()

@property (nonatomic, retain) NSString* currentRequestKey;
@property (nonatomic, retain) SKProduct* currentProduct;
@property (nonatomic, retain) NSMutableDictionary* merchandiseDetails;// Merchandise一覧のキャッシュ
@property (nonatomic, retain) NSDate* initializedDate;
- (void)createCacheOfAppStore:(NSArray*)merchandises;
- (void)checkPurchasable:(PNSKProduct*)product onPurchasable:(void (^)())onPurchasable onNot:(void (^)(PNError* error))onNot;
@end

@implementation PNStoreManager
@synthesize currentRequestKey, currentProduct, merchandiseDetails;
@synthesize productDetails, initializedDate;

- (void)setCurrentRequestKey:(NSString *)value
{
	if (currentRequestKey != nil) {
		[currentRequestKey release];
		currentRequestKey = nil;
	}
	currentRequestKey = [value retain];
}

- (void)createCache
{
	[self createCacheOfAppStore:[[PNGameManager sharedObject] merchandises]];
}
- (void)createCacheOfAppStore:(NSArray*)merchandises
{
	PNCLog(PNLOG_CAT_STORE, @"createCacheOfAppStore");
	
	NSMutableArray *productIdentifiers = [NSMutableArray array];
	for (PNMerchandise* merchandise in merchandises) {
		[productIdentifiers addObject:merchandise.productIdentifier];
	}
	[self getDetailOfProducts:productIdentifiers delegate:self onSucceeded:@selector(createCacheSucceeded:)
					 onFailed:nil];
}
- (void)createCacheSucceeded:(NSArray*)products
{
	PNCLog(PNLOG_CAT_STORE, @"createCacheOK");
}

/**
 @brief Returns whether product is purchasable or not.
 
 If there are no merchandises and items related with the product, or use hasn't enough space for new purchase (=maxed out) this returns NO.
 */
- (void)checkPurchasable:(PNSKProduct*)product onPurchasable:(void (^)())onPurchasable onNot:(void (^)(PNError* error))onNot
{
	PNMerchandise* merchandise = [self merchandiseWithProductIdentifier:product.productIdentifier];
	if (merchandise != nil) {	// Check if a merchandise with the product identifier exists.
		PNItem* item = merchandise.item;
		if (item != nil) {	// Check if an item for the merchandise exists.
			[[PNItemManager sharedObject] getItemOwnershipsFromServerWithOnSuccess:^(NSDictionary *ownerships) {
				PNItemOwnershipModel* ownership = [ownerships objectForKey:[NSString stringWithFormat:@"%d", item.id]];
				if (ownership) {
					if (ownership.quantity + merchandise.multiple > item.maxQuantity) {
						onNot([PNError errorWithCode:kPNPurchaseErrorWillBeMaxedOut
											 message:[NSString stringWithFormat:@"will_be_maxed_out"]]);
						return;
					}
				}
				// There seems to be no problem. Go ahead.
				onPurchasable();
			} onFailure:onNot];
		} else {
			onNot([PNError errorWithCode:kPNPurchaseErrorItemNotFound 
								 message:[NSString stringWithFormat:@"not_found: %@", product.productIdentifier]]);
		}
	} else {
		onNot([PNError errorWithCode:kPNPurchaseErrorMerchandiseNotFound
							 message:[NSString stringWithFormat:@"not_found: %@", product.productIdentifier]]);
	}
}

#pragma mark -
- (void)purchaseWithProductIdentifier:(NSString*)productIdentifier onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	if(![SKPaymentQueue canMakePayments]) {	// You don't have privilege for in app purchase! Check [Settings] of your iPhone!
		onFailure([PNError errorWithCode:kPNPurchaseErrorCannotMakePayments message:@"cannot_make_payments"]);
		return;
	}
	
	// Check product detail in the app store
	PNSKProduct* product = [self productWithProductIdentifier:productIdentifier];
	if (product != nil) {
		// Check purchasable or not.
		[self checkPurchasable:product onPurchasable:^() {
			// Create payment request. Then purchase.
			[[PNStoreObserver sharedObject] purchase:productIdentifier onSuccess:onSuccess onFailure:onFailure];
		} onNot:onFailure];
	} else {
		onFailure([PNError errorWithCode:kPNPurchaseErrorProductNotFoundInTheAppStore 
								 message:[NSString stringWithFormat:@"not_found: %@", productIdentifier]]);
	}
}

#pragma mark -
- (void)getPurchaseHistoryWithDelegate:(id)delegate onSucceeded:(SEL)onSucceededSelector
							  onFailed:(SEL)onFailedSelector
{
	NSString* requestKey = [PNRequestKeyManager registerDelegate:delegate onSucceededSelector:onSucceededSelector onFailedSelector:onFailedSelector];
	[PNStoreRequestHelper getPurchaseHistoryWithOffset:0 limit:50 delegate:self selector:@selector(getPurchaseHistoryResponse:) requestKey:requestKey];
	
}

#pragma mark -

- (NSString*)transactionStoreKeyWithProductIdentifier:(NSString*)productIdentifier
{
//	return [NSString stringWithFormat:@"PaymentTransaction-%@", productIdentifier];
	return @"PaymentTransaction";	// Changed. Don't be aware of product identifier.
}
- (void)saveTransactionWasCleared
{
	PNCLog(PNLOG_CAT_STORE, @"saveTransactionWasCleared");
	NSString* transactionStoreKey = [self transactionStoreKeyWithProductIdentifier:@""];
	[PNSettingManager storeBoolValue:NO forKey:transactionStoreKey];
}
#pragma mark -
- (void)getDetailOfProductsSucceeded:(NSArray*)products
{
	PNCLog(PNLOG_CAT_STORE, @"getDetailOfProductsSucceeded:%@", products);
	// キャッシュします
	for (SKProduct* product in products) {
		[productDetails setObject:[PNSKProduct productFromSKProduct:product] forKey:product.productIdentifier];
	}
	[PNArchiveManager archiveObject:productDetails toFile:@"skproducts.plist"];
	
	NSString* requestKey = self.currentRequestKey;
	[PNRequestKeyManager callOnSucceededSelectorAndRemove:requestKey withObject:products];
}
- (void)getDetailOfProductFailed:(PNError*)error
{
	PNCLog(PNLOG_CAT_STORE, @"getDetailOfProductFailed:");
	// 失敗したことを通知します
	[PNRequestKeyManager callOnFailedSelectorAndRemove:self.currentRequestKey withObject:error];
}
#pragma mark -

- (void)checkIfTransactionRestored
{
	if (!isPaymentCompleted) {
		PNError* error = [[[PNError alloc] init] autorelease];
        error.errorCode = kPNPurchaseErrorTransactionNotRestored;
		[PNRequestKeyManager callOnFailedSelectorAndRemove:self.currentRequestKey withObject:error];
		self.currentRequestKey = nil;
	}
}
#pragma mark -
- (void)registerSucceeded:(NSDictionary*)result
{
	PNItemOwnershipModel* ownership = [result objectForKey:@"ownership"];
	SKPaymentTransaction* transaction = [result objectForKey:@"transaction"];
	
	PNCLog(PNLOG_CAT_STORE, @"Transaction finish.");
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	
	[[PNItemHistory sharedObject] updateOwnership:ownership];
	
	[self saveTransactionWasCleared];
	
	if (self.currentRequestKey == nil) {
		PNWarn(@"[ERROR]Something went wrong. currentRequestKey is nil in registerSucceeded:");
	}
	
	[PNRequestKeyManager callOnSucceededSelectorAndRemove:self.currentRequestKey withObject:ownership];
	self.currentRequestKey = nil;
}
- (void)registerFailed:(NSDictionary*)result
{
//	PNCLog(PNLOG_CAT_STORE, @"registerFailed: %@", result);
	PNError* error = [result objectForKey:@"error"];
	SKPaymentTransaction* transaction = [result objectForKey:@"transaction"];
	if ([error.errorCode isEqualToString:@"already_exists"]) {
		PNWarn(@"[WARNING]you shouldn't reach here. receipt already exists. This transaction is finished.");
		[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
		[self saveTransactionWasCleared];
	} else {
        PNWarn(@"[WARNING]Regietering receipt failed.");
    }
	
	[PNRequestKeyManager callOnFailedSelectorAndRemove:self.currentRequestKey withObject:error];
	self.currentRequestKey = nil;
}
#pragma mark -
- (void)getPurchaseHistoryResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSString*		resp	= [response jsonString];
	NSDictionary*	responseDictionary = [response jsonDictionary];
	
	if(response.isValidAndSuccessful) {
		NSArray* purchases = [PNPurchaseModel dataModelsFromArray:[responseDictionary objectForKey:J_PURCHASES]];
		[PNRequestKeyManager callOnSucceededSelectorAndRemove:requestKey withObject:purchases];
	} else {
		PNError* error = [PNError errorFromResponse:resp];
		[PNRequestKeyManager callOnFailedSelectorAndRemove:requestKey withObject:error];
	}
}
#pragma mark -
- (void)getDetailOfProduct:(NSString*)productIdentifier
{
	PNCLog(PNLOG_CAT_STORE, @"getDetailOfProduct:%@", productIdentifier);
	SKProductsRequest *req = [[SKProductsRequest alloc] initWithProductIdentifiers:
							  [NSSet setWithObject:productIdentifier]];
	req.delegate = self;
	[req start];
}
- (BOOL)getDetailOfProducts:(NSArray*)productIdentifiers delegate:(id)delegate 
				onSucceeded:(SEL)onSucceededSelector onFailed:(SEL)onFailedSelector
{
	PNCLog(PNLOG_CAT_STORE, @"getDetailOfProducts:%@", productIdentifiers);
	// 現在すでに処理中であればNOを返します。
	if (currentRequestKey != nil) return NO;
	
	self.currentRequestKey = [PNRequestKeyManager registerDelegate:delegate 
											   onSucceededSelector:onSucceededSelector 
												  onFailedSelector:onFailedSelector];
	
	SKProductsRequest *req = [[SKProductsRequest alloc] initWithProductIdentifiers:
							  [NSSet setWithArray:productIdentifiers]];
	req.delegate = self;
	[req start];
	
	return YES;
}
- (void)registerTransaction:(SKPaymentTransaction*)transaction onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure;
{
	[self registerProduct:[self productWithProductIdentifier:transaction.payment.productIdentifier]
			  withReceipt:transaction.transactionReceipt onSuccess:onSuccess onFailure:onFailure];
}
- (void)registerProduct:(PNSKProduct*)product withReceipt:(NSData*)receipt onSuccess:(void (^)())onSuccess onFailure:(void (^)(PNError* error))onFailure
{
	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[PNUser currentUser].sessionId, @"session",
							[receipt base64EncodedString], @"receipt",
							[NSString stringWithFormat:@"%.2f", [product.price floatValue]], @"price",
							[product.priceLocale objectForKey:NSLocaleCurrencyCode], @"locale",
							[NSString stringWithFormat:@"%d", [PNUser countUpDedupCounter]], @"dedup_counter", 
							[[PNUser currentUser] verifierStringWithGameSecret:[PNGlobalManager sharedObject].gameSecret], @"verifier", nil];
	[PNHTTPRequestHelper requestWithCommand:kPNHTTPRequestCommandPurchaseRegister params:params onSuccess:^(PNHTTPResponse *response) {
		if ([response isValidAndSuccessful]) {
			PNItemOwnershipModel* ownership = [PNItemOwnershipModel dataModelWithDictionary:[response.jsonDictionary objectForKey:@"ownership"]];
			[[PNItemHistory sharedObject] updateOwnership:ownership];
			onSuccess();
		} else {
			onFailure([PNError errorFromResponse:response.jsonString]);
		}
	} onFailure:onFailure];
}


- (BOOL)registerProduct:(SKProduct*)product withReceipt:(NSData*)receipt 
			   delegate:(id)delegate onSucceeded:(SEL)onSucceededSelector
			   onFailed:(SEL)onFailedSelector
{
	// 現在すでに処理中であればNOを返します。
	if (currentRequestKey != nil) return NO;
	
	self.currentRequestKey = [PNRequestKeyManager registerDelegate:delegate 
											   onSucceededSelector:onSucceededSelector 
												  onFailedSelector:onFailedSelector];
	
	// return NO;	//for debug
	[PNStoreRequestHelper registerReceipt:[receipt base64EncodedString] price:[product.price floatValue] 
								   locale:[product.priceLocale objectForKey:NSLocaleCurrencyCode]
								 delegate:self selector:@selector(registerReceiptResponse:) requestKey:currentRequestKey];
	return YES;
}
#pragma mark -
- (void)registerReceiptResponse:(PNHTTPResponse*)response
{
	NSString* requestKey = [response requestKey];
	NSString* resp		 = [response jsonString];
	NSDictionary*	json = [response jsonDictionary];
	PNCLog(PNLOG_CAT_ITEM, @"purchase/register = %@", resp);
	
	PNRequestObject* request = [PNRequestKeyManager requestForKey:requestKey];
	NSObject* delegate = request.delegate;
	
	if (response.isValidAndSuccessful) {
		PNItemOwnershipModel* itemOwnership = [PNItemOwnershipModel dataModelWithDictionary:[json objectForKey:@"ownership"]];
		SEL onSucceededSelector = request.onSucceededSelector;
		if ([delegate respondsToSelector:onSucceededSelector]) {
			[delegate performSelector:onSucceededSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:
																	  itemOwnership, @"ownership",
																	  [PNRequestKeyManager requestForKey:requestKey].object, @"transaction", nil]];
		}
	} else {
		SEL onFailedSelector = request.onFailedSelector;
		if ([delegate respondsToSelector:onFailedSelector]) {
			id transactionInfo = [PNRequestKeyManager requestForKey:requestKey].object;
			PNError* error = [PNError errorFromResponse:resp];
			NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  @"registerReceipt", @"occured_at",
									  error, @"error",
									  transactionInfo, @"transaction", nil];
			[delegate performSelector:onFailedSelector withObject:userInfo];
		}
	}
	[PNRequestKeyManager removeDelegateAndSelectorsForRequestKey:requestKey];
}
#pragma mark -
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	PNCLog(PNLOG_CAT_STORE, @"productsRequest:didReceiveResponse:");
	if ([response.products count] > 0){
		[self getDetailOfProductsSucceeded:response.products];
	} else {
		PNWarn(@"Error. No products found on AppStore. Invalid identifiers = %@.\nIs this true provisioning profile? ", response.invalidProductIdentifiers);
		PNError* error = [[[PNError alloc] init] autorelease];
		error.errorCode = @"no_products";
		[self getDetailOfProductFailed:error];
	}
	[request autorelease];
}

#pragma mark -
#pragma mark Merchandise

- (PNMerchandise*)merchandiseWithProductIdentifier:(NSString*)productIdentifier
{
	for (PNMerchandise* merchandise in [[PNGameManager sharedObject] merchandises]) {
		if ([merchandise.productIdentifier isEqualToString:productIdentifier]) {
			return merchandise;
		}
	}
	return nil;
}

#pragma mark -
- (PNSKProduct*)productWithProductIdentifier:(NSString*)identifier
{
	return [productDetails objectForKey:identifier];
}
#pragma mark -
#pragma mark HTTP Error
// コネクション・エラーの後処理
- (void) error:(PNError*)error userInfo:(id)userInfo
{
	PNCLog(PNLOG_CAT_ITEM, @"%s", __FUNCTION__);
	
}

#pragma mark -
#pragma mark Singleton pattern

- (id)init
{
	if (self = [super init]) {	
		self.merchandiseDetails = [NSMutableDictionary dictionary];
		self.productDetails = [NSMutableDictionary dictionary];
		
		NSDictionary* cachedProducts = [PNArchiveManager unarchiveObjectWithFile:@"skproducts.plist"];
		if (cachedProducts != nil) {
			PNCLog(PNLOG_CAT_ITEM, @"Loaded skproducts list from cache");
			self.productDetails = [NSMutableDictionary dictionaryWithDictionary:cachedProducts];
		}
		
		self.initializedDate = [NSDate date];
	}
	
	// 起動時に商品リストをとっておく
	// この処理はRevision機構の登場によって廃止されました。
	// [self getMerchandisesWithDelegate:self onSucceeded:nil onFailed:nil];
	
	return self;
}

- (void) dealloc
{
	self.merchandiseDetails = nil;
	
	[super dealloc];
}

+ (PNStoreManager *)sharedObject
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance;  // 最初の割り当てで代入し、返す
		}
	}
	return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (void)release
{
	// 何もしない
}

- (id)autorelease
{
	return self;
}
@end
