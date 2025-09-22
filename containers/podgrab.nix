{ config, pkgs, ... }:

let
  cfgRoot = "/srv/media/podcasts";
in
{
  systemd.tmpfiles.rules = [
    "d ${cfgRoot} 0755 root root -"
  ];

  containers.podgrab = {
    autoStart = true;

    bindMounts = {
      "/podcasts" = {
        hostPath = "/srv/media/podcasts";
        isReadOnly = false;
      };
    };

    config = { pkgs, ... }: {
      system.stateVersion = "25.05";

      services.podgrab = {
        enable = true;
        port = 8078;
        dataDirectory = "/podcasts";
      };

      environment.systemPackages = [ ];
      environment.variables = {
        PORT = "8078";
        PASSWORD = "podgrabber";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8078 ];
}
