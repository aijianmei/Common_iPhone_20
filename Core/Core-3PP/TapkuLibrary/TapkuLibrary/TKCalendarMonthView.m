//
//  TKCalendarMonthView.m
//  Created by Devin Ross on 6/10/10.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKCalendarMonthView.h"
#import "NSDate+TKCategory.h"
#import "TKGlobal.h"
#import "UIImage+TKCategory.h"
#import "TimeUtils.h"
//#import "UIImageUtil.h"

//#define kCalendImagesPath @"TapkuLibrary.bundle/Images/calendar/"
//#pragma mark -
//@interface NSDate (calendarcategory)
//
//- (NSDate*) firstOfMonth;
//- (NSDate*) nextMonth;
//- (NSDate*) previousMonth;
//
//@end


#pragma mark -

@implementation NSDate (calendarcategory)

- (NSDate*) firstOfMonth{
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info.day = 1;
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
}


- (NSDate*) chineseFirstOfMonth{
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
	info.day = 1;
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
}

- (NSDate*) nextMonth{
	
	
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info.month++;
	if(info.month>12){
		info.month = 1;
		info.year++;
	}
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
}

-(NSDate *)chineseNextMonth
{
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
	info.month++;
	if(info.month>12){
		info.month = 1;
		info.year++;
	}
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
}



- (NSDate*) previousMonth{
	
	
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info.month--;
	if(info.month<1){
		info.month = 12;
		info.year--;
	}
	
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
}

@end


#pragma mark -

@interface TKCalendarMonthTiles : UIView {
	
	id target;
	SEL action;
	
	int firstOfPrev,lastOfPrev;
	NSArray *marks;
	int today;
	BOOL markWasOnToday;
	
	int selectedDay,selectedPortion;
	
	int firstWeekday, daysInMonth;
	UILabel *dot;
	UILabel *currentDay;
	UIImageView *selectedImageView;
	BOOL startOnSunday;
	NSDate *monthDate;
    
    NSArray *markTexts;
    NSArray *markTextColors;
    CGFloat latticeHeight;
}
@property (readonly) NSDate *monthDate;

- (id) initWithMonth:(NSDate*)date
       latticeHeight:(CGFloat)height
               marks:(NSArray*)markArray
    startDayOnSunday:(BOOL)sunday
           markTexts:(NSArray *)markTextList
      markTextColors:(NSArray *)markTextColorList;


- (void) setTarget:(id)target action:(SEL)action;

- (void) selectDay:(int)day;
- (NSDate*) dateSelected;

+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday;

@end

#pragma mark -

#define dotFontSize 11.0
#define dateFontSize 18.0

@interface TKCalendarMonthTiles (private)

@property (readonly) UIImageView *selectedImageView;
@property (readonly) UILabel *currentDay;
@property (readonly) UILabel *dot;

@end

#pragma mark -

//#define HEIGHT_LATTICE 44
#define HEIGHT_LATTICE 55
#define WIDTH_LATTICE 46

#define HEIGHT_CURRENT_DAY 20

#define TOP_EDGE_CURRENT_DAY 6

@implementation TKCalendarMonthTiles
@synthesize monthDate;

