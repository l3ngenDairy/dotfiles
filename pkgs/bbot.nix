{ pkgs ? import <nixpkgs> {} }:

let
  # Define Python and package aliases
  python = pkgs.python3.withPackages (ps: with ps; [
    pip
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
    pyopenssl
    pyzmq
    regex
    setproctitle
    socksio
    tldextract
    unidecode
    websockets
    wordninja
    yara-python
    asyncpg
  ]);

  pythonPackages = python.pkgs;

  # poetry-dynamic-versioning dependency
  poetry-dynamic-versioning = pythonPackages.buildPythonPackage rec {
    pname = "poetry-dynamic-versioning";
    version = "1.8.2";

    src = pythonPackages.fetchPypi {
      pname = "poetry_dynamic_versioning";
      inherit version;
      sha256 = "0i2z0qrp0dwk4b3s9myrgawyfmx899zsr6jiyjc8xhka88yy2kfi";
    };

    format = "pyproject";
    nativeBuildInputs = with pythonPackages; [ poetry-core ];
    propagatedBuildInputs = with pythonPackages; [ dunamai jinja2 tomlkit packaging ];
    doCheck = false;
  };

  # Additional dependencies
  tabulate = pythonPackages.buildPythonPackage rec {
    pname = "tabulate";
    version = "0.8.10";
    src = pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-bFfz8916wngncBVfOtstsLGiaWN+QvJ1mZJeZLEU9Rk=";
    };
    doCheck = false;
  };

  xmltojson = pythonPackages.buildPythonPackage rec {
    pname = "xmltojson";
    version = "2.0.2";
    src = pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "01al9xvy1isicvbbq4r614d5j44chjj2ykg00xaq5lcv81h9cw8h";
    };
    doCheck = false;
  };

  # Fix: uses pythonPackages and adds Git for VCS detection
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
    ] ++ [ pkgs.git ]; # <- ensures Git is available for dunamai

    doCheck = false;
  };

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

  baddns = pythonPackages.buildPythonPackage rec {
    pname = "baddns";
    version = "1.9.130";
    src = pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-2YP8WdF7HFwCEFD0UkeWoMijrBOYstTqkYpxA/Xq9jY=";
    };
    format = "pyproject";
    nativeBuildInputs = with pythonPackages; [
      poetry-core
      poetry-dynamic-versioning
    ];
    doCheck = false;
  };

  # System-level dependencies
  systemDeps = with pkgs; [
    openssl
    gnumake
    nmap
    ansible
    jq
  ];

in pythonPackages.buildPythonPackage rec {
  pname = "bbot";
  version = "1.0.5.2022";

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
  ] ++ systemDeps;

  propagatedBuildInputs = with pythonPackages; [
    xmltojson
    cloudcheck
    radixtarget
    tabulate
    baddns
  ];

  preFixup = ''
    export PATH="${pkgs.lib.makeBinPath systemDeps}:$PATH"
    export PYTHONPATH="$PYTHONPATH:$out/${python.sitePackages}"
  '';

  doCheck = false;

  pythonRemoveDependencies = ["xmltojson"];

  meta = with pkgs.lib; {
    description = "The BBOT OSINT framework";
    homepage = "https://github.com/blacklanternsecurity/bbot";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}

