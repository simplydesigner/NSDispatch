//
//  NSDispatchQueue.m
//  NSDispatch
//

#import "NSDispatchGroup.h"
#import "NSDispatchQueue.h"

static NSDispatchQueue *mainQueue;
static NSDispatchQueue *globalQueue;
static NSDispatchQueue *highPriorityGlobalQueue;
static NSDispatchQueue *lowPriorityGlobalQueue;
static NSDispatchQueue *backgroundPriorityGlobalQueue;

@interface NSDispatchQueue ()
@property (strong, readwrite, nonatomic) dispatch_queue_t dispatchQueue;
@end

@implementation NSDispatchQueue

#pragma mark Global queue accessors.

+ (NSDispatchQueue *)mainQueue {
  return mainQueue;
}

+ (NSDispatchQueue *)globalQueue {
  return globalQueue;
}

+ (NSDispatchQueue *)highPriorityGlobalQueue {
  return highPriorityGlobalQueue;
}

+ (NSDispatchQueue *)lowPriorityGlobalQueue {
  return lowPriorityGlobalQueue;
}

+ (NSDispatchQueue *)backgroundPriorityGlobalQueue {
  return backgroundPriorityGlobalQueue;
}

#pragma mark Lifecycle.

+ (void)initialize {
  if (self == [NSDispatchQueue class]) {
    mainQueue = [[NSDispatchQueue alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    globalQueue = [[NSDispatchQueue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    highPriorityGlobalQueue = [[NSDispatchQueue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    lowPriorityGlobalQueue = [[NSDispatchQueue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)];
    backgroundPriorityGlobalQueue = [[NSDispatchQueue alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
  }
}

- (instancetype)init {
  return [self initSerial];
}

- (instancetype)initSerial {
  return [self initWithDispatchQueue:dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)];
}

- (instancetype)initConcurrent {
  return [self initWithDispatchQueue:dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)];
}

- (instancetype)initWithDispatchQueue:(dispatch_queue_t)dispatchQueue {
  if ((self = [super init]) != nil) {
    self.dispatchQueue = dispatchQueue;
  }
  
  return self;
}

#pragma mark Public block methods.

- (void)queueBlock:(dispatch_block_t)block {
  dispatch_async(self.dispatchQueue, block);
}

- (void)queueBlock:(dispatch_block_t)block afterDelay:(double)seconds {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (seconds * NSEC_PER_SEC)), self.dispatchQueue, block);
}

- (void)queueAndAwaitBlock:(dispatch_block_t)block {
  dispatch_sync(self.dispatchQueue, block);
}

- (void)queueAndAwaitBlock:(void (^)(size_t))block iterationCount:(size_t)count {
  dispatch_apply(count, self.dispatchQueue, block);
}

- (void)queueBlock:(dispatch_block_t)block inGroup:(NSDispatchGroup *)group {
  dispatch_group_async(group.dispatchGroup, self.dispatchQueue, block);
}

- (void)queueNotifyBlock:(dispatch_block_t)block inGroup:(NSDispatchGroup *)group {
  dispatch_group_notify(group.dispatchGroup, self.dispatchQueue, block);
}

- (void)queueBarrierBlock:(dispatch_block_t)block {
  dispatch_barrier_async(self.dispatchQueue, block);
}

- (void)queueAndAwaitBarrierBlock:(dispatch_block_t)block {
  dispatch_barrier_sync(self.dispatchQueue, block);
}

#pragma mark Misc public methods.

- (void)suspend {
  dispatch_suspend(self.dispatchQueue);
}

- (void)resume {
  dispatch_resume(self.dispatchQueue);
}

@end