# OneProgress
これは、私がWebサービス開発の勉強のために作成したウェブアプリケーションです。  
下記のURLでこのリポジトリのアプリケーションが稼働しています。  
https://one-progress.net/

# 機能
基本的な機能はシンプルなToDoアプリです。作成したタスクは他のユーザに見られることはありません。しかし、取り組むと決めたタスクはすべてのユーザに公開される、という特徴があります。

このリポジトリはアプリケーションのほか、動作確認を行う環境構築のためのコードを含んでいます。それらを実行することで、仮想マシン上でアプリケーションの動作確認や開発を行うことができます。環境構築にはVirtualbox、Vagrant、Ansibleを使用しています。

# 動作環境
このアプリケーションは、以下の環境で動作確認をしています。
* Ruby 2.3.1
* Vagrant 1.8.6
* Ansible 2.3.2.0
* Virtualbox 5.1.24

# 使い方
## 環境構築
リポジトリルートで以下のコマンドを実行すると、仮想マシンのセットアップとアプリケーションの起動が行われます。
```
$ vagrant up
```
ブラウザで`https://192.168.33.10`を開くと警告メッセージが表示されますが、無視してアクセスするとアプリケーションのページが表示されます。警告メッセージが表示されるのはダミーの証明書を使用しているためです。このとき、仮想マシン上ではWebサーバ、アプリサーバ、データベースサーバの各Dockerコンテナが起動した状態となっています。

## 開発
仮想マシン上でソースコードを変更して動作確認ができます。
まず以下のコマンドで仮想マシンにSSH接続します。
```
$ vagrant ssh
```

デフォルトだと`~/one-progress`ディレクトリが存在します。そこへ移動し、アプリケーションの起動に必要な各種Gemをインストールします。
```
$ cd one-progress
$ bundle install
```

次にデータベースのセットアップを行います。以下のコマンドを実行すると、データベースone\_progress\_developmentとone\_progress\_testが、Dockerコンテナ(コンテナ名:db)に作成されます。
```
$ bundle exec rake db:setup
```

データベースのセットアップが完了したら、以下のコマンドでアプリケーションを実行します。
```
$ bundle exec rails s -b 0.0.0.0
```

この状態で`http://192.168.33.10:3000`にアクセスすると、仮想マシンの`~/one-progress`ディレクトリにあるソースコードの動作確認ができます。ただし、これはあくまで開発時の動作確認用です。プロダクション環境ではアプリケーションもDockerコンテナ内で動作しています。最初にvagrant upしたときのように、変更したソースコードをアプリケーションコンテナで動かしたい場合には、__ホスト__の`one-progress/provisioning/playbook/roles/containers/vars/main.yml`にファイルを配置して、コンテナで動かすソースコードの取得元の変数を上書きする必要があります。以下の例は仮想マシン上の`~/one-progress`のdevelopブランチに加えた変更をコンテナで動かすための設定です。変更はコミットしている必要があります。
```
repository: /home/vagrant/one-progress
version: develop
```
ホスト上で以下のコマンドを実行するとプロビジョニングが実行され、変更したソースコードでDockerコンテナが再作成されます。
```
$ vagrant provision
```

### 注意
デフォルトの状態ではTwitterアカウントによるログイン機能が動作しません。ログイン機能を有効にしたい場合は、ホスト上に`one-progress/provisioning/playbook/roles/containers/vars/main.yml`ファイルを作成し、以下のように変数を上書きする必要があります。
```
twitter_api_key: [Twitterのアプリケーション管理画面のAPI Key]
twitter_api_secret: [Twitterのアプリケーション管理画面のAPI Secret]
```

## テスト
テストを実行するには仮想マシンの`~/one-progress`ディレクトリに移動して以下のコマンドを実行します。先に上記「開発」の手順でGemのインストールとデータベースのセットアップを完了しておいてください。
```
$ bundle exec rspec spec
```

## リリース
### VPSの準備
このアプリケーションは、VPS上で動作しています。VPSは、SELinuxが有効化され、vagrantユーザで鍵認証によるSSH接続、パスなしsudoが可能な状態である必要があります。

### Vagrantプラグインのインストール
vagrantでVPSに接続するのに[vagrant-managed-servers 0.8.0](https://github.com/tknerr/vagrant-managed-servers)を使用しています。以下のコマンドでインストールできます。
```
$ vagrant plugin install vagrant-managed-servers
```

### 設定ファイルの配置
VPSのプロビジョニングを実行する前にいくつかの設定ファイルを配置する必要があります。まずはVagrantのための設定ファイル`one-progress/provisioning/production/config/secrets.yml`の例を以下に示します。`ssh_port`にはプロビジョニングで変更するSSHポートを指定します。`server`にはVPSのURLを指定します。`ssh_private_key_path`にはVPSにSSH接続可能な、ホスト上の鍵のパスを指定します。
```
ssh_port: 9999
server: "your-vps-url.ne.jp"
ssh_private_key_path: path/to/.ssh/priv_key.pem
```

Dockerコンテナの設定ファイル`one-progress/provisioning/playbook/roles/containers/vars/main.yml`の例を以下に示します。`twitter_api_key`、`twitter_api_key`にはTwitterのアプリケーション管理画面で表示されるAPI Key、API Secretを指定します。`db_password`はアプリケーションコンテナからデータベースコンテナへ接続するときのパスワードを指定します(あらかじめ設定したパスワードではなく、ここで指定したパスワードで接続できるようにする)。
```
twitter_api_key: your_api_key
twitter_api_secret: your_api_secret
db_password: pass
```

Certbotコンテナの設定ファイル`./provisioning/playbook/roles/certbot/vars/main.yml`の例を以下に示します。`email`は証明書を取得するための登録用メールアドレスです。
```
email: "your-address@gmail.com"
```

### デプロイ
デプロイのためのVagrantfileが配置してあるproductionディレクトリに移動します。
```
$ cd path/to/one-progress/provisioning/production
```

以下のコマンドを実行してvagrantでVPSに接続可能な状態にします。
```
$ vagrant up
```

以下のコマンドでVPSのプロビジョニングを実行します。
```
$ vagrant provision
```

プロビジョニングが完了するとVPSのSSHポートは設定ファイルの値に変更されるため、そのままではSSH接続できなくなります。VPSの管理コンソールから再起動した後、再度プロビジョニングを実行します。このとき、最初のプロビジョニングにより作成された`one-progress/provisioning/playbook/host_vars/one-progress.yml`から変更後のAnsible用SSHポートの値を読み取っています。このファイルを消してプロビジョニングを実行すると、最初のプロビジョニングだと見なされてデフォルトのSSHポートを使用してしまうので注意してください。
```
$ vagrant provision
```

これでアプリケーションのデプロイは完了です。上記手順が終わってone-progress.ymlができていればSSHポートを意識せずに`vagrant ssh`や`vagrant provision`等のコマンドが使用できます。
