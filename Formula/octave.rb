class Octave < Formula
  desc "High-level interpreted language for numerical computing"
  homepage "https://www.gnu.org/software/octave/index.html"
  url "https://ftp.gnu.org/gnu/octave/octave-5.1.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/octave/octave-5.1.0.tar.xz"
  sha256 "87b4df6dfa28b1f8028f69659f7a1cabd50adfb81e1e02212ff22c863a29454e"
  revision 6

  bottle do
    sha256 "7472104ece73a53719c6e09a373e3bb838964ce7f1b6d877d1f9a5786cec2134" => :catalina
    sha256 "c278bf8ca43532aab61e97fbdb199b92469df24954b8f8eb32cf14e420072ba0" => :mojave
    sha256 "5014b5f992725e269c50aa855e3c71cec76a271c5fd616f5762e8d86e683c0c9" => :high_sierra
    sha256 "52233264b4b5fa844a6779721f97145aa0389a22b73eac3bb5489875b0a934da" => :sierra
    sha256 "f7346eab59163101fd415ad7dcfd00ce95eed7e7e6b20fb4ebea2154cfdb6f12" => :x86_64_linux
  end

  head do
    url "https://hg.savannah.gnu.org/hgweb/octave", :branch => "default", :using => :hg

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bison" => :build
    depends_on "icoutils" => :build
    depends_on "librsvg" => :build
  end

  # Complete list of dependencies at https://wiki.octave.org/Building
  depends_on "gnu-sed" => :build # https://lists.gnu.org/archive/html/octave-maintainers/2016-09/msg00193.html
  depends_on :java => ["1.7+", :build]
  depends_on "pkg-config" => :build
  depends_on "arpack"
  depends_on "epstool"
  depends_on "fftw"
  depends_on "fig2dev"
  depends_on "fltk"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gcc" # for gfortran
  depends_on "ghostscript"
  depends_on "gl2ps"
  depends_on "glpk"
  depends_on "gnuplot"
  depends_on "graphicsmagick"
  depends_on "hdf5"
  depends_on "libsndfile"
  depends_on "libtool"
  depends_on "openblas"
  depends_on "pcre"
  depends_on "portaudio"
  depends_on "pstoedit"
  depends_on "qhull"
  depends_on "qrupdate"
  depends_on "qt"
  depends_on "readline"
  depends_on "suite-sparse"
  depends_on "sundials"
  depends_on "texinfo"
  uses_from_macos "curl"

  # Dependencies use Fortran, leading to spurious messages about GCC
  cxxstdlib_check :skip

  # Octave fails to build due to error with java. See also
  # https://github.com/Homebrew/homebrew-core/issues/39848
  # Patch submitted upstream at: https://savannah.gnu.org/patch/index.php?9806
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/master/octave/5.1.0-java-version.patch"
    sha256 "7ea1e9b410a759fa136d153fb8482ecfc3425a39bfe71c1e71b3ff0f7d9a0b54"
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--enable-link-all-dependencies",
                          "--enable-shared",
                          "--disable-static",
                          "--with-hdf5-includedir=#{Formula["hdf5"].opt_include}",
                          "--with-hdf5-libdir=#{Formula["hdf5"].opt_lib}",
                          "--with-x=no",
                          "--with-blas=-L#{Formula["openblas"].opt_lib} -lopenblas",
                          "--with-portaudio",
                          "--with-sndfile"
    system "make", "all"

    # Avoid revision bumps whenever fftw's, gcc's or OpenBLAS' Cellar paths change
    inreplace "src/mkoctfile.cc" do |s|
      s.gsub! Formula["fftw"].prefix.realpath, Formula["fftw"].opt_prefix
      s.gsub! Formula["gcc"].prefix.realpath, Formula["gcc"].opt_prefix
    end

    # Make sure that Octave uses the modern texinfo at run time
    rcfile = buildpath/"scripts/startup/site-rcfile"
    rcfile.append_lines "makeinfo_program(\"#{Formula["texinfo"].opt_bin}/makeinfo\");"

    system "make", "install"
  end

  test do
    system bin/"octave", "--eval", "(22/7 - pi)/pi"
    # This is supposed to crash octave if there is a problem with BLAS
    system bin/"octave", "--eval", "single ([1+i 2+i 3+i]) * single ([ 4+i ; 5+i ; 6+i])"
  end
end
