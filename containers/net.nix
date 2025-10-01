{ config, pkgs, ... }:
let
  secret = import ../secret/secret.nix;
in
{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-*" ];
    internalIPs = [ "192.168.101.1/24" ];
  };
}
