class ApolloNeoEnvManagerDev < Formula
  desc "Apollo Environment Manager for Apple Silicon"
  homepage "https://github.com/SakuraPuare/aem-silicon"
  url "https://github.com/SakuraPuare/aem-silicon/archive/refs/heads/main.tar.gz"
  version "1.0.0"
  sha256 "32855058ba0ae6c401ae333faa40b81edfee28046c76b20f7ac169827358f4fe"
  license "Apache-2.0"

  depends_on "curl"
  depends_on "gnupg"
  depends_on "python"

  resource "apollo_license" do
    url "https://github.com/ApolloAuto/apollo/raw/refs/heads/master/LICENSE"
    sha256 "bfeea761e813af3e836f7be407ac39b98a742d419879059bcaea15b56d9a2e90"
  end

  resource "apollo_gpg_key" do
    url "https://apollo-pkg-beta.cdn.bcebos.com/neo/beta/key/deb.gpg.key"
    sha256 "52fe1c504d1bae9d48f977ef4d181fd7f916747c32d8649a1d290e77dc70800d"
  end

  def install
    # 安装主要文件到 Homebrew 目录
    # GitHub 仓库中的文件结构已经适配了 Apple Silicon
    prefix.install Dir["*"]

    # 安装许可证文件
    resource("apollo_license").stage do
      (share/"licenses"/name).install "LICENSE"
    end

    # 安装 GPG 密钥
    resource("apollo_gpg_key").stage do
      (share/name).install "deb.gpg.key" => "apollo.gpg.key"
    end

    # 创建符号链接 - 根据 GitHub 仓库的实际文件结构调整
    bin.install_symlink prefix/"aem" => "aem"

    # 安装 bash 补全（如果存在）
    if File.exist?(prefix/"aem/auto_complete.bash")
      bash_completion.install prefix/"aem/auto_complete.bash" => "aem"
    end

    # 安装 zsh 补全（如果存在）
    if File.exist?(prefix/"aem/auto_complete.zsh")
      zsh_completion.install prefix/"aem/auto_complete.zsh" => "_aem"
    end
  end

  def post_install
    # 设置 GPG 密钥
    gpg_key_path = share/name/"apollo.gpg.key"
    keyring_dir = etc/"apt/keyrings"
    keyring_dir.mkpath

    system "gpg", "--dearmor", "--output", keyring_dir/"apolloauto.gpg", gpg_key_path
    chmod "a+r", keyring_dir/"apolloauto.gpg"

    # 创建 Apollo 仓库配置
    sources_dir = etc/"apt/sources.list.d"
    sources_dir.mkpath

    (sources_dir/"apolloauto.list").write <<~EOF
      deb [arch=amd64 signed-by=#{keyring_dir}/apolloauto.gpg] https://apollo-pkg-beta.cdn.bcebos.com/apollo/core jammy main
    EOF

    ohai "安装完成！您可以使用 'aem' 命令启动 Apollo Environment Manager。"
    ohai "这是适配 Apple Silicon 的版本，基于 GitHub 仓库：https://github.com/SakuraPuare/aem-silicon"
  end

  def uninstall
    # 清理符号链接
    rm_f etc/"bash_completion.d/aem"
    rm_f share/"zsh/functions/Completion/Unix/_aem"
    rm_f bin/"aem"

    # 清理 GPG 密钥
    rm_f etc/"apt/keyrings/apolloauto.gpg"

    # 清理仓库配置
    rm_f etc/"apt/sources.list.d/apolloauto.list"

    # 清理主目录（GitHub 仓库的所有文件）
    rm_rf prefix
  end

  test do
    # 测试 aem 命令是否可用
    assert_match "Apollo Environment Manager", shell_output("#{bin}/aem --help", 1)
  end
end
