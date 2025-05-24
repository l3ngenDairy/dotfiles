{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.fastfetch ];      
  programs.fish.interactiveShellInit = ''
    fastfetch
  '';
  programs.fish.shellAliases = {
        cat = "bat";
                # ll = "ls -la";
  };
        
}
