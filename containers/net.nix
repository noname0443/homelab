{ config, pkgs, ... }:
{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-*" ];
    internalIPs = [ "192.168.101.1/24" ];
  };
}
