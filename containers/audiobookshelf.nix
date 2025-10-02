{ config, pkgs, ... }:

let
  cfgRoot = "/srv/audiobookshelf";
  secret = import ../secret/secret.nix;
in
{
  systemd.tmpfiles.rules = [
    "d ${cfgRoot}/config 0777 root root -"
    "d ${cfgRoot}/metadata 0777 root root -"

    "d /srv/media/podcasts   0777 root root -"
    "d /srv/media/audiobooks   0777 root root -"
  ];

  containers.audiobookshelf = {
    autoStart = true;
    extraFlags = [ "-U" ];
    enableTun = true;

    privateNetwork = true;
    localAddress = "${secret.containers.audiobookshelf.ip}";
    hostAddress = "${secret.containers.audiobookshelf.bind_ip}";

    bindMounts = {
      "/config" = {
        hostPath = "${cfgRoot}/config";
        isReadOnly = false;
      };
      "/metadata" = {
        hostPath = "${cfgRoot}/metadata";
        isReadOnly = false;
      };
      "/podcasts" = {
        hostPath = "/srv/media/podcasts";
        isReadOnly = false;
      };
      "/audiobooks" = {
        hostPath = "/srv/media/audiobooks";
        isReadOnly = false;
      };
    };

    config = { pkgs, ... }: {
      system.stateVersion = "25.05";

      services.audiobookshelf = {
        enable = true;
        host = "0.0.0.0";
        port = secret.containers.audiobookshelf.port;
      };

      networking.firewall.enable = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ secret.containers.audiobookshelf.port ];
}
