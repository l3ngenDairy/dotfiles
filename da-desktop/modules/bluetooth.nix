      #}

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
                                # Enable = "Source,Sink,Media,Socket,HID";  # Added HID explicitly
        Experimental = true;
        Class = "0x000540";  # This sets the device class to include keyboard functionality
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };
}
