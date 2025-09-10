class ApolloNeoEnvManagerDev < Formula
  desc "Apollo Environment Manager"
  homepage "https://apollo.baidu.com/"
  url "https://apollo-pkg-beta.cdn.bcebos.com/apollo/core/pool/main/a/apollo-neo-env-manager-dev/apollo-neo-env-manager-dev_10.0.0-rc1-r4_amd64.deb"
  version "10.0.0-rc1-r4"
  sha256 "a51f016eaf57d0e1d13e838978b6fbd67f7a6275bf271fdca782746edddda9ef"
  license :cannot_represent

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
    # 创建临时目录
    temp_dir = buildpath/"temp"
    temp_dir.mkpath

    # 下载并提取 deb 包
    # macOS 的 ar 命令语法不同，需要先切换到目标目录
    Dir.chdir(temp_dir) do
      system "ar", "x", cached_download
    end
    # 查找数据包
    data_tar = temp_dir.glob("data.tar.*").first
    odie "无法找到 deb 包中的数据文件" if data_tar.nil?

    # 提取数据包内容
    system "tar", "-xf", data_tar, "-C", temp_dir

    # 安装文件到 Homebrew 目录
    prefix.install Dir[temp_dir/"opt/apollo/*"]

    # 安装许可证文件
    resource("apollo_license").stage do
      (share/"licenses"/name).install "LICENSE"
    end

    # 安装 GPG 密钥
    resource("apollo_gpg_key").stage do
      (share/name).install "deb.gpg.key" => "apollo.gpg.key"
    end

    # 创建符号链接
    bin.install_symlink prefix/"aem/aem" => "aem"

    # 安装 bash 补全
    bash_completion.install prefix/"aem/auto_complete.bash" => "aem"

    # 安装 zsh 补全
    zsh_completion.install prefix/"aem/auto_complete.zsh" => "_aem"
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
    ohai "注意：这是从 Ubuntu 移植的软件包，某些功能可能需要适配 macOS 环境。"
  end

  def uninstall
    # 清理符号链接
    rm etc/"bash_completion.d/aem"
    rm share/"zsh/functions/Completion/Unix/_aem"
    rm bin/"aem"

    # 清理 GPG 密钥
    rm etc/"apt/keyrings/apolloauto.gpg"

    # 清理仓库配置
    rm etc/"apt/sources.list.d/apolloauto.list"

    # 清理主目录
    rm_r prefix/"aem"
  end

  test do
    # 测试 aem 命令是否可用
    assert_match "Apollo Environment Manager", shell_output("#{bin}/aem --help", 1)
  end
end
