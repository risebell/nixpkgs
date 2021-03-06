{ cairo
, cmake
, fetchFromGitHub
, libXdmcp
, libpthreadstubs
, libxcb
, pcre
, pkg-config
, python3
, python3Packages # sphinx-build
, lib
, stdenv
, xcbproto
, xcbutil
, xcbutilcursor
, xcbutilimage
, xcbutilrenderutil
, xcbutilwm
, xcbutilxrm
, makeWrapper
, removeReferencesTo
, alsaLib
, curl
, libmpdclient
, libpulseaudio
, wirelesstools
, libnl
, i3
, i3-gaps
, jsoncpp

# override the variables ending in 'Support' to enable or disable modules
, alsaSupport   ? true
, githubSupport ? false
, mpdSupport    ? false
, pulseSupport  ? false
, iwSupport     ? false
, nlSupport     ? true
, i3Support     ? false
, i3GapsSupport ? false
}:

stdenv.mkDerivation rec {
    pname = "polybar";
    version = "3.5.5";

    src = fetchFromGitHub {
      owner = pname;
      repo = pname;
      rev = version;
      sha256 = "sha256-oRtTm5bXdL0C2WJsaK8H2Oc40DPWgAfjP7FgIHrpKGI=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [
      cmake
      pkg-config
      python3Packages.sphinx
      removeReferencesTo

      (if i3Support || i3GapsSupport then makeWrapper else null)
    ];

    buildInputs = [
      cairo
      libXdmcp
      libpthreadstubs
      libxcb
      pcre
      python3
      xcbproto
      xcbutil
      xcbutilcursor
      xcbutilimage
      xcbutilrenderutil
      xcbutilwm
      xcbutilxrm

      (if alsaSupport   then alsaLib       else null)
      (if githubSupport then curl          else null)
      (if mpdSupport    then libmpdclient  else null)
      (if pulseSupport  then libpulseaudio else null)

      (if iwSupport     then wirelesstools else null)
      (if nlSupport     then libnl         else null)

      (if i3Support || i3GapsSupport then jsoncpp else null)
      (if i3Support then i3 else null)
      (if i3GapsSupport then i3-gaps else null)
    ];

    postInstall = if i3Support
                  then ''wrapProgram $out/bin/polybar \
                           --prefix PATH : "${i3}/bin"
                       ''
                  else if i3GapsSupport
                  then ''wrapProgram $out/bin/polybar \
                           --prefix PATH : "${i3-gaps}/bin"
                       ''
                  else '''';

    postFixup = ''
        remove-references-to -t ${stdenv.cc} $out/bin/polybar
    '';

    meta = with lib; {
      homepage = "https://polybar.github.io/";
      changelog = "https://github.com/polybar/polybar/releases/tag/${version}";
      description = "A fast and easy-to-use tool for creating status bars";
      longDescription = ''
        Polybar aims to help users build beautiful and highly customizable
        status bars for their desktop environment, without the need of
        having a black belt in shell scripting.
      '';
      license = licenses.mit;
      maintainers = with maintainers; [ afldcr Br1ght0ne fortuneteller2k ];
      platforms = platforms.linux;
    };
}
