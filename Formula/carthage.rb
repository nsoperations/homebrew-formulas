class Carthage < Formula
  desc "Decentralized dependency manager for Cocoa"
  homepage "https://github.com/nsoperations/Carthage"
  url "https://github.com/nsoperations/Carthage.git",
      :tag      => "0.39.3+nsoperations",
      :version  => "0.39.3",
      :revision => "fc4cb6595ec5a309c85c4b563ec75148881610bf",
      :shallow  => false
  head "https://github.com/nsoperations/Carthage.git", :shallow => false

  depends_on :xcode => ["10.2", :build]

  #bottle do
  #  root_url "https://dl.bintray.com/nsoperations/bottles-formulas"
  #  cellar :any_skip_relocation
  #  sha256 "e61b2fb427ec3d0687db90702fe57889a57379380ba8a22fe00059339c921974" => :mojave
  #end

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
