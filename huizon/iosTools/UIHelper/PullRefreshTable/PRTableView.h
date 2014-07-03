#import <UIKit/UIKit.h>

@protocol PRTableViewDelegate;

@interface PRTableView : UITableView {
    ///标记是否正在手动表格
    BOOL isDragging;
	///表格是否正在加载更多或者刷新
    BOOL isLoading;
    ///标记用于记录页数的页码
    __block int pageID;
}
///用于通知刷新与更多的委托
@property (nonatomic, assign) id<PRTableViewDelegate> prDelegate;

/**
 数据为空的时候显示的一个view
 此属性会在每次reloadData的时候检查rowCount和sectionCount，如果都为0，会将此视图添加到table上（会盖住table)
 此视图只有在每次加载结束后调用stopLoading才起作用
 */
@property (nonatomic,retain) UIView *viewEmptyData;
///是否能够加载更多,设置会自动显示和隐藏更多的视图
@property (nonatomic,assign) BOOL isMore;
///是否能够刷新 ，设置会自动显示和隐藏刷新的视图
@property (nonatomic,assign) BOOL isRefresh;
@property (nonatomic,retain) NSString *tableID;///表格ID，用于记录上次刷新时间
@property (nonatomic,assign) BOOL useAutoLayMore;  ///是否自动设置更多位置
@property (nonatomic,assign) BOOL isShowingEmptyView;   ///是否正在显示空白信息

/**
 用于分页时的页码
 默认为1
 */
-(int)pageID;
/**
 设置正在显示的页码，此属性只是为了方便协议层做分页记录
 本身不会进行任何处理
 @param pageid : 要设置的页码
 */
-(void)setPageID:(int)pageid;
///开始进行下拉刷新
- (void)startLoading;
/**
 停止下拉刷新 
 调用此函数会触发空数据视图的判断
 */
- (void)stopLoading;
/**
 开始进行上拉更多的加载
 */
- (void)startLoading_More;
/**
 停止进行上拉更多的加载
 调用此函数（如果使用了自动调整更多视图位置，会导致表格调用delegate自动重新计算moreFooterView的高度）
 */
- (void)stopLoading_More;

/**
 使用表格内容的偏移量设置加载更多视图的位置
 @param _height : 表格内容的调试
 */
- (void)setMoreFooterViewOriginYWithTableViewHeight:(CGFloat)_height;

/**
 下面三个方法请在tableView的delegate中实现，并且在回调中调用此类的这三个方法
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView ;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView ;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate ;
@end

/**
 如果自己不用处理
 - (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView ;
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView ;
 - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate ;
 三个函数的逻辑，此宏定义会将其默认实现
 */
#define PULLREFRESHTABLESCROLL(table) - (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {if(scrollView==table){[table scrollViewWillBeginDragging:scrollView];}}\
\
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {if(scrollView==table){[table scrollViewDidScroll:scrollView];}}\
\
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {if(scrollView==table){[table scrollViewDidEndDragging:scrollView willDecelerate:decelerate];}}


@protocol PRTableViewDelegate <NSObject>
@optional
/**
 表格触发了刷新时回调
 */
-(void)prTableViewTriggerRefresh;
@optional
/**
 表格触发了加载更多时回调
 */
-(void)prTableViewTriggerMore;

@end
