{ stdenv, fetchFromGitHub, libsndfile }:

stdenv.mkDerivation rec {
  name = "soundpipe";
  src = builtins.fetchGit {
    rev = "35d856fcf8a0d85c285818554f569b592d066d10";
    url = "https://github.com/PaulBatchelor/Soundpipe";
  };
  makeFlags = [ "PREFIX=$(out) " ];
  installFlags = [ "PREFIX=$(out)"  ];
  buildInputs = [libsndfile];
}
