# Как опубликовать новость UNCTAD на WordPress-сайте AGRO FOOD CHAIN

Дата подготовки: 21.11.2026. Мероприятие UNCTAD состоялось **25–26 мая 2021 года**.

## Что готово в GitHub
- Новость на английском: `content/insights/unctad-globalgap-dried-fruit-uzbekistan-2021.md`
- Русская версия: `content/insights/unctad-globalgap-dried-fruit-uzbekistan-2021-ru.md`
- Предпросмотр: `preview/pages/unctad-globalgap-dried-fruit-uzbekistan-2021.html`
- Ссылка на новость на статической странице `preview/pages/insights.html`
- Виджет последних публикаций на главной странице темы и статическом предпросмотре.
- **Отдельный файл импорта WordPress:** `content/wordpress-import-unctad-2021.xml`.
- Общий экспорт `content/wordpress-import.xml` также обновлён для *первоначальной* установки сайта.

## Для существующего WordPress
1. Войдите в админ-панель WordPress.
2. Если тема подключена к GitHub, разверните изменения в `theme/agrofoodchain` (активация темы сама по себе не импортирует статьи).
3. Откройте **Инструменты → Импорт → WordPress**. При необходимости установите официальный WordPress Importer.
4. Выберите **только** `content/wordpress-import-unctad-2021.xml`, сопоставьте автора и выполните импорт.
5. Проверьте **Записи**: заголовок «AGRO FOOD CHAIN Expert Contributed to UNCTAD Training on GLOBALG.A.P. and Dried Fruit Quality», статус опубликовано, рубрика International Cooperation.
6. Проверьте ссылку `/unctad-globalgap-dried-fruit-uzbekistan-2021/` (slug: `unctad-globalgap-dried-fruit-uzbekistan-2021`), страницу /insights/ и блок новостей на главной.
7. Убедитесь, что в настройках Чтение (Reading) страница записей назначена на Insights, постоянные ссылки включены и сайт доступен по HTTPS.

**Важно:** не импортируйте одновременно *и* единичный XML, *и* общий файл `wordpress-import.xml`: это может создать дубликаты.

## Для нового WordPress
После установки темы импортируйте один раз общий файл `content/wordpress-import.xml`: он уже включает материал UNCTAD.

## Статус
Коммит в GitHub **не означает**, что информация появилась на публичном WordPress-сайте. Для фактической публикации необходим доступ к административной панели WordPress или подключение инструмента публикации.

Официальный первоисточник: https://unctad.org/meeting/training-international-certification-standards-and-quality-dried-fruit-value-chain
