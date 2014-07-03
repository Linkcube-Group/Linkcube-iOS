#import <UIKit/UIKit.h>

@protocol CustomTabbarDelegate
@optional

- (void) didSelectedIndex:(int)index;

@end

@interface CustomTabbar : UIView {
	
	id   delegate;


	NSArray  *imageNames;
	
	int      index_;
}
@property (nonatomic) id <CustomTabbarDelegate> delegate;
@property (nonatomic, retain) NSArray *imageNames;

- (id)initWithCustom:(CGRect)frame imageNames:(NSArray*)names titles:(NSArray*)titles;

- (void) setIndex:(int)index;

- (void) selectNone;
@end
