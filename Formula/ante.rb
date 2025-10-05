class Ante < Formula
    desc "Building substrate for self-organizing intelligence"
    homepage "https://github.com/AntigmaLabs"

    url "https://github.com/AntigmaLabs/test_release/releases/download/v0.0.0/ante-v0.0.0.tar.gz"
    sha256 "deadbeef" 

    def install
      if OS.mac? && Hardware::CPU.arm?
        bin.install "darwin-arm64/ante"
      elsif OS.linux? && Hardware::CPU.intel?
        bin.install "linux-x86_64/ante"
      else
        odie "Unsupported platform for this binary package"
      end
    end
  
    test do
      system "#{bin}/ante", "--version"
    end
  end