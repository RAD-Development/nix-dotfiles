{ ... }:
{
  services.nginx = {
    enable = true;
    allRecommendOptions = true;
    generateDhparams = true;
    openFirewall = true;
    recommendedDefaults = true;
    resolverAddrFromNameserver = true;
    rotateLogsFaster = true;
    setHSTSHeader = true;
    tcpFastOpen = true;

    quic = {
      enable = true;
      bpf = true;
    };

    # TODO
    # default404Server = {
    #   enable = true;
    #   acmeHost = "";
    # };

    # virtualHosts = {
    # };
  };
}