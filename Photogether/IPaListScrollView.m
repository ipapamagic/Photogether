//
//  IPaListScrollView.m
//  IPaListScrollView
//
//  Created by 陳 尤中 on 11/10/13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "IPaListScrollView.h"
//當使用Loop功能的時候，要將content size 變大到Screen的倍數
#define LOOP_SCREEN_SIZE_RATIO 5
enum {
    NONE_ANIM = 0,
    SET_PAGE_ANIM,
    END_SCROLL_TO_PAGE_ANIM
};
@interface IPaListScrollView ()
@property (nonatomic,weak) id<IPaListScrollViewDelegate> ipaDelegate;
@property (nonatomic,readwrite) NSInteger lastCurrentPage;
-(void)_RefreshContentSize:(NSUInteger)totalColumnItemNum 
           totalRowItemNum:(NSUInteger)totalRowItemNum
            actualItemDisW:(CGFloat)actualItemDisW
            actualItemDisH:(CGFloat)actualItemDisH
                   offsetX:(CGFloat)offsetX
                   offsetY:(CGFloat)offsetY
                 DistanceX:(CGFloat)DistanceX
                 DistanceY:(CGFloat)DistanceY
                    isLoop:(BOOL)isLoop
             isColumnMajor:(BOOL)isColumnMajor;

//取得目前頁數
-(NSInteger) _getCurrentPage:(BOOL)isColumnMajor
              actualItemDisW:(CGFloat)actualItemDisW
              actualItemDisH:(CGFloat)actualItemDisH;
//結束滾動時，調整contentoffset 到中間的部份
-(void)_ScrollingDoLoopConfigure:(NSUInteger)totalColumnItemNum 
                 totalRowItemNum:(NSUInteger)totalRowItemNum
                  actualItemDisW:(CGFloat)actualItemDisW
                  actualItemDisH:(CGFloat)actualItemDisH
                         offsetX:(CGFloat)offsetX
                         offsetY:(CGFloat)offsetY
/*   DistanceX:(CGFloat)DistanceX
DistanceY:(CGFloat)DistanceY*/
                          isLoop:(BOOL)isLoop
                   isColumnMajor:(BOOL)isColumnMajor;
-(void)ScrollingDoLoopConfigure;


-(void)_DoEndScrollingStuff:(CGFloat)actualItemDisW
             actualItemDisH:(CGFloat)actualItemDisH
                    offsetX:(CGFloat)offsetX
                    offsetY:(CGFloat)offsetY
                  DistanceX:(CGFloat)DistanceX
                  DistanceY:(CGFloat)DistanceY
              isColumnMajor:(BOOL)isColumnMajor;
-(void)DoEndScrollingStuff;


//取得第一個編輯的物件index,回傳值為最後兩個參數
-(void)getFirstItemIndexWithCurrentPage:(NSInteger)currentPage
                          isColumnMajor:(BOOL)isColumnMajor
                            allItemsNum:(NSUInteger)allItemsNum
                         actualItemDisW:(CGFloat)actualItemDisW
                         actualItemDisH:(CGFloat)actualItemDisH
                                 isLoop:(BOOL)isLoop
                              FirstItem:(NSInteger*)FirstItem
                          FirstRealItem:(NSInteger*)FirstRealItem;

//根據ColumnMajor(或是RowMajor)判斷兩點位置，誰比較在前面
//-(BOOL)_checkPointIsFront:(CGPoint)a beforePoint:(CGPoint)b withIsColumnMajor:(BOOL)isColumnMajor;



//作RefreshScrollView，每個Item需要作的位置處理
-(void)_RefreshItem:(UIView*)item 
      withItemIndex:(NSInteger)itemIndex
     withAllItemNum:(NSUInteger)allItemsNum
         withIsLoop:(BOOL)isLoop
       withStartPos:(CGFloat)startPos
    withCurrentItem:(NSInteger)currentItem
     withItemCenter:(CGPoint)itemCenter
  withIsColumnMajor:(BOOL)isColumnMajor
            offsetX:(CGFloat)offsetX
            offsetY:(CGFloat)offsetY
     actualItemDisW:(CGFloat)actualItemDisW
     actualItemDisH:(CGFloat)actualItemDisH;


@end
@implementation IPaListScrollView
@synthesize backgroundImg;
@synthesize lastCurrentPage;
#pragma mark - Property
-(BOOL) isLoop
{
    return [self.ipaDelegate respondsToSelector:@selector(isIPaListScrollViewLoopShow:)]?
        [self.ipaDelegate isIPaListScrollViewLoopShow:self]:NO;
    
}
-(NSUInteger) LoopScreenSizeRatio
{
    return [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewLoopScreenSizeRatio:)]?
        [self.ipaDelegate IPaListScrollViewLoopScreenSizeRatio:self]:LOOP_SCREEN_SIZE_RATIO;
}
-(BOOL) isColumnMajor
{
    return ([self.ipaDelegate respondsToSelector:@selector(isIPaListScrollViewColumnMajor:)])?
    [self.ipaDelegate isIPaListScrollViewColumnMajor:self]:YES;
}

#pragma mark - 
-(void)drawRect:(CGRect)rect
{
    
    if (backgroundImg) {
        CGSize imgSize = self.bounds.size;
        if ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewBackgroundImgSize:)]) {
            imgSize = [self.ipaDelegate IPaListScrollViewBackgroundImgSize:self];
        }
        
        NSInteger temp = floor(self.contentOffset.x / imgSize.width);
        CGFloat posX = (self.contentOffset.x - (imgSize.width * temp));
        temp = floor(self.contentOffset.y / imgSize.height);
        CGFloat posY = (self.contentOffset.y - (imgSize.height * temp));
        
        CGPoint drawPoint = CGPointMake(-posX, -posY);
        //畫第一張
        
        while (drawPoint.x < self.bounds.size.width) {
            
            while (drawPoint.y < self.bounds.size.height) {
                [backgroundImg drawInRect:CGRectMake(drawPoint.x + self.contentOffset.x, drawPoint.y + self.contentOffset.y, imgSize.width, imgSize.height)];
                
                drawPoint.y += imgSize.height;
            }
            drawPoint.x += imgSize.width;
            
            drawPoint.y = -posY;
        }
        //        [self layoutSubviews];
    }
}

