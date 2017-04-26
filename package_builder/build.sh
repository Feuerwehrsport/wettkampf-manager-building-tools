#!/bin/bash
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
set -e

usage() {
cat << EOF
usage: $0 [OPTIONS]

OPTIONS:
 -h               Show this message
 -v VERSION       Version
 -g GIT_COMMIT    Specific git commit id
 -d DATE          Specific date
 -c CHANGE_FILE   markdown file with change log
 -f               force publishing
EOF
}

VERSION=""
GIT_COMMIT_ID=""
CHANGE_FILE=""
FORCE_PUBLISH="n"
DATE="$(date '+%Y-%m-%d')"
while getopts "hv:g:d:c:f" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    v)
      VERSION=$OPTARG
      ;;
    g)
      GIT_COMMIT_ID=$OPTARG
      ;;
    d)
      DATE=$OPTARG
      ;;
    c)
      CHANGE_FILE="$OPTARG"
      ;;
    f)
      FORCE_PUBLISH="y"
      ;;
    ?)
      usage
      exit
      ;;
  esac
done


SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

GIT="git@github.com:Feuerwehrsport/wettkampf-manager.git"
PACKAGE_NAME="wettkampf-manager"

TEMP_PATH="/tmp/wettkampf-manager-packaging"
CODE_PATH="$TEMP_PATH/wettkampf-manager"
DEST_PATH="$TEMP_PATH/dest"
BUNDLE_CACHE="/tmp/bundle-cache"
DOWNLOAD_CACHE="$SCRIPT_PATH/../binary-clone"


rm -rf "$TEMP_PATH"

mkdir -p "$TEMP_PATH"
mkdir -p "$CODE_PATH"
mkdir -p "$DEST_PATH"

git clone -b release "$GIT" "$CODE_PATH"
if [[ "$GIT_COMMIT_ID" == "" ]] ; then
  COMMIT_ID=$(git ls-remote $GIT refs/heads/release | cut -f1)
else
  cd "$CODE_PATH"
  git reset --hard "$GIT_COMMIT_ID"
  COMMIT_ID="$GIT_COMMIT_ID"
  cd "$SCRIPT_PATH"
fi

SECRET_KEY_BASE=$(pwgen 60 -n 1)
sed -i "s/<%= CHANGED_BY_BUILDING_TOOL %>/$SECRET_KEY_BASE/" "$CODE_PATH/config/secrets.yml"

rm -rf "$CODE_PATH/.git"
rm -rf "$CODE_PATH/spec"
cd "$CODE_PATH"
rvm use 2.3.3@wettkampf-manager
bundle --without development test
RAILS_ENV=production rake assets:precompile
find public/assets -name *.gz -delete
RAILS_ENV=production rake db:migrate
RAILS_ENV=production rake db:seed
RAILS_ENV=production rake import:suggestions[true]

if [[ "$VERSION" == "" ]] ; then
  CURRENT_RELEASE_FILE="$(ls "$CODE_PATH/doc/releases" | tail -n 1)"
  CHANGE_FILE="$CODE_PATH/doc/releases/$CURRENT_RELEASE_FILE"
  VERSION="$(echo "$CURRENT_RELEASE_FILE" | sed -E 's/^.+_//' | sed 's/.md$//' )"
  DATE="$(echo "$CURRENT_RELEASE_FILE" | sed -E 's/_.+$//')"
fi

if [[ "$CHANGE_FILE" == "" ]] ; then
  touch "$TEMP_PATH/change_log.md"
  vim "$TEMP_PATH/change_log.md"
else
  cp "$CHANGE_FILE" "$TEMP_PATH/change_log.md"
fi


cp -r "$CODE_PATH/doc/dokumentation/" "$TEMP_PATH/"
rm -rf "$CODE_PATH/doc"

$SCRIPT_PATH/release_info.py "$DATE" "$COMMIT_ID" "$(date '+%Y-%m-%d %H:%M:%S')" $TEMP_PATH/change_log.md > $TEMP_PATH/release-info.json

mkdir -p "$TEMP_PATH/packaging/tmp"
mkdir -p "$TEMP_PATH/packaging/vendor"

cp "$CODE_PATH/Gemfile" "$CODE_PATH/Gemfile.lock" "$TEMP_PATH/packaging/tmp/"
cd "$TEMP_PATH/packaging/tmp"

if [[ -d "$BUNDLE_CACHE" ]] ; then
  mkdir -p "$TEMP_PATH/packaging/vendor/ruby"
  cp -r $BUNDLE_CACHE/2.3.0 "$TEMP_PATH/packaging/vendor/ruby/"
fi
rvm use 2.3.3@wettkampf-manager
BUNDLE_IGNORE_CONFIG=1 bundle install --clean --deployment --path ../vendor --without development test
cp -fr "$TEMP_PATH/packaging/vendor/ruby" "$BUNDLE_CACHE"


mkdir -p "$TEMP_PATH/packaging/vendor/.bundle"
cp "$SCRIPT_PATH/linux-bundle-config" "$TEMP_PATH/packaging/vendor/.bundle/config"

# Remove tests
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/test
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/tests
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/spec
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/features
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/benchmark

