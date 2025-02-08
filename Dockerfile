FROM ubuntu:24.04

# Pythonソースをダウンロードしてコンテナに取り込む(これはビルド時に削除)
ADD https://www.python.org/ftp/python/3.13.2/Python-3.13.2.tar.xz /tmp/

# 時間のかかる処理、変更の少ない処理から順に実行してレイヤ構成。
# 開発用なのでイメージサイズは気にしない。

# マニュアル関係・unminimize(通常版Ubuntuに近い構成にする)
RUN     apt update \
    &&  apt upgrade -y \
    &&  apt install -y \
            man-db \
            manpages \
            manpages-posix \
            manpages-posix-dev \
            unminimize \
    &&  yes | unminimize

# 必要なパッケージを導入しPythonをビルド
RUN     apt install -y \
            build-essential \
            libbz2-dev \
            libffi-dev \
            liblzma-dev \
            libncurses5-dev \
            libreadline-dev \
            libsqlite3-dev \
            libssl-dev \
            tk-dev \
            uuid-dev \
            wget \
            xz-utils \
            zlib1g-dev \
    &&  mkdir -p /usr/src/python \
    &&  tar -xJf /tmp/Python-3.13.2.tar.xz -C /usr/src/python --strip-components=1 \
    &&  rm /tmp/Python-3.13.2.tar.xz \
    &&  cd /usr/src/python \
    &&  ./configure --enable-optimizations --with-lto --with-ensurepip=install \
    &&  make -j$(nproc) \
    &&  make altinstall \
    &&  cd / \
    &&  rm -rf /usr/src/python \
    &&  ln -s /usr/local/bin/python3.13 /usr/local/bin/python \
    &&  ln -s /usr/local/bin/pip3.13 /usr/local/bin/pip

# CUDA関連インストール
RUN     wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb \
    &&  dpkg -i cuda-keyring_1.1-1_all.deb \
    &&  apt update \
    &&  apt -y install cuda-toolkit-12-6

# 必要なコマンド関係(好きなの足していく)
# GPGに必要な環境変数の追加
RUN     apt install -y \
            curl \
            git \
            gnupg \
            ssh \
            tree \
            vim \
    &&  echo 'GPG_TTY=$(tty)' >> /root/.bashrc && \
        echo 'export GPG_TTY' >> /root/.bashrc

#Python関係ライブラリインストール
RUN     pip install --no-cache-dir \
            mypy \
            numba \
            numpy

#掃除(開発用コンテナでは省略)
#RUN     apt clean && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリの設定
WORKDIR /app

# デフォルトの実行コマンド
CMD ["bash"]