-(void)RefreshItemViews
{
    if (self.ipaDelegate == nil) {
        return;
    }
    float itemWidth = [self.ipaDelegate IPaListScrollViewItemWidth:self];//self.frame.size.width / columnNum;
    float itemHeight = [self.ipaDelegate IPaListScrollViewItemHeight:self];//self.frame.size.height / rowNum;
    CGFloat offsetX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetY:self]:0;
    
    CGFloat DistanceX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;   
    
    RowItemNum = ceil((self.bounds.size.height - offsetY - DistanceY) / actualItemDisH);
    ColumnItemNum = ceil((self.bounds.size.width - offsetX - DistanceX) / actualItemDisW);
    
    BOOL isColumnMajor = self.isColumnMajor;
    
    NSUInteger itemsNum = ((isColumnMajor)?(ColumnItemNum+2) * RowItemNum :(RowItemNum+2) * ColumnItemNum);
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:itemsNum];
    
    UIView* newItem;
    itemData = [[NSMutableArray alloc] initWithCapacity:itemsNum];
    NSUInteger counter = 0;
    for (UIView *subView in itemArray) {
        subView.frame = CGRectMake(offsetX, offsetY, itemWidth, itemHeight);
        [tempArray addObject:subView];
        [itemData addObject:[NSNumber numberWithInt:-1]];
        
        counter++;
        
        if (counter >= itemsNum) {
            break;
        }
    }
    
    while (counter < itemsNum) {
        newItem = [self.ipaDelegate onIPaListScrollViewNewItem:self withItemIndex:counter];
        [self addSubview:newItem];
        
        newItem.frame = CGRectMake(offsetX, offsetY, itemWidth, itemHeight);
        
        [tempArray addObject:newItem];
        [itemData addObject:[NSNumber numberWithInt:-1]];
        counter++;
    }
    
    
    itemArray = [[NSArray alloc] initWithArray:tempArray];
    
    
    
}

-(void)setControlDelegate:(id<IPaListScrollViewDelegate>)viewDelegate
{
    if (self.ipaDelegate != nil) {
        self.ipaDelegate = viewDelegate;
        [self RefreshItemViews];
        return;
    }
    lastCurrentPage = 0;
    self.delegate = self;
    self.ipaDelegate = viewDelegate;
    workingScrollingAnim = NONE_ANIM;

    float itemWidth = [viewDelegate IPaListScrollViewItemWidth:self];//self.frame.size.width / columnNum;
    float itemHeight = [viewDelegate IPaListScrollViewItemHeight:self];//self.frame.size.height / rowNum;
    CGFloat offsetX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetY:self]:0;
    
    CGFloat DistanceX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;   
    
    RowItemNum = ceil((self.bounds.size.height - offsetY - DistanceY) / actualItemDisH);
    ColumnItemNum = ceil((self.bounds.size.width - offsetX - DistanceX) / actualItemDisW);
    
    
    BOOL isColumnMajor = self.isColumnMajor;
    // NSUInteger itemsNum = ((isColumnMajor)?(columnNum+2) * rowNum :(rowNum+2) * columnNum);
    NSUInteger itemsNum = ((isColumnMajor)?(ColumnItemNum+2) * RowItemNum :(RowItemNum+2) * ColumnItemNum);
    NSUInteger allItemsNum = [viewDelegate IPaListScrollViewTotalItemsNum:self];
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:itemsNum];
    
    
    BOOL isLoop = self.isLoop;    
    
    NSUInteger totalRowItemNum = (isColumnMajor)?RowItemNum:ceil((float)allItemsNum / ColumnItemNum);
    NSUInteger totalColumnItemNum = (isColumnMajor)?ceil((float)allItemsNum / RowItemNum):ColumnItemNum;
    
    [self _RefreshContentSize:totalColumnItemNum 
              totalRowItemNum:totalRowItemNum
               actualItemDisW:actualItemDisW
               actualItemDisH:actualItemDisH
                      offsetX:offsetX
                      offsetY:offsetY
                    DistanceX:DistanceX
                    DistanceY:DistanceY
                       isLoop:isLoop
                isColumnMajor:isColumnMajor];
    
    UIView* newItem;
    
    //若是Loop,初始位置需要改變
    [self _ScrollingDoLoopConfigure:totalColumnItemNum 
                    totalRowItemNum:totalRowItemNum
                     actualItemDisW:actualItemDisW
                     actualItemDisH:actualItemDisH
                            offsetX:offsetX
                            offsetY:offsetY
     /*   DistanceX:DistanceX
      DistanceY:DistanceY*/
                             isLoop:isLoop
                      isColumnMajor:isColumnMajor];
    
    
    //refresh content size
    
    itemData = [[NSMutableArray alloc] initWithCapacity:itemsNum];
    for (int idx = 0; idx < itemsNum; idx++) {
        
        newItem = [viewDelegate onIPaListScrollViewNewItem:self withItemIndex:idx];
        [self addSubview:newItem];
        
        newItem.frame = CGRectMake(offsetX, offsetY, itemWidth, itemHeight);
        
        [tempArray addObject:newItem];
        [itemData addObject:[NSNumber numberWithInt:-1]];
    }
    
    
    
    itemArray = [[NSArray alloc] initWithArray:tempArray];
    
    
    [self RefreshScrollView];
}
-(void)ReloadContent
{
    if (self.ipaDelegate == nil) {
        return;
    }
    NSInteger itemNum = itemData.count;
    [itemData removeAllObjects];
    
    for (int idx = 0; idx < itemNum; idx++) {
        [itemData addObject:[NSNumber numberWithInt:-1]];
    }
    //itemNum = itemData.count;
    [self RefreshContentSize];
    [self RefreshScrollView];
}
-(UIView*) getItemWithIndex:(NSInteger)index

