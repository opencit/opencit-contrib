#!/bin/bash

# define action usage commands
usage() { echo "Usage: $0 [-v \"version\"]" >&2; exit 1; }

# set option arguments to variables and echo usage on failures
version=
while getopts ":v:" o; do
  case "${o}" in
    v)
      version="${OPTARG}"
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      usage
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z "$version" ]; then
  echo "Version not specified" >&2
  exit 2
fi

changeVersionCommand="mvn versions:set -DnewVersion=${version}"
changeParentVersionCommand="mvn versions:update-parent -DallowSnapshots=true -DparentVersion=${version}"
mvnInstallCommand="mvn clean install"

ant ready
if [ $? -ne 0 ]; then echo "Failed to maven install \"maven\" projects" >&2; exit 3; fi
$changeVersionCommand
if [ $? -ne 0 ]; then echo "Failed to change maven version at top level" >&2; exit 3; fi
$changeParentVersionCommand
if [ $? -ne 0 ]; then echo "Failed to change maven parent versions" >&2; exit 3; fi
ant ready
if [ $? -ne 0 ]; then echo "Failed to maven install \"maven\" projects, 2nd time" >&2; exit 3; fi
(cd prebuild && $changeVersionCommand)
if [ $? -ne 0 ]; then echo "Failed to change maven version on \"prebuild\" folder" >&2; exit 3; fi
(cd packages && $changeVersionCommand)
if [ $? -ne 0 ]; then echo "Failed to change maven version on \"packages\" folder" >&2; exit 3; fi
(cd packages && $changeParentVersionCommand)
if [ $? -ne 0 ]; then echo "Failed to change maven parent versions in \"packages\" folder" >&2; exit 3; fi
