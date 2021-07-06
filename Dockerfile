FROM alpine:3.13

RUN apk update && apk upgrade && apk --update add \
    ruby-full ruby-dev ruby-rake ruby-io-console ruby-bigdecimal ruby-json ruby-bundler \
    libstdc++ tzdata bash ca-certificates openjdk8 openjdk11-jdk \
      make gcc libc-dev g++ \
    &&  echo 'gem: --no-document' > /etc/gemrc
    #RUN apk add ruby-full
    #RUN apk add ruby-dev

ENV ANDROID_HOME="/opt/android-sdk" \
    ANDROID_NDK="/opt/android-ndk" \
    JAVA_HOME="/usr/lib/jvm/java-8-openjdk/"

ENV TZ=America/Los_Angeles

# Get the latest version from https://developer.android.com/studio/index.html
ENV ANDROID_SDK_TOOLS_VERSION="4333796"

# Get the latest version from https://developer.android.com/ndk/downloads/index.html
ENV ANDROID_NDK_VERSION="r21e"

# nodejs version
ENV NODE_VERSION="12.x"

# Set locale
ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"

#RUN apt-get clean && \
#    apt-get update -qq && \
#    apt-get install -qq -y apt-utils locales && \
#    locale-gen $LANG

#ENV DEBIAN_FRONTEND="noninteractive" \
#    TERM=dumb \
#    DEBIAN_FRONTEND=noninteractive

# Variables must be references after they are created
ENV ANDROID_SDK_HOME="$ANDROID_HOME"
ENV ANDROID_NDK_HOME="$ANDROID_NDK/android-ndk-$ANDROID_NDK_VERSION"

ENV PATH_NO_JAVA="$JAVA_HOME/bin:$PATH:$ANDROID_SDK_HOME/emulator:$ANDROID_SDK_HOME/tools/bin:$ANDROID_SDK_HOME/tools:$ANDROID_SDK_HOME/platform-tools:$ANDROID_NDK:$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin"
ENV PATH="$JAVA_HOME/bin:$PATH_NO_JAVA"

#WORKDIR /tmp

# Install fastlane with bundler and Gemfile
ENV BUNDLE_GEMFILE=/tmp/Gemfile

COPY Gemfile /tmp/Gemfile

RUN echo "fastlane" && \
    mkdir -p /.fastlane && \
    chmod 777 /.fastlane && \
    bundle install --quiet

# Installing packages
#RUN apt-get update -qq > /dev/null && \
#    apt-get install -qq locales > /dev/null && \
#    locale-gen "$LANG" > /dev/null && \
#    apt-get install -qq --no-install-recommends \
#        autoconf \
#        build-essential \
#        curl \
#        file \
#        git \
#        gpg-agent \
#        less \
#        lib32stdc++6 \
#        lib32z1 \
#        lib32z1-dev \
#        lib32ncurses5 \
#        libc6-dev \
#        libgmp-dev \
#        libmpc-dev \
#        libmpfr-dev \
#        libxslt-dev \
#        libxml2-dev \
#        m4 \
#        ncurses-dev \
#        ocaml \
#        openjdk-8-jdk \
#        openjdk-11-jdk \
#        openssh-client \
#        pkg-config \
#        ruby-full \
#        software-properties-common \
#        tzdata \
#        unzip \
#        vim-tiny \
#        wget \
#        zip \
#        zlib1g-dev > /dev/null && \
#    echo "set timezone" && \
#    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
#    echo "nodejs, npm, cordova, ionic, react-native" && \
#    curl -sL -k https://deb.nodesource.com/setup_${NODE_VERSION} \
#        | bash - > /dev/null && \
#    apt-get install -qq nodejs > /dev/null && \
#    apt-get clean > /dev/null && \
#    curl -sS -k https://dl.yarnpkg.com/debian/pubkey.gpg \
#        | apt-key add - > /dev/null && \
#    echo "deb https://dl.yarnpkg.com/debian/ stable main" \
#        | tee /etc/apt/sources.list.d/yarn.list > /dev/null && \
#    apt-get update -qq > /dev/null && \
#    apt-get install -qq yarn > /dev/null && \
#    rm -rf /var/lib/apt/lists/ && \
#    npm install --quiet -g npm > /dev/null && \
#    npm install --quiet -g \
#        bower \
#        cordova \
#        eslint \
#        gulp \
#        ionic \
#        jshint \
#        karma-cli \
#        mocha \
#        node-gyp \
#        npm-check-updates \
#        react-native-cli > /dev/null && \
#    npm cache clean --force > /dev/null && \
#    rm -rf /tmp/* /var/tmp/*

# Install Android SDK
RUN echo "sdk tools ${ANDROID_SDK_TOOLS_VERSION}" && \
    wget --quiet --output-document=sdk-tools.zip \
        "https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS_VERSION}.zip" && \
    mkdir --parents "$ANDROID_HOME" && \
    unzip -q sdk-tools.zip -d "$ANDROID_HOME" && \
    rm -f sdk-tools.zip && \
    echo "ndk ${ANDROID_NDK_VERSION}" && \
    wget --quiet --output-document=android-ndk.zip \
    "http://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip" && \
    mkdir --parents "$ANDROID_NDK_HOME" && \
    unzip -q android-ndk.zip -d "$ANDROID_NDK" && \
    rm -f android-ndk.zip

# Install SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.
RUN mkdir --parents "$HOME/.android/" && \
    echo '### User Sources for Android SDK Manager' > \
        "$HOME/.android/repositories.cfg" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager --licenses && \
    echo "platforms" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "platforms;android-30" && \
    echo "platform tools" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "platform-tools" && \
    echo "build tools 25-30" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "build-tools;30.0.3" \
    > /dev/null

#RUN echo "emulator" && \
#    yes | "$ANDROID_HOME"/tools/bin/sdkmanager "emulator" > /dev/null

#RUN echo "kotlin" && \
#    wget --quiet -O sdk.install.sh "https://get.sdkman.io" && \
#    bash -c "bash ./sdk.install.sh > /dev/null && source ~/.sdkman/bin/sdkman-init.sh && sdk install kotlin" && \
#    rm -f sdk.install.sh

#RUN echo "Flutter sdk" && \
#    cd /opt && \
#    wget --quiet https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.22.0-stable.tar.xz -O flutter.tar.xz && \
#    tar xf flutter.tar.xz && \
#    flutter config --no-analytics && \
#    rm -f flutter.tar.xz

# Copy sdk license agreement files.
RUN mkdir -p $ANDROID_HOME/licenses && \
    apk del openjdk8
COPY sdk/licenses/* $ANDROID_HOME/licenses/

# Create some jenkins required directory to allow this image run with Jenkins
#RUN mkdir -p /var/lib/jenkins/workspace && \
#    mkdir -p /home/jenkins && \
#    chmod 777 /home/jenkins && \
#    chmod 777 /var/lib/jenkins/workspace && \
#    chmod 777 $ANDROID_HOME/.android

#COPY README.md /README.md

ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk/", PATH="$JAVA_HOME/bin:$PATH_NO_JAVA"

ARG BUILD_DATE=""
ARG SOURCE_BRANCH=""
ARG SOURCE_COMMIT=""
ARG DOCKER_TAG=""

ENV BUILD_DATE=${BUILD_DATE} \
    SOURCE_BRANCH=${SOURCE_BRANCH} \
    SOURCE_COMMIT=${SOURCE_COMMIT} \
    DOCKER_TAG=${DOCKER_TAG}
