@echo off

rem 機能概要: --pagesオプションを用いた各種機能選択用バッチファイル"qpdf_pages.bat"から選択肢[2]を選定したときにコールされるサブモジュール。
rem 選択肢[2]: ページ削除 → 対象ファイルから不要なページを削除し、別ファイルに出力する
rem (注: このバッチファイル単体での使用は想定していない)


rem 初期化
set In_File=
set Out_File=
set SEL_Pages=
set SEL_Pages_Arr=
set SEL_Pages_Arr_x=
set Op_Num=0


echo.
echo ==ページ削除のやり方==
echo 対象となるpdfファイルを指定する。
echo 出力ファイル名を設定する。
echo 削除するページ(個別のページ、ページ範囲)を指定する。
echo ページ指定が終了したらEnterキィを押下する。
echo.

:INPUT_LOOP
rem 対象ファイル指定処理部
set /p In_File="ページ抽出するファイルを指定してください:  "

rem 指定ファイルの存在有無確認処理部
if not exist "%In_File%" (
	echo.
    echo 指定されたファイル "%In_File%" は存在しません。
    choice /C YN /M "終了しますか？ (Y/N)"
    echo.
	if ERRORLEVEL 2 goto :INPUT_LOOP
	if ERRORLEVEL 1 goto :END
)


:SEL_OUTPUT_FILE
rem 書き出しファイル指定処理部

set /p Out_File="出力ファイル名(拡張子不要)を指定してください:  "

rem 指定ファイルの存在有無確認処理部
set Out_File=%Out_File%.pdf
rem echo %Out_File%
rem pause
if not "%Out_File%"=="" (
	if exist "%Out_File%" (
		echo.
		echo 指定されたファイル "%Out_File%" は存在します。
		choice /C 123 /M "(1: 上書き、2: 別ファイル指定、3: 終了)から選択してください"
		echo.
		if ERRORLEVEL 3 goto :END
		if ERRORLEVEL 2 goto :SEL_OUTPUT_FILE
		if ERRORLEVEL 1 goto :PAGE_SELECTION
	)
) 
if "%Out_File%"==".pdf" (
	echo.
	echo 出力ファイルが指定されていません。
	choice /C YN /M "終了しますか? （Y/N)"
	echo.
	if ERRORLEVEL 2 goto :SEL_OUTPUT_FILE
	if ERRORLEVEL 1 goto :END
)



:PAGE_SELECTION
rem 削除ページ選択処理部
set /p SEL_Pages="削除するページ範囲(例: 1,2,3,5-10)を指定してください:  "

rem ページ指定終了判定処理部
if "%SEL_Pages%"=="" (
	if %Op_Num% LSS 1 (
		echo.
		echo 指定ページ数が不足しています。1ページ以上の指定が必須。
		echo.
		goto :PAGE_SELECTION
	)
rem	echo ページ指定終了。
	goto :DELETION
)

rem 選択ページ追記処理部
if %Op_Num% EQU 0 (
	set SEL_Pages_Arr=%SEL_Pages%
	set SEL_Pages_Arr_x=x%SEL_Pages%
) else (
	set SEL_Pages_Arr=%SEL_Pages_Arr%,%SEL_Pages%
	set SEL_Pages_Arr_x=%SEL_Pages_Arr_x%,x%SEL_Pages%
)
set /A Op_Num +=1
rem set SEL_Pages_Arr=%SEL_Pages_Arr% %SEL_Pages%
set SEL_Pages=
rem echo 入力ファイル名は %In_File% です。
rem echo 指定されたページ範囲は %SEL_Pages_Arr% です。
rem echo ループ回数は %Op_Num% です。
rem echo.
goto :PAGE_SELECTION


:DELETION
rem ページ削除・出力処理部
rem echo.
rem echo 入力ファイル名は %In_File% です。
rem echo 指定されたページ範囲は %SEL_Pages_Arr% です。
rem echo 指定されたページ範囲を削除して %Out_File% に出力します。
rem echo.
rem pause
qpdf.exe %In_File% --pages . 1-z,%SEL_Pages_Arr_x% -- %Out_File%


:END
rem 終了処理部
echo.
echo +-------------------------------------------------------+
echo  指定されたページ %SEL_Pages_Arr% を削除して %Out_File% に出力しました。
echo  呼出し元に戻ります。
echo +-------------------------------------------------------+
rem PAUSE
echo.

exit /b



