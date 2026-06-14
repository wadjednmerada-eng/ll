@echo off
chcp 65001 >nul
echo.
echo  ███████╗██╗ ██████╗ ███╗   ███╗ █████╗
echo  ██╔════╝██║██╔════╝ ████╗ ████║██╔══██╗
echo  ███████╗██║██║  ███╗██╔████╔██║███████║
echo  ╚════██║██║██║   ██║██║╚██╔╝██║██╔══██║
echo  ███████║██║╚██████╔╝██║ ╚═╝ ██║██║  ██║
echo  ╚══════╝╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝
echo.
echo  جاري الإعداد التلقائي...
echo.

:: التحقق من Node.js
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [خطأ] Node.js غير مثبت!
    echo حمّله من: https://nodejs.org
    pause
    exit /b 1
)

:: التحقق من pnpm
where pnpm >nul 2>&1
if %errorlevel% neq 0 (
    echo جاري تثبيت pnpm...
    npm install -g pnpm
)

:: إنشاء ملف .env إذا لم يكن موجوداً
if not exist "artifacts\api-server\.env" (
    echo جاري إنشاء ملف .env...
    copy "artifacts\api-server\.env.example" "artifacts\api-server\.env" >nul 2>&1
    if not exist "artifacts\api-server\.env" (
        echo PORT=8080 > "artifacts\api-server\.env"
        echo JWT_SECRET=ustad-riyad-2026-secret-key >> "artifacts\api-server\.env"
        echo GEMINI_API_KEY=ضع_مفتاحك_هنا >> "artifacts\api-server\.env"
        echo OPENROUTER_API_KEY=ضع_مفتاحك_هنا >> "artifacts\api-server\.env"
    )
    echo.
    echo [مهم] افتح الملف artifacts\api-server\.env وضع مفاتيح API
    echo.
)

:: تثبيت الحزم
echo جاري تثبيت الحزم (قد يستغرق دقيقتين)...
pnpm install --no-frozen-lockfile

if %errorlevel% neq 0 (
    echo [خطأ] فشل تثبيت الحزم
    pause
    exit /b 1
)

echo.
echo  تم الإعداد بنجاح!
echo  لتشغيل المشروع افتح ترمينالين:
echo.
echo  الترمينال 1 (الخادم):
echo    pnpm --filter @workspace/api-server run dev
echo.
echo  الترمينال 2 (الواجهة):
echo    pnpm --filter @workspace/sheikh-dhaki run dev
echo.
echo  ثم افتح المتصفح على: http://localhost:5173
echo.
pause
