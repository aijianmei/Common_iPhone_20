//
//  AutoCreateViewByXib.h
//  Draw
//
//  Created by Kira on 12-11-17.
//
//

#ifndef Draw_AutoCreateViewByXib_h
#define Draw_AutoCreateViewByXib_h

#define AUTO_CREATE_VIEW_BY_XIB(classname) \
\
+ (id)createView \
{ \
NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@""#classname"" owner:self options:nil];\
if (topLevelObjects == nil || [topLevelObjects count] <= 0){\
NSLog(@"create "#classname" but cannot find cell object from Nib");\
return nil;\
}\
return [topLevelObjects objectAtIndex:0]; \
}

#define AUTO_CREATE_VIEW_BY_XIBS(classname, n) \
\
+ (id)createView \
{ \
NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@""#classname"" owner:self options:nil];\
if (topLevelObjects == nil || [topLevelObjects count] <= n){\
NSLog(@"create "#classname" but cannot find cell object from Nib");\
return nil;\
}\
return [topLevelObjects objectAtIndex:n]; \
}

#endif
