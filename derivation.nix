{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, wrapGAppsHook3
, libsecret
, glib
, gtk3
, gsettings-desktop-schemas
}:

stdenv.mkDerivation rec {
  name = "PortfolioPerformance-${version}";
  version = "0.89.0";

  src = fetchurl {
    url = "https://github.com/buchen/portfolio/releases/download/${version}/${name}-linux.gtk.x86_64.tar.gz";
    sha256 = "01ee66debf2f52fc6e6c3eb353ecdff9cb3629cedbe9d31b1f7c103b750b322c";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    libsecret
    glib
    gtk3
    gsettings-desktop-schemas
  ];

  unpackPhase = ''
    tar xvf $src
  '';

  dontWrapGApps = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -r portfolio/ $out
    rm -rf $out/portfolio/plugins/com.sun.jna_*/com/sun/jna/dragonflybsd-x86-64
    '';

  postFixup = ''
    makeWrapper $out/portfolio/PortfolioPerformance $out/bin/PortfolioPerformance \
      "''${gappsWrapperArgs[@]}"
    '';

  meta = with lib; {
    homepage = https://www.portfolio-performance.info;
    description = "Portfolio Performance";
    license = licenses.epl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ makefu ];
  };
}