{
    BOOL isColumnMajor = self.isColumnMajor;
    float itemWidth = [self.ipaDelegate IPaListScrollViewItemWidth:self];//self.frame.size.width / columnNum;
    float itemHeight = [self.ipaDelegate IPaListScrollViewItemHeight:self];//self.frame.size.height / rowNum;
    
    
    CGFloat DistanceX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight; 
    NSInteger currentPage = [self _getCurrentPage:isColumnMajor 
                                   actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
    NSUInteger allItemsNum = [self.ipaDelegate IPaListScrollViewTotalItemsNum:self];
    BOOL isLoop = self.isLoop;    
    NSInteger firstItem;
    NSInteger firstRealItem;
    
    [self getFirstItemIndexWithCurrentPage:currentPage isColumnMajor:isColumnMajor allItemsNum:allItemsNum actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH isLoop:isLoop FirstItem:&firstItem FirstRealItem:&firstRealItem];
    
    
    NSUInteger itemsNum = [itemArray count];
    if (index < firstItem) {
        if (isLoop) {
            //若所有的物件比序列剩下來的多，代表有loop的物件會被顯示
            //從firstRealItem到最後剩下的item數量
            NSInteger temp = allItemsNum - firstItem;
            if (itemsNum > temp) {
                temp = index + temp + firstRealItem;
                if (temp >= itemsNum) {
                    temp -= itemsNum;
                }
                
                return (temp >= itemsNum)?nil:[itemArray objectAtIndex:temp];
            }
        }
        
        return nil;
        
    }
    else if (index >= firstItem + itemsNum) {
        
        return nil;
    }
    else
    {
        NSInteger temp = index - firstItem + firstRealItem;
        if (temp >= itemsNum) {
            temp -= itemsNum;
        }
        
        return [itemArray objectAtIndex:temp];
        
    }
    return nil;
    
}
-(void) scrollToItemWithIndex:(NSUInteger)index animated:(BOOL)animated
{
    NSUInteger allItemsNum = [self.ipaDelegate IPaListScrollViewTotalItemsNum:self];
    if (index >= allItemsNum ) {
        return;
    }
    
    BOOL isColumnMajor = self.isColumnMajor;
    
    
    NSUInteger locatePage = index / ((isColumnMajor)?RowItemNum:ColumnItemNum);
    NSUInteger offset = ((isColumnMajor)?ColumnItemNum:RowItemNum);
    
    
    NSUInteger currentPage = [self getCurrentPage];
    
    //    NSInteger currentPage = self.lastCurrentPage;
    if (currentPage < locatePage) {
        if (locatePage - currentPage < offset) {
            //已顯示，就不滑動了
            return;
        }
        [self setPage:locatePage animated:animated];
    }
    else if (currentPage >= locatePage) {
        NSUInteger gotoPage = MAX(0, ((NSInteger)locatePage - (NSInteger)offset + 1));
        [self setPage:gotoPage animated:animated];
    }
}
-(void) setPage:(NSInteger)page
{
    [self setPage:page animated:NO];
}
-(void) setPage:(NSInteger)page animated:(BOOL)animated
{
    
    NSUInteger allItemsNum = [self.ipaDelegate IPaListScrollViewTotalItemsNum:self];
    
    BOOL isColumnMajor = self.isColumnMajor;
    float itemWidth = [self.ipaDelegate IPaListScrollViewItemWidth:self];//self.frame.size.width / columnNum;
    float itemHeight = [self.ipaDelegate IPaListScrollViewItemHeight:self];//self.frame.size.height / rowNum;
    CGFloat offsetX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetY:self]:0;
    CGFloat DistanceX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight; 
    
    {
        NSInteger currentPage = [self _getCurrentPage:isColumnMajor
                                       actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
        if (!self.isLoop) {
            if (page < 0) {
                do {
                    page += allItemsNum;
                } while (page < 0);
            }
            else {
                if (allItemsNum > 0) {
                    page = page %allItemsNum;
                }
                
            }
            
            if (currentPage < 0) {
                NSInteger temp = currentPage;
                NSInteger counter = 1;
                if (allItemsNum > 0) {
                    do {
                        temp += allItemsNum;
                        counter++;
                    } while (temp < 0);
                    
                }
                else {
                    temp = 0;
                    currentPage = 0;
                }
                
                page = currentPage + page - temp;
            }
            else {
                
                NSInteger temp = (allItemsNum > 0)? currentPage % allItemsNum:currentPage;
                page = currentPage + page - temp;
            }  
        }
      
    }
    if (animated) {
        workingScrollingAnim = SET_PAGE_ANIM;
    }
    if (isColumnMajor) {
        CGFloat targetPos = page * actualItemDisW + offsetX;
        [self setContentOffset:CGPointMake(targetPos, self.contentOffset.y) animated:animated];
        
    }
    else {
        CGFloat targetPos = page * actualItemDisH + offsetY;
        [self setContentOffset:CGPointMake( self.contentOffset.x,targetPos) animated:animated];
    }
    
    
}


-(void)_DoEndScrollingStuff:(CGFloat)actualItemDisW
             actualItemDisH:(CGFloat)actualItemDisH
                    offsetX:(CGFloat)offsetX
                    offsetY:(CGFloat)offsetY
                  DistanceX:(CGFloat)DistanceX
                  DistanceY:(CGFloat)DistanceY
              isColumnMajor:(BOOL)isColumnMajor;
{
    //  NSInteger currentPage = [self _getCurrentPage:isColumnMajor actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
    BOOL isPaging = [self.ipaDelegate respondsToSelector:@selector(isIPaListScrollViewUseItemPaging:)]?
    [self.ipaDelegate isIPaListScrollViewUseItemPaging:self]:NO;
    if (!isPaging) {
        if ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewStopOnItemPage:withPage:)]) {
            //若有使用取得頁數的callback
            //則作以下計算
            NSInteger currentPage = [self _getCurrentPage:isColumnMajor
                                           actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
            
            //要將currentPage轉成一般的page，因為loop的時候，page有可能會亂七八糟
            NSUInteger allItemsNum = [self.ipaDelegate IPaListScrollViewTotalItemsNum:self];
            
            NSUInteger totalRowItemNum = (isColumnMajor)?RowItemNum:ceil((float)allItemsNum / ColumnItemNum);
            NSUInteger totalColumnItemNum = (isColumnMajor)?ceil((float)allItemsNum / RowItemNum):ColumnItemNum;
            
            while (currentPage < 0) {
                currentPage += (isColumnMajor)?totalColumnItemNum:totalRowItemNum;
            }
            currentPage =  currentPage % ((isColumnMajor)?totalColumnItemNum:totalRowItemNum);
            [self.ipaDelegate IPaListScrollViewStopOnItemPage:self withPage:currentPage];
        }
        return;
    }
    NSInteger currentPage = [self _getCurrentPage:isColumnMajor 
                                   actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
    
    NSInteger targetPage = currentPage;
    
    
    //要將currentPage轉成一般的page，因為loop的時候，page有可能會亂七八糟
    //   NSUInteger allItemsNum = [self.ipaDelegate IPaListScrollViewTotalItemsNum:self];
    
   
    workingScrollingAnim = END_SCROLL_TO_PAGE_ANIM;
    //設定頁數最後作，若上面的callback有修改頁數的話，底層機制就會不讓下面的動作作修改
    if (isColumnMajor) {
        CGFloat targetPos = targetPage * actualItemDisW;
        [self setContentOffset:CGPointMake(targetPos, self.contentOffset.y) animated:YES];
        
    }
    else {
        CGFloat targetPos = targetPage * actualItemDisH;
        [self setContentOffset:CGPointMake( self.contentOffset.x,targetPos) animated:YES];
    }
    
    
}
-(void)DoEndScrollingStuff
{
    BOOL isColumnMajor = self.isColumnMajor;
    float itemWidth = [self.ipaDelegate IPaListScrollViewItemWidth:self];//self.frame.size.width / columnNum;
    float itemHeight = [self.ipaDelegate IPaListScrollViewItemHeight:self];//self.frame.size.height / rowNum;
    CGFloat offsetX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetY:self]:0;
    CGFloat DistanceX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;   
    
    
    [self _DoEndScrollingStuff:actualItemDisW
                actualItemDisH:actualItemDisH
                       offsetX:offsetX
                       offsetY:offsetY
                     DistanceX:DistanceX
                     DistanceY:DistanceY
                 isColumnMajor:isColumnMajor];
}
-(void)_ScrollingDoLoopConfigure:(NSUInteger)totalColumnItemNum 
                 totalRowItemNum:(NSUInteger)totalRowItemNum
                  actualItemDisW:(CGFloat)actualItemDisW
                  actualItemDisH:(CGFloat)actualItemDisH
                         offsetX:(CGFloat)offsetX
                         offsetY:(CGFloat)offsetY
