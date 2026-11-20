{
  den,
  lib,
  inputs,
  ...
}: {
  den.migrations.user-host-content.acknowledged = true;

  den.schema = {
    host.includes = with den; [
      aspects.defaults
      batteries.mutual-provider
    ];

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
