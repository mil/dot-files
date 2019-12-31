{ stdenv }:

stdenv.mkDerivation rec {
  name = "json2tsv";
  src = builtins.fetchGit {
    rev = "a8950873f2e40fe767530b8e58b723c8b56abc33";
    url = "https://github.com/mil/json2tsv";
  };

  makeFlags = [ "PREFIX=$(out) " ];
  installFlags = [ "PREFIX=$(out)"  ];
  buildInputs = [];
}
