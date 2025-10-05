{ lib, config, pkgs, ... }:
let
  secret = import ../secret/secret.nix;
in
{
  systemd.tmpfiles.rules = [
    "d /srv/media/photos 0777 root root -"
    "d /srv/media/photos/encoded-video 0777 root root -"
    "f /srv/media/photos/encoded-video/.immich 0777 root root -"
    "d /srv/media/photos/library 0777 root root -"
    "f /srv/media/photos/library/.immich 0777 root root -"
    "d /srv/media/photos/upload 0777 root root -"
    "f /srv/media/photos/upload/.immich 0777 root root -"
    "d /srv/media/photos/profile 0777 root root -"
    "f /srv/media/photos/profile/.immich 0777 root root -"
    "d /srv/media/photos/thumbs 0777 root root -"
    "f /srv/media/photos/thumbs/.immich 0777 root root -"
    "d /srv/media/photos/backups 0777 root root -"
    "f /srv/media/photos/backups/.immich 0777 root root -"
  ];

  containers.immich = {
    autoStart = true;

    extraFlags = [ "-U" ];
    enableTun = true;

    privateNetwork = true;
    localAddress = "${secret.containers.immich.ip}";
    hostAddress = "${secret.containers.immich.bind_ip}";

    bindMounts = {
      "/photos" = { hostPath = "/srv/media/photos"; isReadOnly = false; };
    };

    forwardPorts = lib.mkIf (secret.containers.immich.forward) [
      {
        containerPort = secret.containers.immich.port;
        hostPort      = secret.containers.immich.port;
        protocol      = "tcp";
      }
    ];

    config = { pkgs, ... }: {
      system.stateVersion = "25.05";
      networking.firewall.allowedTCPPorts = [ secret.containers.immich.port ];

      services.immich = {
        enable = true;
        package = pkgs.immich;
        port = secret.containers.immich.port;
        mediaLocation = "/photos";
        host = "0.0.0.0";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ secret.containers.immich.port ];
}