/* DistanceX:(CGFloat)DistanceX
DistanceY:(CGFloat)DistanceY*/
                          isLoop:(BOOL)isLoop
                   isColumnMajor:(BOOL)isColumnMajor
{
    if (!isLoop) {
        return;
    }
    //原來的大小
    CGFloat width = totalColumnItemNum * actualItemDisW ;//  - DistanceX;
    CGFloat height = totalRowItemNum * actualItemDisH ;//  - DistanceY;
    
    
    if (isColumnMajor) {
        if (width > 0) {
            CGFloat checkPos = self.contentSize.width / 2;
            //要將Offset移到這個附近
            CGFloat currentPos = self.contentOffset.x;
            
            if (currentPos < checkPos) {
                
                do {
                    currentPos += width;
                } while (currentPos < checkPos);
                currentPos -= width;
                
                self.contentOffset = CGPointMake(currentPos, self.contentOffset.y);
            }
            else if (currentPos > checkPos)
            {
                do {
                    currentPos -= width;
                } while (currentPos > checkPos);
                currentPos += width;
                self.contentOffset = CGPointMake(currentPos, self.contentOffset.y);
            }
            
            
        }
        
    }
    else {
        if (height > 0) {
            CGFloat checkPos = self.contentSize.height / 2;
            //要將Offset移到這個附近
            CGFloat currentPos = self.contentOffset.y;
            
            if (currentPos < checkPos) {
                
                do {
                    currentPos += height;
                } while (currentPos < checkPos);
                currentPos -= height;
                self.contentOffset = CGPointMake(self.contentOffset.x,currentPos);
            }
            else if (currentPos > checkPos)
            {
                do {
                    currentPos -= height;
                } while (currentPos > checkPos);
                currentPos += height;
                
                self.contentOffset = CGPointMake(self.contentOffset.x,currentPos);
            }
            
        }
        
    }
}
-(void)ScrollingDoLoopConfigure
{
    /* NSUInteger rowNum = ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewRowItemsNum:)])?
     [self.ipaDelegate IPaListScrollViewRowItemsNum:self]:1;
     NSUInteger columnNum = ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewColumnItemsNum:)])?
     [self.ipaDelegate IPaListScrollViewColumnItemsNum:self]:1;*/
    BOOL isColumnMajor = self.isColumnMajor;
    NSUInteger allItemsNum = [self.ipaDelegate IPaListScrollViewTotalItemsNum:self];
    float itemWidth = [self.ipaDelegate IPaListScrollViewItemWidth:self];//self.frame.size.width / columnNum;
    float itemHeight = [self.ipaDelegate IPaListScrollViewItemHeight:self];//self.frame.size.height / rowNum;
    CGFloat offsetX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetY:self]:0;
    CGFloat DistanceX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;   
    
    NSUInteger totalRowItemNum = (isColumnMajor)?RowItemNum:ceil((float)allItemsNum / ColumnItemNum);
    NSUInteger totalColumnItemNum = (isColumnMajor)?ceil((float)allItemsNum / RowItemNum):ColumnItemNum;
    
    BOOL isLoop = self.isLoop;
    [self _ScrollingDoLoopConfigure:totalColumnItemNum 
                    totalRowItemNum:totalRowItemNum
                     actualItemDisW:actualItemDisW
                     actualItemDisH:actualItemDisH
                            offsetX:offsetX
                            offsetY:offsetY
     /*  DistanceX:DistanceX
      DistanceY:DistanceY*/
                             isLoop:isLoop
                      isColumnMajor:isColumnMajor];
}


