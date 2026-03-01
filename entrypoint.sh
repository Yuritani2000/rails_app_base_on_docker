#!/bin/bash
set -e


# ユーザーが存在しない場合は作成する
if ! id -u appuser > /dev/null 2>&1; then
  USER_ID=${USER_ID:-1000}
  GROUP_ID=${GROUP_ID:-1000}
  groupadd -g $GROUP_ID appuser 2>/dev/null || true
  useradd -u $USER_ID -g $GROUP_ID -m -s /bin/bash appuser 2>/dev/null || true
fi

# bundleとsample_appディレクトリの権限をappuserに変更(.gitディレクトリを含めないようにしている)
chown -R appuser:appuser /usr/local/bundle
find . -mindepth 1 -maxdepth 1 ! -name ".*" -exec chown -R appuser:appuser {} +


# Rails特有の問題を解決するためのコマンド
rm -f /sample_app/tmp/pids/server.pid


# appuserでコマンドを実行
exec gosu appuser "$@"
