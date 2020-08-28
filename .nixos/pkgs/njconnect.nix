{ stdenv, fetchurl, jack2, pkg-config, ncurses }:

stdenv.mkDerivation rec {
  version = "1.6";
  pname = "njconnect";

  src = fetchurl {
    url = "mirror://sourceforge/njconnect/njconnect-${version}.tar.xz";
    sha256 = "f62ccadbae29129642a3317169058bbd1c3e3299195152426a618ba154726ddd";
  };

  nativeBuildInputs = [ pkg-config ];

  installPhase = ''
    mkdir -p $out $out/bin
    sed -i 's#/usr##g' Makefile
    make DESTDIR=$out install
  '';

  buildInputs = [
    jack2 ncurses
  ];
}
