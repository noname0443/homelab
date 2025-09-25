{ config, pkgs, ... }:
{
  systemd.services.homelab-ssh-tunnel = {
    description = "Persistent SSH tunnel to Homelab";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      User = "eeivanow";
      ExecStart = ''
        ${pkgs.autossh}/bin/autossh -M 0 -N -T \
          -o "ServerAliveInterval=60" \
          -o "ServerAliveCountMax=3" \
          -o "ExitOnForwardFailure=yes" \
          -i /etc/ssh/id_homelab \
          -R 4918:0.0.0.0:4918 \
          eugene@$IP
      '';
  
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
