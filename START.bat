@echo off
chcp 65001 >nul
title سِيغْمَا Σ — جاري التشغيل...
color 0B

echo.
echo   ███████╗██╗ ██████╗ ███╗   ███╗ █████╗
echo   ██╔════╝██║██╔════╝ ████╗ ████║██╔══██╗
echo   ███████╗██║██║  ███╗██╔████╔██║███████║
echo   ╚════██║██║██║   ██║██║╚██╔╝██║██╔══██║
echo   ███████║██║╚██████╔╝██║ ╚═╝ ██║██║  ██║
echo   ╚══════╝╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝
echo.

:: ===============================
:: تحقق من Node.js
:: ===============================
where node >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo  [خطأ] Node.js غير مثبت
    echo  حمّله من: https://nodejs.org  ثم شغّل هذا الملف مجدداً
    start https://nodejs.org
    pause
    exit /b 1
)

:: ===============================
:: تثبيت pnpm
:: ===============================
where pnpm >nul 2>&1
if %errorlevel% neq 0 (
    echo  جاري تثبيت pnpm...
    call npm install -g pnpm >nul 2>&1
)

:: ===============================
:: إصلاح pnpm-workspace.yaml للويندوز
:: ===============================
echo  جاري تجهيز الإعدادات لنظام Windows...
copy /y pnpm-workspace.yaml pnpm-workspace.yaml.bak >nul 2>&1

powershell -NoProfile -Command ^
  "$content = Get-Content 'pnpm-workspace.yaml' -Raw;" ^
  "$fixed = $content -replace '(?ms)^overrides:.*$', '';" ^
  "$fixed | Set-Content 'pnpm-workspace.yaml' -Encoding UTF8"

:: ===============================
:: إنشاء .env
:: ===============================
if not exist "artifacts\api-server\.env" (
    echo  جاري إنشاء ملف الإعدادات...
    (
        echo PORT=8080
        echo JWT_SECRET=ustad-riyad-2026-secret-key
        echo GEMINI_API_KEY=ضع_مفتاحك_هنا
        echo GEMINI_API_KEY_2=
        echo GEMINI_API_KEY_3=
        echo GEMINI_API_KEY_4=
        echo GEMINI_API_KEY_5=
        echo OPENROUTER_API_KEY=ضع_مفتاحك_هنا
    ) > "artifacts\api-server\.env"
)

:: ===============================
:: تثبيت الحزم
:: ===============================
if not exist "node_modules" (
    echo  جاري تثبيت الحزم - انتظر دقيقة...
    call pnpm install --no-frozen-lockfile
    if %errorlevel% neq 0 (
        color 0C
        echo.
        echo  [خطأ] فشل التثبيت - جاري استعادة الملف الأصلي
        copy /y pnpm-workspace.yaml.bak pnpm-workspace.yaml >nul 2>&1
        pause
        exit /b 1
    )
) else (
    echo  الحزم مثبتة مسبقاً ✓
)

:: استعادة الملف الأصلي
copy /y pnpm-workspace.yaml.bak pnpm-workspace.yaml >nul 2>&1

:: ===============================
:: تشغيل الخادم الخلفي
:: ===============================
echo  تشغيل الخادم...
start "سِيغْمَا — الخادم" cmd /k "title الخادم - لا تغلق && color 0A && pnpm --filter @workspace/api-server run dev"
timeout /t 4 /nobreak >nul

:: ===============================
:: تشغيل الواجهة
:: ===============================
echo  تشغيل التطبيق...
start "سِيغْمَا — التطبيق" cmd /k "title التطبيق - لا تغلق && color 0B && pnpm --filter @workspace/sheikh-dhaki run dev"
timeout /t 5 /nobreak >nul

:: ===============================
:: فتح المتصفح
:: ===============================
start http://localhost:5173

echo.
echo  ════════════════════════════════════════════
echo   التطبيق يعمل على: http://localhost:5173
echo   عدّل الملفات في VS Code وستظهر التغييرات
echo   فوراً في المتصفح بدون إعادة تشغيل!
echo  ════════════════════════════════════════════
echo.
pause
