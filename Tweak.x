#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSUserDefaults+Private.h>
#import <UIKit/UIKit.h>


@interface PassWindow: UIWindow
@end
@implementation PassWindow
- (BOOL)_ignoresHitTest {
	return YES;
}
- (BOOL)_usesWindowServerHitTesting {
	return NO;
}
@end

@interface PassLabel: UILabel
@end
@implementation PassLabel
@end

static UIWindow *_noteWindow = nil;
static void createNoteWindow() {

    if (!_noteWindow) {
        _noteWindow = [[PassWindow alloc] init];

        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGSize windowSize = CGSizeMake(screenSize.width, 0);
		CGRect windowFrame = CGRectMake(0, (screenSize.height - windowSize.height) / 2.0, windowSize.width, windowSize.height);

        _noteWindow.frame = windowFrame;
        _noteWindow.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0];
        _noteWindow.windowLevel = UIWindowLevelAlert;
		_noteWindow.userInteractionEnabled = NO;

		CGRect firstLineRect = CGRectMake(0, 0, windowSize.width, CGFLOAT_MAX);
        UILabel *firstLineLabel = [[PassLabel alloc] initWithFrame:firstLineRect];
		firstLineLabel.translatesAutoresizingMaskIntoConstraints = NO;
		firstLineLabel.userInteractionEnabled = NO;
        firstLineLabel.textAlignment = NSTextAlignmentCenter;
        firstLineLabel.textColor = [UIColor colorWithWhite:0.57 alpha:0.5];
        firstLineLabel.font = [UIFont systemFontOfSize:24.0];
        firstLineLabel.numberOfLines = 1;
        firstLineLabel.alpha = 1;
		firstLineLabel.text = @"Activate iOS";
		[firstLineLabel sizeToFit];
		[_noteWindow addSubview:firstLineLabel];	

		CGRect secondLineRect = CGRectMake(0, firstLineLabel.bounds.size.height, windowSize.width, CGFLOAT_MAX);
		UILabel *secondLineLabel = [[PassLabel alloc] initWithFrame:secondLineRect];
		secondLineLabel.translatesAutoresizingMaskIntoConstraints = NO;
		secondLineLabel.userInteractionEnabled = NO;
        secondLineLabel.textAlignment = NSTextAlignmentCenter;
        secondLineLabel.textColor = [UIColor colorWithWhite:0.57 alpha:0.5];
        secondLineLabel.font = [UIFont systemFontOfSize:13.0];
        secondLineLabel.numberOfLines = 1;
        secondLineLabel.alpha = 1;
		secondLineLabel.text = @"Go to “Settings” to activate iOS.";
		[secondLineLabel sizeToFit];
		[_noteWindow addSubview:secondLineLabel];

		firstLineRect = CGRectMake(0, 0, windowSize.width, firstLineLabel.bounds.size.height);
		firstLineLabel.frame = firstLineRect;
		secondLineRect = CGRectMake(0, firstLineLabel.bounds.size.height, windowSize.width, secondLineLabel.bounds.size.height);
		secondLineLabel.frame = secondLineRect;

		windowSize.height = firstLineLabel.bounds.size.height + secondLineLabel.bounds.size.height;
		windowFrame = CGRectMake(0, (screenSize.height - windowSize.height) / 2.0, windowSize.width, windowSize.height);
		_noteWindow.frame = windowFrame;
    }
}


static NSString * nsDomainString = @"com.darwindev.ActivatePhone";
static NSString * nsNotificationString = @"com.darwindev.ActivatePhone/preferences.changed";
static BOOL enabled = YES;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber *enabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
	enabled = (enabledValue) ? [enabledValue boolValue] : YES;

	if (enabled) {
    	[_noteWindow makeKeyAndVisible];
	} else {
		[_noteWindow setHidden:YES];
	}
}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	createNoteWindow();
	notificationCallback(NULL, NULL, NULL, NULL, NULL);
	%orig;
}

%end


%ctor {

	// Set variables on start up
	notificationCallback(NULL, NULL, NULL, NULL, NULL);

	// Register for 'PostNotification' notifications
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
}