# Remove documentation
rm -f $TEMP_PATH/packaging/vendor/ruby/*/gems/*/README*
rm -f $TEMP_PATH/packaging/vendor/ruby/*/gems/*/CHANGE*
rm -f $TEMP_PATH/packaging/vendor/ruby/*/gems/*/Change*
rm -f $TEMP_PATH/packaging/vendor/ruby/*/gems/*/COPYING*
rm -f $TEMP_PATH/packaging/vendor/ruby/*/gems/*/LICENSE*
rm -f $TEMP_PATH/packaging/vendor/ruby/*/gems/*/MIT-LICENSE*
rm -f $TEMP_PATH/packaging/vendor/ruby/*/gems/*/TODO
rm -f $TEMP_PATH/packaging/vendor/ruby/*/gems/*/*.txt
rm -f $TEMP_PATH/packaging/vendor/ruby/*/gems/*/*.md
rm -f $TEMP_PATH/packaging/vendor/ruby/*/gems/*/*.rdoc
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/doc
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/docs
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/example
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/examples
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/sample
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/doc-api
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/GPL*


find $TEMP_PATH/packaging/vendor/ruby -name '*.md' -exec rm {} \;

# Remove misc unnecessary files
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/.gitignore
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/.travis.yml

# Remove leftover native extension sources and compilation objects
rm -f $TEMP_PATH/packaging/vendor/*/*/cache/*
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/extensions
rm -f $TEMP_PATH/packaging/vendor/ruby/*/gems/*/ext/Makefile
rm -f $TEMP_PATH/packaging/vendor/ruby/*/gems/*/ext/*/Makefile
rm -rf $TEMP_PATH/packaging/vendor/ruby/*/gems/*/ext/*/tmp
find $TEMP_PATH/packaging/vendor/ruby -name '*.c' -exec rm {} \;
find $TEMP_PATH/packaging/vendor/ruby -name '*.cpp' -exec rm {} \;
find $TEMP_PATH/packaging/vendor/ruby -name '*.h' -exec rm {} \;
find $TEMP_PATH/packaging/vendor/ruby -name '*.rl' -exec rm {} \;
find $TEMP_PATH/packaging/vendor/ruby -name 'extconf.rb' -exec rm {} \;
find $TEMP_PATH/packaging/vendor/ruby/*/gems -name '*.o' -exec rm {} \;
find $TEMP_PATH/packaging/vendor/ruby/*/gems -name '*.so' -exec rm {} \;
find $TEMP_PATH/packaging/vendor/ruby/*/gems -name '*.bundle' -exec rm {} \;

# Remove Java files. They're only used for JRuby support
find $TEMP_PATH/packaging/vendor/ruby -name '*.java' -exec rm {} \;
find $TEMP_PATH/packaging/vendor/ruby -name '*.class' -exec rm {} \;


windows_target() {
  TARGET="windows"
  PACKAGE_VERSION_NAME="$PACKAGE_NAME-$VERSION-$TARGET"
  PACKAGE_PATH="$TEMP_PATH/$PACKAGE_VERSION_NAME"

  mkdir -p "$PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0"
  cp -r "$CODE_PATH" "$PACKAGE_PATH/"
  cp -pr "$TEMP_PATH/packaging/vendor/ruby/2.3.0" "$PACKAGE_PATH/ruby/lib/ruby/gems/"

  rm -f $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/specifications/bcrypt-*.gemspec
  rm -f $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/specifications/bundler-*.gemspec
  rm -f $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/specifications/ffi-*.gemspec
  rm -f $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/specifications/hitimes-*.gemspec
  rm -f $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/specifications/json-*.gemspec
  rm -f $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/specifications/nokogiri-*.gemspec
  rm -f $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/specifications/sqlite3-*.gemspec
  rm -f $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/specifications/win32console-*.gemspec

  rm -rf $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/gems/bcrypt-*
  rm -rf $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/gems/bundler-*
  rm -rf $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/gems/ffi-*
  rm -rf $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/gems/hitimes-*
  rm -rf $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/gems/json-*
  rm -rf $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/gems/nokogiri-*
  rm -rf $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/gems/sqlite3-*
  rm -rf $PACKAGE_PATH/ruby/lib/ruby/gems/2.3.0/gems/win32console-*

  cp -pr $SCRIPT_PATH/../ruby_windows/* $PACKAGE_PATH/ruby/
  cp -pr $SCRIPT_PATH/windows/* $PACKAGE_PATH/
  cp $TEMP_PATH/dokumentation/windows.pdf $PACKAGE_PATH/anleitung.pdf
  mkdir -p $PACKAGE_PATH/wettkampf-manager/.bundle
  cp $SCRIPT_PATH/windows-bundle-config $PACKAGE_PATH/wettkampf-manager/.bundle/config

  cd $PACKAGE_PATH
  zip -r $DEST_PATH/$PACKAGE_VERSION_NAME.zip .
}


windows_target

cd $DEST_PATH
pwd
ls -lh .

if [[ "$FORCE_PUBLISH" == "y" ]] ; then
  REPLY="y"
else
  echo -n "Erzeugte Dateien veröffentlichen? [j/n] "
  read REPLY
fi

if [[ "$REPLY" =~ ^[YyJj]$ ]] ; then
  PUBLISH_TARGET="/srv/feuerwehrsport-statistik/shared/uploads/wettkampf_manager"
  mkdir -p "$PUBLISH_TARGET/$VERSION/"
  cp -r $DEST_PATH/* "$PUBLISH_TARGET/$VERSION/"
  cp $TEMP_PATH/release-info.json "$PUBLISH_TARGET/$VERSION/"
fi
