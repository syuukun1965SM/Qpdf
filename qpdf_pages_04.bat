@echo off

rem 機能概要: --pagesオプションを用いた各種機能選択用バッチファイル"qpdf_pages.bat"から選択肢[4]を選定したときにコールされるサブモジュール。
rem 選択肢[4]: 異なるファイル内の指定ページの抽出と同時にページ結合 → 各々のファイルで指定した必要ページを結合し、別ファイルに出力する
rem (注: このバッチファイル単体での使用は想定していない)


:File_Bond
rem 結合対象ファイル指定処理部

rem 初期化
set In_File01=
set FPages=
set Op_Num_F=0
set Op_Num_P=0

rem echo 4番を選択
echo.
echo ==やり方==
echo ファイルとファイルの結合なのでpdfファイルが最低二つは必須。
echo ファイルを一つ指定したらエンタキィを押下。
echo 指定ファイル内の抽出するページ(個別のページ、ページ範囲)を指定する。
echo ページ指定が終了したらEnterキィを押下する。
echo 上記を必要ファイル分だけ繰り返す。
echo 最後に出力ファイル名を設定する。
echo.


:File_Bond01
set In_File=
echo.
set /p In_File="ファイルを指定してください(終了時はEnterのみ):  "

rem ファイル指定有無判定・終了判定処理部
if "%In_File%"=="" (
	if %Op_Num_F% LSS 2 (
		echo 指定ファイル数が不足しています。2つ以上の指定が必須。
		echo.
		goto :File_Bond01
	) else (
        goto :SEL_OUTPUT_FILE
    )
) else (
    if not exist "%In_File%" (
        echo 指定されたファイル "%In_File%" は存在しません。
        echo.
	    goto :File_Bond01
    )
)


rem ベースファイル設定部
if %Op_Num_F% EQU 0 set In_File01=%In_File%
set /A Op_Num_F +=1



:PAGE_SELECTION
rem 抽出ページ選択処理部
set /p SEL_Pages="抽出するページ範囲(例: 1,2,3,5-10)を指定してください:  "

rem ページ指定終了判定処理部
if "%SEL_Pages%"=="" (
	if %Op_Num_P% LSS 1 (
		echo.
		echo 指定ページ数が不足しています。1ページ以上の指定が必須。
		echo.
		goto :PAGE_SELECTION
	) else (
		echo.
		echo ページ指定完了。その他のファイルのページ指定を行います。
        echo.
        goto :File_Pages_Combine
    )
)

rem 選択ページ追記処理部
if %Op_Num_P% EQU 0 (
	set SEL_Pages_Arr=%SEL_Pages%
) else (
	set SEL_Pages_Arr=%SEL_Pages_Arr%,%SEL_Pages%
)
set /A Op_Num_P +=1
set SEL_Pages=
goto :PAGE_SELECTION



:File_Pages_Combine
rem 指定ファイルと同ファイル内の指定ページの組み合わせ処理
set FPages=%FPages% %In_File% %SEL_Pages_Arr%
set In_File=
set SEL_Pages_Arr=
set Op_Num_P=0
goto :File_Bond01



:SEL_OUTPUT_FILE
rem 書き出しファイル指定処理部
echo.
set /p Out_File="出力ファイル名(拡張子不要)を指定してください:  "

rem 指定ファイルの存在有無確認処理部
set Out_File=%Out_File%.pdf
if not "%Out_File%"=="" (
	if exist "%Out_File%" (
		echo.
		echo 指定されたファイル "%Out_File%" は存在します。
		choice /C 123 /M "(1: 上書き、2: 別ファイル指定、3: 終了)から選択してください"
		echo.
		if ERRORLEVEL 3 goto :END
		if ERRORLEVEL 2 goto :SEL_OUTPUT_FILE
		if ERRORLEVEL 1 goto :EXTRACTION
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


:EXTRACTION
rem 抽出ページ結合・出力合処理部
qpdf.exe %In_File01% --pages %FPages% -- %Out_File%



:END
rem 終了処理部
echo.
echo +-------------------------------------------------------+
echo  指定されたファイルとページ %FPages% を %Out_File% に出力しました。
echo  呼出し元に戻ります。
echo +-------------------------------------------------------+
echo.

exit /b
