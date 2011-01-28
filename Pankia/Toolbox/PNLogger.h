/*
 *  PNLogger.h
 *  PankakuNet
 *
 *  Created by sota2 on 10/10/21.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifdef DEBUG
#  define PNAssert(condition, msg) NSAssert(condition, msg)
#  define PNCLog(cat, ...) { if (cat == YES) NSLog(__VA_ARGS__); }
#  define PNSplitLog(cat) { if (cat == YES) NSLog(@"---- ---- ---- ---- ---- ---- ---- ----"); }
#  define PNDebugNotice(cat, title) { if (cat == YES) ;}
#  define PNLogMethodName       //NSLog(@"%s", __func__)
#else
#  define PNAssert(condition, msg) ;
#  define PNCLog(...) ;
#  define PNSplitLog(cat) ;
#  define PNDebugNotice(cat, title) ;
#  define PNLogMethodName 
#endif

// This method might be extended in the future
#define PNWarn(...) NSLog(__VA_ARGS__)
#define PNPrintError(error) {if(error) {PNWarn(@"Error code: %@",error.errorCode);} }