{ pkgs ,config , ... }:{
  services.ratbagd.enable = true; 
        
  environment.systemPackages = with pkgs; [
    libratbag
    piper            
  ];
}


