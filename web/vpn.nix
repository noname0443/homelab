{ config, pkgs, ... }:
let
  secret = import ../secret/secret.nix;
in
{
  environment.systemPackages = [ pkgs.openconnect pkgs.vpnc-scripts ];

  systemd.services.openconnect = {
    description = "OpenConnect VPN";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.openconnect}/bin/openconnect \
          ${secret.vpn.ip} \
          --protocol=anyconnect \
          --certificate=/etc/vpn/homelab.p12 \
          --reconnect-timeout=forever \
          --servercert pin-sha256:${secret.vpn.pin}
      '';
      Restart = "always";
      RestartSec = 5;
    };
  };
}
