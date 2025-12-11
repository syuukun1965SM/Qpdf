@echo off

rem 機能概要: --pagesオプションを用いた各種機能をユーザ入力により選択（選択肢は以下の4通り） → 入力情報により処理分岐して実行するって感じ。尚、処理結果は別ファイルに出力する。
rem 選択肢[1]: ページ抽出 → 対象ファイル内の必要なページのみを抽出し、別ファイルに出力する
rem 選択肢[2]: ページ削除 → 対象ファイルから不要なページを削除し、別ファイルに出力する
rem 選択肢[3]: ファイル結合 → 複数ファイルを結合し、別ファイルに出力する
rem 選択肢[4]: 異なるファイル内の指定ページの抽出と同時にページ結合 → 各々のファイルで指定した必要ページを結合し、別ファイルに出力する
rem 各処理終了後に処理の継続・終了のっ判断を仰ぐ
rem (注: 起動は引数なし)

rem 起動時の簡易操作方法表示
echo.
echo  ==使い方==
echo  実施したい機能(1～4)を選択する。各選択肢の機能概要は以下:
echo       選択肢[1]: ページ抽出 → 対象ファイル内の必要なページのみを抽出し、別ファイルに出力する
echo       選択肢[2]: ページ削除 → 対象ファイルから不要なページを削除し、別ファイルに出力する
echo       選択肢[3]: ファイル結合 → 複数ファイルを結合し、別ファイルに出力する
echo       選択肢[4]: 異なるファイル内の指定ページの抽出と同時にページ結合 → 各々のファイルで指定した必要ページを結合し、別ファイルに出力する
echo.



:INPUT_LOOP
rem ユーザ入力値判定処理部

set SEL_Nr=
choice /C 1234 /M "処理を(1: ページ抽出、2: ページ削除、3: ファイル結合、4: ページ結合)から選択してください"
rem set /p ROT_Ang="回転角度を(0度、90度、180度、270度(-90度))から選択してください :  "
echo "%ERRORLEVEL%"
if ERRORLEVEL 4 (
	set SEL_Nr=4
	call qpdf_pages_04.bat
	goto :CONTINUATION_CHECK
)
if ERRORLEVEL 3 (
	set SEL_Nr=3
	call qpdf_pages_03.bat
	goto :CONTINUATION_CHECK
)
if ERRORLEVEL 2 (
	set SEL_Nr=2
	call qpdf_pages_02.bat
	goto :CONTINUATION_CHECK
)
if ERRORLEVEL 1 (
	set SEL_Nr=1
	call qpdf_pages_01.bat
)


:CONTINUATION_CHECK
rem 処理継続の意思確認部
echo.
choice /C YN /M "別の処理をしますか？ (Y/N)"
echo.
if ERRORLEVEL 2 goto :END
if ERRORLEVEL 1 goto :INPUT_LOOP



:END
rem 終了処理部
echo.
echo +-------------------------------------------------------+
echo  %Show_str%
echo  終了します。
echo +-------------------------------------------------------+
rem PAUSE
echo.
EXIT /b
