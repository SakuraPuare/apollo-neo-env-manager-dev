# Apollo Neo Environment Manager (Dev) - Homebrew Formula

这是 Apollo Neo 环境管理器的 Homebrew Formula，从 Arch Linux AUR 包迁移而来。

## 描述

Apollo Neo 环境管理器是百度 Apollo 自动驾驶平台的环境管理工具，主要用于管理和设置 Apollo 开发环境。此 Formula 将 Ubuntu 版本的工具适配到 macOS 上。

## 安装

可以使用 Homebrew 安装：

```bash
# 添加 tap
brew tap sakurapuare/apollo-neo-env-manager-dev

# 安装
brew install apollo-neo-env-manager-dev
```

## 使用

安装后，可以通过以下命令使用：

```bash
# 使用简写命令
aem

# 或使用完整命令
apollo-neo-env-manager-dev
```

## 依赖项

- curl
- gnupg
- python@latest

## 兼容性提示

由于这是从 Ubuntu 移植的软件包，某些功能可能需要额外的设置才能在 macOS 环境中正常工作。程序使用了 apt 相关的目录结构，这些已在安装过程中进行了适配。

## 卸载

可以使用标准的 brew 命令卸载：

```bash
brew uninstall apollo-neo-env-manager-dev
```

## 许可证

请参考 Apollo 项目的 LICENSE 文件。

## 维护者

SakuraPuare

`sakurapuare at sakurapuare dot com`

## 迁移说明

此 Formula 从 Arch Linux AUR 包迁移而来，主要变化包括：

1. 使用 Homebrew 的 Ruby DSL 语法
2. 适配 macOS 的文件系统结构
3. 使用 Homebrew 的依赖管理系统
4. 适配 macOS 的包管理方式
