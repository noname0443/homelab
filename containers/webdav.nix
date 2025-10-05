{ lib, config, pkgs, ... }:

let
  webdavRoot = "/srv/media";
  secret = import ../secret/secret.nix;
in
{
  systemd.tmpfiles.rules = [
    "d ${webdavRoot} 0777 root root -"
  ];

  containers.webdav = {
    autoStart = true;

    extraFlags = [ "-U" ];
    enableTun = true;

    privateNetwork = true;
    localAddress = "${secret.containers.webdav.ip}";
    hostAddress = "${secret.containers.webdav.bind_ip}";

    bindMounts = {
      "/media" = {hostPath = "${webdavRoot}";isReadOnly = false;};
    };

    forwardPorts = lib.mkIf (secret.containers.webdav.forward) [
      {
        containerPort = secret.containers.webdav.port;
        hostPort      = secret.containers.webdav.port;
        protocol      = "tcp";
      }
    ];

    config = { pkgs, ... }: {
      system.stateVersion = "25.05";
      networking.firewall.allowedTCPPorts = [ secret.containers.webdav.port ];

      services.webdav = {
        enable = true;
        package = pkgs.webdav;
        settings = {
          address = "0.0.0.0";
          port = secret.containers.webdav.port;
          directory = "/media";
          users = secret.containers.webdav.users;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ secret.containers.webdav.port ];
}
