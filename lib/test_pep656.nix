{ pep656, ... }:
let
  inherit (pep656) muslLinuxTagCompatible;

  mockStdenvs =
    let
      mkMock = pname: version: cpuName: {
        cc = {
          libc = {
            inherit pname version;
          };
        };
        targetPlatform.parsed.cpu.name = cpuName;
      };
    in
    {
      x86_64-linux = {
        glibc_2_4 = mkMock "glibc" "2.4" "x86_64";
        glibc_2_5 = mkMock "glibc" "2.5" "x86_64";
        musl_1_2_3 = mkMock "musl" "1.2.3" "x86_64";
      };
    };

in
{
  muslLinuxTagCompatible = {
    testSimpleIncompatible = {
      expr = muslLinuxTagCompatible mockStdenvs.x86_64-linux.glibc_2_4 "musllinux_1_1_x86_64";
      expected = false;
    };

    testManyLinux = {
      expr = muslLinuxTagCompatible mockStdenvs.x86_64-linux.musl_1_2_3 "manylinux1_x86_64";
      expectedError.type = "ThrownError";
      expectedError.msg = ".* is not a valid musllinux tag";
    };

    testSimpleCompatible = {
      expr = muslLinuxTagCompatible mockStdenvs.x86_64-linux.musl_1_2_3 "musllinux_1_1_x86_64";
      expected = true;
    };

    testSimpleArchIncompatible = {
      expr = muslLinuxTagCompatible mockStdenvs.x86_64-linux.musl_1_2_3 "musllinux_1_1_armv7l";
      expected = false;
    };
  };
}