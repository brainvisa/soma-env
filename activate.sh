export SOMA_ROOT="$PIXI_PROJECT_ROOT"

export PATH="$SOMA_ROOT/src/brainvisa-cmake/bin:$SOMA_ROOT/build/bin:$PATH:$CONDA_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/bin"
export CMAKE_LIBRARY_PATH="$CONDA_PREFIX/lib:$CONDA_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64"
export BRAINVISA_BVMAKER_CFG="$SOMA_ROOT/conf/bv_maker.cfg"
# force LD_LIBRARY_PATH for QtWebEngine installed via pip
# as a conqequence many host system software will not work in this environment.
export LD_LIBRARY_PATH="$SOMA_ROOT/build/lib:$PIXI_PROJECT_ROOT/.pixi/envs/$PIXI_ENVIRONMENT_NAME:$LD_LIBRARY_PATH"

python_short=$(python -c 'import sys; print(".".join(str(i) for i in sys.version_info[0:2]))')
export PYTHONPATH="$SOMA_ROOT/src/brainvisa-cmake/python:$SOMA_ROOT/build/lib/python${python_short}/site-packages:$PYTHONPATH"
export LC_NUMERIC=C

# Ensure brainvisa-cmake sources are downloaded
if [ ! -e "$SOMA_ROOT/src/brainvisa-cmake" ] ; then
    mkdir -p "$SOMA_ROOT/src"
    git clone https://github.com/brainvisa/brainvisa-cmake "$SOMA_ROOT/src/brainvisa-cmake"
fi

# Ensure that build-info.json file exists
if [ ! -e "$SOMA_ROOT/conf/build_info.json" ] ; then
    echo '{}' > "$SOMA_ROOT/conf/build_info.json"
fi

# remove pip-installed resources for the pip Qt binaries, whenever they come back
# (after an update)
if [ -d "$PIXI_PROJECT_ROOT/.pixi/envs/$PIXI_ENVIRONMENT_NAME/lib/python3.12/site-packages/PyQt6/Qt6" ]; then
    rm -rf $PIXI_PROJECT_ROOT/.pixi/envs/$PIXI_ENVIRONMENT_NAME/lib/python3.12/site-packages/PyQt6/Qt6
    # fix cmake / Qml by commenting out this line,
    # since it gets as is in makefiles
    sed -i -e 's/^  INTERFACE_COMPILE_DEFINITIONS/#  INTERFACE_COMPILE_DEFINITIONS/g' $PIXI_PROJECT_ROOT/.pixi/envs/$PIXI_ENVIRONMENT_NAME/lib/cmake/Qt6Qml/Qt6QmlTargets.cmake
fi
export QT_API=pyqt6
