# 🛰️ Hermes Stack روی Render — راهنمای فارسی (بدون کارت، رایگان)

> هاگینگ‌فیس پلن رایگان Docker را برداشته (ارور `402`) و فعلاً بهترین مسیر
> بدون کارت، **Render Free** است: `0.1 CPU / 512MB RAM`، ماهی `750 ساعت`
> (برای یک سرویس ۲۴/۷ کافی است چون ~۷۴۴ ساعت در ماه لازم داری)، بدون کارت،
> دیپلوی مستقیم از همین ریپو با Blueprint. فقط بدان: بعد از **۱۵ دقیقه**
> بدون ترافیک سرویس می‌خوابد (بیدار شدن ~۱ دقیقه) و فایل لوکال با هر
> ریدیپلوی می‌پرد — ولی بکاپ ساعتی ما به HF dataset این دومی را پوشش می‌دهد.

## ۰) پیش‌نیازها (بدون کارت)

- اکانت رایگان [Render](https://render.com) — فقط ایمیل/گیت‌هاب، **بدون کارت**
- اکانت گیت‌هاب با همین ریپو (fork از `Godde3s/hermes-stack` یا همین ریپوی خودت)
- ربات تلگرام از [@BotFather](https://t.me/BotFather) + آیدی عددی خودت از [@userinfobot](https://t.me/userinfobot)
- یک توکن **Write** هاگینگ‌فیس از [settings/tokens](https://huggingface.co/settings/tokens) — فقط برای بکاپ ساعتی به دیتاست خصوصی (سرویس روی Render اجرا می‌شود، نه HF)

## ۱) دیپلوی با Blueprint (۲ دقیقه)

1. در داشبورد Render: **New → Blueprint** → ریپوی `hermes-stack` را انتخاب کن.
2. Render فایل [`render.yaml`](../render.yaml) را می‌خواند: سرویس `hermes-stack` با پلن **Free**، ریجن `frankfurt`، داکر از `./space/Dockerfile`، هلث‌چک `/healthz`.
3. داشبورد از تو مقادیر سکرت‌ها را می‌پرسد (چون `sync: false` هستند — در فایل فقط اسمشان هست، نه مقدارشان). ست کن:

   | نام | مقدار |
   |---|---|
   | `TELEGRAM_BOT_TOKEN` | توکن BotFather |
   | `TELEGRAM_ALLOWED_USERS` | آیدی عددی خودت |
   | `HERMES_API_KEY` | یک رشته‌ی قوی دلخواه (مثل `hs-…`) |
   | `NINEROUTER_API_KEY` | یک رشته‌ی قوی — بعداً همین را داخل داشبورد ۹روتر می‌سازی |
   | `ROUTER_INITIAL_PASSWORD` | رمز اولین ورود داشبورد ۹روتر |
   | `OMNI_ROUTER_KEY` | فقط اگر OmniRouter را فعال کنی (پیش‌فرض خاموش است) |
   | `OMNI_ADMIN_PASSWORD` | فقط اگر OmniRouter را فعال کنی |
   | `DASHBOARD_USERNAME` / `DASHBOARD_PASSWORD` | ورود به داشبورد وب هرمس (`/hermes/`) |
   | `HF_TOKEN` | توکن Write (برای بکاپ/ریستور ساعتی) |
   | `HERMES_MODEL` | آیدی مدل از تب Models داشبورد ۹روتر |
   | `BACKUP_REPO` | `نام‌کاربری/نام-دیتاست` خصوصی |

4. **Apply** بزن → بیلد شروع می‌شود. اولین بیلد چون دو ایمیج بزرگ دانلود می‌کند **۱۰ تا ۲۵ دقیقه** طول می‌کشد — صبور باش.

## ۲) چرا حالت Slim؟ (مهم — رم ۵۱۲MB)

پلن رایگان فقط **۵۱۲MB رم** دارد و استک کامل (هرمس + ۹روتر + OmniRouter) در آن جا نمی‌شود. پس به‌صورت پیش‌فرض:

- `OMNI_ENABLED=false` → روتر کی‌لس (OmniRouter) خاموش می‌ماند → رم آزاد برای هرمس + ۹روتر.
- هپ Node.js به `256MB` محدود شده (`NODE_OPTIONS=--max-old-space-size=256`).
- مدل پیش‌فرض را از داشبورد ۹روتر انتخاب کن (اکانت‌های رایگان Kiro / OpenCode Free و…)، نه از OmniRouter.

اگر بعداً سرویس پایدار بود و خواستی مدل‌های کی‌لس را برگردانی: در داشبورد Render مقدار `OMNI_ENABLED` را `true` کن و **Manual Deploy** بزن — ولی اگر OOM دیدی برگردان به `false`.

## ۳) آدرس‌ها (بعد از سبز شدن دیپلوی)

| سرویس | آدرس |
|---|---|
| داشبورد ۹روتر | `https://hermes-stack.onrender.com/` |
| API مدل‌های ۹روتر | `https://hermes-stack.onrender.com/v1` |
| داشبورد وب هرمس | `https://hermes-stack.onrender.com/hermes/` |
| API عامل هرمس | `https://hermes-stack.onrender.com/hermes-api/v1` |
| هلث‌چک | `https://hermes-stack.onrender.com/healthz` |

> اسم ساب‌دامین `onrender.com` را Render موقع ساخت می‌سازد؛ اگر اسم سرویس دیگری انتخاب کردی، همان را جایگزین کن.

## ۴) روشن نگه‌داشتن (جلوگیری از خواب ۱۵ دقیقه‌ای)

1. **داخلی:** در همین ریپو فایل [`.github/workflows/keepalive.yml`](../.github/workflows/keepalive.yml) را طوری ست کن که به‌جای `hf.space` به آدرس Render تو پینگ بزند (سکرت `RENDER_APP_URL` مثل `https://hermes-stack.onrender.com`). اکشن هر ۱۰ دقیقه `/healthz` را پینگ می‌کند و سرویس نمی‌خوابد.
2. **خارجی (پیشنهادی):** در [cron-job.org](https://cron-job.org) هم یک Cron هر ۵ دقیقه به `/healthz` بساز — کمربند + شلوار.

## ۵) بکاپ و ریستور (مثل قبل، روی HF dataset)

- هر ساعت `/opt/data` به دیتاست خصوصی (`BACKUP_REPO`) آپلود می‌شود: `latest.tar.gz` + نسخه‌های ساعتی ۷۲ ساعت اخیر.
- ریدیپلوی Render دیسک را پاک می‌کند، ولی بوت بعدی `01-restore.sh` آخرین `latest.tar.gz` را برمی‌گرداند (چون `HF_TOKEN` و `BACKUP_REPO` ست هستند).
- اولین پیام تلگرام بعد از ریدیپلوی ممکن است چند دقیقه طول بکشد (ریستور + بالا آمدن سرویس‌ها).

## ۶) عیب‌یابی سریع

| مشکل | راه‌حل |
|---|---|
| بیلد می‌افتد | لاگ Deploy در داشبورد Render؛ معمولاً قطعی موقت CDN است — **Manual Deploy → Clear build cache** |
| `Out of memory` / سرویس ری‌استارت می‌شود | `OMNI_ENABLED=false` نگه دار؛ `EXTRA_*` نصب نکن؛ هپ را کم کن |
| ربات جواب نمی‌دهد | توکن + `TELEGRAM_ALLOWED_USERS` (آیدی عددی خودت) را چک کن؛ **Manual Deploy** |
| هرمس مدلی پیدا نمی‌کند | `HERMES_MODEL` باید با آیدی تب Models داشبورد ۹روتر **دقیقاً** یکی باشد |
| داشبورد هرمس لاگین نمی‌شود | هر دو `DASHBOARD_USERNAME` و `DASHBOARD_PASSWORD` باید ست باشند |
| سرویس خوابیده و تلگرام دیر جواب می‌دهد | keepalive (بخش ۴) را فعال کن؛ اولین پینگ ~۱ دقیقه طول می‌کشد |
| بکاپ آپلود نمی‌شود | `HF_TOKEN` باید نقش **Write** داشته باشد و `BACKUP_REPO` با فرمت `user/dataset` |
