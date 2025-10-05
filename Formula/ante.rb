class Ante < Formula
    desc "Building substrate for self-organizing intelligence"
    homepage "https://github.com/AntigmaLabs"
    version "0.1.7" # Match your current version
  
    # Add repo name variable
    repo = "AntigmaLabs/homebrew-tap"

    if OS.mac?
      if Hardware::CPU.arm?
        url "https://github.com/AntigmaLabs/test_release/releases/download/v0.1.7/ante"
        sha256 "a5cb34c8cf5d84119e7471183a59fe4139e02e0f44cbc7ba4243c8da849e12e7"
      else
        url "https://github.com/#{repo}/releases/download/v#{version}/ante-v#{version}-Darwin-x86_64.tar.gz"
        # sha256 "THE_HASH_FROM_YOUR_X86_64_RELEASE"
      end
    elsif OS.linux?
      if Hardware::CPU.intel?
        url "https://github.com/#{repo}/releases/download/v#{version}/ante-v#{version}-Linux-x86_64.tar.gz"
        # sha256 "THE_HASH_FROM_YOUR_LINUX_RELEASE"
      end
    end
  
    def install
      chmod 0755, "ante"
      bin.install "ante"
    end
  
    test do
      system "#{bin}/ante", "--version"
    end
  end