#!/bin/bash

set -ue

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

GIT="git@github.com:Feuerwehrsport/wettkampf-manager.git"
PACKAGE_NAME="wettkampf-manager"
VERSION="1.0.0"

TRAVELING_RUBY_VERSION="20150517-2.1.6"
TRAVELING_RUBY_NATIVES=("bcrypt-3.1.10" "json-1.8.2" "nokogiri-1.6.6.2" "sqlite3-1.3.10")
TRAVELING_RUBY_URL="http://d6r77u77i8pq3.cloudfront.net/releases"

TEMP_PATH="/tmp/wettkampf-manager"
CODE_PATH="$TEMP_PATH/wettkampf-manager"

rm -rf "$TEMP_PATH"

mkdir -p "$TEMP_PATH"
mkdir -p "$CODE_PATH"

git clone "$GIT" "$CODE_PATH"
rm -rf "$CODE_PATH/.git"

mkdir -p "$TEMP_PATH/packaging/tmp"
mkdir -p "$TEMP_PATH/packaging/vendor"

cp "$CODE_PATH/Gemfile" "$CODE_PATH/Gemfile.lock" "$TEMP_PATH/packaging/tmp/"
cd "$TEMP_PATH/packaging/tmp"
cp -r "/tmp/ruby" "$TEMP_PATH/packaging/vendor/ruby"
# BUNDLE_IGNORE_CONFIG=1 bundle install --deployment --verbose --path ../vendor --without development test
#fake bundle

mkdir -p "$TEMP_PATH/packaging/vendor/.bundle"
cp "$SCRIPT_PATH/bundle-config" "$TEMP_PATH/packaging/vendor/.bundle/config"

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
  cd "$TEMP_PATH"
  curl -L -O --fail "$TRAVELING_RUBY_URL/traveling-ruby-$TRAVELING_RUBY_VERSION-$TARGET.tar.gz"

  mkdir -p "$PACKAGE_PATH/lib/ruby"
  tar -xzf "traveling-ruby-$TRAVELING_RUBY_VERSION-$TARGET.tar.gz" -C "$PACKAGE_PATH/lib/ruby"
  cp -pR "$TEMP_PATH/packaging/vendor" "$PACKAGE_PATH/lib/"
  cp "$CODE_PATH/Gemfile" "$CODE_PATH/Gemfile.lock" "$PACKAGE_PATH/lib/vendor/"

  for NATIVE in ${TRAVELING_RUBY_NATIVES[@]}; do
    curl -L --fail -o "$TEMP_PATH/traveling-ruby-$TRAVELING_RUBY_VERSION-$TARGET-$NATIVE.tar.gz" "$TRAVELING_RUBY_URL/traveling-ruby-gems-$TRAVELING_RUBY_VERSION-$TARGET/$NATIVE.tar.gz"
    mkdir -p "$PACKAGE_PATH/lib/vendor/ruby"
    tar -xzf "$TEMP_PATH/traveling-ruby-$TRAVELING_RUBY_VERSION-$TARGET-$NATIVE.tar.gz" -C "$PACKAGE_PATH/lib/vendor/ruby"
  done
  
  cp -r "$CODE_PATH" "$PACKAGE_PATH/"
  cp "$SCRIPT_PATH/wrapper.sh" "$PACKAGE_PATH/lib/"
  chmod +x "$PACKAGE_PATH/lib/wrapper.sh"

  # node
  curl -L --fail -o "$TEMP_PATH/node-$NODEJS_TARGET.tar.gz" "https://nodejs.org/dist/v4.1.0/node-v4.1.0-$NODEJS_TARGET.tar.gz"
  tar -xzf "$TEMP_PATH/node-$NODEJS_TARGET.tar.gz" -C "$TEMP_PATH"
  mkdir -p "$PACKAGE_PATH/lib/node/bin"
  chmod -R go-w "$PACKAGE_PATH/lib/node"
  cp "$TEMP_PATH/node-v4.1.0-$NODEJS_TARGET/bin/node" "$PACKAGE_PATH/lib/node/bin/"
  cp "$TEMP_PATH/node-v4.1.0-$NODEJS_TARGET/LICENSE" "$PACKAGE_PATH/lib/node/"

  # clean
  rm -rf $PACKAGE_PATH/lib/ruby/lib/ruby/*/rdoc*

  # Skripte kopieren
  cp $SCRIPT_PATH/install.sh $PACKAGE_PATH/
  cp $SCRIPT_PATH/start_console.sh $PACKAGE_PATH/
  cp $SCRIPT_PATH/start_server.sh $PACKAGE_PATH/
  cp $SCRIPT_PATH/port_redirection.sh $PACKAGE_PATH/

  tar -C $TEMP_PATH -czf $PACKAGE_PATH.tar.gz $PACKAGE_VERSION_NAME
  # upload to server
}

default_target "linux-x86_64" "linux-x64"
default_target "linux-x86" "linux-x86"
default_target "osx" "darwin-x64"
