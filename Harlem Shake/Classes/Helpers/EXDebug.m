//
//  EXDebug.m
//

#import "EXDebug.h"

#ifndef EXDEBUGCOMPONENTS
#define EXDEBUGCOMPONENTS EXDBGCOMP_ANY
#endif 


#ifndef EXDEBUGLEVEL
#define EXDEBUGLEVEL EXDBGLVL_DBG
#endif


#ifdef EXDEBUGENABLED

static double s_start_time = 0;

void Timing_MarkStartTime() {	
	s_start_time = CFAbsoluteTimeGetCurrent();
}

double Timing_GetElapsedTime() {	
	return CFAbsoluteTimeGetCurrent() - s_start_time;
}


#endif



