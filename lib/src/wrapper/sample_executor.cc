// Derived from Chromium sample.

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "sample_executor.h"
#include <iostream>
extern void *handle;
extern Dart_Port _callback_port;

/* Executor Only */

Cronet_ExecutorPtr (*Cronet_Executor_CreateWith) (Cronet_Executor_ExecuteFunc) = reinterpret_cast<Cronet_ExecutorPtr (*) (Cronet_Executor_ExecuteFunc)>(dlsym(handle,"Cronet_Executor_CreateWith"));
void (*Cronet_Executor_SetClientContext)(
    Cronet_ExecutorPtr,
    Cronet_ClientContext) = reinterpret_cast<void (*)(
    Cronet_ExecutorPtr,
    Cronet_ClientContext)>(dlsym(handle,"Cronet_Executor_SetClientContext"));


void (*Cronet_Executor_Destroy)(Cronet_ExecutorPtr) = reinterpret_cast<void (*) (Cronet_ExecutorPtr) >(dlsym(handle,"Cronet_Executor_Destroy"));

void (*Cronet_Runnable_Run)(Cronet_RunnablePtr) = reinterpret_cast<void (*)(Cronet_RunnablePtr) >(dlsym(handle,"Cronet_Runnable_Run"));

void (*Cronet_Runnable_Destroy)(Cronet_RunnablePtr) = reinterpret_cast<void (*)(Cronet_RunnablePtr)>(dlsym(handle,"Cronet_Runnable_Destroy"));

Cronet_ClientContext (*Cronet_Executor_GetClientContext)(Cronet_ExecutorPtr) = reinterpret_cast<Cronet_ClientContext (*)(Cronet_ExecutorPtr)>(dlsym(handle,"Cronet_Executor_GetClientContext"));

SampleExecutor::SampleExecutor()
    : executor_thread_(SampleExecutor::ThreadLoop, this) {}
SampleExecutor::~SampleExecutor() {
  ShutdownExecutor();
  Cronet_Executor_Destroy(executor_);
}

void SampleExecutor::Init() {
  executor_ = Cronet_Executor_CreateWith(SampleExecutor::Execute);
  Cronet_Executor_SetClientContext(executor_, this);
}

Cronet_ExecutorPtr SampleExecutor::GetExecutor() {
  return executor_;
}
void SampleExecutor::ShutdownExecutor() {
  printf("Executor shut down\n");
  // Break tasks loop.
  {
    std::lock_guard<std::mutex> lock(lock_);
    stop_thread_loop_ = true;
  }
  task_available_.notify_one();
  // Wait for executor thread.
  executor_thread_.join();
}
void SampleExecutor::RunTasksInQueue() {
  printf("Running tasks");
  // Process runnables in |task_queue_|.
  while (true) {
    printf("loop\n");
    Cronet_RunnablePtr runnable = nullptr;
    {
      
      // Wait for a task to run or stop signal.
      std::unique_lock<std::mutex> lock(lock_);
      while (task_queue_.empty() && !stop_thread_loop_) {
        printf("waiting\n");
        task_available_.wait(lock);
      }
      if (stop_thread_loop_) {
        printf("stop thread\n");
        break;
      }
      if (task_queue_.empty()) {
        printf("task queue empty\n");
        continue;
      }
      runnable = task_queue_.front();
      task_queue_.pop();
      
    }
    Cronet_Runnable_Run(runnable);
    Cronet_Runnable_Destroy(runnable);
  }
  // Delete remaining tasks.
  std::queue<Cronet_RunnablePtr> tasks_to_destroy;
  {
    std::unique_lock<std::mutex> lock(lock_);
    tasks_to_destroy.swap(task_queue_);
  }
  while (!tasks_to_destroy.empty()) {
    Cronet_Runnable_Destroy(tasks_to_destroy.front());
    tasks_to_destroy.pop();
  }
}
/* static */
void SampleExecutor::ThreadLoop(SampleExecutor* executor) {
  executor->RunTasksInQueue();
}
void SampleExecutor::Execute(Cronet_RunnablePtr runnable) {
  // printf("Execute\n");
  {
    std::lock_guard<std::mutex> lock(lock_);
    if (!stop_thread_loop_) {
      task_queue_.push(runnable);
      runnable = nullptr;
    }
  }
  if (runnable) {
    Cronet_Runnable_Destroy(runnable);
  } else {
    task_available_.notify_one();
  }
}
/* static */
void SampleExecutor::Execute(Cronet_ExecutorPtr self,
                             Cronet_RunnablePtr runnable) {
  auto* executor =
      static_cast<SampleExecutor*>(Cronet_Executor_GetClientContext(self));
  executor->Execute(runnable);
}