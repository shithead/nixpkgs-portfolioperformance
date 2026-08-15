{ stdenv
, fetchurl
, autoPatchelfHook
, libsecret
, glib
}:

stdenv.mkDerivation rec {
  name = "PortfolioPerformance-${version}";
  version = "0.86.1";

  src = fetchurl {
    url = "https://github.com/buchen/portfolio/releases/download/${version}/${name}-linux.gtk.x86_64.tar.gz";
    sha256 = "8931ed22e4956a935ce597242087c35d8a4c3f63e260b57c2688eea90f6797d1";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
  	libsecret
	glib
  ];
  unpackPhase = ''
    tar xvf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r portfolio/ $out
    ln -s $out/portfolio/PortfolioPerformance  $out/bin/PortfolioPerformance
    '';

  meta = with stdenv.lib; {
    homepage = https://www.portfolio-performance.info;
    description = "Portfolio Performance";
    license = licenses.epl10;
    platforms = platforms.linux;
    maintainers = with maintainers; [ makefu ];
  };
}
