# سِيغْمَا Σ — إعداد VS Code (محلي)

## المتطلبات الأساسية
- **Node.js** v20 أو أحدث → https://nodejs.org
- **pnpm** → `npm install -g pnpm`
- **Git** → https://git-scm.com

---

## الخطوة 1 — استنساخ المشروع

```bash
git clone https://github.com/shahedmerada2009-dot/SigmaBac.git
cd SigmaBac
```

> إذا لم يكن الريبو على GitHub، انسخ مجلد المشروع يدوياً من Replit عبر زر **Download as ZIP** من قائمة الثلاث نقاط في Replit.

---

## الخطوة 2 — تعديل `pnpm-workspace.yaml`

المشروع يحتوي على قيود منصة (Linux فقط) ستسبب مشاكل على Mac/Windows.  
**احذف** كل مقطع `overrides:` من الملف وأبقِ فقط هذا:

```yaml
minimumReleaseAge: 1440

minimumReleaseAgeExclude:
  - '@replit/*'

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
```

---

## الخطوة 3 — إنشاء ملف `.env`

أنشئ الملف: `artifacts/api-server/.env`

```env
# ══════════════════════════════════════════
#  سِيغْمَا Σ — متغيرات البيئة
# ══════════════════════════════════════════

PORT=8080
JWT_SECRET=ustad-riyad-2026-secret-key

# مفاتيح Gemini — احصل عليها من: https://aistudio.google.com/apikey
GEMINI_API_KEY=ضع_مفتاحك_هنا
GEMINI_API_KEY_2=
GEMINI_API_KEY_3=
GEMINI_API_KEY_4=
GEMINI_API_KEY_5=

# OpenRouter — احصل عليه من: https://openrouter.ai/keys
OPENROUTER_API_KEY=ضع_مفتاحك_هنا

# Replit Database (اختياري — للاتصال بقاعدة البيانات الحقيقية عن بُعد)
# شغّل في Replit Shell: echo $REPLIT_DB_URL  ثم الصق الرابط هنا
# REPLIT_DB_URL=https://kv.replit.com/v0/xxxxxxxx
```

---

## الخطوة 4 — استبدال `@replit/database` بمحاكي محلي

`@replit/database` لا يعمل خارج Replit بدون `REPLIT_DB_URL`.  
**الحل**: أنشئ ملفاً يحاكيه بـ JSON محلي.

أنشئ الملف: `artifacts/api-server/src/lib/local-db.ts`

```typescript
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DB_FILE = path.resolve(__dirname, "../../../../.sigma-db.json");

function load(): Record<string, string> {
  try {
    if (fs.existsSync(DB_FILE)) return JSON.parse(fs.readFileSync(DB_FILE, "utf8"));
  } catch {}
  return {};
}

function save(store: Record<string, string>) {
  fs.writeFileSync(DB_FILE, JSON.stringify(store, null, 2), "utf8");
}

export default class LocalDatabase {
  async get(key: string) {
    return { ok: true, value: load()[key] ?? null };
  }
  async set(key: string, value: string) {
    const s = load(); s[key] = value; save(s);
    return { ok: true };
  }
  async delete(key: string) {
    const s = load(); delete s[key]; save(s);
    return { ok: true };
  }
  async list(prefix = "") {
    return { ok: true, value: Object.keys(load()).filter(k => k.startsWith(prefix)) };
  }
}
```

ثم في `artifacts/api-server/src/routes/auth.ts` و `correct.ts`، غيّر:

```typescript
// قبل:
import Database from "@replit/database";
const db = new Database();

// بعد:
import Database from "../lib/local-db.js";
const db = new Database();
```

---

## الخطوة 5 — تثبيت الحزم

```bash
pnpm install --no-frozen-lockfile
```

---

## الخطوة 6 — تشغيل المشروع

افتح **ترمينالين** في VS Code:

**ترمينال 1 — الخادم الخلفي (API):**
```bash
pnpm --filter @workspace/api-server run dev
```
→ يعمل على: `http://localhost:8080`

**ترمينال 2 — الواجهة الأمامية:**
```bash
pnpm --filter @workspace/sheikh-dhaki run dev
```
→ افتح المتصفح على: `http://localhost:5173`

---

## ملفات المشروع الرئيسية

```
SigmaBac/
├── artifacts/
│   ├── api-server/           # الخادم الخلفي Express
│   │   └── src/
│   │       ├── routes/
│   │       │   ├── auth.ts   # تسجيل/دخول/تفعيل الوصل
│   │       │   └── correct.ts # تصحيح الرياضيات بالذكاء الاصطناعي
│   │       └── index.ts
│   └── sheikh-dhaki/         # الواجهة الأمامية React
│       ├── public/
│       │   ├── manifest.json # PWA Manifest
│       │   └── sw.js         # Service Worker
│       └── src/
│           ├── pages/
│           │   ├── Login.tsx      # صفحة الدخول والتفعيل
│           │   └── Dashboard.tsx  # لوحة التصحيح الرئيسية
│           └── context/
│               └── AuthContext.tsx
├── pnpm-workspace.yaml
└── package.json
```

---

## المتغيرات البيئية — ملخص

| المتغير | القيمة | المصدر |
|---------|--------|--------|
| `PORT` | `8080` | ثابت |
| `JWT_SECRET` | `ustad-riyad-2026-secret-key` | ثابت |
| `GEMINI_API_KEY` | مفتاح Gemini المدفوع | https://aistudio.google.com |
| `GEMINI_API_KEY_2..5` | مفاتيح Gemini مجانية | https://aistudio.google.com |
| `OPENROUTER_API_KEY` | مفتاح OpenRouter | https://openrouter.ai/keys |
| `REPLIT_DB_URL` | رابط قاعدة Replit | من Replit Shell: `echo $REPLIT_DB_URL` |

---

## ملاحظات مهمة

1. **بدون `REPLIT_DB_URL`**: المستخدمون وبيانات الاشتراك تُحفظ في `.sigma-db.json` محلياً
2. **مع `REPLIT_DB_URL`**: يتصل بنفس قاعدة بيانات Replit الحقيقية عن بُعد
3. الـ `pnpm-workspace.yaml` الأصلي مخصص لـ Linux فقط — الخطوة 2 ضرورية لـ Mac/Windows

---

*سِيغْمَا Σ © 2026 — جميع الحقوق محفوظة*