+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday{
	
	NSDate *firstDate, *lastDate;
	
	TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info.day = 1;
	info.hour = 0;
	info.minute = 0;
	info.second = 0;
	
	NSDate *currentMonth = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info = [currentMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	
	NSDate *previousMonth = [currentMonth previousMonth];
	NSDate *nextMonth = [currentMonth nextMonth];
	
	if(info.weekday > 1 && sunday){
		
		TKDateInformation info2 = [previousMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		
		int preDayCnt = [previousMonth daysBetweenDate:currentMonth];		
		info2.day = preDayCnt - info.weekday + 2;
		firstDate = [NSDate dateFromDateInformation:info2 timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		
		
	}else if(!sunday && info.weekday != 2){
		
		TKDateInformation info2 = [previousMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		int preDayCnt = [previousMonth daysBetweenDate:currentMonth];
		if(info.weekday==1){
			info2.day = preDayCnt - 5;
		}else{
			info2.day = preDayCnt - info.weekday + 3;
		}
		firstDate = [NSDate dateFromDateInformation:info2 timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		
		
		
	}else{
		firstDate = currentMonth;
	}
	
	
	
	int daysInMonth = [currentMonth daysBetweenDate:nextMonth];		
	info.day = daysInMonth;
	NSDate *lastInMonth = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	TKDateInformation lastDateInfo = [lastInMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

	
	
	if(lastDateInfo.weekday < 7 && sunday){
		
		lastDateInfo.day = 7 - lastDateInfo.weekday;
		lastDateInfo.month++;
		lastDateInfo.weekday = 0;
		if(lastDateInfo.month>12){
			lastDateInfo.month = 1;
			lastDateInfo.year++;
		}
		lastDate = [NSDate dateFromDateInformation:lastDateInfo timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	}else if(!sunday && lastDateInfo.weekday != 1){
		
		
		lastDateInfo.day = 8 - lastDateInfo.weekday;
		lastDateInfo.month++;
		if(lastDateInfo.month>12){ lastDateInfo.month = 1; lastDateInfo.year++; }

		
		lastDate = [NSDate dateFromDateInformation:lastDateInfo timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

	}else{
		lastDate = lastInMonth;
	}
	
	return [NSArray arrayWithObjects:firstDate,lastDate,nil];
}

- (id) initWithMonth:(NSDate*)date
       latticeHeight:(CGFloat)height
               marks:(NSArray*)markArray
    startDayOnSunday:(BOOL)sunday
           markTexts:(NSArray *)markTextList
      markTextColors:(NSArray *)markTextColorList
{
	if(![super initWithFrame:CGRectZero]) return nil;

	firstOfPrev = -1;
	marks = [markArray retain];
    markTexts = [markTextList retain];
    markTextColors = [markTextColorList retain];
    
    latticeHeight = height;
    
	monthDate = [date retain];
    
	startOnSunday = sunday;
	
	TKDateInformation dateInfo = [monthDate dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	firstWeekday = dateInfo.weekday;
	
	
	NSDate *prev = [monthDate previousMonth];
	//NSDate *next = [monthDate nextMonth];
	
	daysInMonth = [[monthDate nextMonth] daysBetweenDate:monthDate];
	
	int row = (daysInMonth + dateInfo.weekday - 1);
	if(dateInfo.weekday==1&&!sunday) row = daysInMonth + 6;
	if(!sunday) row--;
	

	row = (row / 7) + ((row % 7 == 0) ? 0:1);
//	float h = 44 * row;
	float h = latticeHeight * row;
	
	TKDateInformation todayInfo = [[NSDate date] dateInformation];
	today = dateInfo.month == todayInfo.month && dateInfo.year == todayInfo.year ? todayInfo.day : -5;
	
	int preDayCnt = [prev daysBetweenDate:monthDate];		
	if(firstWeekday>1 && sunday){
		firstOfPrev = preDayCnt - firstWeekday+2;
		lastOfPrev = preDayCnt;
	}else if(!sunday && firstWeekday != 2){
		
		if(firstWeekday ==1){
			firstOfPrev = preDayCnt - 5;
		}else{
			firstOfPrev = preDayCnt - firstWeekday+3;
		}
		lastOfPrev = preDayCnt;

	}
	
	self.frame = CGRectMake(0, 1, 320, h+1);
	
	[self.selectedImageView addSubview:self.currentDay];
	[self.selectedImageView addSubview:self.dot];
	self.multipleTouchEnabled = NO;
    	
	return self;
}
- (void) dealloc {
	[currentDay release];
	[dot release];
	[selectedImageView release];
	[marks release];
    [markTexts release];
	[monthDate release];
    [super dealloc];
}

- (void) setTarget:(id)t action:(SEL)a{
	target = t;
	action = a;
}


- (CGRect) rectForCellAtIndex:(int)index{
	
	int row = index / 7;
	int col = index % 7;
	
//	return CGRectMake(col*46, row*44+6, 47, 45);
    return CGRectMake(col*WIDTH_LATTICE, row*latticeHeight+6, WIDTH_LATTICE + 1, latticeHeight + 1);
    
}
- (void) drawTileInRect:(CGRect)r day:(int)day mark:(BOOL)mark markText:(NSString *)text font:(UIFont*)f1 font2:(UIFont*)f2 color1:(UIColor *)color1 color2:(UIColor *)color2{
	
	[color1 set];
    
	NSString *str = [NSString stringWithFormat:@"%d",day];
	
	r.size.height -= 2;
    r.origin.y -= 4;

	[str drawInRect: r
		   withFont: f1
	  lineBreakMode: UILineBreakModeWordWrap 
		  alignment: UITextAlignmentCenter];
	
    [color2 set];
	if(mark){
		r.size.height = 10;
        r.origin.y += 22;

		NSArray *tA = [text componentsSeparatedByString:@"\n"];
        
        for (NSString *t in tA) {
            [t drawInRect: r
                 withFont: f2
            lineBreakMode: UILineBreakModeWordWrap 
                alignment: UITextAlignmentCenter];
            r.origin.y += 12;
        }
	}
}

- (void) drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
//	UIImage *tile = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile.png")];
    UIImage* tile = [UIImage imageNamed:@"date_t_bg.png"]; //非今天,非选中日期的image
//    UIImage *tile =  [UIImage imageNamed:@"all_page_bg@2x.jpg"];
//	CGRect r = CGRectMake(0, 0, 46, 44);
    CGRect r = CGRectMake(0, 0, WIDTH_LATTICE, latticeHeight);

	CGContextDrawTiledImage(context, r, tile.CGImage);
	
	if(today > 0){
		int pre = firstOfPrev > 0 ? lastOfPrev - firstOfPrev + 1 : 0;
		int index = today +  pre-1;
		CGRect r =[self rectForCellAtIndex:index];
		r.origin.y -= 7;
		[[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Tile.png")] drawInRect:r];   //今天日期的image
//        [[UIImage imageNamed:@"date_tile_selected_bg.png"] drawInRect:r];

	}
	
	int index = 0;
	
	UIFont *font = [UIFont boldSystemFontOfSize:dateFontSize];
	UIFont *font2 =[UIFont systemFontOfSize:dotFontSize];
    UIColor *color1 = [UIColor colorWithRed:172./255. green:172./255. blue:172./255. alpha:1];
	//UIColor *color2 = [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1];

	if(firstOfPrev>0){
		for(int i = firstOfPrev;i<= lastOfPrev;i++){
			r = [self rectForCellAtIndex:index];
			if ([marks count] > 0)
//				[self drawTileInRect:r day:i mark:[[marks objectAtIndex:index] boolValue] markText:[markTexts objectAtIndex:index] font:font font2:font2 color1:color1 color2:color2];
                [self drawTileInRect:r day:i mark:NO markText:nil font:font font2:font2 color1:color1 color2:[markTextColors objectAtIndex:index]];

			else
				[self drawTileInRect:r day:i mark:NO markText:nil font:font font2:font2 color1:color1 color2:[markTextColors objectAtIndex:index]];
			index++;
		}
	}
	
	color1 = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
	for(int i=1; i <= daysInMonth; i++){
		
		r = [self rectForCellAtIndex:index];
		if(today == i) [[UIColor whiteColor] set];
		
		if ([marks count] > 0) 
			[self drawTileInRect:r day:i mark:[[marks objectAtIndex:index] boolValue] markText:[markTexts objectAtIndex:index] font:font font2:font2 color1:color1 color2:[markTextColors objectAtIndex:index]];
		else
			[self drawTileInRect:r day:i mark:NO markText:[markTexts objectAtIndex:index] font:font font2:font2 color1:color1 color2:[markTextColors objectAtIndex:index]];
//		if(today == i) [color set];
		index++;
	}
	
//	color1 = [UIColor grayColor];
    color1 = [UIColor colorWithRed:172./255. green:172./255. blue:172./255. alpha:1];
	int i = 1;
	while(index % 7 != 0){
		r = [self rectForCellAtIndex:index] ;
		if ([marks count] > 0) 
//			[self drawTileInRect:r day:i mark:[[marks objectAtIndex:index] boolValue] markText:[markTexts objectAtIndex:index] font:font font2:font2 color1:color1 color2:color2];
            [self drawTileInRect:r day:i mark:NO markText:nil font:font font2:font2 color1:color1 color2:[markTextColors objectAtIndex:index]];

		else
			[self drawTileInRect:r day:i mark:NO markText:nil font:font font2:font2 color1:color1 color2:[markTextColors objectAtIndex:index]];
		i++;
		index++;
	}
	
	
}

- (void) selectDay:(int)day{
	
	int pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
	
	int tot = day + pre;
	int row = tot / 7;
	int column = (tot % 7)-1;
	
	selectedDay = day;
	selectedPortion = 1;
	
	
	if(day == today){
		self.currentDay.shadowOffset = CGSizeMake(0, 1);
		self.dot.shadowOffset = CGSizeMake(0, 1);
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Selected Tile.png")];//目前没有发现该image有什么作用
//        self.selectedImageView.image = [UIImage imageNamed:@"date_t_bg2@2x.png"];
//        self.selectedImageView.image = [UIImage imageNamed:@"all_page_bg2.jpg"];
		markWasOnToday = YES;
	}else if(markWasOnToday){
		self.dot.shadowOffset = CGSizeMake(0, -1);
		self.currentDay.shadowOffset = CGSizeMake(0, -1);
		
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png")];//目前没有发现该image的作用
//        self.selectedImageView.image = [UIImage imageNamed:@"date_tile_selected_bg.png"];
//        self.selectedImageView.image = [UIImage imageNamed:@"all_page_bg2.jpg"];

		markWasOnToday = NO;
	}
	
	
	
	[self addSubview:self.selectedImageView];

	self.currentDay.text = [NSString stringWithFormat:@"%d",day];
	
	if ([marks count] > 0) {
		
		if([[marks objectAtIndex: row * 7 + column ] boolValue]){
			[self.selectedImageView addSubview:self.dot];
            self.dot.text = [markTexts objectAtIndex: row * 7 + column];
		}else{
			[self.dot removeFromSuperview];
		}
		
		
	}else{
		[self.dot removeFromSuperview];
	}
	
	if(column < 0){
		column = 6;
		row--;
	}
	
	CGRect r = self.selectedImageView.frame;
//	r.origin.x = (column*46);
	r.origin.x = (column*WIDTH_LATTICE);

//	r.origin.y = (row*44)-1;
    r.origin.y = (row*latticeHeight)-1;

	self.selectedImageView.frame = r;
}

- (NSDate*) dateSelected{
	if(selectedDay < 1 || selectedPortion != 1) return nil;
	
	TKDateInformation info = [monthDate dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info.hour = 0;
	info.minute = 0;
	info.second = 0;
	info.day = selectedDay;
	NSDate *d = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	return d;	
}



- (void) reactToTouch:(UITouch*)touch down:(BOOL)down{
	
	CGPoint p = [touch locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0) return;
	
//	int column = p.x / 46, row = p.y / 44;
    int column = p.x / WIDTH_LATTICE, row = p.y / latticeHeight;

	int day = 1, portion = 0;
	
//	if(row == (int) (self.bounds.size.height / 44)) row --;
    if(row == (int) (self.bounds.size.height / latticeHeight)) row --;

	
	int fir = firstWeekday - 1;
	if(!startOnSunday && fir == 0) fir = 7;
	if(!startOnSunday) fir--;
	
	
	if(row==0 && column < fir){
		day = firstOfPrev + column;
	}else{
		portion = 1;
		day = row * 7 + column  - firstWeekday+2;
		if(!startOnSunday) day++;
		if(!startOnSunday && fir==6) day -= 7;

	}
	if(portion > 0 && day > daysInMonth){
		portion = 2;
		day = day - daysInMonth;
	}
	
	
	if(portion != 1){
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png")];//点击暗色日期后，该image起作用了
//        self.selectedImageView.image = [UIImage imageNamed:@"date_tile_bg.png"];
		markWasOnToday = YES;
	}else if(portion==1 && day == today){
		self.currentDay.shadowOffset = CGSizeMake(0, 1);
		self.dot.shadowOffset = CGSizeMake(0, 1);
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Selected Tile.png")];//目前没有发现这个image的作用
//        self.selectedImageView.image = [UIImage imageNamed:@"date_tile_selected_bg.png"];
//        self.selectedImageView.image = [UIImage imageNamed:@"all_page_bg2.jpg"];
		markWasOnToday = YES;
	}else if(markWasOnToday){
		self.dot.shadowOffset = CGSizeMake(0, -1);
		self.currentDay.shadowOffset = CGSizeMake(0, -1);
//		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png")];
        self.selectedImageView.image = [UIImage imageNamed:@"date_t_bg2.png"];//点击较暗的日期后，如果再点击其他日期时候时，此处的image便会起作用
		markWasOnToday = NO;
	}
	
	[self addSubview:self.selectedImageView];

	self.currentDay.text = [NSString stringWithFormat:@"%d",day];
	
	if ([marks count] > 0) {
		if([[marks objectAtIndex: row * 7 + column] boolValue]){
            [self.selectedImageView addSubview:self.dot];
//            self.dot.text = [markTexts objectAtIndex: row * 7 + column];
            self.dot.text = ((portion == 1) ? [markTexts objectAtIndex: row * 7 + column] : @"");
        }
		else
			[self.dot removeFromSuperview];
	}else{
		[self.dot removeFromSuperview];
	}
	

	
	
	CGRect r = self.selectedImageView.frame;
//	r.origin.x = (column*46);
    r.origin.x = (column*WIDTH_LATTICE);
//	r.origin.y = (row*44)-1;
    r.origin.y = (row*latticeHeight)-1;

	self.selectedImageView.frame = r;
	
	if(day == selectedDay && selectedPortion == portion) return;
	
	if(portion == 1){
		selectedDay = day;
		selectedPortion = portion;
		[target performSelector:action withObject:[NSArray arrayWithObject:[NSNumber numberWithInt:day]]];
	}
	else if(down){
		[target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil]];
		selectedDay = day;
		selectedPortion = portion;
	}
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	//[super touchesBegan:touches withEvent:event];
	[self reactToTouch:[touches anyObject] down:NO];
} 
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[self reactToTouch:[touches anyObject] down:NO];
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//	[self reactToTouch:[touches anyObject] down:YES];
}

- (UILabel *) currentDay{
	if(currentDay==nil){
//		CGRect r = self.selectedImageView.bounds;
//		r.origin.y -= 2;
        
        CGRect r = CGRectMake(0, 0, WIDTH_LATTICE, HEIGHT_CURRENT_DAY);
		r.origin.y += TOP_EDGE_CURRENT_DAY;
    
		currentDay = [[UILabel alloc] initWithFrame:r];
		currentDay.text = @"1";
        currentDay.textColor = [UIColor whiteColor];
    /* NOTE By Tonny
     * -------------
     * Aug 18, 2011
     * 
     * White over light green is a little bit dizzy
     * 
     */

//		currentDay.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];//this file @364 //
		currentDay.backgroundColor = [UIColor clearColor];
		currentDay.font = [UIFont boldSystemFontOfSize:dateFontSize];
		currentDay.textAlignment = UITextAlignmentCenter;
		currentDay.shadowColor = [UIColor darkGrayColor];
		currentDay.shadowOffset = CGSizeMake(0, -1);
	}
	return currentDay;
}

- (UILabel *) dot{
	if(dot==nil ){
		CGRect r = self.selectedImageView.bounds;
//		r.origin.y += 35;
//		r.size.height -= 31;
        r.origin.y += 21;
        r.size.height -= HEIGHT_CURRENT_DAY;

		dot = [[UILabel alloc] initWithFrame:r];
		
		dot.text = @"•";
//        NSLog(@"call dot, %@", dot.text);
		dot.textColor = [UIColor whiteColor];
		dot.backgroundColor = [UIColor clearColor];
		dot.font = [UIFont boldSystemFontOfSize:dotFontSize];
		dot.textAlignment = UITextAlignmentCenter;
		dot.shadowColor = [UIColor darkGrayColor];
		dot.shadowOffset = CGSizeMake(0, -1);
        dot.numberOfLines = 3;
	}
	return dot;
}

- (UIImageView *) selectedImageView{
	if(selectedImageView==nil){
		selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected"]];
//        selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"date_tile_selected_bg.png"]];
        selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_LATTICE, latticeHeight)];
//        selectedImageView.image = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected"];
        selectedImageView.image = [UIImage imageNamed:@"date_t_bg2@2x.png"]; //选中日期的image
        
	}
	return selectedImageView;
}

@end

#pragma mark -

@interface TKCalendarMonthView (private)

@property (readonly) UIScrollView *tileBox;
@property (readonly) UIImageView *topBackground;
@property (readonly) UILabel *monthYear;
@property (readonly) UIButton *leftArrow;
@property (readonly) UIButton *rightArrow;
@property (readonly) UIImageView *shadow;

@end

#pragma mark -
@implementation TKCalendarMonthView
@synthesize delegate,dataSource;


- (id) init{
	self = [self initWithSundayAsFirst:YES];
	return self;
}
- (id) initWithSundayAsFirst:(BOOL)s{    
    [self initWithSundayAsFirst:s 
                           date:[NSDate date] 
           hasMonthYearAndArrow:YES
               hasTopBackground:YES
                      hasShadow:YES 
          userInteractionEnable:YES];
    
	return self;
}

- (id) initWithSundayAsFirst:(BOOL)s
                        date:(NSDate *)date
        hasMonthYearAndArrow:(BOOL)hasMonthYearAndArr
            hasTopBackground:(BOOL)hasTopBackground
                   hasShadow:(BOOL)hasShadow
       userInteractionEnable:(BOOL)enable
{
	if (!(self = [super initWithFrame:CGRectZero])) return nil;
//	self.backgroundColor = [UIColor grayColor];
    self.backgroundColor = [UIColor clearColor];
    
	sunday = s;
    hasMonthYearAndArrow = hasMonthYearAndArr;
    userInteractionEnable = enable;
    latticeHeight = HEIGHT_LATTICE;
	
	currentTile = [[[TKCalendarMonthTiles alloc] initWithMonth:[date firstOfMonth] 
                                                 latticeHeight:latticeHeight
                                                         marks:nil 
                                              startDayOnSunday:sunday
                                                     markTexts:nil markTextColors:nil] autorelease];
    
    if (userInteractionEnable) {
        [currentTile setTarget:self action:@selector(tile:)];
        
//        [currentTile setTarget:self action:@selector(tile:)];
    }

	CGRect r = CGRectMake(0, 0, self.tileBox.bounds.size.width, self.tileBox.bounds.size.height + self.tileBox.frame.origin.y);
    
	self.frame = r;
	
	[currentTile retain];
	
    if (hasTopBackground) {
        [self addSubview:self.topBackground];
    }
    
	[self.tileBox addSubview:currentTile];
	[self addSubview:self.tileBox];
    
    
	
	if (hasMonthYearAndArrow) {
        self.monthYear.text = [NSString stringWithFormat:@"%@",[date monthYearString]];
        [self addSubview:self.monthYear];
        [self addSubview:self.leftArrow];
        [self addSubview:self.rightArrow];
    }

    if (hasShadow) {
        [self addSubview:self.shadow];
        self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
    }
	
    [self addWeeks];
	
	return self;
}

- (void)addWeeks
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"eee"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
    TKDateInformation sund;
	sund.day = 5;
	sund.month = 12;
	sund.year = 2010;
	sund.hour = 0;
	sund.minute = 0;
	sund.second = 0;
	sund.weekday = 0;
	
	
	NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];
    //	NSString * sun = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
    NSString *sun = chineseWeekDay2FromDate([NSDate dateFromDateInformation:sund timeZone:tz]);
    
	sund.day = 6;
    //	NSString *mon = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
    NSString *mon = chineseWeekDay2FromDate([NSDate dateFromDateInformation:sund timeZone:tz]);
    
	sund.day = 7;
    //	NSString *tue = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
    NSString *tue = chineseWeekDay2FromDate([NSDate dateFromDateInformation:sund timeZone:tz]);
    
	sund.day = 8;
    //	NSString *wed = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
    NSString *wed = chineseWeekDay2FromDate([NSDate dateFromDateInformation:sund timeZone:tz]);
    
	sund.day = 9;
    //	NSString *thu = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
    NSString *thu = chineseWeekDay2FromDate([NSDate dateFromDateInformation:sund timeZone:tz]);
    
	sund.day = 10;
    //	NSString *fri = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	NSString *fri = chineseWeekDay2FromDate([NSDate dateFromDateInformation:sund timeZone:tz]);
	
	sund.day = 11;
    //	NSString *sat = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	NSString *sat = chineseWeekDay2FromDate([NSDate dateFromDateInformation:sund timeZone:tz]);
	
	[dateFormat release];
    
	NSArray *ar;
	if(sunday) ar = [NSArray arrayWithObjects:sun,mon,tue,wed,thu,fri,sat,nil];
	else ar = [NSArray arrayWithObjects:mon,tue,wed,thu,fri,sat,sun,nil];
	
	int i = 0;
	for(NSString *s in ar){
		
        //		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(46 * i, 29, 46, 15)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH_LATTICE * i, 29, WIDTH_LATTICE, 15)];
        
		[self addSubview:label];
		label.text = s;
		label.textAlignment = UITextAlignmentCenter;
		label.shadowColor = [UIColor whiteColor];
		label.shadowOffset = CGSizeMake(0, 1);
		label.font = [UIFont systemFontOfSize:11];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
        
		i++;
		[label release];
	}
}

- (void) dealloc {
	[shadow release];
	[topBackground release];
	[leftArrow release];
	[monthYear release];
	[rightArrow release];
	[tileBox release];
	[currentTile release];
    [super dealloc];
}


- (NSDate*) dateForMonthChange:(UIView*)sender {
	BOOL isNext = (sender.tag == 1);
	NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonth] : [currentTile.monthDate previousMonth];
	
	TKDateInformation nextInfo = [nextMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate *localNextMonth = [NSDate dateFromDateInformation:nextInfo];
	
	return localNextMonth;
}

- (void) changeMonthAnimation:(UIView*)sender{
	
	BOOL isNext = (sender.tag == 1);
	NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonth] : [currentTile.monthDate previousMonth];
	
	TKDateInformation nextInfo = [nextMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate *localNextMonth = [NSDate dateFromDateInformation:nextInfo];
	
	
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:nextMonth startOnSunday:sunday];
	NSArray *ar = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    NSArray *markTexts = [dataSource calendarMonthView:self markTextsFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    NSArray *markTextColors = [dataSource calendarMonthView:self markTextColorsFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    
	TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:nextMonth
                                                                  latticeHeight:latticeHeight
                                                                          marks:ar
                                                               startDayOnSunday:sunday 
                                                                      markTexts:markTexts markTextColors:markTextColors];
    
    if (userInteractionEnable) {
        [newTile setTarget:self action:@selector(tile:)];
    }
	
	int overlap =  0;
	
	if(isNext){
//		overlap = [newTile.monthDate isEqualToDate:[dates objectAtIndex:0]] ? 0 : 44;
        overlap = [newTile.monthDate isEqualToDate:[dates objectAtIndex:0]] ? 0 : latticeHeight;

	}else{
//		overlap = [currentTile.monthDate compare:[dates lastObject]] !=  NSOrderedDescending ? 44 : 0;
        overlap = [currentTile.monthDate compare:[dates lastObject]] !=  NSOrderedDescending ? latticeHeight : 0;
	}
	
	float y = isNext ? currentTile.bounds.size.height - overlap : newTile.bounds.size.height * -1 + overlap +2;
	
	newTile.frame = CGRectMake(0, y, newTile.frame.size.width, newTile.frame.size.height);
	newTile.alpha = 0;
	[self.tileBox addSubview:newTile];
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1];
	newTile.alpha = 1;

	[UIView commitAnimations];
	
	
	
	self.userInteractionEnabled = NO;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(animationEnded)];
	[UIView setAnimationDelay:0.1];
	[UIView setAnimationDuration:0.4];
	
	
	
	if(isNext){
		
		currentTile.frame = CGRectMake(0, -1 * currentTile.bounds.size.height + overlap + 2, currentTile.frame.size.width, currentTile.frame.size.height);
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
		
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		
		
	}else{
		
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
		currentTile.frame = CGRectMake(0,  newTile.frame.size.height - overlap, currentTile.frame.size.width, currentTile.frame.size.height);
		
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		
	}
	
	
	[UIView commitAnimations];
	
	oldTile = currentTile;
	currentTile = newTile;
	
	
	
	monthYear.text = [NSString stringWithFormat:@"%@",[localNextMonth monthYearString]];
	
	

}
- (void) changeMonth:(UIButton *)sender{
	
	NSDate *newDate = [self dateForMonthChange:sender];
	if ([delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![delegate calendarMonthView:self monthShouldChange:newDate animated:YES] ) 
		return;
	
	
	if ([delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] ) 
		[delegate calendarMonthView:self monthWillChange:newDate animated:YES];
	

	
	
	[self changeMonthAnimation:sender];
	if([delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
		[delegate calendarMonthView:self monthDidChange:currentTile.monthDate animated:YES];

}
- (void) animationEnded{
	self.userInteractionEnabled = YES;
	[oldTile removeFromSuperview];
	[oldTile release];
	oldTile = nil;
}

- (NSDate*) dateSelected{
	return [currentTile dateSelected];
}
- (NSDate*) monthDate{
	return [currentTile monthDate];
}
- (void) selectDate:(NSDate*)date{
	//TKDateInformation info = [date dateInformation];
	TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	NSDate *month = [date firstOfMonth];
//    NSDate *month = [date nextMonth];

	
	if([month isEqualToDate:[currentTile monthDate]]){
		[currentTile selectDay:info.day];
		return;
	}else {
		
		if ([delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![delegate calendarMonthView:self monthShouldChange:month animated:YES] ) 
			return;
		
		if ([delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] )
			[delegate calendarMonthView:self monthWillChange:month animated:YES];
		
		
		NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:month startOnSunday:sunday];
		NSArray *data = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
        NSArray *markTexts = [dataSource calendarMonthView:self markTextsFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
        NSArray *markTextColors = [dataSource calendarMonthView:self markTextColorsFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];

		TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:month 
                                                                      latticeHeight:latticeHeight
																			  marks:data 
																   startDayOnSunday:sunday
                                                                          markTexts:markTexts markTextColors:markTextColors];
        if (userInteractionEnable) {
            [newTile setTarget:self action:@selector(tile:)];
        }
		[currentTile removeFromSuperview];
		[currentTile release];
		currentTile = newTile;
		[self.tileBox addSubview:currentTile];
//		self.tileBox.frame = CGRectMake(0, 44, newTile.frame.size.width, newTile.frame.size.height);
        self.tileBox.frame = CGRectMake(0, 44, newTile.frame.size.width, newTile.frame.size.height);

		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);

		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		self.monthYear.text = [NSString stringWithFormat:@"%@",[date monthYearString]];
		[currentTile selectDay:info.day];
		
		if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
			[self.delegate calendarMonthView:self monthDidChange:date animated:NO];
	}
}

- (void) reload{
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:[currentTile monthDate] startOnSunday:sunday];
	NSArray *ar = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    NSArray *markTexts = [dataSource calendarMonthView:self markTextsFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    NSArray *markTextColors = [dataSource calendarMonthView:self markTextColorsFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];

	TKCalendarMonthTiles *refresh = [[[TKCalendarMonthTiles alloc] initWithMonth:[currentTile monthDate] 
                                                                   latticeHeight:latticeHeight
                                                                           marks:ar 
                                                                startDayOnSunday:sunday 
                                                                       markTexts:markTexts markTextColors:markTextColors] autorelease];
    if (userInteractionEnable) {
        [refresh setTarget:self action:@selector(tile:)];
    }
	
	[self.tileBox addSubview:refresh];
	[currentTile removeFromSuperview];
	[currentTile release];
	currentTile = [refresh retain];
	
}

- (void) tile:(NSArray*)ar{
	
	if([ar count] < 2){
		
		if([delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
			[delegate calendarMonthView:self didSelectDate:[self dateSelected]];
	
	}else{
		
		int direction = [[ar lastObject] intValue];
		UIButton *b = direction > 1 ? self.rightArrow : self.leftArrow;
		
		NSDate* newMonth = [self dateForMonthChange:b];
		if ([delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![delegate calendarMonthView:self monthShouldChange:newMonth animated:YES])
			return;
		
		if ([delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)])					
			[delegate calendarMonthView:self monthWillChange:newMonth animated:YES];
		
		
		
		[self changeMonthAnimation:b];
		
		int day = [[ar objectAtIndex:0] intValue];

	
		// thanks rafael
		TKDateInformation info = [[currentTile monthDate] dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		info.day = day;
        
        NSDate *dateForMonth = [NSDate dateFromDateInformation:info  timeZone:[NSTimeZone timeZoneWithName:@"GMT"]]; 
		[currentTile selectDay:day];
		
		
		if([delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
			[delegate calendarMonthView:self didSelectDate:dateForMonth];
		
		if([delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
			[delegate calendarMonthView:self monthDidChange:dateForMonth animated:YES];

		
	}
	
}

#pragma mark Properties
- (UIImageView *) topBackground{
	if(topBackground==nil){
		topBackground = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Grid Top Bar.png")]];//目前没有发现这个image的作用
        
        CGFloat height = hasMonthYearAndArrow ? 44 : 18;
        topBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44 - height, self.bounds.size.width, height)];
        topBackground.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Grid Top Bar.png")];//目前没有发现这个image的作用

	}
	return topBackground;
}
- (UILabel *) monthYear{
	if(monthYear==nil){
		monthYear = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tileBox.frame.size.width, 38)];
		
		monthYear.textAlignment = UITextAlignmentCenter;
		monthYear.backgroundColor = [UIColor clearColor];
		monthYear.font = [UIFont boldSystemFontOfSize:22];
		monthYear.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
	}
	return monthYear;
}
- (UIButton *) leftArrow{
	if(leftArrow==nil){
		leftArrow = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		leftArrow.tag = 0;
		[leftArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
		
		[leftArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Left Arrow"] forState:0];
		
		leftArrow.frame = CGRectMake(0, 0, 48, 38);
	}
	return leftArrow;
}
- (UIButton *) rightArrow{
	if(rightArrow==nil){
		rightArrow = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		rightArrow.tag = 1;
		[rightArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
		rightArrow.frame = CGRectMake(320-45, 0, 48, 38);
		


		[rightArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Right Arrow"] forState:0];
		
	}
	return rightArrow;
}
- (UIScrollView *) tileBox{
	if(tileBox==nil){
//		tileBox = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, currentTile.frame.size.height)];
        tileBox = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, currentTile.frame.size.height)];

	}
	return tileBox;
}
- (UIImageView *) shadow{
	if(shadow==nil){
		shadow = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Shadow.png")]];//目前没发现该image的作用
	}
	return shadow;
}

- (void)hideLeftArrow:(BOOL)isHide
{
    leftArrow.hidden = isHide;
}

- (void)hideRightArrow:(BOOL)isHide
{
    rightArrow.hidden= isHide;
}

@end