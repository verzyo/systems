inputs:
inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree [
  ./parts
  ./modules
  ./hosts
  ./users
])
