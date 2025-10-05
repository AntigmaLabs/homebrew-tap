require_relative "lib/custom_download_strategy"
class Ante < Formula
    desc "Building substrate for self-organizing intelligence"
    homepage "https://github.com/AntigmaLabs"

    url "https://github.com/AntigmaLabs/test_release/releases/download/v0.2.2/ante-v0.2.2.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "8dc7ac526794cbf220e0bd1a8621ebb5ea9851ef99af03fc53b12c03427ededb" 

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