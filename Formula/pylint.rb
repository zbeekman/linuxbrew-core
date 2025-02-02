class Pylint < Formula
  include Language::Python::Virtualenv

  desc "It's not just a linter that annoys you!"
  homepage "https://github.com/PyCQA/pylint"
  url "https://files.pythonhosted.org/packages/ca/dc/6b85a88376ec32fc72e598e6ff20cd6d7741e4cb9a3dda173739e5459d7d/pylint-2.4.2.tar.gz"
  sha256 "7edbae11476c2182708063ac387a8f97c760d9cfe36a5ede0ca996f90cf346c8"

  bottle do
    cellar :any_skip_relocation
    sha256 "9accde32d77d78c5fb63ed6b0d7bec0af1f8aafbb3adb1f4b5e16ad870fb5e32" => :catalina
    sha256 "73b8cc0825f38b34cfefa5739b2a43ad47ebbcae01c6f339c2ea35fa5ccaf653" => :mojave
    sha256 "8723d320a90f2ddb47b6d5d9716263934aee4ff55acf89bf8038b11d540445a6" => :high_sierra
    sha256 "82afefa0c4bb6d3446f133beafa207cc85eb997d6b64a986b49ae8b7a42ae4aa" => :x86_64_linux
  end

  depends_on "python"

  resource "astroid" do
    url "https://files.pythonhosted.org/packages/15/7c/c56122bdec2cc8508aca5eae27502f3fdd970f4a9233ba43e398d79847de/astroid-2.3.1.tar.gz"
    sha256 "b7546ffdedbf7abcfbff93cd1de9e9980b1ef744852689decc5aeada324238c6"
  end

  resource "isort" do
    url "https://files.pythonhosted.org/packages/43/00/8705e8d0c05ba22f042634f791a61f4c678c32175763dcf2ca2a133f4739/isort-4.3.21.tar.gz"
    sha256 "54da7e92468955c4fceacd0c86bd0ec997b0e1ee80d97f67c35a78b719dccab1"
  end

  resource "lazy-object-proxy" do
    url "https://files.pythonhosted.org/packages/36/39/d9b7d05775c3d12fe49c1119f53e20adf81757bfd3840f30961a0d57e6d1/lazy-object-proxy-1.4.2.tar.gz"
    sha256 "fd135b8d35dfdcdb984828c84d695937e58cc5f49e1c854eb311c4d6aa03f4f1"
  end

  resource "mccabe" do
    url "https://files.pythonhosted.org/packages/06/18/fa675aa501e11d6d6ca0ae73a101b2f3571a565e0f7d38e062eec18a91ee/mccabe-0.6.1.tar.gz"
    sha256 "dd8d182285a0fe56bace7f45b5e7d1a6ebcbf524e8f3bd87eb0f125271b8831f"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"
    sha256 "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"
  end

  resource "typed-ast" do
    url "https://files.pythonhosted.org/packages/34/de/d0cfe2ea7ddfd8b2b8374ed2e04eeb08b6ee6e1e84081d151341bba596e5/typed_ast-1.4.0.tar.gz"
    sha256 "66480f95b8167c9c5c5c87f32cf437d585937970f3fc24386f313a4c97b44e34"
  end

  resource "wrapt" do
    url "https://files.pythonhosted.org/packages/23/84/323c2415280bc4fc880ac5050dddfb3c8062c2552b34c2e512eb4aa68f79/wrapt-1.11.2.tar.gz"
    sha256 "565a021fd19419476b9362b05eeaa094178de64f8361e44468f9e9d7843901e1"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    (testpath/"pylint_test.py").write <<~EOS
      print('Test file'
      )
    EOS
    system bin/"pylint", "--exit-zero", "pylint_test.py"
  end
end
