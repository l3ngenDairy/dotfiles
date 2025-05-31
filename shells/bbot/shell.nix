{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.python312
    pkgs.python312Packages.virtualenv
    pkgs.zeromq             # for pyzmq
    pkgs.stdenv.cc.cc.lib   # for libstdc++.so.6
    pkgs.libpcap            
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH

    if [ ! -d ".venv" ]; then
      echo "Creating virtualenv..."
      python -m venv .venv
      source .venv/bin/activate
      pip install --upgrade pip
      pip install bbot
    else
      echo "Activating existing virtualenv..."
      source .venv/bin/activate
    fi

    echo "✅ bbot ready to run."
  '';
}

