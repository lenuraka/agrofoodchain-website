# AGRO FOOD CHAIN — сайт на базе утверждённого дизайна (27.10.2026)

**Актуальная версия дизайн-темы: 1.2.0.** Взята концепция из беседы «Гранты и проекты Узбекистана»: зелёный и золотой эмблемный знак, Montserrat, белая навигация, большой аграрный пейзаж Центральной Азии, шесть фото-категорий, восемь направлений услуг и региональная полоса пяти стран.

- Эталон дизайн-борда: `docs/APPROVED-BRAND-BOARD.png`.
- Просмотр без WordPress: `preview/index.html` (открывается в браузере); предусмотрена локальная векторная подложка.
- WordPress-тема: `theme/agrofoodchain` (в отдельном архиве `agrofoodchain-theme-approved.zip`).
- Контент и материалы SEO из предыдущего проекта сохранены в папке `content/`.
- Цвета: #123C32 / #15966A / #D8AD57 / #18324A / #F4F7F5 / #FFFFFF.
- Тема не содержит паролей и частных ключей.

## Что потребуется до запуска

1. Приобрести домен `agrofoodchain.com` (доступность и покупка не проверены) и европейский WordPress-хостинг.
2. Установить WordPress и тему (Внешний вид → Темы → Добавить → Загрузить тему).
3. Создать соответствующие страницы, главное меню и настроить постоянные ссылки.
4. В меню оформления задать действующие почту, телефон и официальный юридический адрес.
5. Утвердить оригиналы фотографий высокого разрешения вместо временных миниатюр из бренд-борда.
6. Проверить и согласовать разделы услуг, условия сотрудничества, конфиденциальность, форму заявок и юридические формулировки по сертификатам.
7. Подключить EN / RU / UZ на многоязычном плагине, выполнить SEO и тестирование на реальном хостинге.

## Изображения и права

- `assets/images/afc-approved-mark.svg`: эмблема из ранее подготовленной WordPress-темы v1.1 проекта.
- `assets/images/sector-*.webp`: временные миниатюры, вырезанные из вашего утверждённого дизайн-борда; для качественного продакшн-сайта нужны изображения с установленными правами использования.
- `assets/images/central-asia-landscape.svg`: оригинальная локальная векторная подложка (работает без интернета).
- Дополнительная фотография Chimgan Mountains, Uzbekistan: **Nodir Khalilov / Unsplash** (https://unsplash.com/photos/a-grassy-field-with-mountains-in-the-background-zyoRx9ZBZ84), использование в рамках Unsplash License: https://unsplash.com/license. Она подгружается в CSS извне; перед публикацией рекомендуется локально разместить правильно лицензированную оптимизированную копию.

> Дизайн сохранён как концепция; это подготовленный исходный код, а не уже опубликованный сайт. Показатели «100+ проектов» и «20+ стандартов» из иллюстративного бренд-борда не использованы как неподтверждённые маркетинговые факты.

---

# AGRO FOOD CHAIN — Website Development Repository

A WordPress corporate website starter for **AGRO FOOD CHAIN LLC** targeting international buyers, certification clients, investors and development partners across Central Asia.

**Status:** development starter / not deployed / not independently tested on a hosted WordPress instance. Content, company contact information and legal texts must be verified before launch.

## Repository structure

```
agrofoodchain-github-starter/
├── README.md
├── .gitignore
├── theme/
│   └── agrofoodchain/         # Installable WordPress classic theme (PHP/CSS/JS)
│       ├── style.css
│       ├── functions.php
│       ├── header.php
│       ├── front-page.php
│       ├── page.php
│       ├── footer.php
│       ├── index.php
│       ├── single.php
│       ├── 404.php
│       └── assets/
│           ├── css/site.css
│           └── js/main.js
├── content/
│   ├── wordpress-import.xml   # WordPress page import (WXR)
│   ├── website-pages-en.md    # English copy and site navigation
│   └── seo-plan.csv           # Search-intent plan
├── preview/
│   └── index.html             # Standalone non-WordPress homepage visual preview
└── docs/
    ├── 01-GITHUB-SETUP-RU.md
    ├── 02-WORDPRESS-INSTALL-RU.md
    └── 03-LAUNCH-CHECKLIST-RU.md
```

## Quick start

1. Create a **private** GitHub repository `agrofoodchain-website`.
2. Extract the main `agrofoodchain-github-starter.zip` **before uploading**; GitHub does not automatically unpack it. Upload the extracted folders and files using **Add file → Upload files** or GitHub Desktop.
3. Preview the standalone `preview/index.html` in a web browser.
4. Upload `agrofoodchain-theme.zip` (provided separately with this package) to your WordPress admin under **Appearance → Themes → Add New → Upload Theme**.
5. Activate the theme and import `content/wordpress-import.xml` using **Tools → Import → WordPress** (WordPress Importer plugin may need installation).
6. Go to **Settings → Reading** and choose a static homepage, `Home`; set the posts page to `Insights`.
7. In **Appearance → Customize → Company contact details**, enter verified company email and phone. Add a contact form via a reputable WordPress form plugin; test email sending.
8. In **Appearance → Menus**, assign primary navigation (for block administration interfaces, use the available menus customization location).
9. Add your *approved* company logo under **Appearance → Customize → Site Identity**.
10. Before launch, complete the checklist in `docs/03-LAUNCH-CHECKLIST-RU.md`.

The repository must **not** contain WordPress database exports, wp-config.php, credentials or client reports.

## Positioning and compliance safeguards

- AGRO FOOD CHAIN is positioned as an auditing, consulting, implementation, certification-readiness and coordination provider.
- Do not imply AGRO FOOD CHAIN independently issues accredited certificates unless legal authority to do so is verified.
- SMETA/Sedex and amfori BSCI terms refer to related customer requirements/readiness support; formal audits under proprietary programmes require relevant permissions.
- RINA partner/representative status must be presented using contractually approved wording and branding (no RINA logo is included).
- Do not publish unverified contacts, case studies, logos or client testimonials.
- English is the primary language of this starter. Other languages and SEO localisation need implementation before multilingual launch.

© 2026 AGRO FOOD CHAIN LLC — internal project materials.


## Update 2026-11-09
- Header and footer updated to use the client-provided AGRO FOOD CHAIN logo.
- Added expanded internal-page copy for each service direction.
- Added preview pages under `preview/pages/`.
- Updated WordPress import file with service-detail pages.
