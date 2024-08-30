niimath_url = "https://github.com/rordenlab/niimath/archive/a905ecd61c1f14e02872983ec6961537bf0d636c.tar.gz"

niimath_compile = define.build_vm(
    directives = [
        define.plan(
            builder = "alpine@3.20",
            packages = [
                query("build-base"),
                query("zlib-dev"),
                query("zlib-static"),
            ],
            tags = ["level3", "defaults"],
        ),
        define.read_archive(define.fetch_http(niimath_url), ".tar.gz"),
        directive.run_command("\n".join([
            "source /etc/profile",
            "cd /niimath-a905ecd61c1f14e02872983ec6961537bf0d636c",
            "cd src/",
            "gcc -O3 -static -std=gnu99 -DHAVE_BUTTERWORTH bw.c -DHAVE_TENSOR tensor.c -DHAVE_FORMATS base64.c -DNII2MESH meshify.c quadric.c bwlabel.c radixsort.c fdr.c -DUSE_CLASSIC_CUBES oldcubes.c niimath.c core.c core32.c niftilib/nifti2_io.c znzlib/znzlib.c -I./niftilib -I./znzlib -DFSLSTYLE -DPIGZ -DREJECT_COMPLEX -lm conform.c -DHAVE_CONFORM -DHAVE_64BITS core64.c -DHAVE_ZLIB -lz -flto -o niimath",
            "mv niimath /niimath",
        ])),
    ],
    output = "/niimath",
)

def make_release(ctx, niimath):
    fs = filesystem()

    fs["/usr/bin/niimath"] = file(niimath.read(), executable = True)

    return ctx.archive(fs)

niimath_release = define.build(
    make_release,
    niimath_compile,
)

niimath_root = define.build_fs([
    define.plan(
        builder = "alpine@3.20",
        packages = [
            query("bash"),
        ],
        tags = ["level3", "defaults", "noScripts"],
    ),
    directive.builtin("init", "/init"),
    niimath_release,
], "tar")
