@ECHO off

REM 引数指定してバッチファイルを起動した場合の判定
SET filename=%1
IF NOT "%filename%"=="" GOTO :MAIN_BODY 


ECHO  ==使い方==
ECHO    1) エクスプローラ上でで目的のpdfファイルを選択する。
ECHO    2)右クリックして「送る」を開く。
ECHO    3)qpdf_PW_apply.batを選択する。
ECHO  これにより目的のpdfファイルにパスワードが設されるけど、手入力でもファイル指定可能。
ECHO.


:INPUT_LOOP
REM ユーザーにファイル名の入力を促す
SET Op_Num=
SET /P filename="パスワード設定するpdfファイル名を入力してください: "

REM 入力されたファイル名が存在するか確認する
IF EXIST "%filename%" (
    GOTO :MAIN_BODY
) ELSE (
    ECHO 指定されたファイル "%filename%" は存在しません。
	SET Op_Num=1
)

REM 処理を続けるか確認する
SET filename=
ECHO.
CHOICE /C YN /M "別のファイルを確認しますか？ (Y/N)"
IF ERRORLEVEL 2 GOTO END
IF ERRORLEVEL 1 GOTO INPUT_LOOP



REM qpdf.exeを用いたパスワード設定処理部
:MAIN_BODY
REM パスワード指定をユーザに促す。
ECHO.
SET Op_Num=2
SET /P Pword="パスワードを入力してください: "

REM パスワードが入力されたかの確認
IF "%Pword%"=="" (
	ECHO.
	ECHO パスワードが無入力です。設定してください。
	CHOICE /C YN /M "それとも処理を中断しますか？ (Y/N)"
	IF ERRORLEVEL 2 GOTO :MAIN_BODY
	IF ERRORLEVEL 1 GOTO :END
)

REM パスワード設定処理
qpdf.exe --encrypt %PWord% %PWord% 256 --print=full -- %filename% --replace-input
REM ECHO 設定されたPW: %PWord%

ECHO.
CHOICE /C YN /M "続けて別のファイルにパスワード設定しますか？ (Y/N)"
ECHO.
SET Op_Num=3
SET filename=
SET PWord=
IF ERRORLEVEL 2 GOTO END
IF ERRORLEVEL 1 GOTO INPUT_LOOP





REM バッチ処理終了
:END
IF "%Op_Num%"=="1" (
	SET Show_str="pdfファイルの指定がなされなかったか、ファイルが存在しませんでした。"
)

IF "%Op_Num%"=="2" (
	SET Show_str="中断しました。
)

IF "%Op_Num%"=="3" (
	SET Show_str="やり遂げました。"
)

ECHO.
ECHO +-------------------------------------------------------+
ECHO  %Show_str%
ECHO  終了します。
ECHO +-------------------------------------------------------+
rem PAUSE
ECHO.
EXIT /b