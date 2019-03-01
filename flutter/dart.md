# Build DART

## Environment

- Ubuntu 16.04
  - Based on Google Compute Engine's _ubuntu-1604-xenial-v20190212_ image

***

## Prerequisite

- Install necessary packages

```bash
$ sudo apt-get install g++-multilib git python curl 
re2c
```

- Get tools

- LLVM (v7.0.1)
  - Get prebuilt binary from [http://releases.llvm.org/](http://releases.llvm.org/)
  - Extract & put in /usr/local

  ```bash
  $ wget http://releases.llvm.org/7.0.1/clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz
  $ tar xf clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz
  $ sudo cp -R clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-16.04/* /usr/local/
  ```

- ninja (v1.9.0)

  ```bash
  # Prebuilt binary
  $ wget https://github.com/ninja-build/ninja/releases/download/v1.9.0/ninja-linux.zip
  $ unzip ninja-linux.zip
  $ chmod +x ninja
  $ sudo mv ninja /usr/local/bin/

  # or from source:
  $ wget https://github.com/ninja-build/ninja/archive/v1.9.0.tar.gz
  $ tar xf v1.9.0.tar.gz
  $ cd ninja-1.9.0/
  $ ./configure.py --bootstrap
  $ sudo cp -R ninja /usr/local/bin/
  ```

- gn

  - From source

  ```bash
  $ git clone https://gn.googlesource.com/gn
  $ cd gn
  $ python build/gen.py
  # May need to be root
  $ ninja -C out
  # Optional: run tests
  $ out/gn_unittests
  ```

  - Or get prebuilt binary from [https://gn.googlesource.com/gn/](https://gn.googlesource.com/gn/)

- Depot tool: get & set path to it

  ```bash
  $ git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
  $ export PATH="$PATH:$PWD/depot_tools"
  ```

***

## Get source

```bash
$ mkdir dart-sdk
$ cd dart-sdk
$ fetch dart

# Get v2.2.0
$ cd sdk
$ git checkout 2.2.0
```

***

## Build

```bash
$ ./tools/build.py -m release -a arm64 create_sdk
```

- Final product is _out/ReleaseXARM64/dart_

***

## Run

```bash
$ ./dart hello-world.dart
The number is 42.
```

***

## References

- [https://github.com/dart-lang/sdk/wiki/Building](https://github.com/dart-lang/sdk/wiki/Building)
- [https://github.com/dart-lang/sdk/wiki/Building-Dart-SDK-for-ARM-processors](https://github.com/dart-lang/sdk/wiki/Building-Dart-SDK-for-ARM-processors)
