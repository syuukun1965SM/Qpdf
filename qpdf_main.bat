@echo off
rem chcp 65001

rem このバッチファイルはqpdfの各機能別バッチファイルを呼び出すためのHubとして機能させる。
rem 各機能に紐づけした番号を表示し、入力数値により紐づけした機能別バッチファイルに処理を分岐させる。
rem 分岐先処理が終了したら本バッチファイルにpromptを戻して上記機能選択待ちとする。


:INPUT_LOOP
rem 実施処理選択部
echo.
echo  ==実施する処理の選択==
echo    1) 暗号化: ユーザによる指定pdfファイルを暗号化(パスワード付加)する。
echo    2) 復号化: ユーザによる指定pdfファイルを復号化(パスワード解除)する。
echo    3) ファイル回転: ユーザによる指定pdfファイル全体を指定した角度だけ回転する。
echo    4) ページ抽出・削除・結合他: ユーザによる指定ファイル内のページに関連した各種処理を実行する。
echo    5) 処理終了。
echo.

choice /C 12345 /M "処理を(1:暗号化、2:復号化、3:ファイル回転、4:ページ処理、５:終了)から選択してください"
echo "%ERRORLEVEL%"
PAUSE

if ERRORLEVEL 5 goto :END

if ERRORLEVEL 4 (
	call %~dp0qpdf_pages.bat
)
if ERRORLEVEL 3 (
	call %~dp0qpdf_rotate.bat
)
if ERRORLEVEL 2 (
	call %~dp0qpdf_decrypt.bat
)
if ERRORLEVEL 1 (
	call %~dp0qpdf_encrypt.bat
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
echo  終了します。
echo +-------------------------------------------------------+
echo.

exit /b

