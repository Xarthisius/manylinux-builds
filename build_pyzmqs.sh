#!/bin/bash
# Run with:
#    docker run --rm -v $PWD:/io quay.io/pypa/manylinux1_x86_64 /io/build_pyzmqs.sh
# or something like:
#    docker run --rm -e PYTHON_VERSIONS=2.7 -v $PWD:/io quay.io/pypa/manylinux1_x86_64 /io/build_pyzmqs.sh
# or:
#    docker run --rm -e PYZMQ_VERSIONS=15.2.0 -e PYTHON_VERSIONS=2.7 -v $PWD:/io quay.io/pypa/manylinux1_x86_64 /io/build_pyzmqs.sh
set -e

# Manylinux, openblas version, lex_ver, Python versions
source /io/common_vars.sh

PYZMQ_VERSIONS="${PYZMQ_VERSIONS:-14.0.1 14.1.0 14.1.1 14.2.0 14.3.0 14.3.1 \
                14.4.0 14.4.1 14.5.0 14.6.0 14.7.0 15.0.0 15.1.0 15.2.0}"

LIBSODIUM_VERSION="${LIBSODIUM_VERSION:-1.0.10}"
ZMQ_VERSION="${ZMQ_VERSION:-4.1.5}"

# Build libsodium
build_archive libsodium-${LIBSODIUM_VERSION} https://download.libsodium.org/libsodium/releases

# Build zmq
build_archive zeromq-${ZMQ_VERSION} https://github.com/zeromq/zeromq4-1/releases/download/v${ZMQ_VERSION}

# Directory to store wheels
rm_mkdir unfixed_wheels

# Compile wheels
for PYTHON in ${PYTHON_VERSIONS}; do
    PIP="$(cpython_path $PYTHON)/bin/pip"
    for PYZMQ in ${PYZMQ_VERSIONS}; do
        $PIP wheel "pyzmq==$PYZMQ" -w unfixed_wheels
    done
done

# Bundle external shared libraries into the wheels
repair_wheelhouse unfixed_wheels $WHEELHOUSE
