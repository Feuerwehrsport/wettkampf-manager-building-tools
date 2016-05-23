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

if [[ "$VERSION" == "" ]] ; then
  usage
  exit 1
fi


SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

GIT="git@github.com:Feuerwehrsport/wettkampf-manager.git"
PACKAGE_NAME="wettkampf-manager"

TRAVELING_RUBY_VERSION="20150517-2.1.6"
TRAVELING_RUBY_NATIVES=("bcrypt-3.1.10" "json-1.8.2" "nokogiri-1.6.6.2" "sqlite3-1.3.10")
TRAVELING_RUBY_URL="http://d6r77u77i8pq3.cloudfront.net/releases"

TEMP_PATH="/tmp/wettkampf-manager-packaging"
CODE_PATH="$TEMP_PATH/wettkampf-manager"
DEST_PATH="$TEMP_PATH/dest"
BUNDLE_CACHE="/tmp/bundle-cache"
DOWNLOAD_CACHE="$SCRIPT_PATH/../binary-clone"


rm -rf "$TEMP_PATH"

mkdir -p "$TEMP_PATH"
mkdir -p "$CODE_PATH"
mkdir -p "$DEST_PATH"

git clone "$GIT" "$CODE_PATH"
if [[ "$GIT_COMMIT_ID" == "" ]] ; then
  COMMIT_ID=$(git ls-remote $GIT refs/heads/master | cut -f1)
else
  cd "$CODE_PATH"
  git reset --hard "$GIT_COMMIT_ID"
  COMMIT_ID="$GIT_COMMIT_ID"
  cd "$SCRIPT_PATH"
fi
rm -rf "$CODE_PATH/.git"
rm -rf "$CODE_PATH/spec"
cd "$CODE_PATH"
rvm use 2.1.0@wettkampf-manager
bundle --without development test
RAILS_ENV=production rake assets:precompile
RAILS_ENV=production rake db:migrate
RAILS_ENV=production rake db:seed
RAILS_ENV=production rake import:suggestions[true]


if [[ "$CHANGE_FILE" == "" ]] ; then
  touch "$TEMP_PATH/change_log.md"
  vim "$TEMP_PATH/change_log.md"
else
  cp "$CHANGE_FILE" "$TEMP_PATH/change_log.md"
fi

$SCRIPT_PATH/release_info.py "$DATE" "$COMMIT_ID" "$(date '+%Y-%m-%d %H:%M:%S')" $TEMP_PATH/change_log.md > $TEMP_PATH/release-info.json

mkdir -p "$TEMP_PATH/packaging/tmp"
mkdir -p "$TEMP_PATH/packaging/vendor"

cp "$CODE_PATH/Gemfile" "$CODE_PATH/Gemfile.lock" "$TEMP_PATH/packaging/tmp/"
cd "$TEMP_PATH/packaging/tmp"

if [[ -d "$BUNDLE_CACHE" ]] ; then
  mkdir -p "$TEMP_PATH/packaging/vendor/ruby"
  cp -r $BUNDLE_CACHE/2.1.0 "$TEMP_PATH/packaging/vendor/ruby/"
