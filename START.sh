#!/bin/bash
clear
echo ""
echo "  ███████╗██╗ ██████╗ ███╗   ███╗ █████╗"
echo "  ██╔════╝██║██╔════╝ ████╗ ████║██╔══██╗"
echo "  ███████╗██║██║  ███╗██╔████╔██║███████║"
echo "  ╚════██║██║██║   ██║██║╚██╔╝██║██╔══██║"
echo "  ███████║██║╚██████╔╝██║ ╚═╝ ██║██║  ██║"
echo "  ╚══════╝╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝"
echo ""
echo "  جاري الإعداد التلقائي..."
echo ""

if ! command -v node &> /dev/null; then
    echo "[خطأ] Node.js غير مثبت! حمّله من: https://nodejs.org"
    exit 1
fi

if ! command -v pnpm &> /dev/null; then
    echo "جاري تثبيت pnpm..."
    npm install -g pnpm
fi

if [ ! -f "artifacts/api-server/.env" ]; then
    echo "جاري إنشاء ملف .env..."
    cat > artifacts/api-server/.env << 'EOF'
PORT=8080
JWT_SECRET=ustad-riyad-2026-secret-key
GEMINI_API_KEY=ضع_مفتاحك_هنا
GEMINI_API_KEY_2=
GEMINI_API_KEY_3=
OPENROUTER_API_KEY=ضع_مفتاحك_هنا
EOF
    echo ""
    echo "[مهم] افتح الملف artifacts/api-server/.env وضع مفاتيح API"
    echo ""
fi

echo "جاري تثبيت الحزم (قد يستغرق دقيقتين)..."
pnpm install --no-frozen-lockfile

echo ""
echo "  تم الإعداد بنجاح!"
echo ""
echo "  الترمينال 1 (الخادم):"
echo "    pnpm --filter @workspace/api-server run dev"
echo ""
echo "  الترمينال 2 (الواجهة):"
echo "    pnpm --filter @workspace/sheikh-dhaki run dev"
echo ""
echo "  ثم افتح المتصفح على: http://localhost:5173"
echo ""
