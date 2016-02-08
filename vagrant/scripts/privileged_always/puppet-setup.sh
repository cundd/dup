#!/bin/bash
set -o nounset
set -o errexit
set -e

: ${PUPPET_SETUP="false"}
: ${SOURCE_DIRECTORY_PATH=".puppet-source"}

#BINARY_TARGET_PATH="${BINARY_TARGET_PATH:-/usr/local/bin/sassc}";

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../../../shell/lib.sh}";
source "$DUP_LIB_PATH";

# --------------------------------------------------------
# Main methods
# --------------------------------------------------------
# Install the build tools
function install_build_tools() {
    #local build_tools="cmake make gcc
    local build_tools="build-base cmake boost-dev yaml-dev yaml";

    set -e;
    DUP_LIB_PACKAGE_NONINTERACTIVE="true" duplib::package_install $build_tools;
    set +e;
}

# Install ruby
function install_ruby() {
    local build_tools="ruby-dev ruby-json ruby-bundler ruby-io-console ";

    set -e;
    DUP_LIB_PACKAGE_NONINTERACTIVE="true" duplib::package_install $build_tools;
    set +e;
}

function install_yaml-cpp() {
    print_info "Download yaml-cpp";

    if [[ ! -e "yaml-cpp" ]]; then
        git clone "https://github.com/jbeder/yaml-cpp.git";
        cd "yaml-cpp";
    else
        cd "yaml-cpp";
        git pull;
    fi

    print_info "Build yaml-cpp";

    _cd "build";
    cmake -DBUILD_SHARED_LIBS=ON ..;

    make && sudo make install;
}

function download_from_puppetlabs() {
    if [[ $# -lt 2 ]]; then
        echo "Missing arguments";
        return 1;
    fi

    local package="$1";
    local package_version="$2";

    curl -O -Ss "https://downloads.puppetlabs.com/$package/$package-$package_version.tar.gz";
    tar xzf "$package-$package_version.tar.gz";
}

function install_facter() {
    local package="facter";
    local package_version="3.1.4";

    print_info "Download $package (v$package_version)";
    download_from_puppetlabs $package $package_version;
    cd "$package-$package_version";

    print_info "Build $package";

    _cd "release";
    cmake ..;

    make && sudo make install;
}

function install_puppet-agent() {
    local package="puppet";
    local package_version="4.3.2";

    print_info "Download $package (v$package_version)";
    download_from_puppetlabs $package $package_version;
    cd "$package-$package_version";

    print_info "Build $package";
    ruby install.rb --sitelibdir="$( ruby -e 'puts RbConfig::CONFIG["vendorlibdir"]' )";
}

function install_hiera() {
    # pkgname=hiera
    # pkgver=3.0.6
    # pkgrel=1
    # pkgdesc="Lightweight pluggable hierarchical database"
    # arch=('any')
    # url="http://projects.puppetlabs.com/projects/hiera"
    # license=('APACHE')
    # depends=('ruby')
    # backup=('etc/hiera.yaml')
    # source=(https://downloads.puppetlabs.com/$pkgname/$pkgname-$pkgver.tar.gz)
    # md5sums=('596be5ef2521f5a8c98d05760f5c86ad')
    #
    # package() {
    #   cd $pkgname-$pkgver
    #
    #   ruby install.rb --destdir="$pkgdir" --sitelibdir="$( ruby -e \
    #     'puts RbConfig::CONFIG["vendorlibdir"]' )" --mandir=/
    #
    #   install -d "$pkgdir"/var/lib/hiera/
    #
    #   install -Dm644 LICENSE "$pkgdir"/usr/share/licenses/$pkgname/LICENSE
    # }

    local package="hiera";
    local package_version="3.0.6";

    print_info "Download $package (v$package_version)";
    download_from_puppetlabs $package $package_version;
    cd "$package-$package_version";

    print_info "Build $package";
    ruby install.rb --sitelibdir="$( ruby -e 'puts RbConfig::CONFIG["vendorlibdir"]' )" --mandir=/;
}


# function download_sources() {
#     # curl -O -Ss https://downloads.puppetlabs.com/facter/facter-3.1.4.tar.gz
#     # curl -O -Ss https://downloads.puppetlabs.com/puppet/puppet-4.3.2.tar.gz
#
#     echo "Download puppet-agent";
#     if [[ ! -e "$SOURCE_DIRECTORY_PATH" ]]; then
#         git clone --depth=1 https://github.com/puppetlabs/puppet-agent.git "$SOURCE_DIRECTORY_PATH";
#     else
#         local current_directory="`pwd`";
#         cd "$SOURCE_DIRECTORY_PATH";
#         git pull;
#         cd "$current_directory";
#     fi
# }
# function build() {
#     cd "$SOURCE_DIRECTORY_PATH";
#
#     echo "Build puppet-agent";
#     echo "This may take a while";
#
#
#     ruby install.rb --sitelibdir="$( ruby -e 'puts RbConfig::CONFIG["vendorlibdir"]' )"
#
#     # bundle install;
#     # bundle exec build puppet-agent ;
#     #<desired platform> <vm hostname>
# }


# --------------------------------------------------------
# Helper methods
# --------------------------------------------------------
function print_info() {
    echo "$@" | tr '[:lower:]' '[:upper:]';
}

function _cd() {
    if [[ ! -e "$1" ]]; then
        mkdir "$1";
    fi
    cd "$1";
}

function main() {
    if [[ "$PUPPET_SETUP" == "true" ]]; then
        _cd "$SOURCE_DIRECTORY_PATH";
        SOURCE_DIRECTORY_PATH="`pwd`";

        install_build_tools;
        install_ruby;

        install_yaml-cpp;
        install_facter;
        install_hiera;
        install_puppet-agent;

        # download_sources;
        # build;

        # if [[ ! -x $BINARY_TARGET_PATH ]]; then
        #     echo "Install sass";
        #     mkdir -p "$SOURCE_DIRECTORY_PATH";
        #     cd "$SOURCE_DIRECTORY_PATH";
        #     SOURCE_DIRECTORY_PATH=`pwd`;
        #
        #     install_build_tools;
        #     download_sources;
        #     build;
        # else
        #     echo "sass already installed in $BINARY_TARGET_PATH";
        # fi
    fi
}

main $@
