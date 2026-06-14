#!/bin/bash
# ══════════════════════════════════════════════════════════════════
#  سِيغْمَا Σ — إعداد بيئة التطوير المحلية (VS Code / Linux / Mac)
# ══════════════════════════════════════════════════════════════════
set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}${GREEN}"
echo "  ███████╗██╗ ██████╗ ███╗   ███╗ █████╗ "
echo "  ██╔════╝██║██╔════╝ ████╗ ████║██╔══██╗"
echo "  ███████╗██║██║  ███╗██╔████╔██║███████║"
echo "  ╚════██║██║██║   ██║██║╚██╔╝██║██╔══██║"
echo "  ███████║██║╚██████╔╝██║ ╚═╝ ██║██║  ██║"
echo "  ╚══════╝╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝"
echo -e "${RESET}"
echo -e "${BOLD}  مصحح رياضيات البكالوريا الجزائرية — إعداد VS Code${RESET}"
echo ""

# ── 1. التحقق من Node.js ──────────────────────────────────────────
echo -e "${YELLOW}[1/6] التحقق من Node.js...${RESET}"
if ! command -v node &> /dev/null; then
  echo -e "${RED}✗ Node.js غير مثبت. ثبّته من: https://nodejs.org (v20+)${RESET}"
  exit 1
fi
NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VER" -lt 20 ]; then
  echo -e "${RED}✗ يلزم Node.js v20 أو أحدث. الإصدار الحالي: $(node -v)${RESET}"
  exit 1
fi
echo -e "${GREEN}✓ Node.js $(node -v)${RESET}"

# ── 2. التحقق من pnpm ────────────────────────────────────────────
echo -e "${YELLOW}[2/6] التحقق من pnpm...${RESET}"
if ! command -v pnpm &> /dev/null; then
  echo "  pnpm غير مثبت — جاري التثبيت..."
  npm install -g pnpm@latest
fi
echo -e "${GREEN}✓ pnpm $(pnpm -v)${RESET}"

# ── 3. تعديل pnpm-workspace.yaml للتوافق مع Mac/Windows ──────────
echo -e "${YELLOW}[3/6] تعديل pnpm-workspace.yaml للتوافق المحلي...${RESET}"

# إنشاء نسخة محلية من pnpm-workspace.yaml بدون قيود المنصة
cat > pnpm-workspace.yaml << 'WORKSPACE_EOF'
minimumReleaseAge: 1440

minimumReleaseAgeExclude:
  - '@replit/*'
  - stripe-replit-sync

