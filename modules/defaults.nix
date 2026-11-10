{
  den,
  inputs,
  ...
}: {
  den.schema.host.includes = [den.aspects.defaults];

  den.aspects.defaults = {
    includes = with den; [
      batteries.hostname
      aspects.nix
    ];

    os = {
      time.timeZone = "Europe/Prague";
      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    };
  };
}
