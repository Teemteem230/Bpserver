#!/bin/bash

# إنشاء كلمة المرور الافتراضية
htpasswd -cb /etc/squid/passwords user2020 user2020

# إنشاء المجلدات اللازمة
mkdir -p /var/spool/squid
mkdir -p /var/log/squid
chown -R proxy:proxy /var/spool/squid
chown -R proxy:proxy /var/log/squid

# تهيئة الكاش
echo "🔧 جاري تهيئة خادم البروكسي..."
squid -z

# تشغيل سكويد
echo "🚀 بدء تشغيل خادم البروكسي..."
echo "📍 العنوان: squid-proxy.onrender.com:8080"
echo "👤 المستخدم: user2020"
echo "🔐 كلمة المرور: user2020"
echo "📊 افتح المتصفح لعرض معلومات البروكسي"

exec squid -N -d 1
