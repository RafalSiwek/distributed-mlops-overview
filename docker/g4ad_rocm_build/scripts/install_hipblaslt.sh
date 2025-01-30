#!/bin/bash

set -ex

git clone --recursive https://github.com/ROCm/hipBLASLt.git -b rocm-${ROCM_VERSION}
pushd hipBLASLt

# Apply patch  in order to be able to build PyTorch from source, but treat as unused:
# https://github.com/ROCm/hipBLASLt/issues/648
patch -p1 <<'EOF'
diff --git a/CMakeLists.txt b/CMakeLists.txt
index d0579114f..e6778539f 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -205,6 +205,10 @@ else()
     else()
       find_package(Tensile 4.33.0 EXACT REQUIRED HIP LLVM OpenMP PATHS "${INSTALLED_TENSILE_PATH}")
     endif()
+    else()  # link to Tensile (required), but don't generate libraries
+      cmake_policy(SET CMP0074 NEW)
+      set(Tensile_ROOT "${CMAKE_SOURCE_DIR}/tensilelite/Tensile")
+      find_package(Tensile REQUIRED HIP LLVM OpenMP)
     endif()
 
     # setup hipblaslt defines used for both the library and clients
diff --git a/library/CMakeLists.txt b/library/CMakeLists.txt
index dbc0bdc54..0247870cf 100644
--- a/library/CMakeLists.txt
+++ b/library/CMakeLists.txt
@@ -75,7 +75,7 @@ add_library(roc::hipblaslt ALIAS hipblaslt)
 
 # Target compile definitions
 if(NOT BUILD_CUDA)
-if( BUILD_WITH_TENSILE )
+if( TRUE )  # link with Tensile is always reqiured
 
   if( BUILD_SHARED_LIBS )
     target_link_libraries( hipblaslt PRIVATE TensileHost )
@@ -195,7 +195,7 @@ rocm_install_targets(TARGETS hipblaslt
                        ${CMAKE_BINARY_DIR}/include
 )
 
-if ( NOT BUILD_CUDA )
+if ( NOT BUILD_CUDA AND BUILD_WITH_TENSILE )
     if (WIN32)
       set( HIPBLASLT_TENSILE_LIBRARY_DIR "\${CPACK_PACKAGING_INSTALL_PREFIX}hipblaslt/bin" CACHE PATH "path to tensile library" )
     else()
diff --git a/library/src/amd_detail/rocblaslt/src/CMakeLists.txt b/library/src/amd_detail/rocblaslt/src/CMakeLists.txt
index 3d5ace353..a34252e15 100644
--- a/library/src/amd_detail/rocblaslt/src/CMakeLists.txt
+++ b/library/src/amd_detail/rocblaslt/src/CMakeLists.txt
@@ -107,6 +107,18 @@ if( BUILD_WITH_TENSILE )
     ${CMAKE_CURRENT_SOURCE_DIR}/src/amd_detail/rocblaslt/src/Tensile
   )
 
+  else()
+  set_target_properties( TensileHost PROPERTIES POSITION_INDEPENDENT_CODE ON )
+ 
+  set( Tensile_SRC
+  ${CMAKE_CURRENT_SOURCE_DIR}/src/amd_detail/rocblaslt/src/tensile_host.cpp
+  ${PROJECT_SOURCE_DIR}/tensilelite/Tensile/Source/lib/source/msgpack/MessagePack.cpp
+  )
+
+  set( Tensile_INC
+  ${CMAKE_CURRENT_SOURCE_DIR}/src/amd_detail/rocblaslt/src/Tensile
+  )
+
 endif( ) # BUILD_WITH_TENSILE
 
 set(DL_LIB dl)
diff --git a/library/src/amd_detail/rocblaslt/src/rocblaslt_mat.cpp b/library/src/amd_detail/rocblaslt/src/rocblaslt_mat.cpp
index ccc2a08df..ea85050cc 100644
--- a/library/src/amd_detail/rocblaslt/src/rocblaslt_mat.cpp
+++ b/library/src/amd_detail/rocblaslt/src/rocblaslt_mat.cpp
@@ -28,6 +28,7 @@
 #include "handle.h"
 #include "rocblaslt_mat_utils.hpp"
 #include "tensile_host.hpp"
+#include <array>
 
 #include <hip/hip_runtime_api.h>
 
@@ -602,7 +603,7 @@ rocblaslt_status
     std::vector<int64_t>            ldc_vec, batch_stride_c_vec, num_batches_c_vec;
     std::vector<int64_t>            ldd_vec, batch_stride_d_vec, num_batches_d_vec;
     std::vector<int64_t>            lde_vec, batch_stride_e_vec, num_batches_e_vec;
-    std::vector<int8_t[16]>         alpha_1(matmul_descr.size());
+    std::vector<std::array<int8_t, 16>>         alpha_1(matmul_descr.size());
 
     std::vector<bool> gradient_vec;
 
@@ -692,10 +693,10 @@ rocblaslt_status
             return validArgs;
 
         const void* alphaTmp = nullptr;
-        memset(alpha_1[i], 0, sizeof(int8_t) * 16);
+        memset(alpha_1[i].data(), 0, sizeof(int8_t) * 16);
         if(scaleAlphaVec)
         {
-            setTo1(compute_type, (void*)alpha_1[i], &alphaTmp);
+            setTo1(compute_type, (void*)alpha_1[i].data(), &alphaTmp);
         }
         else
         {
@@ -867,7 +868,7 @@ rocblaslt_status
     std::vector<int64_t> lde_vec, batch_stride_e_vec, num_batches_e_vec;
     std::vector<bool>    gradient_vec;
 
-    std::vector<int8_t[16]> alpha_1(m.size());
+    std::vector<std::array<int8_t, 16>> alpha_1(m.size());
 
     for(int i = 0; i < m.size(); i++)
     {
@@ -924,10 +925,10 @@ rocblaslt_status
             return validArgs;
 
         const void* alphaTmp = nullptr;
-        memset(alpha_1[i], 0, sizeof(int8_t) * 16);
+        memset(alpha_1[i].data(), 0, sizeof(int8_t) * 16);
         if(scaleAlphaVec)
         {
-            setTo1(compute_type, (void*)alpha_1[i], &alphaTmp);
+            setTo1(compute_type, (void*)alpha_1[i].data(), &alphaTmp);
         }
         else
         {
EOF

./install.sh -i -a "" -n
popd
rm -rf hipBLASLt