-(void)_RefreshContentSize:(NSUInteger)totalColumnItemNum 
           totalRowItemNum:(NSUInteger)totalRowItemNum
            actualItemDisW:(CGFloat)actualItemDisW
            actualItemDisH:(CGFloat)actualItemDisH
                   offsetX:(CGFloat)offsetX
                   offsetY:(CGFloat)offsetY
                 DistanceX:(CGFloat)DistanceX
                 DistanceY:(CGFloat)DistanceY
                    isLoop:(BOOL)isLoop
             isColumnMajor:(BOOL)isColumnMajor
{
    CGFloat contentSizeX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewSizeOffsetX:)]?
    [self.ipaDelegate IPaListScrollViewSizeOffsetX:self]:0;
    CGFloat contentSizeY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewSizeOffsetY:)]?
    [self.ipaDelegate IPaListScrollViewSizeOffsetY:self]:0;
    if (isLoop) {
        
        CGFloat width = totalColumnItemNum * actualItemDisW + offsetX - DistanceX;
        
        CGFloat height = totalRowItemNum * actualItemDisH + offsetY - DistanceY;
        
        //Scroll的區要變的很大才行，要不然滾到邊邊的時候會強制停住
        if (isColumnMajor) {
            CGFloat needScrollSize = [UIScreen mainScreen].bounds.size.width * self.LoopScreenSizeRatio;            
            if (width > 0) {
                CGFloat size = width;
                
                
                while (width < needScrollSize)
                {
                    width += size;
                }
            }
            else {
                width = needScrollSize;
            }
            
        }
        else {
            CGFloat needScrollSize = [UIScreen mainScreen].bounds.size.height * self.LoopScreenSizeRatio;
            if (height > 0) {
                CGFloat size = height;
                
                while (height < needScrollSize)
                {
                    height += size;
                }
                
            }
            else {
                height = needScrollSize;
            }
        }
        
        
        
        
        [self setContentSize:CGSizeMake(width + contentSizeX,height + contentSizeY)];
    }
    else {
        [self setContentSize:CGSizeMake(totalColumnItemNum * actualItemDisW + offsetX - DistanceX + contentSizeX, totalRowItemNum * actualItemDisH + offsetY - DistanceY + contentSizeY)];
        
    }
    //不使用Loop的時候才用的code
    //[self setContentSize:CGSizeMake(totalColumnItemNum * actualItemDisW + offsetX - DistanceX, totalRowItemNum * actualItemDisH + offsetY - DistanceY)];
}
-(void)RefreshContentSize
{
    /*NSUInteger rowNum = ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewRowItemsNum:)])?
     [self.ipaDelegate IPaListScrollViewRowItemsNum:self]:1;
     NSUInteger columnNum = ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewColumnItemsNum:)])?
     [self.ipaDelegate IPaListScrollViewColumnItemsNum:self]:1;*/
    BOOL isColumnMajor = self.isColumnMajor;
    NSUInteger allItemsNum = [self.ipaDelegate IPaListScrollViewTotalItemsNum:self];
    float itemWidth = [self.ipaDelegate IPaListScrollViewItemWidth:self];//self.frame.size.width / columnNum;
    float itemHeight = [self.ipaDelegate IPaListScrollViewItemHeight:self];//self.frame.size.height / rowNum;
    CGFloat offsetX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetY:self]:0;
    CGFloat DistanceX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceY:self]:0;
    
    BOOL isLoop = self.isLoop;
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;   
    
    NSUInteger totalRowItemNum = (isColumnMajor)?RowItemNum:ceil((float)allItemsNum / ColumnItemNum);
    NSUInteger totalColumnItemNum = (isColumnMajor)?ceil((float)allItemsNum / RowItemNum):ColumnItemNum;
    
    
    [self _RefreshContentSize:totalColumnItemNum 
              totalRowItemNum:totalRowItemNum
               actualItemDisW:actualItemDisW
               actualItemDisH:actualItemDisH
                      offsetX:offsetX
                      offsetY:offsetY
                    DistanceX:DistanceX
                    DistanceY:DistanceY
                       isLoop:isLoop
                isColumnMajor:isColumnMajor];
}
-(NSInteger) _getCurrentPage:(BOOL)isColumnMajor 
              actualItemDisW:(CGFloat)actualItemDisW 
              actualItemDisH:(CGFloat)actualItemDisH
{
    self.lastCurrentPage = (isColumnMajor)?floor((self.contentOffset.x - actualItemDisW / 2) / actualItemDisW) + 1:
    floor((self.contentOffset.y -  actualItemDisH / 2) / actualItemDisH) + 1;
    return self.lastCurrentPage;
}
-(NSInteger) getCurrentPage
{
    BOOL isColumnMajor = self.isColumnMajor;
    CGFloat itemWidth = [self.ipaDelegate IPaListScrollViewItemWidth:self];
    CGFloat itemHeight = [self.ipaDelegate IPaListScrollViewItemHeight:self];
    //按鈕間的間隔
    CGFloat DistanceX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceY:self]:0;
    //兩個元件開頭的距離
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;   
    NSInteger currentPage = [self _getCurrentPage:isColumnMajor
                                   actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
    
    //要將currentPage轉成一般的page，因為loop的時候，page有可能會亂七八糟
    NSUInteger allItemsNum = [self.ipaDelegate IPaListScrollViewTotalItemsNum:self];
    
    /* NSUInteger rowNum = ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewRowItemsNum:)])?
     [self.ipaDelegate IPaListScrollViewRowItemsNum:self]:1;
     NSUInteger columnNum = ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewColumnItemsNum:)])?
     [self.ipaDelegate IPaListScrollViewColumnItemsNum:self]:1;*/
    NSUInteger totalRowItemNum = MAX(1, (isColumnMajor)?RowItemNum:ceil((float)allItemsNum / ColumnItemNum));
    NSUInteger totalColumnItemNum = MAX(1, (isColumnMajor)?ceil((float)allItemsNum / RowItemNum):ColumnItemNum);
    
    while (currentPage < 0) {
        currentPage += (isColumnMajor)?totalColumnItemNum:totalRowItemNum;
    }
    
    return currentPage % ((isColumnMajor)?totalColumnItemNum:totalRowItemNum);
    
    
    
    
}
-(void)ResetItemTransform
{
    for (UIView *Item in itemArray) {
        Item.transform = CGAffineTransformIdentity;
    }
}
-(BOOL)_checkPointIsFront:(CGPoint)a beforePoint:(CGPoint)b withIsColumnMajor:(BOOL)isColumnMajor
{
    
    return (isColumnMajor)?((a.x < b.x) || (a.x == b.x && a.y < b.y)):((a.y < b.y) || (a.y == b.y && a.x < b.x));
}

