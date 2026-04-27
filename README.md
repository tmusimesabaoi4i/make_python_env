# Python 業務用PC向け 環境作成・更新スクリプト

## 目的

Windows の cmd から、以下を簡単に実行するためのスクリプト一式です。

- `python_env_tools\make_env.bat --name YYY`  
  → `YYY` という Python 仮想環境を作成し、基本ライブラリをインストールします。

- `python_env_tools\update_env.bat --name YYY`  
  → `YYY` 仮想環境内のライブラリを更新します。

- `python_env_tools\update_all.bat`  
  → 可能であれば Python 本体を `winget` で更新し、現在のフォルダ直下にある全仮想環境のライブラリを更新します。

## ファイル構成

```text
make_env.bat
update_env.bat
update_all.bat
requirements_basic.txt
make_env.sh
update_env.sh
update_all.sh
pip_proxy_example.ini
```

通常の Windows 業務用PCでは、まず `.bat` だけ使えば十分です。

## 基本的な使い方

### 1. 仮想環境を作る

```cmd
python_env_tools\make_env.bat --name YYY
```

これにより、コマンドを実行したフォルダ直下に `YYY` フォルダが作成されます。

### 2. 仮想環境を有効化する

```cmd
python_env_tools\YYY\Scripts\activate.bat
```

### 3. 仮想環境内のライブラリを更新する

```cmd
python_env_tools\update_env.bat --name YYY
```

### 4. 直下の全仮想環境をまとめて更新する

```cmd
python_env_tools\update_all.bat
```

### 5. 仮想環境の保存場所を指定する場合

```cmd
python_env_tools\make_env.bat --name YYY --dir C:\work\venvs\YYY
python_env_tools\update_env.bat --name YYY --dir C:\work\venvs\YYY
python_env_tools\update_all.bat --root C:\work\venvs
```

## Python 本体更新について

`update_all.bat` は、Windows の `winget` が使える場合のみ Python 本体の更新を試みます。

業務用PCでは、以下の理由で Python 本体更新が失敗することがあります。

- `winget` が無効化されている
- 管理者権限がない
- 組織のソフトウェア配布ツールで Python が管理されている
- プロキシやセキュリティ製品でブロックされる

その場合でも、仮想環境内のライブラリ更新は続行します。

## インストールされる基本ライブラリ

`requirements_basic.txt` に定義しています。不要なものは削除して構いません。

主な内容は以下です。

- Excel・データ処理: `pandas`, `openpyxl`, `xlsxwriter`, `duckdb`, `pyarrow`
- PDF・Office: `pypdf`, `pymupdf`, `pdfplumber`, `python-docx`, `python-pptx`
- HTML・Web: `requests`, `beautifulsoup4`, `lxml`, `jinja2`, `markdownify`
- Notebook: `ipykernel`, `jupyterlab`
- ユーティリティ: `tqdm`, `python-dotenv`, `tenacity`

## 社内プロキシがある場合

pip が失敗する場合は、`pip_proxy_example.ini` を参考にしてください。

Windows の pip 設定ファイルの代表的な配置先は次です。

```text
%APPDATA%\pip\pip.ini
```

例:

```ini
[global]
proxy = http://user:password@proxy.example.local:8080
trusted-host =
    pypi.org
    files.pythonhosted.org
```

※ パスワードを平文保存する運用は、社内ルールに従ってください。

## 注意

- 業務用PCでは、Python 本体の更新は情報システム部門のルールに従ってください。
- `update_env.bat` は仮想環境内の全 outdated package を順番に更新します。
- 既存環境を壊したくない重要案件では、更新前にフォルダごとコピーするか、新しい仮想環境を作って検証してください。
