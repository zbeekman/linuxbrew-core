class Ghq < Formula
  desc "Remote repository management made easy"
  homepage "https://github.com/motemen/ghq"
  url "https://github.com/motemen/ghq.git",
      :tag      => "v0.12.6",
      :revision => "f75cda17931f3d24829f425344dff18f91d78bf6"

  bottle do
    cellar :any_skip_relocation
    sha256 "feb197303052612409d47fdfcaa1ed48e617a2a6c561d24a9590994ba8f956f5" => :mojave
    sha256 "5b301b1b73f6e915107fad6dbe50de2f298cfdc0e847f926bd64205935c3922d" => :high_sierra
    sha256 "4d36b962ed79ab2736ecd7bd8b7480ac00a13258df8ad2f0c37226abcb660b4d" => :sierra
    sha256 "9968096ea19c5a6afe83d69c24d2336c02c7811cd33f1a7d0d31b45db9feb0a4" => :x86_64_linux
  end

  depends_on "go" => :build

  # Go 1.13 compatibility, remove when version > 0.12.6
  patch do
    url "https://github.com/motemen/ghq/pull/193.patch?full_index=1"
    sha256 "03e9a4297d8ab94355f1f7fda2880e555154d034f3a670910fb0574b463f6468"
  end

  def install
    system "make", "build"
    bin.install "ghq"
    zsh_completion.install "zsh/_ghq"
    prefix.install_metafiles
  end

  test do
    assert_match "#{testpath}/.ghq", shell_output("#{bin}/ghq root")
  end
end
