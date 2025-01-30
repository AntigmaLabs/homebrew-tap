class Ant < Formula
    desc "Buidling substrate for self-organizing intelligence"
    homepage "https://github.com/AntigmaLabs"
    version "0.1.0" # Match your current version
  
    # Add repo name variable
    repo = "AntigmaLabs/homebrew-tap"
    if OS.mac?
      if Hardware::CPU.arm?
        url "https://github.com/#{repo}/releases/download/v#{version}/ant-v#{version}-Darwin-arm64.tar.gz"
        sha256 "1b177a1ed606421ce4598655c28d28f51d3ab89a6ffef61d5e61f0889cf1a070"
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