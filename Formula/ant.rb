class Ant < Formula
    desc "Buidling substrate for self-organizing intelligence"
    homepage "https://github.com/AntigmaLabs"
    version "0.0.0" # Match your current version
  
    # Add repo name variable
    repo = "AntigmaLabs/homebrew-tap"

    if OS.mac?
      if Hardware::CPU.arm?
        url "https://github.com/#{repo}/releases/download/v#{version}/ant-v#{version}-Darwin-arm64.tar.gz"
        sha256 "5143305eaba46b7efd563a86e58fb85a7210e9c2a0531e5ca77df78908f092c0"
      else
        url "https://github.com/#{repo}/releases/download/v#{version}/ant-v#{version}-Darwin-x86_64.tar.gz"
        # sha256 "THE_HASH_FROM_YOUR_X86_64_RELEASE"
      end
    elsif OS.linux?
      if Hardware::CPU.intel?
        url "https://github.com/#{repo}/releases/download/v#{version}/ant-v#{version}-Linux-x86_64.tar.gz"
        # sha256 "THE_HASH_FROM_YOUR_LINUX_RELEASE"
      end
    end
  
    def install
      bin.install "ant"
    end
  
    test do
      system "#{bin}/ant", "--version"
    end
  end