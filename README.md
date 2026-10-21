# Phloem

Phloem is a small suite of MPI benchmarks built the way HPC applications are typically buit and
showcasing some HPC communication patterns (such as partitioned communicators) that are generally
not seen in other MPI benchmarking suites.
You can find detailed documentation at `software.llnl.gov/phloem/
<https://software.llnl.gov/phloem/>`_.

## UNDER CONSTRUCTION

We are just getting this new version of Phloem set up on Github with containers, documentation,
[Hubcast](https://hpc.llnl.gov/software/hubcast), style, and more. We appreciate your patience
while we complete this process.

## Getting Started

The containerfile under `containers/` has a container based on the
[Flux Framework Containers](https://flux-framework.readthedocs.io/en/latest/tutorials/containers/index.html).
We used Flux because it does not require root and therefore takes quite well to container
environments, allowing you to quickly test your stack when fully integrated with a resource
manager. The Development Container information in `.devcontainer` is designed to provide everything
you need to test locally on your system.

### Prerequisites

At a minimum, the Phloem suite depends on MPI, CMake, and C. You will find the Umpire and BLT
dependencies vendored in this repo. These submodules only need to be initialized if you will build
outside of Spack.

### Installing

Phloem can be installed in 2 ways:

1. Spack
2. Standalone CMake with BLT

#### Spack-Based Installation

If you are using Spack, it is highly recommended that you use a Spack Environment to control
dependencies and concretization.

Create and activate an environment with the commands:

```bash
spack env create my-environment && spack env activate my-environment
```

Now find your desired externals. For example, if you would like to use GCC as the compiler and
MVAPICH as the MPI, run:

```bash
spack external find cmake gmake gcc mvapich
```

If Spack doesn't correctly resolve externals that you are sure exist, you can manually edit the
`spack.yaml` for your environment in a variety of ways, for exmaple:

```bash
code -r `spack location -e`/spack.yaml
```

You can see what is available on your system with commands such as:

```bash
module spider cmake
```

or


```bash
rpm -qa cmake
```

or

```bash
apt list --installed cmake
```

You can query the available options or variants for Phloem with:

```bash
spack info phloem
```

and then add phloem to your environment with a command such as:

```bash
spack add phloem
```

Please see our included `spack.yaml` files for examples of environments in different systems. The
ideal workflow for Spack Environment creation for Phloem is to try to get the output of
`spack concretize --force --fresh` to look like the below:

```
==> Concretized 1 spec:
[+]  6lwk2al  phloem@main~cuda~ipo~rocm build_system=cmake build_type=Release dev_path=/g/g0/nhanford/.jacamar-ci/builds/Xyp9ididg/001/gitlab/phloem/phloem2 generator=make platform=linux os=rhel8 target=broadwell %!c(MISSING),cxx=gcc@13.3.1
[+]  msr5on6      ^blt@0.7.1 build_system=generic patches:=116702b platform=linux os=rhel8 target=broadwell %!c(MISSING),cxx,fortran=gcc@13.3.1
[e]  t6y4x4g      ^cmake@3.26.5~doc+ncurses+ownlibs~qtgui build_system=generic build_type=Release platform=linux os=rhel8 target=x86_64
[+]  nepdugr      ^compiler-wrapper@1.0 build_system=generic platform=linux os=rhel8 target=broadwell
[e]  xrm3n2p      ^gcc@13.3.1+binutils+bootstrap~graphite+libsanitizer~mold~nvptx~piclibs~profiled~strip build_system=autotools build_type=RelWithDebInfo languages:='c,c++,fortran' platform=linux os=rhel8 target=x86_64
[+]  rawdqhs      ^gcc-runtime@13.3.1 build_system=generic platform=linux os=rhel8 target=broadwell
[e]  wklw66w      ^glibc@2.28 build_system=autotools platform=linux os=rhel8 target=x86_64
[e]  62xfmgh      ^gmake@4.2.1~guile build_system=generic platform=linux os=rhel8 target=x86_64
[e]  kca2am7      ^mvapich2@2.3.7~alloca~debug~hwloc_graphics~hwlocv2+regcache+wrapperrpath build_system=autotools ch3_rank_bits:=32 fabrics:=mrail file_systems:=lustre,nfs,ufs process_managers:=hydra threads:=multiple platform=linux os=rhel8 target=x86_64
[+]  ph2jec7      ^umpire@2025.12.0~asan~backtrace+c~cuda~dev_benchmarks~device_alloc~deviceconst~examples+fmt_header_only~fortran~ipc_shmem~ipo~mpi~mpi3_shmem~numa~omptarget~openmp~rocm~sanitizer_tests+shared~sqlite_experimental~tools~werror build_system=cmake build_type=Release commit=0372fbd6e1f17d7e6dd72693f8b857f3ec7559e9 generator=make tests=none platform=linux os=rhel8 target=broadwell %!c(MISSING),cxx=gcc@13.3.1
[+]  h2f67u4          ^camp@2025.12.0~cuda~ipo~omptarget~openmp~rocm~sycl~tests build_system=cmake build_type=Release commit=a8caefa9f4c811b1a114b4ed2c9b681d40f12325 generator=make platform=linux os=rhel8 target=broadwell %!c(MISSING),cxx=gcc@13.3.1
[+]  hzu7nq5          ^fmt@11.0.2~ipo+pic~shared build_system=cmake build_type=Release cxxstd=11 generator=make platform=linux os=rhel8 target=broadwell %!c(MISSING),cxx=gcc@13.3.1
==> Updating view at /p/vast1/nhanford/ci/spack/var/spack/environments/phloem/.spack-env/view
```

Once you're satisfied with the result, you are ready to install Phloem with Spack as follows:

```bash
spack install --fail-fast --keep-stage
```

#### BLT-Based Installation

Initialize the vendored dependencies by either cloning appropriately:

```bash
git clone --recurse-submodules https://github.com/llnl/phloem.git
```

or initializing them in the already-cloned repo:

```bash
git submodule update --init --recursive
```

Copy one of the host-config.cmake files in the repository and modify the dependencies and options
therein based on your desired test environment.

Then, build and install with CMake:

```bash
cmake -B build -C /path/to/host-config.cmake
cmake --build build -j
cmake --install build
```

## Running Phloem

You will get several executables:

1. `mpiBench` tests collective operations
2. `mpiGraph` tests your fabric topology link-by-link and can be used to find slow links
3. `com` tests point-to-point operations
4. `sqmr` tests messaging rates

Further documentation is available in the manpages in the `docs/` folder of this repository.

## Troubleshooting

Building and running GPU-aware MPI benchmarks on various platforms can be challenging, but we're
here to help. Please feel welcome to open an issue on this repository and we will be more than
happy to assist you.

The following are some common culprits:

### CMake Version

Older versions of CMake are unaware that, for example, CUDA version 12+ implements C++20. Make sure
you have a recent enough version of CMake loaded to overcome such configure errors.

### Common Build and Runtime Environment Issues

You may find that you need to ensure that CUDA or ROCm are in your path with commands such as:

```bash
module load cuda
```

or

```bash
LD_LIBRARY_PATH=/path/to/cuda:${LD_LIBRARY_PATH}
```

On HPE systems with the Cray Programming Environment, be sure to set:

```bash
LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}$:${LD_LIBRARY_PATH}
```

Furthermore, be sure to run:

```bash
export MPICH_GPU_SUPPORT_ENABLED=1
```

for GPU-Aware HPE Cray MPI.

You will also notice we have taken care to link the `mpi_gtl_hsa` or `mpi_gtl_cuda` libraries.

## Validation

The banner of all GPU-aware tests (everything except `mpiGraph`) should display `ROCm` or `CUDA`.
If they do not, they are ***not*** being run GPU-aware.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process
for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/LLNL/phloem/tags).

## Authors

* **Adam Moody** - *Initial work on mpiBench and mpiGraph* - [GitHub Profile](https://github.com/adammoody)
* **Andrew Friedley** - *Initial work on sqmr*
* **Chris Chambreau** - *Initial work on com* - [GitHub Profile](https://github.com/cchambreau)
* **Nathan Hanford** - *Updates and GPU-awareness* - [GitHub Profile](https://github.com/nhanford)


See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

LLNL-CODE-2020767
CP 2026-188
