{ stdenv }:

stdenv.mkDerivation rec {
  name = "json2tsv";
  src = builtins.fetchGit {
    rev = "5b92fe10218579d7dd0c725c043de425d4076a9c";
    url = "https://github.com/mil/json2tsv";
  };

  makeFlags = [ "PREFIX=$(out) " ];
  installFlags = [ "PREFIX=$(out)"  ];
  buildInputs = [];
}