//取得第一個顯示物件的index
-(void)getFirstItemIndexWithCurrentPage:(NSInteger)currentPage
                          isColumnMajor:(BOOL)isColumnMajor
                            allItemsNum:(NSUInteger)allItemsNum
                         actualItemDisW:(CGFloat)actualItemDisW
                         actualItemDisH:(CGFloat)actualItemDisH
                                 isLoop:(BOOL)isLoop
                              FirstItem:(NSInteger*)FirstItem
                          FirstRealItem:(NSInteger*)FirstRealItem;

{
    
    CGFloat startPos = (isColumnMajor)?currentPage * actualItemDisW - actualItemDisW:
    currentPage * actualItemDisH - actualItemDisH;
    
    if (!isLoop && startPos < 0) {
        *FirstItem = 0;
        *FirstRealItem = 0;
        return;
    }
    NSInteger itemIndex = 0;
    
    NSInteger temp = (isColumnMajor)?RowItemNum:ColumnItemNum;
    
    //第一個要排位置的實際物件,currentPage的上一頁
    
    if (allItemsNum > 0) {
        itemIndex = (currentPage-1) * temp;
        while (itemIndex < 0) {
            itemIndex += allItemsNum;
        }
        itemIndex = itemIndex % allItemsNum;
    }
    
    *FirstItem = itemIndex;
    NSUInteger itemsNum = [itemArray count];
    NSInteger realItemIndex = 0;
    if (itemsNum > 0) {
        realItemIndex = (currentPage*temp % itemsNum - temp);
        while (realItemIndex < 0) {
            realItemIndex = itemsNum+ realItemIndex;
        }
        
        
    }    
    *FirstRealItem = realItemIndex;
    
}
-(void)_RefreshItem:(UIView*)item 
      withItemIndex:(NSInteger)itemIndex
     withAllItemNum:(NSUInteger)allItemsNum
         withIsLoop:(BOOL)isLoop
       withStartPos:(CGFloat)startPos
    withCurrentItem:(NSInteger)currentItem
     withItemCenter:(CGPoint)itemCenter
  withIsColumnMajor:(BOOL)isColumnMajor
            offsetX:(CGFloat)offsetX
            offsetY:(CGFloat)offsetY
     actualItemDisW:(CGFloat)actualItemDisW
     actualItemDisH:(CGFloat)actualItemDisH

