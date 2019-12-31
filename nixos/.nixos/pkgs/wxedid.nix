{ stdenv, fetchurl, pkg-config, wxGTK30, autoreconfHook }:

stdenv.mkDerivation rec {
  version = "0.0.18";
  pname = "wxedid";

  src = fetchurl {
    url = "mirror://sourceforge/wxedid/wxedid-${version}.tar.gz";
    sha256 = "788dadb0f1c4cec5e1eb14c16a1cbbf53c442cffd23181d0889a391a1b434f17";
  };

  nativeBuildInputs = [ pkg-config autoreconfHook ];

  installPhase = ''
    mkdir -p $out $out/bin
    sed -i 's#/usr##g' Makefile
    make DESTDIR=$out install
  '';

  buildInputs = [
    wxGTK30
  ];
}
