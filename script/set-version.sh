#!/bin/bash
branch_current="$(git branch | awk '/^\* +/{print $2}')"
if [ "$branch_current" != "main" ]; then
    read -ep "Current branch is not main; it is $current_branch. Proceed nonetheless? [yN] "
    echo "$REPLY" | xargs | grep -qvi '^y' && exit 1
fi
if [ -n "$(git status --short)" ]; then
    echo "Repository is dirty. Git status:" 1>&2
    echo 1>&2
    git status | awk '{printf("    %s\n", $0)}' 1>&2
    echo 1>&2
    read -ep "Proceed with setting new version nonetheless? [yN] "
    echo "$REPLY" | xargs | grep -qvi '^y' && exit 1
fi
echo -n "Current version:   " 1>&2
sed -Ene '2{s/VERSION="([^"]*)"/\1/; p}' dws 1>&2
read -ep "Input new version: "
version_new="$(echo "$REPLY" | xargs)"
read -ep "New version will be $version_new. Are you sure? [yN] "
echo "$REPLY" | xargs | grep -qvi '^y' && exit 1

sed -i -e "2s/^.*$/VERSION=\"$version_new\"/" dws || exit
if ! (git add dws && git commit --message="Set version to $version_new"); then
    x=$?
    git checkout dws
    echo "*** Version change is reverted. ***" 1>&2
    exit $x
fi
if ! git tag --sign --message="Release version $version_new" "$version_new" ; then
    x=$?
    git reset --hard HEAD^
    echo "*** Version change commit has been reset. ***" 1>&2
    exit $x
fi
if ! (git push && git push --tags) ; then
    x=$?
    echo "*** Despite the failure to push the new changes and tags, the version change is committed. ***" 1>&2
    exit $x
fi
