#!/bin/bash

set -e -o pipefail

increment_version() {
  local version=$1
  local releaseType=$2

  local delimiter=.
  local array=($(echo "${version}" | tr $delimiter '\n'))

  array[$releaseType]=$((array[$releaseType]+1))
  if [ $releaseType -lt 2 ]; then array[2]=0; fi
  if [ $releaseType -lt 1 ]; then array[1]=0; fi

  echo $(local IFS=$delimiter ; echo "${array[*]}")
}

COMMIT_MESSAGE="${INPUT_COMMIT_MESSAGE}"

if [[ "${COMMIT_MESSAGE}" =~ "major" ]] ||
   [[ "${COMMIT_MESSAGE}" =~ "minor" ]]; then
  echo "Release increment value found in commit message, continuing..."
else
  echo "New release should be either of type major or minor"

  exit 1
fi

cd "${GITHUB_WORKSPACE}" || exit

git config --global --add safe.directory "${GITHUB_WORKSPACE}"
git config user.name "github-actions"
git config user.email "github-actions@users.noreply.github.com"
git fetch

# Version master is checked out to obtain to obtain the latest master version which is then used to know the new release version
git checkout version/master
masterVersion=$(cat version)

# This makes sure everything after the second dot is removed. 1.20.12 will result in 1.20
releaseVersion=$(echo ${masterVersion} | grep -o "^[^.]*.\?[^.]*")

echo "${releaseVersion}"

# A version branch for this specific release is created with only the version file
releaseVersionBranch="version/v${releaseVersion}"
git checkout -b "${releaseVersionBranch}"
git push --set-upstream origin "${releaseVersionBranch}"

git checkout master

# After checking out master, we then create a new release branch with the latest changes in master
releaseBranch="release/v${releaseVersion}"
git checkout -b "${releaseBranch}"
git push --set-upstream origin "${releaseBranch}"

# Checkout version of master again to make sure we can bump this version to the new minor or major one
git checkout version/master

# The increment version script takes an argument which should contain 0 (in case of major increment) and 1 (in case of minor increment)
major=0
minor=1

if [[ "${COMMIT_MESSAGE}" =~ "minor" ]]; then
  releaseType="${minor}"
fi

if [[ "${COMMIT_MESSAGE}" =~ "major" ]]; then
  releaseType="${major}"
fi

newMasterVersion=$(increment_version ${masterVersion} "${releaseType}")
echo "${newMasterVersion}" > version
git add version
git commit -m "Bump version to ${newMasterVersion}"
git push

git checkout master

# version master is exported, to make sure we can reuse that in the next steps of the pipeline
echo "version-master=${newMasterVersion}" >> $GITHUB_OUTPUT
