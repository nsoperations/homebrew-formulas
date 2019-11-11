class Carthage < Formula
  desc "Decentralized dependency manager for Cocoa"
  homepage "https://github.com/nsoperations/Carthage"
  url "https://github.com/nsoperations/Carthage.git",
      :tag      => "0.40.2+nsoperations",
      :version  => "0.40.2",
      :revision => "5e391d914119ff6b8a546c8d85206dc5755a02b2",
      :shallow  => false
  head "https://github.com/nsoperations/Carthage.git", :shallow => false

  depends_on :xcode => ["10.2", :build]

  bottle do
    root_url "https://dl.bintray.com/nsoperations/bottles-formulas"
    cellar :any_skip_relocation
    sha256 "1aad73afac5d1b52f851958b985721d8d9dfe003e5d262f33097a0c9afae3917" => :mojave
  end

  def install
    if MacOS::Xcode.version >= "10.2" && MacOS.full_version < "10.14.4" && MacOS.version >= "10.14"
      odie "Xcode >=10.2 requires macOS >=10.14.4 to build Swift formulae."
    end

    system "make", "prefix_install", "PREFIX=#{prefix}"
    bash_completion.install "Source/Scripts/carthage-bash-completion" => "carthage"
    zsh_completion.install "Source/Scripts/carthage-zsh-completion" => "_carthage"
    fish_completion.install "Source/Scripts/carthage-fish-completion" => "carthage.fish"
  end

  test do
    system bin/"carthage", "version"
  end
end
