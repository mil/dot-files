{ stdenv, fetchFromGitHub, libsndfile, libjack2, callPackage }:

stdenv.mkDerivation rec {
  soundpipe = callPackage ./soundpipe.nix {};

  name = "sporth";
  src = builtins.fetchGit {
    ref = "custom-ugens";
    rev = "156d5189262f126f8658b3c4e1910d9cda84b587"; #localsporth
    #url = "https://github.com/PaulBatchelor/Sporth";
    url = "https://github.com/mil/Sporth";
    #url = "file:///home/m/Repos/Sporth"; 
  };
  NIX_CFLAGS_COMPILE = "-DNO_POLYSPORTH -DDEBUG_MODE";
  buildInputs = [soundpipe libsndfile libjack2];

  preBuild=''
    #export DEBUG_MODE=true
    export BUILD_JACK=true
  '';

  installPhase = ''
   mkdir -p $out $out/bin $out/usr/bin $out/lib $out/usr/include $out/usr/local/share/sporth $out/usr/share/sporth $out/lib $out/include
   sed -i 's#/usr/local/bin#/bin#g' Makefile util/installer.sh
   sed -i 's#/usr/local/lib#/lib#g' Makefile util/installer.sh
   sed -i 's#/usr/local/include#/include#g' Makefile util/installer.sh
   sed -i 's#/usr/local/#/usr/#g' Makefile util/installer.sh 

   sed -i "s#/usr/local/#$out/usr/#g" util/ugen_lookup
   sed -i '/mkdir/d' Makefile
   sed -i '/polysporth/d' Makefile
   sed -i -E 's/install (.*) (.*)/install \1 $(PREFIX)\2/ ' Makefile util/installer.sh
   make PREFIX=$out install
   echo done
   cp libsporth.a $out/lib/
   cp libsporth.a $out/lib/libsporth.so
  '';

  #patches = [/etc/nixos/pkgs/sporthpatch];

  dontFixup = true;
}
