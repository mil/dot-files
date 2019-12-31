{ stdenv, ncurses }:

stdenv.mkDerivation rec {
   name = "sacc";
   src = builtins.fetchGit {
     rev = "88d7f160cb44cdb08634b034b23d2f2d640bf7fd";
     url = "https://github.com/mil/sacc";
   };

   makeFlags = [ "PREFIX=$(out)" ];
   preBuild = ''
     sed -i  's/-lcurses/-lncurses/' config.mk
   '';
   buildInputs = [ncurses.dev];
}
