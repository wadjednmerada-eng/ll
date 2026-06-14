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
echo   جاري تشغيل سِيغْمَا...
echo.

:: ===============================
:: تحقق من Node.js
:: ===============================
where node >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo  [خطأ] Node.js غير مثبت على جهازك
    echo.
    echo  1. افتح هذا الرابط: https://nodejs.org
    echo  2. حمّل النسخة LTS
    echo  3. ثبّتها ثم شغّل هذا الملف مجدداً
    echo.
    start https://nodejs.org
    pause
    exit /b 1
)

:: ===============================
:: تثبيت pnpm إذا غير موجود
:: ===============================
where pnpm >nul 2>&1
if %errorlevel% neq 0 (
    echo  [1/3] جاري تثبيت pnpm...
    call npm install -g pnpm >nul 2>&1
)

:: ===============================
:: إنشاء .env إذا غير موجود
:: ===============================
if not exist "artifacts\api-server\.env" (
    echo  [2/3] جاري إنشاء ملف الإعدادات...
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
    echo  [3/3] جاري تثبيت الحزم ^(دقيقة واحدة^)...
    call pnpm install --no-frozen-lockfile
    if %errorlevel% neq 0 (
        color 0C
        echo  [خطأ] فشل التثبيت
        pause
        exit /b 1
    )
) else (
    echo  [3/3] الحزم مثبتة مسبقاً ✓
)

:: ===============================
:: تشغيل الخادم الخلفي
:: ===============================
echo.
echo  جاري تشغيل الخادم...
start "سِيغْمَا — الخادم" cmd /k "title سِيغْمَا - الخادم ^(لا تغلق^) && color 0A && pnpm --filter @workspace/api-server run dev"

timeout /t 3 /nobreak >nul

:: ===============================
:: تشغيل الواجهة الأمامية
:: ===============================
echo  جاري تشغيل التطبيق...
start "سِيغْمَا — التطبيق" cmd /k "title سِيغْمَا - التطبيق ^(لا تغلق^) && color 0B && pnpm --filter @workspace/sheikh-dhaki run dev"

timeout /t 5 /nobreak >nul

:: ===============================
:: فتح المتصفح تلقائياً
:: ===============================
echo  فتح التطبيق في المتصفح...
start http://localhost:5173

echo.
echo  ════════════════════════════════════════
echo   التطبيق يعمل على: http://localhost:5173
echo   عدّل الملفات في VS Code وستظهر التغييرات
echo   فوراً في المتصفح بدون إعادة تشغيل!
echo  ════════════════════════════════════════
echo.
echo  لإيقاف التطبيق: اغلق النافذتين الخضراء والزرقاء
echo.
pause
