{ config, pkgs, ... }:

let
  webdavRoot = "/srv/webdav";
  authFile = "/srv/webdav-htpasswd";
in
{
  systemd.tmpfiles.rules = [
    "d ${webdavRoot} 0775 root root -"
  ];

  containers.webdav = {
    autoStart = true;

    #privateNetwork = true;
    #hostAddress = "192.168.101.19";
    #localAddress = "192.168.101.20";

    #forwardPorts = [
    #  { containerPort = 4918; hostPort = 4918; protocol = "tcp"; }
    #];

    bindMounts = {
      "/media/webdav" = {hostPath = "${webdavRoot}";isReadOnly = false;};
      "/etc/webdav-htpasswd" = {hostPath = "${authFile}";isReadOnly = false;};
    };

    config = { pkgs, ... }: {
      system.stateVersion = "25.05";
      networking.firewall.allowedTCPPorts = [ 4918 ];

      services.webdav = {
        enable = true;
        package = pkgs.webdav;
        settings = {
          address = "0.0.0.0";
          port = 4918;
          directory = "/media/webdav";
          users = [ { username = "user"; password = "user"; } ]; # TODO: change
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 4918 ];
}
