{
  den,
  lib,
  inputs,
  ...
}: {
  den.schema = {
    host.includes = [den.aspects.defaults];

    user.classes = lib.mkDefault ["homeManager"];
    hm-host.includes = [den.aspects.home-manager];
  };

  den.aspects.defaults = {
    includes = with den; [
      batteries.hostname
      aspects.nix
      aspects.kernel
    ];

    os = {
      time.timeZone = "Europe/Prague";
      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    };
  };
}
