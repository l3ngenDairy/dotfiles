{ config, pkgs, lib, ... }:
let
  ollamaDataDir = "/home/david/ollama-data";
in {
  # System packages
  environment.systemPackages = with pkgs; [
    ollama
    podman
    podman-compose  # Optional, add if you want to use podman-compose
  ];
        
  # Enable GPU container support
  hardware.nvidia-container-toolkit.enable = true;
  
  # Ensure ollama data directory exists on boot
  systemd.tmpfiles.rules = [
    "d ${ollamaDataDir} 0755 david users - -"
  ];
  
  # Configure podman for rootless operation
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # Optional: enables docker command compatibility
    extraPackages = with pkgs; [ zfs ]; # Only include if you're using ZFS
  };
  
  # User configuration
  users.users.david = {
    extraGroups = [ "podman" "video" ];  # video group for GPU access
  };
  
  # Create a systemd user service for Ollama instead of using system oci-containers
  systemd.user.services.ollama-container = {
    description = "Rootless Ollama Container";
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "-${pkgs.podman}/bin/podman rm -f ollama";
      ExecStart = "${pkgs.podman}/bin/podman run --rm --name ollama \
        -p 11434:11434 \
        -v ${ollamaDataDir}:/root/.ollama:Z \
        --security-opt label=disable \
        --userns=keep-id \
        --gpus=all \
        ollama/ollama:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop ollama";
      Restart = "on-failure";
      RestartSec = "10";
    };
  };
  
  # Optional: Create a systemd user timer for periodic tasks (like model management or updates)
  systemd.user.timers.ollama-maintenance = {
    description = "Timer for Ollama maintenance tasks";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15min";
      OnUnitActiveSec = "1d";  # Run once a day
    };
  };
  
  systemd.user.services.ollama-maintenance = {
    description = "Perform maintenance tasks for Ollama";
    after = [ "ollama-container.service" ];
    script = ''
      # Add any maintenance commands here
      ${pkgs.podman}/bin/podman exec ollama ollama list
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };
  
  # Optional: Add convenient shell aliases
  environment.shellAliases = {
    ollama-list = "podman exec ollama ollama list";
    ollama-pull = "podman exec ollama ollama pull";
    ollama-run = "podman exec ollama ollama run";
  };
  
  # Enable cgroups v2 (recommended for rootless containers)
  systemd.enableUnifiedCgroupHierarchy = lib.mkDefault true;
  
  # Remove the system oci-containers definition since we're using a user service
  # virtualisation.oci-containers.containers.ollama = {...};
}
