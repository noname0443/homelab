{ config, pkgs, ... }:

let
  cfgRoot = "/srv/media/podcasts";
  secret = import ../secret/secret.nix;
in
{
  systemd.tmpfiles.rules = [
    "d ${cfgRoot} 0755 root root -"
  ];

  containers.podgrab = {
    autoStart = true;

    privateNetwork = true;
    localAddress = "${secret.containers.podgrab.ip}";
    hostAddress = "${secret.containers.podgrab.bind_ip}";

    bindMounts = {
      "/podcasts" = {
        hostPath = "/srv/media/podcasts";
        isReadOnly = false;
      };
    };

    config = { pkgs, ... }: {
      system.stateVersion = "25.05";

      environment.etc."podgrab.password" = {
        text  = "PASSWORD=${secret.containers.podgrab.password}\n";
        mode  = "0600";
        user  = "podgrab";
        group = "podgrab";
      };

      services.podgrab = {
        enable = true;
        port = secret.containers.podgrab.port;
        passwordFile = "/etc/podgrab.password";
        dataDirectory = "/podcasts";
      };

      networking.firewall.allowedTCPPorts = [ secret.containers.podgrab.port ];
    };
  };

  networking.firewall.allowedTCPPorts = [ secret.containers.podgrab.port ];
}
