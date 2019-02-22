# Build DART

## Prerequisite

- ninja (v1.9.0)
  - Get prebuilt binary

```bash
$ wget https://github.com/ninja-build/ninja/archive/v1.9.0.tar.gz
$ unzip v1.9.0.tar.gz
$ chmod +x ninja
```

- gn
  - Get prebuilt binary from [https://gn.googlesource.com/gn/](https://gn.googlesource.com/gn/)

- LLVM (v7.0.1)
  - Get prebuilt binary from [http://releases.llvm.org/](http://releases.llvm.org/)

```bash

```

##


***

```bash
$ git clone https://gn.googlesource.com/gn
$ cd gn
$ python build/gen.py
# May need to be root
$ ninja -C out

# To run tests:
$ out/gn_unittests
```
0