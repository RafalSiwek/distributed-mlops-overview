#!/bin/bash

# Work around bug where devtoolset replaces sudo and breaks it.
if [ -n "$DEVTOOLSET_VERSION" ]; then
  export SUDO=/bin/sudo
else
  export SUDO=sudo
fi


conda_install() {
  # Ensure that the install command don't upgrade/downgrade Python
  # This should be called as
  #   conda_install pkg1 pkg2 ... [-c channel]
  conda install -q -n py_$ANACONDA_PYTHON_VERSION -y python="$ANACONDA_PYTHON_VERSION" $*
}

conda_run() {
  conda run -n py_$ANACONDA_PYTHON_VERSION --no-capture-output $*
}

pip_install() {
  conda run -n py_$ANACONDA_PYTHON_VERSION pip install --progress-bar off $*
}

get_pinned_commit() {
  cat "${1}".txt
}
