; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=memcpyopt -S -verify-memoryssa | FileCheck %s
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

define void @test(i64 %size) {
; CHECK-LABEL: @test(
; CHECK-NEXT:    [[SRC:%.*]] = alloca i8, i64 [[SIZE:%.*]], align 1
; CHECK-NEXT:    [[DST:%.*]] = alloca i8, i64 [[SIZE]], align 1
; CHECK-NEXT:    ret void
;
  %src = alloca i8, i64 %size
  %dst = alloca i8, i64 %size
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %dst, ptr align 8 %src, i64 %size, i1 false)

  ret void
}

define void @test2(i64 %size1, i64 %size2, i64 %cpy_size) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[SRC:%.*]] = alloca i8, i64 [[SIZE1:%.*]], align 1
; CHECK-NEXT:    [[DST:%.*]] = alloca i8, i64 [[SIZE2:%.*]], align 1
; CHECK-NEXT:    ret void
;
  %src = alloca i8, i64 %size1
  %dst = alloca i8, i64 %size2
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %dst, ptr align 8 %src, i64 %cpy_size, i1 false)

  ret void
}

declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)