packages:
  - artifacts/*
  - lib/*
  - lib/integrations/*
  - scripts

catalog:
  '@replit/vite-plugin-cartographer': ^0.5.1
  '@replit/vite-plugin-dev-banner': ^0.1.1
  '@replit/vite-plugin-runtime-error-modal': ^0.0.6
  '@tailwindcss/vite': ^4.1.14
  '@tanstack/react-query': ^5.90.21
  '@types/node': ^25.3.3
  '@types/react': ^19.2.0
  '@types/react-dom': ^19.2.0
  '@vitejs/plugin-react': ^5.0.4
  class-variance-authority: ^0.7.1
  clsx: ^2.1.1
  drizzle-orm: ^0.45.1
  framer-motion: ^12.23.24
  lucide-react: ^0.545.0
  react: 19.1.0
  react-dom: 19.1.0
  tailwind-merge: ^3.3.1
  tailwindcss: ^4.1.14
  tsx: ^4.21.0
  vite: ^7.3.0
  zod: ^3.25.76

autoInstallPeers: false
WORKSPACE_EOF

echo -e "${GREEN}✓ pnpm-workspace.yaml محدّث${RESET}"

# ── 4. إنشاء ملف .env ─────────────────────────────────────────────
echo -e "${YELLOW}[4/6] إنشاء ملف .env...${RESET}"

if [ -f "artifacts/api-server/.env" ]; then
  echo -e "${YELLOW}  ملف .env موجود مسبقاً — لن يُستبدل${RESET}"
else
  cat > artifacts/api-server/.env << 'ENV_EOF'
# ══════════════════════════════════════════════════════
#  سِيغْمَا Σ — متغيرات البيئة
#  عدّل هذا الملف بمفاتيح API الحقيقية الخاصة بك
# ══════════════════════════════════════════════════════

# ── المنفذ ───────────────────────────────────────────
PORT=8080

# ── JWT Secret ──────────────────────────────────────
JWT_SECRET=ustad-riyad-2026-secret-key

# ── مفاتيح Gemini API ────────────────────────────────
# احصل عليها من: https://aistudio.google.com/apikey
GEMINI_API_KEY=ضع_مفتاحك_هنا
GEMINI_API_KEY_2=
GEMINI_API_KEY_3=
GEMINI_API_KEY_4=
GEMINI_API_KEY_5=

# ── OpenRouter API Key (أولوية قصوى) ────────────────
# احصل عليه من: https://openrouter.ai/keys
OPENROUTER_API_KEY=ضع_مفتاحك_هنا

# ── قاعدة بيانات Replit (اختياري) ───────────────────
# إذا أردت استخدام قاعدة بيانات Replit من بعد:
# افتح Shell في Replit وشغّل: echo $REPLIT_DB_URL
# ثم الصق الرابط هنا
# REPLIT_DB_URL=https://kv.replit.com/v0/xxxxx
#
# إذا تركته فارغاً سيُستخدم المحاكي المحلي (ملف JSON)
# ══════════════════════════════════════════════════════
ENV_EOF
  echo -e "${GREEN}✓ artifacts/api-server/.env أُنشئ${RESET}"
fi

# ── 5. إنشاء محاكي @replit/database المحلي ────────────────────────
echo -e "${YELLOW}[5/6] إنشاء محاكي قاعدة البيانات المحلية...${RESET}"

mkdir -p artifacts/api-server/src/lib

cat > artifacts/api-server/src/lib/local-db-mock.ts << 'MOCK_EOF'
/**
 * محاكي محلي لـ @replit/database
 * يُستخدم تلقائياً عندما لا يكون REPLIT_DB_URL مضبوطاً
 * يحفظ البيانات في ملف .sigma-db.json
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DB_FILE = path.resolve(__dirname, "../../../../.sigma-db.json");

function loadStore(): Record<string, string> {
  try {
    if (fs.existsSync(DB_FILE)) {
      return JSON.parse(fs.readFileSync(DB_FILE, "utf8"));
    }
  } catch {}
  return {};
}

function saveStore(store: Record<string, string>): void {
  try {
    fs.writeFileSync(DB_FILE, JSON.stringify(store, null, 2), "utf8");
  } catch {}
}

class LocalDatabase {
  async get(key: string): Promise<{ ok: boolean; value: string | null }> {
    const store = loadStore();
    const value = store[key] ?? null;
    return { ok: true, value };
  }

  async set(key: string, value: string): Promise<{ ok: boolean }> {
    const store = loadStore();
    store[key] = value;
    saveStore(store);
    return { ok: true };
  }

  async delete(key: string): Promise<{ ok: boolean }> {
    const store = loadStore();
    delete store[key];
    saveStore(store);
    return { ok: true };
  }

  async list(prefix = ""): Promise<{ ok: boolean; value: string[] }> {
    const store = loadStore();
    const keys = Object.keys(store).filter(k => k.startsWith(prefix));
    return { ok: true, value: keys };
  }
}

export default LocalDatabase;
MOCK_EOF

echo -e "${GREEN}✓ محاكي قاعدة البيانات أُنشئ${RESET}"

# ── 6. تثبيت الحزم ───────────────────────────────────────────────
echo -e "${YELLOW}[6/6] تثبيت الحزم (pnpm install)...${RESET}"
pnpm install --no-frozen-lockfile
echo -e "${GREEN}✓ الحزم مثبّتة${RESET}"

# ── النهاية ───────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}  ✓ الإعداد اكتمل بنجاح!${RESET}"
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${BOLD}الخطوات التالية:${RESET}"
echo ""
echo -e "  ${YELLOW}1. عدّل مفاتيح API في:${RESET}"
echo -e "     artifacts/api-server/.env"
echo ""
echo -e "  ${YELLOW}2. شغّل الخادم الخلفي (terminal 1):${RESET}"
echo -e "     ${BOLD}PORT=8080 pnpm --filter @workspace/api-server run dev${RESET}"
echo ""
echo -e "  ${YELLOW}3. شغّل الواجهة الأمامية (terminal 2):${RESET}"
echo -e "     ${BOLD}pnpm --filter @workspace/sheikh-dhaki run dev${RESET}"
echo ""
echo -e "  ${YELLOW}4. افتح المتصفح على:${RESET}"
echo -e "     ${BOLD}http://localhost:5173${RESET}"
echo ""
echo -e "${YELLOW}⚠  ملاحظة:${RESET} إذا لم تضبط REPLIT_DB_URL، ستُحفظ"
echo -e "   بيانات المستخدمين في ملف ${BOLD}.sigma-db.json${RESET} محلياً"
echo ""
