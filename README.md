# Jaycom Contacts

تطبيق Flutter Web عربي لإدارة المهن وأرقام التواصل الخاصة بمنصة جايكم فور.

## التشغيل

```bash
flutter pub get
flutter run -d chrome
```

## البناء

```bash
flutter build web --release
```

عنوان الخدمة الآمن موجود مركزيًا في `lib/core/constants/api_constants.dart`.
ويمكن تغييره دون تعديل الكود باستخدام:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://api.example.com/
```

> تنبيه: تم اعتماد HTTPS بعد التحقق من توفره. ما زال الخادم لا يعيد رؤوس CORS
> ولا يقبل طلب OPTIONS التمهيدي، لذلك يجب السماح بنطاق الواجهة في إعدادات الخادم.

طلبات `GET` في التطبيق لا ترسل `Content-Type` ولا تحتاج إلى preflight. طلبات
`POST` ترسل JSON، ولذلك يحتاج الخادم إلى قبول `OPTIONS` وإرجاع رؤوس CORS المناسبة.
