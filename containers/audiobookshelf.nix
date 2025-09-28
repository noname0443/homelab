{ config, pkgs, ... }:

let
  cfgRoot = "/srv/audiobookshelf";
  secret = import ../secret/secret.nix;
in
{
  systemd.tmpfiles.rules = [
    "d ${cfgRoot} 0755 root root -"

    "d /srv/books            0777 root root -"
    "d /srv/media/podcasts   0755 root root -"
    "d /srv/media/music      0755 root root -"
  ];

  containers.audiobookshelf = {
    autoStart = true;

    privateNetwork = true;
    localAddress = "${secret.containers.audiobookshelf.ip}";
    hostAddress = "${secret.containers.audiobookshelf.bind_ip}";

    bindMounts = {
      "/var/lib/audiobookshelf" = {
        hostPath = "${cfgRoot}";
        isReadOnly = false;
      };
      "/media/books" = {
        hostPath = "/srv/books";
        isReadOnly = false;
      };
      "/media/podcasts" = {
        hostPath = "/srv/media/podcasts";
        isReadOnly = false;
      };
      "/media/music" = {
        hostPath = "/srv/media/music";
        isReadOnly = false;
      };
    };

    config = { pkgs, ... }: {
      system.stateVersion = "25.05";

      networking.firewall.enable = false;
      services.audiobookshelf = {
        enable = true;
        host = "0.0.0.0";
        port = secret.containers.audiobookshelf.port;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ secret.containers.audiobookshelf.port ];
}
