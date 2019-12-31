{ stdenv, linuxHeaders, gnutls, libressl, cacert }:

stdenv.mkDerivation rec {
  name = "idiotbox";
  src = builtins.fetchGit {
    ref = "a49fcb846283d4672a3a7e2d99560a047117022e";
    url = "https://github.com/mil/idiotbox";
  };
  preBuild=''
    sed -i 's#tls.h#linux/tls.h#' youtube.c
    sed -i 's#-static##' Makefile
    sed -i '1 i\#define TLS_CA_CERT_FILE "testo"\n' *.c
  '';
  installPhase = ''
   mkdir -p $out/bin
   cp cli $out/bin/idiotbox
   cp cli $out/bin/idiotbox_cli
   cp cgi $out/bin/idiotbox_cgi
   cp gph $out/bin/idiotbox_gph
  '';

    postInstall = ''
          ln -s ${cacert}/etc/ssl/certs/ca-bundle.crt $out/cacert.pem
              '';


  makeFlags = [ "PREFIX=$(out)" ];
  installFlags = [ "PREFIX=$(out)"  ];
  buildInputs = [linuxHeaders gnutls libressl cacert];
}
