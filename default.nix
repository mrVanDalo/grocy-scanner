{ config, lib, pkgs, ... }:
with lib;
with types;
let
  cfg = config.services.grocy-scanner;
in
{
  options.services.grocy-scanner = {
    enable = mkEnableOption "grocy barcode scanner client";
    package = mkOption {
      default = pkgs.grocy-scanner.barcode-reader;
      type = package;
    };
    device = mkOption {
      type = str;
      default = "/dev/input/by-id/usb-Belon.cn_2.4G_Wireless_Device_Belon_Smart-event-kbd";
    };
    host = mkOption {
      type =  str;
      default = "http://localhost";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.grocy-scanner = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${cfg.package}/bin/barcode-scanner ${cfg.device} | \
          while read barcode
          do
            echo "Yey I read '$barcode'"
            ${pkgs.curl}/bin/curl \
              --header "Content-Type: application/json" \
              --request POST \
              --data '{
                "amount": 1,
                "transaction_type": "consume",
                "spoiled": false
              } \
              ${cfg.host}/stock/products/by-barcode/${barcode}/consume
          done
      '';
    };
  };
}
