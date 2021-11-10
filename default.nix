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
    apiKey = mkOption {
      type =  str;
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
      serviceConfig = {
        Restart = "always";
        RestartSec = 3;
      };
      script = ''
        set -e
        set -o pipefail
        ${cfg.package}/bin/barcode-reader ${cfg.device} | \
          while read barcode
          do
            ${pkgs.curl}/bin/curl \
              --request 'POST' \
              "${cfg.host}/api/stock/products/by-barcode/$barcode/consume" \
              --header 'accept: application/json' \
              --header "Content-Type: application/json" \
              --header "GROCY-API-KEY: ${cfg.apiKey}" \
              --data '{
                "amount": 1,
                "transaction_type": "consume",
                "spoiled": false
              }'
          done
      '';
    };
  };
}
