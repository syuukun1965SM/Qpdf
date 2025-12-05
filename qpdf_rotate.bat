@echo off

rem 機能概要: 引数またはbat起動後のファイル指定(手入力)にる指定ファイルの全体、または指定ページを回転して保存するバッチファイル

rem 引数に対象ファイルを指定するのもOK
rem 対象pdfファイルが設定されたらファイル自体の有無確認を行う
rem 対象pdfファイルが存在したらファイル全体か対象ページのみかの指定を仰ぐ (ページ無指定だったらファイル全体を対象に設定)
rem 回転方向と角度指定を仰ぐ (回転方向無指定だったら時計回りに90度回転)
rem 出力ファイル名入力を仰ぐ (出力ファイル名無入力だったら上書き保存)
rem 処理終了したら処理の継続・終了の判断を仰ぐ


rem 引数指定してバッチファイルを起動した場合の判定
set filename=%1
if not "%filename%"=="" goto :EXIST_CHECK 

rem 引数なしで起動した場合の簡易操作方法表示
echo.
echo  ==使い方==
echo    1)パスワードを解除したいファイル名を手入力する。
echo    2)現在設定されているパスワードを入力する。
echo  これにより指定したpdfファイルからパスワードが削除される。
echo.


rem ユーザによる対象pdfファイル名入力要求処理部
:INPUT_LOOP
set Op_Num=
set /P filename="パスワード解除するpdfファイル名を入力してください: "


rem 指定ファイルの存在有無確認処理部
:EXIST_CHECK
if not exist "%filename%" (
    echo 指定されたファイル "%filename%" は存在しません。
	set Op_Num=1
    goto :CONTINUATION_CHECK
)


rem qpdf.exeを用いたパスワード設定状況判断処理部
rem for~do 部はCopilot提案の処理。qpdfが吐き出すメッセージ中に”not encrypted"があれば暗号化されていると判断する
rem 因みに、qpdfの判定出力は五月蠅くなるので非表示(>nul)に設定
:ENCRYPTION_CHECK

set Encrypt_Status=

for /f "tokens=*" %%A in ('qpdf.exe --show-encryption "%filename%"') do (
    echo %%A | find /i "not encrypted" >nul && echo 指定されたファイル "%filename%" は暗号化されていません。 && set "Encrypt_Status=1" && set "Op_Num=2" && goto :CONTINUATION_CHECK
)


rem qpdf.exeを用いたパスワード解除処理部
rem ユーザによるパスワード入力要求
:MAIN_BODY
echo.
set Op_Num=3
set /P Pword="パスワードを入力してください: "

rem パスワードが入力されたかの確認
if "%Pword%"=="" (
	echo.
	echo パスワードが無入力です。設定してください。
	choice /C YN /M "それとも処理を中断しますか？ (Y/N)"
	if ERRORLEVEL 2 goto :MAIN_BODY
	if ERRORLEVEL 1 goto :END
)

rem パスワード解除処理
qpdf.exe --decrypt --password=%PWord% %filename% --replace-input >nul 2>&1
if "%ERRORLEVEL%"=="2" (
	echo.
	echo 入力されたパスワードが正しくありません。
	goto :CONTINUATION_CHECK
	set Op_Num=3
)
set Op_Num=4
set PWord=


rem 処理継続の意思確認部
:CONTINUATION_CHECK
set filename=
echo.
choice /C YN /M "別ファイルを指定・復号化処理しますか？ (Y/N)"
echo.
if ERRORLEVEL 2 goto :END
if ERRORLEVEL 1 goto :INPUT_LOOP


rem クロージング処理部
:END
if %Op_Num% EQU 1 (
	set Show_str="pdfファイルの指定がなされなかったか、ファイルが存在しませんでした。"
)

if "%Op_Num%"=="2" (
	set Show_str="指定ファイルは暗号化されていませんでした。中断しました。"
)

if "%Op_Num%"=="3" (
	set Show_str="復号化処理を中断しました。"
)

if "%Op_Num%"=="4" (
	set Show_str="やり遂げました。"
)
echo.
echo +-------------------------------------------------------+
echo  %Show_str%
echo  終了します。
echo +-------------------------------------------------------+
rem PAUSE
echo.
EXIT /b