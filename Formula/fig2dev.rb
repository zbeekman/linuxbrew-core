class Fig2dev < Formula
  desc "Translates figures generated by xfig to other formats"
  homepage "https://mcj.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/mcj/fig2dev-3.2.7a.tar.xz"
  sha256 "bda219a15efcdb829e6cc913a4174f5a4ded084bf91565c783733b34a89bfb28"

  bottle do
    rebuild 1
    sha256 "244ade7b1dc565aaa38a221682309bda9d04686ebb32217524658c94db38a275" => :catalina
    sha256 "79e3ce0deff39f9a8787014dae667668a8d585c600bb20c0a839629dfc561a14" => :mojave
    sha256 "995e027eba6f1857d13ddfcec5c19abd126133cb4b4420beed173e197cb6b5fb" => :high_sierra
    sha256 "2a4bf3ad00d9d2194f087e95c250dd848c1cb4734d7c020b3607ddf20cf6f3ad" => :sierra
    sha256 "b8fa123ee19fa1144aaabb5365edc5701215c06683ebfd3670475fa865065e42" => :x86_64_linux
  end

  depends_on "ghostscript"
  depends_on "libpng"
  depends_on "netpbm"

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-transfig
      --without-xpm
      --without-x
    ]

    system "./configure", *args
    system "make", "install"

    # Install a fig file for testing
    pkgshare.install "fig2dev/tests/data/patterns.fig"
  end

  test do
    system "#{bin}/fig2dev", "-L", "png", "#{pkgshare}/patterns.fig", "patterns.png"
    assert_predicate testpath/"patterns.png", :exist?, "Failed to create PNG"
  end
end
