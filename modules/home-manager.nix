{
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";

  den.aspects.home-manager.os.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    backupFileExtension = "backup";
  };
}
