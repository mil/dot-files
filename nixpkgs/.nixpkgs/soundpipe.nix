{ stdenv, fetchFromGitHub, libsndfile }:

stdenv.mkDerivation rec {
  name = "soundpipe";
  #NIX_CFLAGS_COMPILE = "-DUSE_DOUBLE";
  src = builtins.fetchGit {
    rev = "3a0803b1e21c3e6de1e3bb1051cecd1b39d98aa0"; #localsoundpipe
    url = "https://github.com/PaulBatchelor/Soundpipe";
    #url = "file:///home/m/Repos/Soundpipe"; 
  };
  makeFlags = [ "PREFIX=$(out) " ];
  installFlags = [ "PREFIX=$(out)"  ];
  buildInputs = [libsndfile];
}