{
    //hidden的修件
    [item setHidden:(!isLoop && ((itemIndex >= allItemsNum) || (startPos < 0)))];
    
    
    if (itemIndex != [[itemData objectAtIndex:currentItem] intValue]) {
        CGPoint center = CGPointApplyAffineTransform(itemCenter, (isColumnMajor)?CGAffineTransformMakeTranslation(startPos+offsetX,itemIndex%RowItemNum * actualItemDisH+offsetY):
                                                     CGAffineTransformMakeTranslation(itemIndex%ColumnItemNum * actualItemDisW + offsetX,startPos + offsetY));
        [item setCenter:center];
        [itemData removeObjectAtIndex:currentItem];
        [itemData insertObject:[NSNumber numberWithInt:itemIndex] atIndex:currentItem];
        if (itemIndex < allItemsNum) {
            [self.ipaDelegate configureIPaListScrollView:self withItem:item withIdx:itemIndex];
        }
    }
    else if (isLoop)
    {
        //若是loop的話，得隨時處理位置資訊
        CGPoint center = CGPointApplyAffineTransform(itemCenter, (isColumnMajor)?CGAffineTransformMakeTranslation(startPos + offsetX,itemIndex%RowItemNum * actualItemDisH + offsetY):
                                                     CGAffineTransformMakeTranslation(itemIndex%ColumnItemNum * actualItemDisW + offsetX,startPos + offsetY));
        [item setCenter:center];
        
    }
    
}
-(void)RefreshScrollView
{
    //看的到的row number還有column number
    /* NSUInteger rowNum = ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewRowItemsNum:)])?
     [self.ipaDelegate IPaListScrollViewRowItemsNum:self]:1;
     NSUInteger columnNum = ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewColumnItemsNum:)])?
     [self.ipaDelegate IPaListScrollViewColumnItemsNum:self]:1;
     */
    //是否為column major
    BOOL isColumnMajor = self.isColumnMajor;
    //實際產生的按鈕數量
    NSUInteger itemsNum = [itemArray count];
    //所有的元件數量
    NSUInteger allItemsNum = [self.ipaDelegate IPaListScrollViewTotalItemsNum:self];
    //元件的大小
    CGFloat itemWidth = [self.ipaDelegate IPaListScrollViewItemWidth:self];
    CGFloat itemHeight = [self.ipaDelegate IPaListScrollViewItemHeight:self];
    CGFloat offsetX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetX:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetX:self]:0;
    CGFloat offsetY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemOffsetY:)]?
    [self.ipaDelegate IPaListScrollViewItemOffsetY:self]:0;
    
    //按鈕間的間隔
    CGFloat DistanceX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceX:self]:0;
    CGFloat DistanceY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
    [self.ipaDelegate IPaListScrollViewItemDistanceY:self]:0;
    //兩個元件開頭的距離
    CGFloat actualItemDisW = DistanceX + itemWidth;
    CGFloat actualItemDisH = DistanceY + itemHeight;   
    
    //是否為循環滾動
    BOOL isLoop = self.isLoop;
    
    [self ScrollingDoLoopConfigure];
    
    
    //目前顯示的"頁數"，一頁代表一個column or row
    NSInteger currentPage = [self _getCurrentPage:isColumnMajor
                                   actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
    
    //開始的位置
    CGFloat startPos = (isColumnMajor)?currentPage * actualItemDisW - actualItemDisW:
    currentPage * actualItemDisH - actualItemDisH;
    if (!isLoop && startPos < 0) {
        startPos = 0;
    }
    
    
    //目前要排位置的item
    NSInteger currentItem;
    
    //目前編輯元件的index(實際元件的index)
    NSInteger itemIndex;
    
    [self getFirstItemIndexWithCurrentPage:currentPage isColumnMajor:isColumnMajor allItemsNum:allItemsNum actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH isLoop:isLoop FirstItem:&itemIndex FirstRealItem:&currentItem];
    
    
    CGPoint itemCenter = CGPointMake(itemWidth / 2, itemHeight / 2);
    
    /*  if (movingItemInfo != nil) {
     CGAffineTransform movingTransform = movingItemInfo.transform;
     movingItemInfo.isMovingForward = (isColumnMajor)? ((movingTransform.tx < 0) || (movingTransform.tx == 0 && movingTransform.ty < 0)):
     ((movingTransform.ty < 0) || (movingTransform.ty == 0 && movingTransform.tx < 0));
     }
     */
    
    for (NSInteger idx = 0; idx < itemsNum; idx++) {
        if (currentItem >= itemsNum ) {
            currentItem = 0;
        }
        UIView *item = [itemArray objectAtIndex:currentItem];
        
        if (idx > 0 && (idx % ((isColumnMajor)?RowItemNum:ColumnItemNum) == 0)) {
            startPos += ((isColumnMajor)?actualItemDisW:actualItemDisH);
        }
        if (isLoop && (itemIndex >= allItemsNum))
        {
            itemIndex = 0;
        }  
        //判斷目前處理的實際物件index是否是movingView所佔用的
        
        /*   if (movingItemInfo != nil) {
         
         if (itemIndex == movingItemInfo.ItemIndex) {
         //不處理同一個物件
         
         itemIndex++;
         if (item == movingItemInfo.movingView) {
         currentItem++;
         continue;
         }
         
         }
         else if (item == movingItemInfo.movingView) {
         //需要額外的視窗來使用
         if (movingItemInfo.extraView == nil) {
         movingItemInfo.extraView = [self.ipaDelegate onIPaListScrollViewNewItem:self withItemIndex:currentItem];
         
         [itemData removeObjectAtIndex:currentItem];
         [itemData insertObject:[NSNumber numberWithInt:-1] atIndex:currentItem];
         movingItemInfo.extraViewItemIndex = itemIndex;
         }
         else if (movingItemInfo.extraViewItemIndex != itemIndex) {
         [itemData removeObjectAtIndex:currentItem];
         [itemData insertObject:[NSNumber numberWithInt:-1] atIndex:currentItem];
         
         movingItemInfo.extraViewItemIndex = itemIndex;
         }
         item = movingItemInfo.extraView;
         }
         
         
         [self _RefreshItem:item 
         withItemIndex:itemIndex
         withAllItemNum:allItemsNum
         withIsLoop:isLoop
         withStartPos:startPos
         withCurrentItem:currentItem
         withItemCenter:itemCenter
         withIsColumnMajor:isColumnMajor
         actualItemDisW:actualItemDisW
         actualItemDisH:actualItemDisH];
         
         
         //計算位置transform
         if (movingItemInfo.isMovingForward) {
         //向前移動
         if (itemIndex > movingItemInfo.ItemIndex) {
         item.transform = CGAffineTransformIdentity;
         }
         else {
         
         if ([self _checkPointIsFront:movingItemInfo.center beforePoint:item.center withIsColumnMajor:isColumnMajor]) {
         //在區塊內，向後移一格
         if ((idx+1) % ((isColumnMajor)?RowItemNum:ColumnItemNum) == 0) {
         
         //向後一格需要換行
         item.transform = (isColumnMajor)?CGAffineTransformMakeTranslation(actualItemDisW, -(RowItemNum - 1) * actualItemDisH):
         CGAffineTransformMakeTranslation( -(ColumnItemNum - 1) * actualItemDisW,actualItemDisH);
         }
         else {
         //不需換行
         item.transform = (isColumnMajor)?CGAffineTransformMakeTranslation(0,actualItemDisH):
         CGAffineTransformMakeTranslation(actualItemDisW,0);
         }
         }
         else {
         item.transform = CGAffineTransformIdentity;
         }
         }
         }
         else {
         //向後移動
         if (itemIndex < movingItemInfo.ItemIndex) {
         item.transform = CGAffineTransformIdentity;
         }
         else {
         
         if ([self _checkPointIsFront:item.center beforePoint:movingItemInfo.center withIsColumnMajor:isColumnMajor]) {
         //在區塊內，向前移一格
         if ((idx-1) % ((isColumnMajor)?RowItemNum:ColumnItemNum) == 0) {
         
         //向前一格需要換行
         item.transform = (isColumnMajor)?CGAffineTransformMakeTranslation(-actualItemDisW, (RowItemNum - 1) * actualItemDisH):
         CGAffineTransformMakeTranslation( (ColumnItemNum - 1) * actualItemDisW,-actualItemDisH);
         }
         else {
         //不需換行
         item.transform = (isColumnMajor)?CGAffineTransformMakeTranslation(0,-actualItemDisH):
         CGAffineTransformMakeTranslation(-actualItemDisW,0);
         }
         }
         else {
         item.transform = CGAffineTransformIdentity;
         }
         }
         }
         
         
         }*/
        //        else {
        
        [self _RefreshItem:item 
             withItemIndex:itemIndex
            withAllItemNum:allItemsNum
                withIsLoop:isLoop
              withStartPos:startPos
           withCurrentItem:currentItem
            withItemCenter:itemCenter
         withIsColumnMajor:isColumnMajor
                   offsetX:offsetX
                   offsetY:offsetY
            actualItemDisW:actualItemDisW
            actualItemDisH:actualItemDisH];
        item.transform = CGAffineTransformIdentity;
        //       }
        
        
        
        
        //更新每個view的transform
        
        
        itemIndex++;
        currentItem++;
    }
}
/*
 -(void)setMovingItemIndex:(NSInteger)ItemIndex withTransform:(CGAffineTransform)transform
 {
 UIView *currentView = [self getItemWithIndex:ItemIndex];
 if (movingItemInfo == nil) {
 movingItemInfo = [[IPaMoveingItemInfo alloc] initWithItemIndex:ItemIndex withMovingView:currentView];
 movingItemInfo.transform = transform;
 }
 else{
 movingItemInfo.ItemIndex = ItemIndex;
 movingItemInfo.movingView = currentView;
 movingItemInfo.transform = transform;
 }
 }
 -(void)updateMovingItemTransform:(CGAffineTransform)transform
 {
 if (movingItemInfo == nil) {
 return;
 }
 movingItemInfo.transform = transform;
 [UIView animateWithDuration:0.1 animations:^(void)
 {
 [self RefreshScrollView];
 }];
 }
 -(void)removeMovingItem
 {
 if (movingItemInfo != nil) {
 if (movingItemInfo.extraView != nil) {
 [self.ipaDelegate configureIPaListScrollView:self withItem:movingItemInfo.movingView withIdx:movingItemInfo.extraViewItemIndex];
 [movingItemInfo.extraView removeFromSuperview];
 movingItemInfo.movingView = nil;
 }
 movingItemInfo = nil;
 [UIView animateWithDuration:0.1 animations:^(void)
 {
 [self RefreshScrollView];
 }];
 }
 }*/


