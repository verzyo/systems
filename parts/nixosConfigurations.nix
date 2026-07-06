{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations = {
    laptop = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = ["${self}/hosts/laptop/"];
    };
  };
}
