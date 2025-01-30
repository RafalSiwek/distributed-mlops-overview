set -ex
git clone https://github.com/ROCm/MIOpen.git -b rocm-${ROCM_VERSION} --recursive
pushd MIOpen

git submodule update --init --recursive

# Build boost with -fPIC flag and rocMLIR for gfx1011 arch, composable kernel was build earlier and ditch googletest
patch -p1 <<'EOF'
diff --git a/requirements.txt b/requirements.txt
index dd74f2041..8eb33eb0d 100755
--- a/requirements.txt
+++ b/requirements.txt
@@ -1,11 +1,8 @@
 sqlite3@3.43.2 -DCMAKE_POSITION_INDEPENDENT_CODE=On
-boost@1.83 -DCMAKE_POSITION_INDEPENDENT_CODE=On --build -DCMAKE_CXX_FLAGS=" -std=c++14 -Wno-enum-constexpr-conversion -Wno-deprecated-builtins -Wno-deprecated-declarations "
+boost@1.83 -DCMAKE_POSITION_INDEPENDENT_CODE=On --build -DCMAKE_CXX_FLAGS=" -std=c++14 -Wno-enum-constexpr-conversion -Wno-deprecated-builtins -Wno-deprecated-declarations -fPIC "
 facebook/zstd@v1.4.5 -X subdir -DCMAKE_DIR=build/cmake
-# ROCm/half@10abd99e7815f0ca5d892f58dd7d15a23b7cf92c --build
-ROCm/rocMLIR@rocm-5.5.0 -H sha256:a5f62769d28a73e60bc8d61022820f050e97c977c8f6f6275488db31512e1f42 -DBUILD_FAT_LIBROCKCOMPILER=1 -DCMAKE_IGNORE_PATH="/opt/conda/envs/py_3.8;/opt/conda/envs/py_3.9;/opt/conda/envs/py_3.10" -DCMAKE_IGNORE_PREFIX_PATH=/opt/conda
+ROCm/rocMLIR@rocm-5.5.0 -H sha256:a5f62769d28a73e60bc8d61022820f050e97c977c8f6f6275488db31512e1f42 -DBUILD_FAT_LIBROCKCOMPILER=1 -DCMAKE_IGNORE_PATH="/opt/conda/envs/py_3.12" -DCMAKE_IGNORE_PREFIX_PATH=/opt/conda -DGPU_TARGETS=gfx1011
 nlohmann/json@v3.11.2 -DJSON_MultipleHeaders=ON -DJSON_BuildTests=Off
 ROCm/FunctionalPlus@v0.2.18-p0
 ROCm/eigen@3.4.0
 ROCm/frugally-deep@9683d557eb672ee2304f80f6682c51242d748a50
-ROCm/composable_kernel@665934078ecc6743e049de61e67d28d2a0e5dfe9 -DCMAKE_BUILD_TYPE=Release -DINSTANCES_ONLY=ON
-google/googletest@v1.14.0
EOF

cmake -P install_deps.cmake --minimum

mkdir build
pushd build
export CXX=/opt/rocm/llvm/bin/clang++ && cmake -DMIOPEN_BACKEND=HIP -DCMAKE_PREFIX_PATH="/opt/rocm/;/opt/rocm/hip;/usr/local" -DGPU_TARGETS="gfx1011" ..
time make -j$(nproc)
sudo make -j$(nproc) install
popd
popd
rm -rf MIOpen
