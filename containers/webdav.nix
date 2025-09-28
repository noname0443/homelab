{ config, pkgs, ... }:

let
  webdavRoot = "/srv/webdav";
  authFile = "/srv/webdav-htpasswd";
  secret = import ../secret/secret.nix;
in
{
  systemd.tmpfiles.rules = [
    "d ${webdavRoot} 0775 root root -"
  ];

  containers.webdav = {
    autoStart = true;

    privateNetwork = true;
    localAddress = "${secret.containers.webdav.ip}";
    hostAddress = "${secret.containers.webdav.bind_ip}";

    bindMounts = {
      "/media/webdav" = {hostPath = "${webdavRoot}";isReadOnly = false;};
      "/etc/webdav-htpasswd" = {hostPath = "${authFile}";isReadOnly = false;};
    };

    config = { pkgs, ... }: {
      system.stateVersion = "25.05";
      networking.firewall.allowedTCPPorts = [ secret.containers.webdav.port ];

      services.webdav = {
        enable = true;
        package = pkgs.webdav;
        settings = {
          address = "0.0.0.0";
          port = secret.containers.webdav.port;
          directory = "/media/webdav";
          users = secret.containers.webdav.users;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ secret.containers.webdav.port ];
}
