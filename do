#!/bin/sh
# You may redistribute this program and/or modify it under the terms of
# the GNU General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

CMAKE_DOWNLOAD=http://www.cmake.org/files/v2.8/cmake-2.8.8.tar.gz
CMAKE_SHA256=2b59897864d6220ff20aa8eac64cac8994e004898a1c0f899c8cb4d7b7570b46


# get a sha256sum implementation.
getsha256sum() {
    testFile=`tempfile`
    echo "test" > $testFile
    for hasher in sha256sum gsha256sum 'shasum -a 256' 'openssl sha256'
    do
        expected="f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2"
        #echo "trying ${hasher} ${testFile}"
        ${hasher} ${testFile} 2>/dev/null | grep -q ${expected} && SHA256SUM=${hasher} && break
    done
    [ ! "${SHA256SUM}" ] && echo "couldn't find working sha256 hasher." && exit 1
}



if [ ! -d build ]; then
    mkdir build;
fi
cd build

CMAKE=`which cmake`
if [ -d cmake-build ]; then
    CMAKE=`pwd`/cmake-build/bin/cmake
fi

[ "${CMAKE}" != "" ] && [ "`${CMAKE} --version | grep 2.8.[2-9]`" != "" ] || needCMake=1
if [ "$needCMake" = 1 ]; then
    getsha256sum
    [ -d cmake-build ] && rm -r cmake-build
    mkdir cmake-build
    cd cmake-build
    wget ${CMAKE_DOWNLOAD}
    ${SHA256SUM} ./*.tar.gz | grep ${CMAKE_SHA256} || exit -1
    tar -xf *.tar.gz
    find ./ -mindepth 1 -maxdepth 1 -type d -exec mv {} build \;
    ./build/configure && make || exit -1
    CMAKE=`pwd`/bin/cmake
    cd ..
fi

${CMAKE} .. && make