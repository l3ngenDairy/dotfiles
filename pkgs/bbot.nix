{ pkgs ? import <nixpkgs> {} }:

let
  # Override tabulate globally for all Python packages
  python = pkgs.python3.override {
    packageOverrides = self: super: {
      tabulate = super.tabulate.overridePythonAttrs (old: {
        version = "0.8.10";
        src = super.fetchPypi {
          pname = "tabulate";
          version = "0.8.10";
          sha256 = "bFfz8916wngncBVfOtstsLGiaWN+QvJ1mZJeZLEU9Rk=";
        };
      });

      # Add xmltojson package
      xmltojson = super.buildPythonPackage rec {
        pname = "xmltojson";
        version = "2.0.2";
        src = super.fetchPypi {
          inherit pname version;
          sha256 = "01al9xvy1isicvbbq4r614d5j44chjj2ykg00xaq5lcv81h9cw8h";
        };
        doCheck = false;
      };
    };
  };

  pythonPackages = python.pkgs;

  # Add cloudcheck with fixed dependencies
  cloudcheck = pythonPackages.buildPythonPackage rec {
    pname = "cloudcheck";
    version = "7.0.12";
    
    src = pkgs.fetchFromGitHub {
      owner = "blacklanternsecurity";
      repo = "cloudcheck";
      rev = "845c7a33d29d6c52c9ba101280c87ca0b208aa20";
      sha256 = "sha256-TOvIjirQxJN0gBQ98HArNC9evzHpNG+DNAZWPHRj58A=";
    };

    format = "pyproject";

    nativeBuildInputs = with pythonPackages; [
      poetry-core
      poetry-dynamic-versioning
    ];

    propagatedBuildInputs = with pythonPackages; [
      httpx
      pydantic
      radixtarget
      regex
    ];

    doCheck = false;
  };

  # Define radixtarget dependency
  radixtarget = pythonPackages.buildPythonPackage rec {
    pname = "radixtarget";
    version = "3.0.13";

    src = pkgs.fetchFromGitHub {
      owner = "blacklanternsecurity";
      repo = "radixtarget";
      rev = "d9a117cf67378354595ebd640ff675fd8e91fae6";
      sha256 = "sha256-HgbCR9a99InnvddzZ+BBsczgVbcMJmbjozDfhwjLrkM=";
    };

    format = "pyproject";

    nativeBuildInputs = with pythonPackages; [
      poetry-core
      poetry-dynamic-versioning
    ];

    doCheck = false;
  };

in

# Final package: bbot
pythonPackages.buildPythonPackage rec {
  pname = "bbot";
  version = "0.1.0+gita09d9c3";

  src = pkgs.fetchFromGitHub {
    owner = "blacklanternsecurity";
    repo = "bbot";
    rev = "a09d9c313847b11e99a6f31a14b3f1b636b7ffc7";
    sha256 = "sha256-Zisx1wWUrbvEiTu7p9g0EOzcdbycDUCpFVmkmb/tIeM=";
  };

  format = "pyproject";

  nativeBuildInputs = with pythonPackages; [
    poetry-core
    poetry-dynamic-versioning
  ];

  propagatedBuildInputs = with pythonPackages; [
    xmltojson
    cloudcheck
    radixtarget
    ansible-core
    ansible-runner
    beautifulsoup4
    cachetools
    deepdiff
    dnspython
    httpx
    idna
    lxml
    mmh3
    omegaconf
    orjson
    psutil
    puremagic
    pycryptodome
    pydantic
    pyjwt
    pyzmq
    regex
    setproctitle
    socksio
    tldextract
    unidecode
    websockets
    wordninja
    yara-python
  ];

  # Disable runtime dependency check for xmltojson
  pythonRemoveDependencies = ["xmltojson"];

  meta = {
    description = "The BBOT OSINT framework";
    homepage = "https://github.com/blacklanternsecurity/bbot";
    license = pkgs.lib.licenses.mit;
  };
}
