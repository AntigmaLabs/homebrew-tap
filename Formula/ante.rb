class Ante < Formula
  desc "Building substrate for self-organizing intelligence"
  homepage "https://github.com/AntigmaLabs"
  version "0.2.0" # Match your current version

  # Add repo name variable
  repo = "AntigmaLabs/homebrew-tap"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/AntigmaLabs/test_release/releases/download/v0.2.0/ante-aarch64-apple-darwin"
      sha256 "5e6554f6beb0237d74c6b2565fb5dbd29a81326fae9698518d13f668331bf016"
    else
      odie "ante is not currently supported on macOS x86_64 (Intel). Only Apple Silicon (ARM64) is supported."
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/#{repo}/releases/download/v#{version}/ante-x86_64-unknown-linux-gnu"
      sha256 "REPLACE_WITH_ACTUAL_SHA256_FOR_LINUX_X86_64"
    else
      odie "ante is not currently supported on Linux ARM. Only x86_64 is supported."
    end
  else
    odie "ante is only supported on macOS (Apple Silicon) and Linux (x86_64)."
  end

  def install
    # The downloaded file is the binary itself, rename it to 'ante'
    binary_name = if OS.mac? && Hardware::CPU.arm?
                    "ante-aarch64-apple-darwin"
                  elsif OS.linux?
                    "ante-x86_64-unknown-linux-gnu"
                  end

    bin.install binary_name => "ante"
  end

  test do
    system "#{bin}/ante", "--version"
  end
end
