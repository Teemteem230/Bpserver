FROM sameersbn/squid:3.5.27-2

# تثبيت حزم إضافية
RUN apt-get update && apt-get install -y \
    apache2-utils \
    curl \
    && rm -rf /var/lib/apt/lists/*

# إنشاء start.sh مباشرة في الصورة
RUN cat > /start.sh << 'EOF'
#!/bin/bash

# إنشاء كلمة المرور
htpasswd -cb /etc/squid/passwords user2020 user2020

# إنشاء مجلدات السجلات
mkdir -p /var/log/squid
chown -R proxy:proxy /var/log/squid

# إنشاء مجلد الكاش
mkdir -p /var/spool/squid
chown -R proxy:proxy /var/spool/squid

# تهيئة الكاش
squid -z

# إنشاء صفحة ويب لعرض المعلومات
cat > /var/www/html/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>خادم البروكسي - Render</title>
    <style>
        body { font-family: Arial, sans-serif; direction: rtl; max-width: 800px; margin: 0 auto; padding: 20px; }
        .card { background: #f5f5f5; padding: 20px; margin: 10px 0; border-radius: 10px; }
        .info { background: #e3f2fd; padding: 15px; border-right: 5px solid #2196f3; }
        .success { background: #e8f5e8; padding: 15px; border-right: 5px solid #4caf50; }
        code { background: #333; color: white; padding: 10px; display: block; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>🎯 خادم البروكسي يعمل بنجاح على Render</h1>
    
    <div class="card info">
        <h2>📊 معلومات الخادم:</h2>
        <p><strong>🌐 عنوان الخادم:</strong> squid-proxy.onrender.com</p>
        <p><strong>🔌 البورت:</strong> 8080</p>
        <p><strong>👤 اسم المستخدم:</strong> user2020</p>
        <p><strong>🔐 كلمة المرور:</strong> user2020</p>
        <p><strong>🔄 البروتوكول:</strong> HTTP/HTTPS</p>
    </div>

    <div class="card success">
        <h2>🚀 كيفية الاستخدام:</h2>
        
        <h3>في المتصفح (إعدادات البروكسي):</h3>
        <code>
            الخادم: squid-proxy.onrender.com<br>
            البورت: 8080<br>
            اسم المستخدم: user2020<br>
            كلمة المرور: user2020
        </code>

        <h3>في Terminal:</h3>
        <code>
            curl -x http://user2020:user2020@squid-proxy.onrender.com:8080 \
            -L https://httpbin.org/ip
        </code>

        <h3>في Python:</h3>
        <code>
            import requests<br>
            proxies = {<br>
            &nbsp;&nbsp;'http': 'http://user2020:user2020@squid-proxy.onrender.com:8080',<br>
            &nbsp;&nbsp;'https': 'http://user2020:user2020@squid-proxy.onrender.com:8080'<br>
            }<br>
            response = requests.get('https://httpbin.org/ip', proxies=proxies)
        </code>
    </div>

    <div class="card">
        <h2>📡 معلومات IP الحقيقية:</h2>
        <div id="ip-info">جاري جلب المعلومات...</div>
    </div>

    <script>
        // جلب IP المستخدم عبر البروكسي
        fetch('https://httpbin.org/ip')
            .then(response => response.json())
            .then(data => {
                document.getElementById('ip-info').innerHTML = 
                    `<strong>IP الخاص بك:</strong> ${data.origin}`;
            });
    </script>
</body>
</html>
HTMLEOF

# تشغيل سكويد وخدمة الويب
exec squid -N -d 1
EOF

RUN chmod +x /start.sh

# نسخ squid.conf
COPY squid.conf /etc/squid/squid.conf

# استخدام منفذ متوافق مع Render
EXPOSE 8080

CMD ["/start.sh"]
