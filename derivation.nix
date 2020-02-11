{ stdenv
, fetchurl
, autoPatchelfHook
, libsecret
, glib
}:

stdenv.mkDerivation rec {
  name = "PortfolioPerformance-${version}";
  version = "0.44.1";

  src = fetchurl {
    url = "https://github.com/buchen/portfolio/releases/download/${version}/${name}-linux.gtk.x86_64.tar.gz";
    sha256 = "08799ff23a818b6006bf9d86799a2ae67da660b5f5a27c01793c570e28cacf29";
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
