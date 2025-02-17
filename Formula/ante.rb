class Ante < Formula
    desc "Building substrate for self-organizing intelligence"
    homepage "https://github.com/AntigmaLabs"
    version "0.0.0" # Match your current version
  
    # Add repo name variable
    repo = "AntigmaLabs/homebrew-tap"

    if OS.mac?
      if Hardware::CPU.arm?
        url "https://github.com/#{repo}/releases/download/v#{version}/ante-v#{version}-Darwin-arm64.tar.gz"
        sha256 "c178ba9f2de2552831d5a50283614b1dbe093babca24684313c86f527225a568"
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