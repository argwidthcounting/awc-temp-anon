; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -S -passes=argpromotion < %s | FileCheck %s
; Test that we only promote arguments when the caller/callee have compatible
; function attrubtes.

target triple = "x86_64-unknown-linux-gnu"

define internal fastcc void @no_promote_avx2(ptr %arg, ptr readonly %arg1) #0 {
; CHECK-LABEL: define {{[^@]+}}@no_promote_avx2
; CHECK-SAME: (ptr [[ARG:%.*]], ptr readonly [[ARG1:%.*]])
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[TMP:%.*]] = load <4 x i64>, ptr [[ARG1]]
; CHECK-NEXT:    store <4 x i64> [[TMP]], ptr [[ARG]]
; CHECK-NEXT:    ret void
;
bb:
  %tmp = load <4 x i64>, ptr %arg1
  store <4 x i64> %tmp, ptr %arg
  ret void
}

define void @no_promote(ptr %arg) #1 {
; CHECK-LABEL: define {{[^@]+}}@no_promote
; CHECK-SAME: (ptr [[ARG:%.*]])
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[TMP:%.*]] = alloca <4 x i64>, align 32
; CHECK-NEXT:    [[TMP2:%.*]] = alloca <4 x i64>, align 32
; CHECK-NEXT:    call void @llvm.memset.p0.i64(ptr align 32 [[TMP]], i8 0, i64 32, i1 false)
; CHECK-NEXT:    call fastcc void @no_promote_avx2(ptr [[TMP2]], ptr [[TMP]])
; CHECK-NEXT:    [[TMP4:%.*]] = load <4 x i64>, ptr [[TMP2]], align 32
; CHECK-NEXT:    store <4 x i64> [[TMP4]], ptr [[ARG]], align 2
; CHECK-NEXT:    ret void
;
bb:
  %tmp = alloca <4 x i64>, align 32
  %tmp2 = alloca <4 x i64>, align 32
  call void @llvm.memset.p0.i64(ptr align 32 %tmp, i8 0, i64 32, i1 false)
  call fastcc void @no_promote_avx2(ptr %tmp2, ptr %tmp)
  %tmp4 = load <4 x i64>, ptr %tmp2, align 32
  store <4 x i64> %tmp4, ptr %arg, align 2
  ret void
}

define internal fastcc void @promote_avx2(ptr %arg, ptr readonly %arg1) #0 {
; CHECK-LABEL: define {{[^@]+}}@promote_avx2
; CHECK-SAME: (ptr [[ARG:%.*]], <4 x i64> [[ARG1_VAL:%.*]])
; CHECK-NEXT:  bb:
; CHECK-NEXT:    store <4 x i64> [[ARG1_VAL]], ptr [[ARG]]
; CHECK-NEXT:    ret void
;
bb:
  %tmp = load <4 x i64>, ptr %arg1
  store <4 x i64> %tmp, ptr %arg
  ret void
}

define void @promote(ptr %arg) #0 {
; CHECK-LABEL: define {{[^@]+}}@promote
; CHECK-SAME: (ptr [[ARG:%.*]])
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[TMP:%.*]] = alloca <4 x i64>, align 32
; CHECK-NEXT:    [[TMP2:%.*]] = alloca <4 x i64>, align 32
; CHECK-NEXT:    call void @llvm.memset.p0.i64(ptr align 32 [[TMP]], i8 0, i64 32, i1 false)
; CHECK-NEXT:    [[TMP_VAL:%.*]] = load <4 x i64>, ptr [[TMP]]
; CHECK-NEXT:    call fastcc void @promote_avx2(ptr [[TMP2]], <4 x i64> [[TMP_VAL]])
; CHECK-NEXT:    [[TMP4:%.*]] = load <4 x i64>, ptr [[TMP2]], align 32
; CHECK-NEXT:    store <4 x i64> [[TMP4]], ptr [[ARG]], align 2
; CHECK-NEXT:    ret void
;
bb:
  %tmp = alloca <4 x i64>, align 32
  %tmp2 = alloca <4 x i64>, align 32
  call void @llvm.memset.p0.i64(ptr align 32 %tmp, i8 0, i64 32, i1 false)
  call fastcc void @promote_avx2(ptr %tmp2, ptr %tmp)
  %tmp4 = load <4 x i64>, ptr %tmp2, align 32
  store <4 x i64> %tmp4, ptr %arg, align 2
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1) #2

attributes #0 = { inlinehint norecurse nounwind uwtable "target-features"="+avx2" }
attributes #1 = { nounwind uwtable }
attributes #2 = { argmemonly nounwind }