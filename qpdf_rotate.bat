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
echo    1) ページを回転させたいファイル名を手入力する。
echo    2) 回転させたいページを指定する (無指定時はファイル全体を対象にする)。
echo    3) 回転方向と角度を指定する (無指定時は時計回りに90度回転する)。
echo    4) 出力ファイル名を指定する (無指定時は上書き保存する)。
echo  これにより指定したpdfファイルからファイル全体、または指定ページを回転させた状態で保存される。
echo.


rem ユーザによる対象pdfファイル名入力要求処理部
:INPUT_LOOP
set Op_Num=
set /P filename="回転させるpdfファイル名を入力してください: "


rem 指定ファイルの存在有無確認処理部
:EXIST_CHECK
if not exist "%filename%" (
    echo 指定されたファイル "%filename%" は存在しません。
	set Op_Num=1
    goto :CONTINUATION_CHECK
)


rem ユーザによる回転対象(ファイル全体・個別のページ)指定処理部
:SELECTION
set SEL_Pages=

echo.
echo ==指定方法==
echo    1) ファイル全体の回転指定はEnterキィを押下するだけ。
echo    2) 連続ページ指定の場合は開始ページと終了ページをハイホンで記述: 例) 5-9
echo    3) 離散ページ指定の場合は対象ページ毎にカンマで区切って記述: 例) 1,5,9
echo    4) 連続ページと離散ページ指定の場合は上記2項、3項の複合形: 例) 1,3,5-9
echo    5) 全頁を範囲指定して特定ページを除外する方法: 例) 1-z,x5,6 や 1-z,x7-9
echo 注) 存在しないページを指定するとエラーになります。
echo.

set /p SEL_Pages="ファイル全体、またはページを指定してください :  "
if "%SEL_Pages%"=="" set SEL_Pages%=1-z



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
choice /C YN /M "別ファイルを指定・回転処理しますか？ (Y/N)"
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