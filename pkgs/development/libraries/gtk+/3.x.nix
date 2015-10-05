{ stdenv, fetchurl, pkgconfig, gettext, perl
, expat, glib, cairo, pango, gdk_pixbuf, atk, at_spi2_atk, gobjectIntrospection
, xlibs, x11, wayland, libxkbcommon, epoxy
, xineramaSupport ? stdenv.isLinux
, cupsSupport ? stdenv.isLinux, cups ? null
}:

assert xineramaSupport -> xlibs.libXinerama != null;
assert cupsSupport -> cups != null;

let
  ver_maj = "3.18";
  ver_min = "0";
  version = "${ver_maj}.${ver_min}";
in
stdenv.mkDerivation rec {
  name = "gtk+3-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtk+/${ver_maj}/gtk+-${version}.tar.xz";
    sha256 = "7fb8ae257403317d3852bad28d064d35f67e978b1fed8b71d5997e87204271b9";
  };

  outputs = [ "dev" "out" ];
  outputBin = "dev";

  nativeBuildInputs = [ pkgconfig gettext gobjectIntrospection perl ];

  buildInputs = [ libxkbcommon epoxy ];
  propagatedBuildInputs = with xlibs; with stdenv.lib;
    [ expat glib cairo pango gdk_pixbuf atk at_spi2_atk libXrandr libXrender libXcomposite libXi libXcursor ]
    ++ optionals stdenv.isLinux [ wayland ]
    ++ optional xineramaSupport libXinerama
    ++ optional cupsSupport cups;

  NIX_LDFLAGS = if stdenv.isDarwin then "-lintl" else null;

  # demos fail to install, no idea where's the problem
  preConfigure = "sed '/^SRC_SUBDIRS /s/demos//' -i Makefile.in";

  enableParallelBuilding = true;

  postInstall = "rm -rf $out/share/gtk-doc";

  passthru = {
    gtkExeEnvPostBuild = ''
      rm $out/lib/gtk-3.0/3.0.0/immodules.cache
      $out/bin/gtk-query-immodules-3.0 $out/lib/gtk-3.0/3.0.0/immodules/*.so > $out/lib/gtk-3.0/3.0.0/immodules.cache
    ''; # workaround for bug of nix-mode for Emacs */ '';
  };

  meta = {
    description = "A multi-platform toolkit for creating graphical user interfaces";

    longDescription = ''
      GTK+ is a highly usable, feature rich toolkit for creating
      graphical user interfaces which boasts cross platform
      compatibility and an easy to use API.  GTK+ it is written in C,
      but has bindings to many other popular programming languages
      such as C++, Python and C# among others.  GTK+ is licensed
      under the GNU LGPL 2.1 allowing development of both free and
      proprietary software with GTK+ without any license fees or
      royalties.
    '';

    homepage = http://www.gtk.org/;

    license = stdenv.lib.licenses.lgpl2Plus;

    maintainers = with stdenv.lib.maintainers; [ urkud raskin vcunat lethalman ];
    platforms = stdenv.lib.platforms.all;
  };
}
