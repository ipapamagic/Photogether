//
//  IPaListScrollView.h
//  IPaListScrollView
//
//  Created by 陳 尤中 on 11/10/13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol IPaListScrollViewDelegate;


//@class IPaMoveingItemInfo;
@interface IPaListScrollView : UIScrollView <UIScrollViewDelegate>{
    
    NSArray *itemArray;

    
    //紀錄每個UIView使用的資料
    NSMutableArray *itemData;
    NSUInteger RowItemNum;
    NSUInteger ColumnItemNum;
    NSInteger workingScrollingAnim;
    
    //移除功能
    //當某Item需要作位移時，需要紀錄一些額外的資訊 
   // IPaMoveingItemInfo *movingItemInfo;
}
@property (nonatomic,readonly) BOOL isColumnMajor;
@property (nonatomic,strong)  UIImage *backgroundImg;
@property (nonatomic,readonly) NSUInteger LoopScreenSizeRatio;
@property (nonatomic,readonly) BOOL isLoop;
//最後一次計算的currentPage;
@property (nonatomic,readonly) NSInteger lastCurrentPage;
//@property (nonatomic,readonly) UIView* movingView;
-(void)setControlDelegate:(id<IPaListScrollViewDelegate>)viewDelegate;
-(void)RefreshScrollView;
-(void)RefreshContentSize;
-(void)ReloadContent;
-(NSInteger) getCurrentPage;
-(void) setPage:(NSInteger)page;
-(void) setPage:(NSInteger)page animated:(BOOL)animated;
//取得指定頁面的item，若回傳nil，則代表頁面未顯示
-(UIView*) getItemWithIndex:(NSInteger)index;
-(void) scrollToItemWithIndex:(NSUInteger)index animated:(BOOL)animated;
/*-(void)setMovingItemIndex:(NSInteger)ItemIndex withTransform:(CGAffineTransform)transform;
-(void)updateMovingItemTransform:(CGAffineTransform)transform;
-(void)removeMovingItem;*/
//自動跳至下一頁，若沒有開啟loop則到最後一頁會停止
-(void)goNextPage;
//回到上一頁，若沒有開啟loop則到第一頁會停止
-(void)backLastPage;
-(void)RefreshItemViews;
@end


@protocol IPaListScrollViewDelegate <NSObject>

-(NSUInteger) IPaListScrollViewTotalItemsNum:(IPaListScrollView*)scrollView;
//get item size
-(CGFloat) IPaListScrollViewItemHeight:(IPaListScrollView*)scrollView;
-(CGFloat) IPaListScrollViewItemWidth:(IPaListScrollView*)scrollView;

//get a new item for list view
-(UIView*) onIPaListScrollViewNewItem:(IPaListScrollView*)scrollView withItemIndex:(NSUInteger)Index;
-(void) configureIPaListScrollView:(IPaListScrollView*)scrollView withItem:(UIView*)Item withIdx:(NSUInteger)Index;

@optional
//if item column major
-(BOOL) isIPaListScrollViewColumnMajor:(IPaListScrollView*)scrollView;
/*// get items number per row
-(NSUInteger) IPaListScrollViewRowItemsNum:(IPaListScrollView*)scrollView;
// get items number per column
-(NSUInteger) IPaListScrollViewColumnItemsNum:(IPaListScrollView*)scrollView;
 */

-(CGFloat) IPaListScrollViewItemOffsetX:(IPaListScrollView*)scrollView;
-(CGFloat) IPaListScrollViewItemOffsetY:(IPaListScrollView*)scrollView;
-(CGFloat) IPaListScrollViewItemDistanceX:(IPaListScrollView*)scrollView;
-(CGFloat) IPaListScrollViewItemDistanceY:(IPaListScrollView*)scrollView;
-(BOOL) isIPaListScrollViewLoopShow:(IPaListScrollView*)scrollView;
-(BOOL) isIPaListScrollViewUseItemPaging:(IPaListScrollView*)scrollView;
-(void) IPaListScrollViewStopOnItemPage:(IPaListScrollView*)scrollView withPage:(NSInteger)page;
-(void) IPaListScrollViewDidScroll:(IPaListScrollView*)scrollView;
-(void) IPaListScrollViewDidSetPageAnim:(IPaListScrollView*)scrollView;
//加大content size
-(CGFloat) IPaListScrollViewSizeOffsetX:(IPaListScrollView*)scrollView;
-(CGFloat) IPaListScrollViewSizeOffsetY:(IPaListScrollView*)scrollView;


//是否要作移動Item的函式，後面兩個參數是回傳值，回傳所希望作修改的
-(void) IPaListScrollViewIsMoveItem:(IPaListScrollView*)scrollView 
                    withTransform:(CGAffineTransform*)transform
                    withItemIndex:(NSInteger*)ItemIndex;
                
-(void) IPaListScrollViewWillBeginDragging:(IPaListScrollView*)scrollView;

//若有要支援zooming，可以加上這個function
-(UIView*)viewForZoomingInScrollView:(IPaListScrollView *)scrollView;

-(CGSize)IPaListScrollViewBackgroundImgSize:(IPaListScrollView *)scrollView;
//開啟Loop的時候，ContentSize要變成Screen Size的倍數
-(NSUInteger)IPaListScrollViewLoopScreenSizeRatio:(IPaListScrollView *)scrollView;
@end