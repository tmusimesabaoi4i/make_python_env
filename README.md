# Python 業務用PC向け 環境作成・更新スクリプト

## 目的

Windows の cmd から、以下を簡単に実行するためのスクリプト一式です。

- `python_env_tools\make_env.bat --name my_env_for_work`  
  → `my_env_for_work` という Python 仮想環境を作成し、基本ライブラリをインストールします。

- `python_env_tools\update_env.bat --name my_env_for_work`  
  → `my_env_for_work` 仮想環境内のライブラリを更新します。

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
python_env_tools\make_env.bat --name my_env_for_work
```

これにより、コマンドを実行したフォルダ直下に `my_env_for_work` フォルダが作成されます。

たとえば、以下の場所でコマンドを実行した場合、

```cmd
C:\work>
```

仮想環境は次の場所に作成されます。

```text
C:\work\my_env_for_work
```

### 2. 仮想環境を有効化する

```cmd
my_env_for_work\Scripts\activate.bat
```

有効化されると、cmd の行頭に次のように仮想環境名が表示されます。

```cmd
(my_env_for_work) C:\work>
```

この状態で `python` や `pip` を実行すると、`my_env_for_work` 仮想環境内の Python・ライブラリが使われます。

### 3. 仮想環境から出る

仮想環境の利用を終了する場合は、以下を実行します。

```cmd
deactivate
```

実行後、cmd の行頭から `(my_env_for_work)` が消えていれば、仮想環境から出ています。

```cmd
C:\work>
```

### 4. 仮想環境内のライブラリを更新する

```cmd
python_env_tools\update_env.bat --name my_env_for_work
```

### 5. 直下の全仮想環境をまとめて更新する

```cmd
python_env_tools\update_all.bat
```

### 6. 仮想環境の保存場所を指定する場合

仮想環境を特定のフォルダに作成したい場合は、`--dir` を指定します。

```cmd
python_env_tools\make_env.bat --name my_env_for_work --dir C:\work\venvs\my_env_for_work
```

指定した場所の仮想環境を更新する場合は、同じく `--dir` を指定します。

```cmd
python_env_tools\update_env.bat --name my_env_for_work --dir C:\work\venvs\my_env_for_work
```

複数の仮想環境をまとめて更新する場合は、仮想環境を格納している親フォルダを `--root` で指定します。

```cmd
python_env_tools\update_all.bat --root C:\work\venvs
```

### 7. 仮想環境を削除する

仮想環境が不要になった場合は、仮想環境フォルダを削除します。

まず、仮想環境に入っている場合は、先に仮想環境から出ます。

```cmd
deactivate
```

その後、仮想環境フォルダを削除します。

たとえば、`C:\work\my_env_for_work` に作成された仮想環境を削除する場合は、以下を実行します。

```cmd
rmdir /s /q my_env_for_work
```

または、フルパスで指定する場合は以下です。

```cmd
rmdir /s /q C:\work\my_env_for_work
```

`--dir` で仮想環境を `C:\work\venvs\my_env_for_work` に作成していた場合は、以下を実行します。

```cmd
rmdir /s /q C:\work\venvs\my_env_for_work
```

削除後、以下のようにフォルダが存在しないことを確認できます。

```cmd
dir
```

注意点として、`rmdir /s /q` は確認なしでフォルダを削除します。  
必要なファイルが仮想環境フォルダ内にないことを確認してから実行してください。

### 8. 仮想環境を `python_env_tools` フォルダ内に作りたい場合

仮想環境を `python_env_tools` フォルダ内に作りたい場合は、作成時に `--dir` を指定します。

```cmd
python_env_tools\make_env.bat --name my_env_for_work --dir python_env_tools\my_env_for_work
```

この場合、有効化コマンドは次のとおりです。

```cmd
python_env_tools\my_env_for_work\Scripts\activate.bat
```

仮想環境から出る場合は、同じく以下です。

```cmd
deactivate
```

仮想環境を削除する場合は、以下を実行します。

```cmd
rmdir /s /q python_env_tools\my_env_for_work
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

