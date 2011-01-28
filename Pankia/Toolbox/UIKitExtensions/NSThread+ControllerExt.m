#import "NSThread+ControllerExt.h"
#include <pthread.h>


int getMaxPriority() {
	return sched_get_priority_max(2);
}

int getMinPriority() {
	return sched_get_priority_min(2);
}

void setThreadParams(int priority,int schedule_type) {
	pthread_t tid;
	int ret;
	struct sched_param param;
	int policy;
	
	tid = pthread_self();
	
	/* sched_priority will be the priority of the thread */
	param.sched_priority = priority;
	
	// ラウンドロビン方式(SCHED_OTHER)だとPOSIXの仕様上プライオリティが関係なくなるが、若干作用するみたい。
	// キューイング方式(SCHED_FIFO)にすればプライオリティが効くようになるが、他のスレッドに移らなくなる可能性がある。
	policy = schedule_type;
	
	/* scheduling parameters of target thread */
	ret = pthread_setschedparam(tid, policy, &param);
}

NSString *printThreadInfo() {
	pthread_t tid;
	int ret;
	struct sched_param param;
	int policy;
	tid = pthread_self();
	ret = pthread_getschedparam (tid, &policy, &param);
	char *policy_cs;
	switch(policy) {
		case SCHED_OTHER:{
			policy_cs = "SCHED_OTHER";
		}break;
#ifdef POSIX_DESKTOP
		case SCHED_BATCH:{
			policy_cs = "SCHED_OTHER";
		}break;
		case SCHED_IDLE:{
			policy_cs = "SCHED_IDLE";
		}break;
#endif
		case SCHED_FIFO:{
			policy_cs = "SCHED_FIFO";
		}break;
		case SCHED_RR:{
			policy_cs = "SCHED_RR";
		}break;
		default:
			policy_cs = "SCHED_UNKNOWN";
			break;
	}
	return [NSString stringWithFormat:@"PID:(%d) MIN:(%d) MAX:(%d) P:%d %s",tid,sched_get_priority_min(2),sched_get_priority_max(2),param.sched_priority, policy_cs];
}

@implementation NSThread(Controller)


+(void)changeThreadModeToQueueWithPriority:(int)priority {
	float s = priority/100.0;
	int min = getMinPriority();
	int max = getMaxPriority();
	int off = (int)((max - min)*s);
	setThreadParams(min+off,SCHED_FIFO);
}

+(void)changeThreadModeToRoundRobin {
	float s = 50/100.0;
	int min = getMinPriority();
	int max = getMaxPriority();
	int off = (int)((max - min)*s);
	setThreadParams(min+off,SCHED_OTHER);
}

+(NSString*)threadInformation {
	return printThreadInfo();
}

@end


