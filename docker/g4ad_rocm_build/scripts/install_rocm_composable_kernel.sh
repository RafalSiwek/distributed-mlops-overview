set -ex
git clone https://github.com/ROCm/composable_kernel.git -b rocm-${ROCM_VERSION} --recursive
pushd composable_kernel

git submodule update --init --recursive

# Apply patch to support the current architecture
# https://github.com/ROCm/composable_kernel/issues/775
patch -p1 <<'EOF'
diff --git a/include/ck/ck.hpp b/include/ck/ck.hpp
index 32eea551f..95d902e87 100644
--- a/include/ck/ck.hpp
+++ b/include/ck/ck.hpp
@@ -75,7 +75,7 @@ CK_DECLARE_ENV_VAR_BOOL(CK_LOGGING)
 #define CK_BUFFER_RESOURCE_3RD_DWORD -1
 #elif defined(__gfx803__) || defined(__gfx900__) || defined(__gfx906__) || defined(__gfx9__)
 #define CK_BUFFER_RESOURCE_3RD_DWORD 0x00020000
-#elif defined(__gfx103__)
+#elif defined(__gfx103__) || defined(__gfx101__)
 #define CK_BUFFER_RESOURCE_3RD_DWORD 0x31014000
 #elif defined(__gfx11__)
 #define CK_BUFFER_RESOURCE_3RD_DWORD 0x31004000
@@ -85,10 +85,12 @@ CK_DECLARE_ENV_VAR_BOOL(CK_LOGGING)
 #ifndef __HIP_DEVICE_COMPILE__                   // for host code, define nothing
 #elif defined(__gfx803__) || defined(__gfx900__) // for GPU code
 #define CK_USE_AMD_V_MAC_F32
-#elif defined(__gfx906__) || defined(__gfx9__) || defined(__gfx103__) // for GPU code
+#elif defined(__gfx906__) || defined(__gfx9__) || defined(__gfx103__) || defined(__gfx1011__) // for GPU code
 #define CK_USE_AMD_V_FMAC_F32
 #define CK_USE_AMD_V_DOT2_F32_F16
 #define CK_USE_AMD_V_DOT4_I32_I8
+#elif defined(__gfx101__)
+#define CK_USE_AMD_V_MAC_F32
 #elif defined(__gfx11__)
 #define CK_USE_AMD_V_FMAC_F32
 #define CK_USE_AMD_V_DOT2_F32_F16
diff --git a/include/ck_tile/core/config.hpp b/include/ck_tile/core/config.hpp
index 601aad19b..157b450d5 100644
--- a/include/ck_tile/core/config.hpp
+++ b/include/ck_tile/core/config.hpp
@@ -10,6 +10,9 @@
 #if defined(__gfx940__) || defined(__gfx941__) || defined(__gfx942__)
 #define __gfx94__
 #endif
+#if defined(__gfx1010__) || defined(__gfx1011__) || defined(__gfx1012__)
+#define __gfx101__
+#endif
 #if defined(__gfx1030__) || defined(__gfx1031__) || defined(__gfx1032__) || \
     defined(__gfx1034__) || defined(__gfx1035__) || defined(__gfx1036__)
 #define __gfx103__
@@ -153,7 +156,7 @@
 #elif defined(__gfx803__) || defined(__gfx900__) || defined(__gfx906__) || \
     defined(__gfx9__) // for GPU code
 #define CK_TILE_BUFFER_RESOURCE_3RD_DWORD 0x00020000
-#elif defined(__gfx103__) // for GPU code
+#elif defined(__gfx103__) || defined(__gfx101__) // for GPU code
 #define CK_TILE_BUFFER_RESOURCE_3RD_DWORD 0x31014000
 #elif defined(__gfx11__) // for GPU code
 #define CK_TILE_BUFFER_RESOURCE_3RD_DWORD 0x31004000
EOF

mkdir build
pushd build
cmake -DCMAKE_PREFIX_PATH=/opt/rocm -DCMAKE_CXX_COMPILER=/opt/rocm/bin/hipcc -DCMAKE_BUILD_TYPE=Release -DGPU_TARGETS="gfx1011" ..
time make -j$(nproc)
sudo make -j$(nproc) install
popd
popd
rm -rf composable_kernel