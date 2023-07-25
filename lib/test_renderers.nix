{ lib
, project
, fixtures
, renderers
, mocks
, ...
}:
let
  inherit (project) loadPyproject;

  projects = {
    pdm = loadPyproject {
      pyproject = fixtures."pdm.toml";
      extrasAttrPaths = [ "tool.pdm.dev-dependencies" ];
    };
    pandas = loadPyproject { pyproject = fixtures."pandas.toml"; };
  };

in
lib.fix (_self: {
  withPackages = {
    testPdm = {
      expr =
        let
          rendered = renderers.withPackages {
            project = projects.pdm;
            python = mocks.cpythonLinux38;
          };
        in
        rendered mocks.cpythonLinux38.pkgs;
      expected = [ "blinker" "certifi" "packaging" "platformdirs" "rich" "virtualenv" "pyproject-hooks" "requests-toolbelt" "unearth" "findpython" "tomlkit" "shellingham" "python-dotenv" "resolvelib" "installer" "cachecontrol" "tomli" "importlib-resources" "importlib-metadata" "pdm-backend" ];
    };
  };

  buildPythonPackage = {
    testPdm = {
      expr = renderers.buildPythonPackage {
        project = projects.pdm;
        python = mocks.cpythonLinux38;
      };
      expected = {
        nativeBuildInputs = [ "pdm-backend" ];
        pname = "pdm";
        propagatedBuildInputs = [ "blinker" "certifi" "packaging" "platformdirs" "rich" "virtualenv" "pyproject-hooks" "requests-toolbelt" "unearth" "findpython" "tomlkit" "shellingham" "python-dotenv" "resolvelib" "installer" "cachecontrol" "tomli" "importlib-resources" "importlib-metadata" ];
      };
    };

    testPdmWithMaps = {
      expr = renderers.buildPythonPackage {
        project = projects.pdm;
        python = mocks.cpythonLinux38;
        extras = [ "tox" ];
        extrasAttrMappings = {
          tox = "checkInputs";
        };
      };
      expected = {
        checkInputs = [ "tox" "tox-pdm" ];
        nativeBuildInputs = [ "pdm-backend" ];
        pname = "pdm";
        propagatedBuildInputs = [ "blinker" "certifi" "packaging" "platformdirs" "rich" "virtualenv" "pyproject-hooks" "requests-toolbelt" "unearth" "findpython" "tomlkit" "shellingham" "python-dotenv" "resolvelib" "installer" "cachecontrol" "tomli" "importlib-resources" "importlib-metadata" ];
      };
    };
  };
})