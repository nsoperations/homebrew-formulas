class Carthage < Formula
  desc "Decentralized dependency manager for Cocoa"
  homepage "https://github.com/nsoperations/Carthage"
  url "https://github.com/nsoperations/Carthage.git",
      :version  => "0.33.0",
      :revision => "8767d0d4c978b05f700a92b094aa915637aa8940",
      :shallow  => false
  head "https://github.com/nsoperations/Carthage.git", :shallow => false

  bottle do
    cellar :any
    sha256 "265d7c1e06f0acb8f5615b6c1d71ffc05b05844bb0fb1da931799ec18ca318a5" => :mojave
    sha256 "576468454342dc278837901358ce2f325584307cafd457ae9ada46436b84a941" => :high_sierra
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