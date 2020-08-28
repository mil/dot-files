{ stdenv }:

stdenv.mkDerivation rec {
  name = "tscrape";
  src = builtins.fetchGit {
    rev = "f8629e681a16fc3af086355a44c942df57291b4b";
    url = "https://github.com/mil/tscrape";
  };

  makeFlags = [ "PREFIX=$(out) " ];
  installFlags = [ "PREFIX=$(out)"  ];
  buildInputs = [];
}
