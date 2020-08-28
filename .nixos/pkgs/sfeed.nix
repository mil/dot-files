{ stdenv }:

stdenv.mkDerivation rec {
  name = "sfeed";
  src = builtins.fetchGit {
    rev = "ade689b7c91c338333b367ee5a12e5b6afb3dba1";
    url = "https://github.com/mil/sfeed";
  };

  makeFlags = [ "PREFIX=$(out) " ];
  installFlags = [ "PREFIX=$(out)"  ];
  buildInputs = [];
}
