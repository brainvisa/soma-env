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

# Fix fontconfig cache issue by disabling it

if [ -d "$SOMA_ROOT/fontconfig_local" -a -w "$SOMA_ROOT/fontconfig_local" ]; then
    FONTCONFIG_LOCAL="$SOMA_ROOT/fontconfig_local"
else
    if [ ! -d "$SOMA_ROOT/fontconfig_local" -a -w "$SOMA_ROOT" ];
 then
        mkdir "$SOMA_ROOT/fontconfig_local"
        FONTCONFIG_LOCAL="$SOMA_ROOT/fontconfig_local"
    fi
fi
if [ -z "$FONTCONFIG_LOCAL" ]; then
    CLEAN_FONTCONFIG_CACHE=1
    if [ -z "$TMPDIR" ]; then
        TMPDIR=/tmp
    fi
    mkdir -p "$TMPDIR/soma_pixi"
    FONTCONFIG_LOCAL=$(mktemp -d -p "" soma_pixi/fontconfig_XXXXXXX)
    chmod a+rwx "$FONTCONFIG_LOCAL"
fi

if [ ! -e "$FONTCONFIG_LOCAL/conf/fontconfig" ]; then
    mkdir -p "$FONTCONFIG_LOCAL/conf/fontconfig"
    mkdir -p "$FONTCONFIG_LOCAL/fontconfig_cache"
    if [ -f /etc/fonts/fonts.conf ]; then
        sed "s/^.*<cachedir.*$//" /etc/fonts/fonts.conf > "$FONTCONFIG_LOCAL/conf/fontconfig/fonts.conf"
        sed -i "/^.*<\!-- Font cache directory list.*$/a\\\t<cachedir>$FONTCONFIG_LOCAL\/fontconfig_cache<\/cachedir>" "$FONTCONFIG_LOCAL/conf/fontconfig/fonts.conf"
    else
        # this does not work actually if /etc/fonts/fonts.conf exists
        cat << EOF > "$FONTCONFIG_LOCAL/conf/fontconfig/fonts.conf"
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
    <cachedir>$FONTCONFIG_LOCAL/fontconfig_cache</cachedir>
    <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
</fontconfig>
EOF
    fi
fi
export FONTCONFIG_FILE="$FONTCONFIG_LOCAL/conf/fontconfig/fonts.conf"

# unfortunately we cannot clean $$FONTCONFIG_LOCAL at pixi exit.

# clean_up() {
#     echo "Clean temp fontconfig cache..."
#     rm -rf "$FONTCONFIG_LOCAL"
# }
# if [ -n "$CLEAN_FONTCONFIG_CACHE" ]; then
#     trap clean_up EXIT
# fi
