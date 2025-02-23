class Ante < Formula
    desc "Building substrate for self-organizing intelligence"
    homepage "https://github.com/AntigmaLabs"
    version "0.0.0" # Match your current version
  
    # Add repo name variable
    repo = "AntigmaLabs/homebrew-tap"

    if OS.mac?
      if Hardware::CPU.arm?
        url "https://github.com/#{repo}/releases/download/v#{version}/ante-v#{version}-Darwin-arm64.tar.gz"
        sha256 "d03a7bff5ef722468a8ce5f1382e835a2f955c5de14e4d3f8b684c1e46124678"
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
      bin.install "ante"
    end
  
    test do
      system "#{bin}/ante", "--version"
    end
  end