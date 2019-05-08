class Carthage < Formula
  desc "Decentralized dependency manager for Cocoa"
  homepage "https://github.com/nsoperations/Carthage"
  url "https://github.com/nsoperations/Carthage.git",
      :tag  => "0.35.0+nsoperations",
      :version  => "0.35.0",
      :revision => "655e9386bf8eb66c1d474d3a4e184fe48532552c",
      :shallow  => false
  head "https://github.com/nsoperations/Carthage.git", :shallow => false

  bottle do
    root_url "https://homebrew.bintray.com/bottles-formulas"
    cellar :any_skip_relocation
    rebuild 1
    sha256 "0fd53e8d4d87fc4279552ec4a921944ac0f2b283885aa7c1307bd97a4b912217" => :mojave
  end

  depends_on :xcode => ["9.4", :build]

  def install
    system "make", "prefix_install", "PREFIX=#{prefix}"
    bash_completion.install "Source/Scripts/carthage-bash-completion" => "carthage"
    zsh_completion.install "Source/Scripts/carthage-zsh-completion" => "_carthage"
    fish_completion.install "Source/Scripts/carthage-fish-completion" => "carthage.fish"
  end

  test do
    (testpath/"Cartfile").write 'github "jspahrsummers/xcconfigs"'
    system bin/"carthage", "update"
  end
end