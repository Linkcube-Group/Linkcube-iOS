
#import "CustomTabbar.h"


@implementation CustomTabbar
@synthesize delegate;
@synthesize imageNames;


- (id)initWithCustom:(CGRect)frame imageNames:(NSArray*)names titles:(NSArray*)titles{
	if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
		self.backgroundColor = [UIColor whiteColor];
		//[self.layer setContents:(id)[[UIImage imageNamed:@"bottombar.png"] CGImage]];
		
		index_ = 0;
		
		float x = 1.0;
		float y = 0.0;
		float w = 160;
		float h = frame.size.height;
		
		int baseTag = 100;
		
		self.imageNames = names;
    
		for(int i = 0; i < [names count]; i++){
			NSString *normalName = [NSString stringWithFormat:@"%@.png",[names objectAtIndex:i]];
			NSString *downName = [NSString stringWithFormat:@"%@_s.png", [names objectAtIndex:i]];
			
			UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
			btn.frame = CGRectMake(x, y, w, h);
           // btn.contentEdgeInsets = UIEdgeInsetsMake(2,0,3,0);
            
            x+=w;
			
			btn.tag = baseTag+i;
			btn.exclusiveTouch = YES;
			[btn setImage:[UIImage imageNamed:normalName] forState:UIControlStateNormal];
			[btn setImage:[UIImage imageNamed:downName] forState:UIControlStateHighlighted];
			//btn.showsTouchWhenHighlighted = YES;
			[btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:btn];
	
		}
		
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		index_ = 0;
    }
    return self;
}


- (void) buttonAction:(id)sender{
	if([sender isKindOfClass:[UIButton class]]){
		
		UIButton *btn = sender;
		
		int itag = btn.tag;
		
		int index = itag-100;
		
		NSString *downName = [NSString stringWithFormat:@"%@_s.png",[imageNames objectAtIndex:index]];
		[btn setImage:[UIImage imageNamed:downName] forState:UIControlStateNormal];
		
		
		if(index_ > -1){
			if(index_+100 != itag){
				UIButton *btnPrev = (UIButton*)[self viewWithTag:index_+100];
				NSString *normalName = [NSString stringWithFormat:@"%@.png",[imageNames objectAtIndex:index_]];
				[btnPrev setImage:[UIImage imageNamed:normalName] forState:UIControlStateNormal];
			}
		}
		
		index_ = index;
		
		if(delegate && [delegate respondsToSelector:@selector(didSelectedIndex:)]){
			[delegate didSelectedIndex:index_];
		}
	}
}

- (void) setIndex:(int)index
{
	UIButton *btn = (UIButton*)[self viewWithTag:index+100];
	[self buttonAction:btn];
}

- (void) selectNone
{
	if(index_==-1)return;
	
	UIButton *btnPrev = (UIButton*)[self viewWithTag:index_+100];
	NSString *normalName = [NSString stringWithFormat:@"%@_s.png",[imageNames objectAtIndex:index_]];
	[btnPrev setImage:[UIImage imageNamed:normalName] forState:UIControlStateNormal];
	
	index_ = -1;
}


- (void)dealloc {
    imageNames = nil;
}


@end
