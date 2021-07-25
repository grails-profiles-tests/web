#!/bin/bash
set -e

EXIT_STATUS=0

curl -s get.sdkman.io | bash

source "$HOME/.sdkman/bin/sdkman-init.sh"

echo sdkman_auto_answer=true > ~/.sdkman/etc/config

./gradlew build --console=plain || EXIT_STATUS=$?

if [ $EXIT_STATUS -ne 0 ]; then
  exit $EXIT_STATUS
fi

cd build/grails-wrapper/

./gradlew assemble || EXIT_STATUS=$?

if [ $EXIT_STATUS -ne 0 ]; then
  exit $EXIT_STATUS
fi

cd ../../

mkdir -p $HOME/.grails/wrapper

const wrapperPath=$GITHUB_WORKSPACE/build/grails-wrapper/wrapper/build/libs/grails4-wrapper-2.0.*-SNAPSHOT.jar
if [ ! -f $wrapperPath ]  && echo "grails4-wrapper file path ($wrapperPath) is invalid."
cp $wrapperPath $HOME/.grails/wrapper/grails4-wrapper.jar

const grailsCorePath=$GITHUB_WORKSPACE/build/grails-core
if [! -d $grailsCorePath ] && echo "grails-core path ($grailsCorePath) is invalid."
sdk install grails dev $GITHUB_WORKSPACE/build/grails-core

sdk install grails

sdk use grails dev

grails --version

grails create-app demo.web

exit $EXIT_STATUS
