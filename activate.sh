export SOMA_ROOT="$PIXI_PROJECT_ROOT"

export PATH="$SOMA_ROOT/src/brainvisa-cmake/bin:$SOMA_ROOT/build/bin:$PATH:$CONDA_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/bin"
export CMAKE_LIBRARY_PATH="$CONDA_PREFIX/lib:$CONDA_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64"
export BRAINVISA_BVMAKER_CFG="$SOMA_ROOT/conf/bv_maker.cfg"
export LD_LIBRARY_PATH="$SOMA_ROOT/build/lib:$LD_LIBRARY_PATH"
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

# try to fix fontconfig cache issue by disabling it

if [ ! -e "$SOMA_ROOT/conf/fontconfig" ]; then
    mkdir "$SOMA_ROOT/conf/fontconfig"
    mkdir -p "$SOMA_ROOT/.pixi/fontconfig_cache"
    if [ -f /etc/fonts/fonts.conf ]; then
        sed "s/^.*<cachedir.*$//" /etc/fonts/fonts.conf > "$SOMA_ROOT/conf/fontconfig/fonts.conf"
        sed -i "/^.*<\!-- Font cache directory list.*$/a\\\t<cachedir>$SOMA_ROOT\/.pixi\/fontconfig_cache<\/cachedir>" "$SOMA_ROOT/conf/fontconfig/fonts.conf"
    else
        # this does not work actually if /etc/fonts/fonts.conf exists
        cat << EOF > "$SOMA_ROOT/conf/fontconfig/fonts.conf"
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
    <cachedir>$SOMA_ROOT/.pixi/fontconfig_cache</cachedir>
    <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
</fontconfig>
EOF
    fi
fi
# export FONTCONFIG_PATH="$SOMA_ROOT/conf/fontconfig"
export FONTCONFIG_FILE="$SOMA_ROOT/conf/fontconfig/fonts.conf"
