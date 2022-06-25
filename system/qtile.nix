{ lib
, fetchFromGitHub
, python3
, python3Packages
, mypy
, glib
, pango
, pkg-config
, libinput
, libxkbcommon
, wayland
, wlroots
, xcbutilcursor
}:

let

  qtile-extras = python3Packages.buildPythonPackage {
    pname = "qtile-extras";
    version = "unstable-2022-05-26";
    src = fetchFromGitHub {
      owner = "elParaguayo";
      repo = "qtile-extras";
      rev = "52c143da6917ac0f1e0b1aacc1af48e2bebc7289";
      sha256 = "0rnc1mqmqccydk5bsgfzzj5q9s6syk6abc6n83wr62gd843ff6p7";
    };
    doCheck = false;
  };

  unwrapped = python3Packages.buildPythonPackage rec {
    pname = "qtile";
    version = "0.21.0";

    src = fetchFromGitHub {
      owner = "qtile";
      repo = "qtile";
      rev = "v${version}";
      sha256 = "3QCI1TZIh1LcWuklVQkqgR1MQphi6CzZKc1UZcytV0k=";
    };

    patches = [
      ./fix-restart.patch # https://github.com/NixOS/nixpkgs/issues/139568
    ];

    postPatch = ''
      substituteInPlace libqtile/pangocffi.py \
        --replace libgobject-2.0.so.0 ${glib.out}/lib/libgobject-2.0.so.0 \
        --replace libpangocairo-1.0.so.0 ${pango.out}/lib/libpangocairo-1.0.so.0 \
        --replace libpango-1.0.so.0 ${pango.out}/lib/libpango-1.0.so.0
      substituteInPlace libqtile/backend/x11/xcursors.py \
        --replace libxcb-cursor.so.0 ${xcbutilcursor.out}/lib/libxcb-cursor.so.0
    '';

    SETUPTOOLS_SCM_PRETEND_VERSION = version;

    nativeBuildInputs = [
      pkg-config
    ] ++ (with python3Packages; [
      setuptools-scm
    ]);

    propagatedBuildInputs = [
      qtile-extras
      python3Packages.xcffib
      (python3Packages.cairocffi.override { withXcffib = true; })
      python3Packages.setuptools
      python3Packages.python-dateutil
     python3Packages.dbus-python
     python3Packages.dbus-next
     python3Packages.mpd2
     python3Packages.psutil
     python3Packages.pyxdg
     python3Packages.pygobject3
     python3Packages.pywayland
     python3Packages.pywlroots
     python3Packages.xkbcommon
    ];

    buildInputs = [
      libinput
      wayland
      wlroots
      libxkbcommon
    ];

    # for `qtile check`, needs `stubtest` and `mypy` commands
    makeWrapperArgs = [
      "--suffix PATH : ${lib.makeBinPath [ mypy ]}"
    ];

    doCheck = false; # Requires X server #TODO this can be worked out with the existing NixOS testing infrastructure.

    meta = with lib; {
      homepage = "http://www.qtile.org/";
      license = licenses.mit;
      description = "A small, flexible, scriptable tiling window manager written in Python";
      platforms = platforms.linux;
      maintainers = with maintainers; [ kamilchm ];
    };
  };
in
(python3.withPackages (_: [ unwrapped ])).overrideAttrs (_: {
  # otherwise will be exported as "env", this restores `nix search` behavior
  name = "${unwrapped.pname}-${unwrapped.version}";
  # export underlying qtile package
  passthru = { inherit unwrapped; };

  # restore original qtile attrs
  inherit (unwrapped) pname version meta;
})