## インストールされるライブラリ一覧

`make_env.bat` 実行時には、`requirements_basic.txt` に定義された以下のライブラリがインストールされます。

### 基本・インストール補助

| ライブラリ | 用途 |
|---|---|
| `pip` | Python パッケージのインストール・管理 |
| `setuptools` | Python パッケージのビルド・管理 |
| `wheel` | Python パッケージの配布形式対応 |

### HTTP通信・Web取得・スクレイピング補助

| ライブラリ | 用途 |
|---|---|
| `requests` | Webページ・ファイルの取得、HTTP通信 |
| `beautifulsoup4` | HTML/XML の解析 |
| `lxml` | 高速な HTML/XML パーサー |
| `charset-normalizer` | 文字コード判定・文字化け対策 |
| `tqdm` | 処理状況をプログレスバーで表示 |
| `python-dotenv` | `.env` ファイルから環境変数を読み込み |
| `tenacity` | リトライ処理、再実行制御 |

### Excel・データ処理・データベース

| ライブラリ | 用途 |
|---|---|
| `pandas` | 表形式データの処理、CSV/Excel 処理 |
| `numpy` | 数値計算、配列処理 |
| `openpyxl` | Excel `.xlsx` ファイルの読み書き |
| `xlsxwriter` | Excel `.xlsx` ファイルの作成 |
| `duckdb` | 大きめの CSV/Parquet 分析、SQL処理 |
| `pyarrow` | Parquet、Arrow 形式のデータ処理 |

### PDF・Office文書処理

| ライブラリ | 用途 |
|---|---|
| `pypdf` | PDF の結合、分割、テキスト抽出 |
| `pymupdf` | PDF の高速処理、ページ画像化、テキスト抽出 |
| `pdfplumber` | PDF 内の表・テキスト抽出 |
| `python-docx` | Word `.docx` ファイルの読み書き |
| `python-pptx` | PowerPoint `.pptx` ファイルの読み書き |

### HTML・レポート作成・可視化

| ライブラリ | 用途 |
|---|---|
| `jinja2` | HTMLテンプレート生成 |
| `markdownify` | HTML から Markdown への変換 |
| `matplotlib` | グラフ作成、可視化 |

### Notebook・対話実行環境

| ライブラリ | 用途 |
|---|---|
| `ipykernel` | Jupyter Notebook から仮想環境を選択可能にする |
| `jupyterlab` | ブラウザ上で Python を実行できる開発環境 |

### 用途別まとめ

| 用途 | 主なライブラリ |
|---|---|
| Excel処理 | `pandas`, `openpyxl`, `xlsxwriter` |
| CSV・大容量データ分析 | `pandas`, `duckdb`, `pyarrow` |
| PDF処理 | `pypdf`, `pymupdf`, `pdfplumber` |
| Word処理 | `python-docx` |
| PowerPoint処理 | `python-pptx` |
| Web取得 | `requests`, `beautifulsoup4`, `lxml` |
| HTML生成 | `jinja2`, `markdownify` |
| グラフ作成 | `matplotlib` |
| Notebook利用 | `ipykernel`, `jupyterlab` |
| 業務自動化補助 | `tqdm`, `python-dotenv`, `tenacity` |

不要なライブラリがある場合は、`requirements_basic.txt` から削除してから `make_env.bat` を実行してください。

追加したいライブラリがある場合は、`requirements_basic.txt` にライブラリ名を1行ずつ追加してください。

## 注意

- 業務用PCでは、Python 本体の更新は情報システム部門のルールに従ってください。
- `update_env.bat` は仮想環境内の全 outdated package を順番に更新します。
- 仮想環境を削除する場合は、必ず削除対象のフォルダを確認してください。
- `rmdir /s /q` は確認なしで削除するため、誤って別フォルダを指定しないよう注意してください。
- 既存環境を壊したくない重要案件では、更新前にフォルダごとコピーするか、新しい仮想環境を作って検証してください。
