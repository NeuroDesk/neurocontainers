revision = "018c646f17958a5b57feac6a7b1ccef6da8bb83e"

niimath_url = "https://github.com/rordenlab/niimath/archive/{}.tar.gz".format(revision)

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
            "cd /niimath-{}".format(revision),
            "cd src/",
            "make static",
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
