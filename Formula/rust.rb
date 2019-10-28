class Rust < Formula
  desc "Safe, concurrent, practical language"
  homepage "https://www.rust-lang.org/"

  stable do
    url "https://static.rust-lang.org/dist/rustc-1.38.0-src.tar.gz"
    sha256 "644263ca7c7106f8ee8fcde6bb16910d246b30668a74be20b8c7e0e9f4a52d80"

    resource "cargo" do
      url "https://github.com/rust-lang/cargo.git",
          :tag      => "0.39.0",
          :revision => "23ef9a4ef8a96d09b1fd67b2f4e023f416bb1ff1"
    end

    resource "racer" do
      # Racer should stay < 2.1 for now as 2.1 needs the nightly build of rust
      # See https://github.com/racer-rust/racer/tree/v2.1.2#installation
      url "https://github.com/racer-rust/racer/archive/2.0.14.tar.gz"
      sha256 "0442721c01ae4465843cb73b24f6caa0127c3308d72b944ad75736164756e522"
    end
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "dc59b31db0a9095768c7c5487f892b0eeb206208f22beffae5183d44b407f5ae" => :catalina
    sha256 "1bc1a95de1a2ed519c60b666927fcfe7253004f2ba5adb022a8fb1065ba5760b" => :mojave
    sha256 "8b459d752dfa399f3595dbcdcee37024f60042501ffac23a5e3f83351e2b74d7" => :high_sierra
    sha256 "dbb92755cdfbd17ba6e55ca6591318d01a448f41d744de5c9eeaaac3f5ecb9b1" => :x86_64_linux
  end

  head do
    url "https://github.com/rust-lang/rust.git"

    resource "cargo" do
      url "https://github.com/rust-lang/cargo.git"
    end

    resource "racer" do
      url "https://github.com/racer-rust/racer.git"
    end
  end

  depends_on "cmake" => :build
  depends_on "libssh2"
  depends_on "openssl@1.1"
  depends_on "pkg-config"

  unless OS.mac?
    depends_on "binutils"
    depends_on "curl"
    depends_on "python@2"
    depends_on "zlib"
  end

  resource "cargobootstrap" do
    # From: https://github.com/rust-lang/rust/blob/#{version}/src/stage0.txt
    if OS.mac?
      url "https://static.rust-lang.org/dist/2019-09-26/cargo-0.39.0-x86_64-apple-darwin.tar.gz"
      sha256 "107af82e268dfe7dbb35908ab0dfd96d0356c3750520612f1add1ecb8ecbc535"
    elsif OS.linux?
      if Hardware::CPU.intel?
        url "https://static.rust-lang.org/dist/2019-09-26/cargo-0.39.0-x86_64-unknown-linux-gnu.tar.gz"
        sha256 "406ea5822851cf853a14b250386d47df0a60000410ce8ae92b47dedf8162ba9c"
      elsif Hardware::CPU.arm?
        if Hardware::CPU.is_64_bit?
          url "https://static.rust-lang.org/dist/2019-09-26/cargo-0.39.0-aarch64-unknown-linux-gnu.tar.gz"
          sha256 "496d008dc715ccd7d509c531cec04d9d432c84d779e7b2b1b3cf5abf3d68d172"
        else
          url "https://static.rust-lang.org/dist/2019-09-26/cargo-0.39.0-arm-unknown-linux-gnueabi.tar.gz"
          sha256 "c46a770868446e293506004f592a1a772bdfac1feb931cb1b3f1159fb780a318"
        end
      end
    end
  end

  def install
    # Fix build failure for compiler_builtins "error: invalid deployment target
    # for -stdlib=libc++ (requires OS X 10.7 or later)"
    ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version if OS.mac?

    # Ensure that the `openssl` crate picks up the intended library.
    # https://crates.io/crates/openssl#manual-configuration
    ENV["OPENSSL_DIR"] = Formula["openssl@1.1"].opt_prefix

    # Fix build failure for cmake v0.1.24 "error: internal compiler error:
    # src/librustc/ty/subst.rs:127: impossible case reached" on 10.11, and for
    # libgit2-sys-0.6.12 "fatal error: 'os/availability.h' file not found
    # #include <os/availability.h>" on 10.11 and "SecTrust.h:170:67: error:
    # expected ';' after top level declarator" among other errors on 10.12
    ENV["SDKROOT"] = MacOS.sdk_path if OS.mac?

    args = ["--prefix=#{prefix}"]
    args << "--disable-rpath" if build.head?
    if build.head?
      args << "--release-channel=nightly"
    else
      args << "--release-channel=stable"
    end
    system "./configure", *args
    system "make"
    system "make", "install"

    resource("cargobootstrap").stage do
      system "./install.sh", "--prefix=#{buildpath}/cargobootstrap"
    end
    ENV.prepend_path "PATH", buildpath/"cargobootstrap/bin"

    resource("cargo").stage do
      ENV["RUSTC"] = bin/"rustc"
      system "cargo", "install", "--root", prefix, "--path", ".", *("--features" if OS.mac?), *("curl-sys/force-system-lib-on-osx" if OS.mac?)
    end

    resource("racer").stage do
      ENV.prepend_path "PATH", bin
      cargo_home = buildpath/"cargo_home"
      cargo_home.mkpath
      ENV["CARGO_HOME"] = cargo_home
      system "cargo", "install", "--root", libexec, "--path", "."
      (bin/"racer").write_env_script(libexec/"bin/racer", :RUST_SRC_PATH => pkgshare/"rust_src")
    end

    # Remove any binary files; as Homebrew will run ranlib on them and barf.
    rm_rf Dir["src/{llvm-project,llvm-emscripten,test,librustdoc,etc/snapshot.pyc}"]
    (pkgshare/"rust_src").install Dir["src/*"]

    rm_rf prefix/"lib/rustlib/uninstall.sh"
    rm_rf prefix/"lib/rustlib/install.log"
  end

  def post_install
    Dir["#{lib}/rustlib/**/*.dylib"].each do |dylib|
      chmod 0664, dylib
      MachO::Tools.change_dylib_id(dylib, "@rpath/#{File.basename(dylib)}")
      chmod 0444, dylib
    end
  end

  test do
    system "#{bin}/rustdoc", "-h"
    (testpath/"hello.rs").write <<~EOS
      fn main() {
        println!("Hello World!");
      }
    EOS
    system "#{bin}/rustc", "hello.rs"
    assert_equal "Hello World!\n", `./hello`
    system "#{bin}/cargo", "new", "hello_world", "--bin"
    assert_equal "Hello, world!",
                 (testpath/"hello_world").cd { `#{bin}/cargo run`.split("\n").last }
  end
end
