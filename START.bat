@echo off
chcp 65001 >nul
title سِيغْمَا Σ — جاري التشغيل...
color 0B

echo.
echo   *** سِيغْمَا ***
echo.

:: ===============================
:: البحث عن Node.js في المسارات الشائعة
:: ===============================
where node >nul 2>&1
if %errorlevel% equ 0 goto node_found

:: البحث اليدوي في مسارات التثبيت الشائعة
if exist "C:\Program Files\nodejs\node.exe" (
    set "PATH=C:\Program Files\nodejs;%PATH%"
    goto node_found
)
if exist "C:\Program Files (x86)\nodejs\node.exe" (
    set "PATH=C:\Program Files (x86)\nodejs;%PATH%"
    goto node_found
)
if exist "%LOCALAPPDATA%\Programs\nodejs\node.exe" (
    set "PATH=%LOCALAPPDATA%\Programs\nodejs;%PATH%"
    goto node_found
)
if exist "%APPDATA%\nvm\nvm.exe" (
    for /f "delims=" %%i in ('"%APPDATA%\nvm\nvm.exe" current 2^>nul') do (
        set "PATH=%APPDATA%\nvm\%%i;%PATH%"
    )
    goto node_found
)

:: Node.js غير موجود فعلاً
color 0C
echo.
echo  [خطأ] Node.js غير مثبت على جهازك
echo.
echo  اتبع هذه الخطوات:
echo  1. افتح: https://nodejs.org
echo  2. حمّل النسخة LTS وثبّتها
echo  3. اعد تشغيل الحاسوب
echo  4. شغّل هذا الملف مجدداً
echo.
start https://nodejs.org
pause
exit /b 1

:node_found
echo  Node.js موجود ✓

:: ===============================
:: تثبيت pnpm
:: ===============================
where pnpm >nul 2>&1
if %errorlevel% neq 0 (
    echo  جاري تثبيت pnpm...
    call npm install -g pnpm
    set "PATH=%APPDATA%\npm;%PATH%"
)
echo  pnpm موجود ✓

:: ===============================
:: إصلاح pnpm-workspace.yaml للويندوز
:: ===============================
echo  جاري تجهيز الإعدادات لنظام Windows...
copy /y pnpm-workspace.yaml pnpm-workspace.yaml.bak >nul 2>&1

powershell -NoProfile -ExecutionPolicy Bypass -Command "$c = Get-Content 'pnpm-workspace.yaml' -Raw; $i = $c.IndexOf('overrides:'); if ($i -ge 0) { $c = $c.Substring(0, $i) }; $c.TrimEnd() | Set-Content 'pnpm-workspace.yaml' -Encoding UTF8"

echo  pnpm-workspace.yaml مُصلح ✓

:: ===============================
:: إنشاء .env
:: ===============================
if not exist "artifacts\api-server\.env" (
    echo  جاري إنشاء ملف الإعدادات...
    (
        echo PORT=8080
        echo JWT_SECRET=ustad-riyad-2026-secret-key
        echo GEMINI_API_KEY=ضع_مفتاحك_هنا
        echo OPENROUTER_API_KEY=ضع_مفتاحك_هنا
    ) > "artifacts\api-server\.env"
)
echo  ملف .env موجود ✓

:: ===============================
:: تثبيت الحزم
:: ===============================
if not exist "node_modules" (
    echo.
    echo  جاري تثبيت الحزم - انتظر 2-3 دقائق...
    echo.
    call pnpm install --no-frozen-lockfile
    if %errorlevel% neq 0 (
        color 0C
        echo.
        echo  [خطأ] فشل التثبيت
        copy /y pnpm-workspace.yaml.bak pnpm-workspace.yaml >nul 2>&1
        pause
        exit /b 1
    )
) else (
    echo  الحزم مثبتة مسبقاً ✓
)

:: استعادة workspace الأصلي
copy /y pnpm-workspace.yaml.bak pnpm-workspace.yaml >nul 2>&1

:: ===============================
:: تشغيل الخادم الخلفي
:: ===============================
echo.
echo  جاري تشغيل الخادم الخلفي...
start "الخادم - لا تغلق" cmd /k "color 0A && title الخادم - لا تغلق && pnpm --filter @workspace/api-server run dev"
timeout /t 4 /nobreak >nul

:: ===============================
:: تشغيل الواجهة
:: ===============================
echo  جاري تشغيل التطبيق...
start "التطبيق - لا تغلق" cmd /k "color 0B && title التطبيق - لا تغلق && pnpm --filter @workspace/sheikh-dhaki run dev"
timeout /t 6 /nobreak >nul

:: ===============================
:: فتح المتصفح
:: ===============================
start http://localhost:5173

echo.
echo  =========================================
echo   التطبيق يعمل على: http://localhost:5173
echo  =========================================
echo.
pause
