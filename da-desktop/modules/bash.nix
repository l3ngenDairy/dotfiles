{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.fastfetch ];      
  programs.fish.interactiveShellInit = ''
    fastfetch
  '';
}
