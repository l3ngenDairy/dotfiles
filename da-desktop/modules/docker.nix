{ pkgs, config, ... }:
{
 
virtualisation.docker = {
		enable = true;
		enableOnBoot = false;
		rootless = {
		  enable = true;
                  daemon.settings = {
		    runtimes = {
		      nvidia = {
        		path = "${pkgs.nvidia-docker}/bin/nvidia-container-runtime";
          	      };
	            };
                  };
	        };
};

hardware.nvidia-container-toolkit.enable = true;       
}

