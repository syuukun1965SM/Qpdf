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
rem echo "%ERRORLEVEL%"
if ERRORLEVEL 4 (
	set SEL_Nr=4
	goto :Page_Bind
)
if ERRORLEVEL 3 (
	set SEL_Nr=3
	goto :File_Bond
)
if ERRORLEVEL 2 (
	set SEL_Nr=2
	goto :Page_Del
)
if ERRORLEVEL 1 set SEL_Nr=1


:Page_Sel
echo 1番を選択
exit /b


:Page_Del
echo 2番を選択
exit /b



:File_Bond
set In_File01=
set Target_Files=
set Op_Num=0

echo 3番を選択
echo.
echo ==やり方==
echo ファイルとファイルの結合なので最低二つは必須。
echo ファイルを一つ指定したらエンタキィを押下。
echo 必要ファイルを全て指定し終わったらもう一回エンタキィを押下する。
echo 結合ファイルはoutput.pdfとして出力される。
echo.

:File_Bond01
set In_File=

set /p In_File="ファイルを指定してください(終了時はEnterのみ):  "

rem ファイル指定終了判定処理部
if "%In_File%"=="" (
	if %Op_Num% LSS 2 (
		echo 指定ファイル数が不足しています。2つ以上の指定が必須。
		echo.
		goto :File_Bond01
	)
rem	echo ファイル指定終了。
	goto :Bond
)

rem 指定ファイルの存在有無確認処理部
if not exist "%In_File%" (
    echo 指定されたファイル "%In_File%" は存在しません。
    echo.
	goto :File_Bond01
)

rem ベースファイル設定部
if %Op_Num% EQU 0 set In_File01=%In_File%

rem 結合用ファイル追記処理部
set Target_Files=%Target_Files% %In_File%
set /A Op_Num +=1
rem echo 入力ファイル名は %In_File% です。
rem echo 指定されたファイル群は %Target_Files% です。
rem echo ループ回数は %Op_Num% です。
rem echo.
goto :File_Bond01


:Bond
rem ファイル結合処理部
rem echo.
rem echo ベースファイルは %In_File01% です。
rem echo 指定されたファイル群は %Target_Files% です。
rem echo 指定されたファイル群を結合します。
rem echo.

rem pause
qpdf.exe %In_File01% --pages %Target_Files% -- output.pdf

exit /b


:Page_Bind
echo 4番を選択
exit /b
