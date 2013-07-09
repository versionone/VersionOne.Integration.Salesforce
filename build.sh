#!/bin/bash -e

# ----- Variables -------------------------------------------------------------
# Variables in the build.properties file will be available to Jenkins
# build steps. Variables local to this script can be defined below.
. ./build.properties



# -----------------------------------------------------------------------------

# fix for jenkins inserting the windows-style path in $WORKSPACE
cd "$WORKSPACE"
export WORKSPACE=`pwd`



# ----- Utility functions -----------------------------------------------------

function winpath() {
  # Convert gitbash style path '/c/Users/Big John/Development' to 'c:\Users\Big John\Development',
  # via dumb substitution. Handles drive letters; incurs process creation penalty for sed.
  if [ -e /etc/bash.bashrc ] ; then
    # Cygwin specific settings
    echo "`cygpath -w $1`"
  else
    # Msysgit specific settings
    echo "$1" | sed -e 's|^/\(\w\)/|\1:\\|g;s|/|\\|g'
  fi
}

function bashpath() {
  # Convert windows style path 'c:\Users\Big John\Development' to '/c/Users/Big John/Development'
  # via dumb substitution. Handles drive letters; incurs process creation penalty for sed.
  if [ -e /etc/bash.bashrc ] ; then
    # Cygwin specific settings
    echo "`cygpath $1`"
  else
    # Msysgit specific settings
    echo "$1" | sed -e 's|\(\w\):|/\1|g;s|\\|/|g'
  fi
}

function parentwith() {  # used to find $WORKSPACE, below.
  # Starting at the current dir and progressing up the ancestors,
  # retuns the first dir containing $1. If not found returns pwd.
  SEARCHTERM="$1"
  DIR=`pwd`
  while [ ! -e "$DIR/$SEARCHTERM" ]; do
    NEWDIR=`dirname "$DIR"`
    if [ "$NEWDIR" = "$DIR" ]; then
      pwd
      return
    fi
    DIR="$NEWDIR"
  done
  echo "$DIR"
  }


# If we aren't running under jenkins. some variables will be unset.
# So set them to a reasonable value

if [ -z "$WORKSPACE" ]; then
  export WORKSPACE=`parentwith .git`;
fi

TOOLSDIRS=". $WORKSPACE/GetBuildTools $WORKSPACE/v1_build_tools $WORKSPACE/../v1_build_tools $WORKSPACE/nuget_tools"
#TOOLSDIRS="."
for D in $TOOLSDIRS; do
  if [ -d "$D/bin" ]; then
    export BUILDTOOLS_PATH="$D/bin"
  fi
done
echo $(which $BUILDTOOLS_PATH/NuGet.exe)
echo $(which $WORKSPACE/.nuget/NuGet.exe)
if [ ! $(which $BUILDTOOLS_PATH/NuGet.exe) ] && [ $(which $WORKSPACE/.nuget/NuGet.exe) ]; then
  export BUILDTOOLS_PATH="$WORKSPACE/.nuget"
fi
echo "Using $BUILDTOOLS_PATH for NuGet"

if [ -z "$DOTNET_PATH" ]; then
  for D in `bashpath "$SYSTEMROOT\\Microsoft.NET\\Framework\\*"`; do
    if [ -d $D ]; then
      export DOTNET_PATH="$D"
    fi
  done
fi
echo "Using $DOTNET_PATH for .NET"

export PATH="$PATH:$BUILDTOOLS_PATH:$DOTNET_PATH"

if [ -z "$SIGNING_KEY_DIR" ]; then
  export SIGNING_KEY_DIR=`pwd`;
fi

export SIGNING_KEY="$SIGNING_KEY_DIR/VersionOne.snk"

if [ -f "$SIGNING_KEY" ]; then 
  export SIGN_ASSEMBLY="true"
else
  export SIGN_ASSEMBLY="false"
  echo "Please place VersionOne.snk in `pwd` or $SIGNING_KEY_DIR to enable signing.";
fi

if [ -z "$VERSION_NUMBER" ]; then
  export VERSION_NUMBER="0.0.0"
fi

if [ -z "$BUILD_NUMBER" ]; then
  # presume local workstation, use date-based build number
  export BUILD_NUMBER=`date +%H%M`  # hour + minute
fi

function update_nuget_deps() {
  install_nuget_deps
  NuGet.exe update $SOLUTION_FILE -Verbose -Source $NUGET_FETCH_URL
}

function install_nuget_deps() {
  PKGSDIRW=`winpath "$WORKSPACE/packages"`
  for D in $WORKSPACE/*; do
    if [ -d $D ] && [ -f $D/packages.config ]; then
      PKGSCONFIGW=`winpath "$D/packages.config"`
      NuGet.exe install "$PKGSCONFIGW" -o "$PKGSDIRW" -Source "$NUGET_FETCH_URL"
    fi
  done
}



# ---- Clean solution ---------------------------------------------------------

## Don't clean unless there's code.
# rm -rf $WORKSPACE/*.nupkg
# MSBuild.exe $SOLUTION_FILE -m \
#  -t:Clean \
#  -p:Configuration="$Configuration" \
#  -p:Platform="$Platform" \
#  -p:Verbosity=Diagnostic



# ---- Update NuGet Packages --------------------------------------------------

# Don't use NuGet unless there's code.
# update_nuget_deps
# install_nuget_deps


# ---- Build solution using msbuild -------------------------------------------

# Don't build unless there's code.
# WIN_SIGNING_KEY="`winpath "$SIGNING_KEY"`"
# MSBuild.exe $SOLUTION_FILE \
#   -p:SignAssembly=$SIGN_ASSEMBLY \
#   -p:AssemblyOriginatorKeyFile=$WIN_SIGNING_KEY \
#   -p:RequireRestoreConsent=false \
#   -p:Configuration="$Configuration" \
#   -p:Platform="$Platform" \
#   -p:Verbosity=Diagnostic
echo Code coming soon.



# ---- Produce .zip file ----------------------------------------------------------

git archive -o ${MAIN_DIR}_${VERSION_NUMBER}.${BUILD_NUMBER}.zip HEAD


