# ベースイメージにUbuntuを指定
FROM ubuntu:24.04

# Git, GPG, SSH, Pythonを導入
RUN apt update && apt upgrade -y && \
    apt install -y \
        git \
        gnupg \
        python3 \
        ssh

# 作業ディレクトリの設定
WORKDIR /app

# デフォルトの実行コマンド
CMD ["bash"]