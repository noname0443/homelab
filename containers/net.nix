{ config, pkgs, ... }:
{
  networking.nat = {
    enable = true;
    externalInterface = "eth0";
    internalInterfaces = [ "br-containers" ];
    internalIPs = [ "192.168.101.1/24" ];
  };
}
