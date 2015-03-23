#!/bin/bash

# ----------------------
# KUDU Deployment Script
# Version: 0.1.11
# ----------------------

# Helpers
# -------

exitWithMessageOnError () {
  if [ ! $? -eq 0 ]; then
    echo "An error has occurred during web site deployment."
    echo $1
    exit 1
  fi
}

# Prerequisites
# -------------

# Verify node.js installed
hash node 2>/dev/null
exitWithMessageOnError "Missing node.js executable, please install node.js, if already installed make sure it can be reached from current environment."

# Setup
# -----

SCRIPT_DIR="${BASH_SOURCE[0]%\\*}"
SCRIPT_DIR="${SCRIPT_DIR%/*}"
ARTIFACTS=$SCRIPT_DIR/../artifacts
KUDU_SYNC_CMD=${KUDU_SYNC_CMD//\"}

if [[ ! -n "$DEPLOYMENT_SOURCE" ]]; then
  DEPLOYMENT_SOURCE=$SCRIPT_DIR
fi

if [[ ! -n "$NEXT_MANIFEST_PATH" ]]; then
  NEXT_MANIFEST_PATH=$ARTIFACTS/manifest

  if [[ ! -n "$PREVIOUS_MANIFEST_PATH" ]]; then
    PREVIOUS_MANIFEST_PATH=$NEXT_MANIFEST_PATH
  fi
fi

if [[ ! -n "$DEPLOYMENT_TARGET" ]]; then
  DEPLOYMENT_TARGET=$ARTIFACTS/wwwroot
else
  KUDU_SERVICE=true
fi

if [[ ! -n "$KUDU_SYNC_CMD" ]]; then
  # Install kudu sync
  echo Installing Kudu Sync
  npm install kudusync -g --silent
  exitWithMessageOnError "npm failed"

  if [[ ! -n "$KUDU_SERVICE" ]]; then
    # In case we are running locally this is the correct location of kuduSync
    KUDU_SYNC_CMD=kuduSync
  else
    # In case we are running on kudu service this is the correct location of kuduSync
    KUDU_SYNC_CMD=$APPDATA/npm/node_modules/kuduSync/bin/kuduSync
  fi
fi

############################################################################
# Build
############################################################################

# Include JRE binaries in PATH -- used by lein self-install later
export PATH=$PATH:$JAVA_HOME/bin

# Fetch and install lein script
LEIN_DIR=${HOME}/bin
if [ ! -d "$LEIN_DIR" ]; then
  mkdir -p $LEIN_DIR
fi

LEIN_BIN=${LEIN_DIR}/lein
if [ ! -f "$LEIN_BIN" ]; then
  curl -sSL https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -o $LEIN_BIN
fi

# Build uberwar
WAR_NAME="ROOT.war"
_JAVA_OPTIONS='-Djava.net.preferIPv4Stack=true' sh $LEIN_BIN ring uberwar $WAR_NAME

##################################################################################################################################
# Deployment
# ----------

echo Handling Basic Web Site deployment.

WAR_SRC=${DEPLOYMENT_SOURCE}/target/${WAR_NAME}
WAR_DST=${DEPLOYMENT_TARGET}/webapps/${WAR_NAME}
if [[ "$IN_PLACE_DEPLOYMENT" -ne "1" ]]; then
  rm -rfv $WAR_DST ${WAR_DST%.*}
  cp -fv $WAR_SRC $WAR_DST
  exitWithMessageOnError "Could not deploy ROOT.war"
fi

##################################################################################################################################

# Post deployment stub
if [[ -n "$POST_DEPLOYMENT_ACTION" ]]; then
  POST_DEPLOYMENT_ACTION=${POST_DEPLOYMENT_ACTION//\"}
  cd "${POST_DEPLOYMENT_ACTION_DIR%\\*}"
  "$POST_DEPLOYMENT_ACTION"
  exitWithMessageOnError "post deployment action failed"
fi

echo "Finished successfully."