//自動跳至下一頁，若沒有開啟loop則到最後一頁會停止
-(void)goNextPage
{
    BOOL isLoop = self.isLoop;    //    NSInteger currentPage = [self getCurrentPage];
    NSInteger currentPage = self.lastCurrentPage;
    if (isLoop) {
        [self setPage:currentPage + 1 animated:YES];
    }
    else {
        
        BOOL isColumnMajor = self.isColumnMajor;
        
        NSUInteger allItemsNum = [self.ipaDelegate IPaListScrollViewTotalItemsNum:self];
        
        NSUInteger maxPageNum = (isColumnMajor)?ceil((float)allItemsNum / RowItemNum) - ColumnItemNum:ceil((float)allItemsNum / ColumnItemNum) - RowItemNum;
        
        
        if (currentPage + 1 <= maxPageNum) {
            [self setPage:currentPage + 1 animated:YES];
        }    
        
        
    }
    
}
//回到上一頁，若沒有開啟loop則到第一頁會停止
-(void)backLastPage
{
    BOOL isLoop = self.isLoop;    //NSInteger currentPage = [self getCurrentPage];
    NSInteger currentPage = self.lastCurrentPage;
    if (isLoop || (currentPage > 0)) {
        [self setPage:currentPage - 1 animated:YES];
    }
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewWillBeginDragging:)]) {
        [self.ipaDelegate IPaListScrollViewWillBeginDragging:self];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self RefreshScrollView];
    if ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewDidScroll:)]) {
        [self.ipaDelegate IPaListScrollViewDidScroll:self];
    }
    if (self.backgroundImg != nil) {
        [self setNeedsDisplay];
    }
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self DoEndScrollingStuff];
    }
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self DoEndScrollingStuff];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    switch (workingScrollingAnim) {
        case SET_PAGE_ANIM:
            if ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewDidSetPageAnim:)]) {
                [self.ipaDelegate IPaListScrollViewDidSetPageAnim:self];
            }
            
            break;
        case END_SCROLL_TO_PAGE_ANIM:
        {
            
        }
        default:
            break;
    }
    if ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewStopOnItemPage:withPage:)]) {
        
        //若有需要作StopOnItemPage的callback時，在作以下的計算
        BOOL isColumnMajor = self.isColumnMajor;
        float itemWidth = [self.ipaDelegate IPaListScrollViewItemWidth:self];//self.frame.size.width / columnNum;
        float itemHeight = [self.ipaDelegate IPaListScrollViewItemHeight:self];//self.frame.size.height / rowNum;
        
        
        CGFloat DistanceX = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceX:)]?
        [self.ipaDelegate IPaListScrollViewItemDistanceX:self]:0;
        CGFloat DistanceY = [self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewItemDistanceY:)]?
        [self.ipaDelegate IPaListScrollViewItemDistanceY:self]:0;
        
        CGFloat actualItemDisW = DistanceX + itemWidth;
        CGFloat actualItemDisH = DistanceY + itemHeight; 
        
        NSInteger currentPage = [self _getCurrentPage:isColumnMajor 
                                       actualItemDisW:actualItemDisW actualItemDisH:actualItemDisH];
        
        
        //要將currentPage轉成一般的page，因為loop的時候，page有可能會亂七八糟
        NSUInteger allItemsNum = [self.ipaDelegate IPaListScrollViewTotalItemsNum:self];
        
        /*    NSUInteger rowNum = ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewRowItemsNum:)])?
         [self.ipaDelegate IPaListScrollViewRowItemsNum:self]:1;
         NSUInteger columnNum = ([self.ipaDelegate respondsToSelector:@selector(IPaListScrollViewColumnItemsNum:)])?
         [self.ipaDelegate IPaListScrollViewColumnItemsNum:self]:1;
         */
        NSUInteger totalRowItemNum = (isColumnMajor)?RowItemNum:ceil((float)allItemsNum / ColumnItemNum);
        NSUInteger totalColumnItemNum = (isColumnMajor)?ceil((float)allItemsNum / RowItemNum):ColumnItemNum;
        
        while (currentPage < 0) {
            currentPage += (isColumnMajor)?totalColumnItemNum:totalRowItemNum;
        }
        if (isColumnMajor) {
            if (totalColumnItemNum > 0) {
                currentPage = currentPage % totalColumnItemNum;
                [self.ipaDelegate IPaListScrollViewStopOnItemPage:self withPage:currentPage];
            }
            else {
                currentPage = 0;
            }
        }
        else {
            if (totalRowItemNum > 0) {
                currentPage = currentPage % totalRowItemNum;
                [self.ipaDelegate IPaListScrollViewStopOnItemPage:self withPage:currentPage];                
            }
            else {
                currentPage = 0;
            }
        }
    }
    workingScrollingAnim = NONE_ANIM;
    
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return ([self.ipaDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)])?[self.ipaDelegate viewForZoomingInScrollView:self]:nil;
}
@end
