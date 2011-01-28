
@interface PNControllerLoader : NSObject {

}

+ (UIViewController*)loadUIViewControllerFromNib:(NSString*)nibName filesOwner:(NSObject*)filesOwner;
+ (UITableViewCell*)loadUITableViewCellFromNib:(NSString*)nibName filesOwner:(NSObject*)filesOwner;
+ (UIView*)loadUIViewFromNib:(NSString*)nibName filesOwner:(NSObject*)filesOwner;
+ (NSString*)getControllerNibName:(NSString*)controllerName;
+ (NSString*)getControllerClassName:(NSString*)controllerName;
+ (UIViewController*)load:(NSString*)name filesOwner:(NSObject*)filesOwner;
@end
