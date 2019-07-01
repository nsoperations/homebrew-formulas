class Carthage < Formula
  desc "Decentralized dependency manager for Cocoa"
  homepage "https://github.com/nsoperations/Carthage"
  url "https://github.com/nsoperations/Carthage.git",
      :tag      => "0.36.2+nsoperations",
      :version  => "0.36.2",
      :revision => "457e4939b811a69fde1c64f4e11ec712df52a9f8",
      :shallow  => false
  head "https://github.com/nsoperations/Carthage.git", :shallow => false

  depends_on :xcode => ["10.2", :build]

  bottle do
    root_url "https://dl.bintray.com/nsoperations/bottles-formulas"
    cellar :any_skip_relocation
    sha256 "f5e071cb66f0ab4f3ac41f231ab2dc0535c9bb10036b49357a9c4475978355c8" => :mojave
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
