@echo off

rem 機能概要: --pagesオプションを用いた各種機能選択用バッチファイル"qpdf_pages.bat"から選択肢[3]を選定したときにコールされるサブモジュール。
rem 選択肢[3]: ファイル結合 → 複数ファイルを結合し、別ファイルに出力する
rem (注: このバッチファイル単体での使用は想定していない)

:File_Bond
rem 結合対象ファイル指定処理部

rem 初期化
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