fi
rvm use 2.1.0@wettkampf-manager
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
rm -f $TEMP_PATH/packaging/vendor/ruby/*/gems/*/ext/*/tmp
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


default_target() {
  TARGET="$1"
  NODEJS_TARGET="$2"

  PACKAGE_VERSION_NAME="$PACKAGE_NAME-$VERSION-$TARGET"
  PACKAGE_PATH="$TEMP_PATH/$PACKAGE_VERSION_NAME"

  RUBY_TAR="$DOWNLOAD_CACHE/traveling-ruby-$TRAVELING_RUBY_VERSION-$TARGET.tar.gz"
  cd "$TEMP_PATH"

  mkdir -p "$PACKAGE_PATH/lib/ruby"
  tar -xzf "$RUBY_TAR" -C "$PACKAGE_PATH/lib/ruby"
  cp -pR "$TEMP_PATH/packaging/vendor" "$PACKAGE_PATH/lib/"
  cp "$CODE_PATH/Gemfile" "$CODE_PATH/Gemfile.lock" "$PACKAGE_PATH/lib/vendor/"

  for NATIVE in ${TRAVELING_RUBY_NATIVES[@]}; do
    NATIVE_TAR="$DOWNLOAD_CACHE/traveling-ruby-$TRAVELING_RUBY_VERSION-$TARGET-$NATIVE.tar.gz"
    mkdir -p "$PACKAGE_PATH/lib/vendor/ruby"
    tar -xzf "$NATIVE_TAR" -C "$PACKAGE_PATH/lib/vendor/ruby"
  done
  
  cp -r "$CODE_PATH" "$PACKAGE_PATH/"

  # node
  NODE_TAR="$DOWNLOAD_CACHE/node-$NODEJS_TARGET.tar.gz"
  tar -xzf "$NODE_TAR" -C "$TEMP_PATH"
  mkdir -p "$PACKAGE_PATH/lib/node/bin"
  chmod -R go-w "$PACKAGE_PATH/lib/node"
  cp "$TEMP_PATH/node-v4.1.0-$NODEJS_TARGET/bin/node" "$PACKAGE_PATH/lib/node/bin/"
  cp "$TEMP_PATH/node-v4.1.0-$NODEJS_TARGET/LICENSE" "$PACKAGE_PATH/lib/node/"

  # clean
  rm -rf $PACKAGE_PATH/lib/ruby/lib/ruby/*/rdoc*

  # Skripte kopieren
  cp -r $SCRIPT_PATH/posix/ $PACKAGE_PATH/
  cp $SCRIPT_PATH/../dokumentation/dokumentation.pdf $PACKAGE_PATH/anleitung.pdf

  tar -C $TEMP_PATH -czf $DEST_PATH/$PACKAGE_VERSION_NAME.tar.gz $PACKAGE_VERSION_NAME
}

windows_target() {
  TARGET="windows"
  PACKAGE_VERSION_NAME="$PACKAGE_NAME-$VERSION-$TARGET"
  PACKAGE_PATH="$TEMP_PATH/$PACKAGE_VERSION_NAME"


  mkdir -p "$PACKAGE_PATH/ruby/lib/ruby/gems/2.1.0"
  cp -r "$CODE_PATH" "$PACKAGE_PATH/"
  cp -pr "$TEMP_PATH/packaging/vendor/ruby/2.1.0" "$PACKAGE_PATH/ruby/lib/ruby/gems/"

  rm $PACKAGE_PATH/ruby/lib/ruby/gems/2.1.0/specifications/bcrypt-3*.gemspec
  rm $PACKAGE_PATH/ruby/lib/ruby/gems/2.1.0/specifications/nokogiri-1*.gemspec
  rm $PACKAGE_PATH/ruby/lib/ruby/gems/2.1.0/specifications/sqlite3-1*.gemspec

  rm -r $PACKAGE_PATH/ruby/lib/ruby/gems/2.1.0/gems/bcrypt-3*
  rm -r $PACKAGE_PATH/ruby/lib/ruby/gems/2.1.0/gems/json-1*
  rm -r $PACKAGE_PATH/ruby/lib/ruby/gems/2.1.0/gems/nokogiri-1*
  rm -r $PACKAGE_PATH/ruby/lib/ruby/gems/2.1.0/gems/sqlite3-1*

  cp -pr $SCRIPT_PATH/../ruby_windows/* $PACKAGE_PATH/ruby/
  cp -pr $SCRIPT_PATH/windows/* $PACKAGE_PATH/
  cp $SCRIPT_PATH/../dokumentation/dokumentation.pdf $PACKAGE_PATH/anleitung.pdf
  mkdir -p $PACKAGE_PATH/wettkampf-manager/.bundle
  cp $SCRIPT_PATH/windows-bundle-config $PACKAGE_PATH/wettkampf-manager/.bundle/config

  cd $PACKAGE_PATH
  zip -r $DEST_PATH/$PACKAGE_VERSION_NAME.zip .
}


default_target "linux-x86_64" "linux-x64"
default_target "linux-x86" "linux-x86"
default_target "osx" "darwin-x64"
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
  PUBLISH_TARGET="/srv/fws-statistik/shared/uploads/wettkampf_manager"
  mkdir -p "$PUBLISH_TARGET/$VERSION/"
  cp -r $DEST_PATH/* "$PUBLISH_TARGET/$VERSION/"
  cp $TEMP_PATH/release-info.json "$PUBLISH_TARGET/$VERSION/"
fi
