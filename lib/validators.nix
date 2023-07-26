{ lib
, pep440
, pep508
, pep621
, pypa
, ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib) flatten;

in
{
  /*
    Validates the Python package set held by Python (`python.pkgs`) against the parsed project.

    Returns an attribute set where the name is the Python package derivation `pname` and the value is a list of the mismatching conditions.

    Type: validateVersionConstraints :: AttrSet -> AttrSet

    Example:
      # validateVersionConstraints (lib.project.loadPyproject { ... })
      {
        resolvelib = {
          # conditions as returned by `lib.pep440.parseVersionCond`
          conditions = [ { op = ">="; version = { dev = null; epoch = 0; local = null; post = null; pre = null; release = [ 1 0 1 ]; }; } ];
          # Version from Python package set
          version = "0.5.5";
        };
        unearth = {
          conditions = [ { op = ">="; version = { dev = null; epoch = 0; local = null; post = null; pre = null; release = [ 0 10 0 ]; }; } ];
          version = "0.9.1";
        };
      }
    */
  validateVersionConstraints =
    {
      # Project metadata as returned by `lib.project.loadPyproject`
      project
    , # Python derivation
      python
    , # Python extras (optionals) to enable
      extras ? [ ]
    ,
    }:
    let
      filteredDeps = pep621.filterDependencies {
        inherit (project) dependencies;
        environ = pep508.mkEnviron python;
        inherit extras;
      };
      flatDeps = filteredDeps.dependencies ++ flatten (attrValues filteredDeps.extras) ++ filteredDeps.build-systems;

    in
    builtins.foldl'
      (acc: dep:
      let
        pname = pypa.normalizePackageName dep.name;
        pversion = python.pkgs.${pname}.version;
        version = pep440.parseVersion python.pkgs.${pname}.version;
        incompatible = builtins.filter (cond: ! pep440.comparators.${cond.op} version cond.version) dep.conditions;
      in
      if incompatible == [ ] then acc else acc // {
        ${pname} = {
          version = pversion;
          conditions = incompatible;
        };
      })
      { }
      flatDeps;
}
