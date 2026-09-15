# KahveGo Mobil Kahve Sipariş Uygulaması — Ödev Yanıtları

## GÖREV 1: Mobil Akış Şeması / Sözde Kod

```
Algoritma: KahveGo Sipariş Akışı
Giriş: Oturum durumu, sepet içeriği, cüzdan bakiyesi
Çıkış: Sipariş onayı veya uyarı mesajı

Adım 1: BAŞLA
Adım 2: Uygulama açılır, oturum durumu kontrol edilir
Adım 3: EĞER kullanıcı giriş yapmamış İSE:
    Adım 3.1: Giriş Ekranı'na yönlendir
    Adım 3.2: Kullanıcı giriş yapar, GİT ADIM 4
Adım 4: DEĞİLSE (kullanıcı giriş yapmışsa):
    Adım 4.1: Ürün listesi ekranı gösterilir
Adım 5: Kullanıcı ürünleri seçer ve sepete ekler
Adım 6: Kullanıcı siparişi onaylar, sepet tutarı hesaplanır
Adım 7: EĞER cüzdan bakiyesi >= sepet tutarı İSE:
    Adım 7.1: Sipariş paketi sunucuya gönderilir
    Adım 7.2: Bakiyeden sepet tutarı düşülür
    Adım 7.3: Sipariş onay ekranı gösterilir
Adım 8: DEĞİLSE (bakiye yetersizse):
    Adım 8.1: "Bakiye Yükle" uyarısı gösterilir
    Adım 8.2: Kullanıcı bakiye yükler, GİT ADIM 6
Adım 9: BİTİR
```

## GÖREV 2: REST API Uç Noktası & JSON Tasarımı

### 1. Sipariş Oluşturma Endpoint'i

- **HTTP Metodu:** POST
- **URL:** `/api/v1/siparisler`
- **Header:** `Authorization: Bearer <token>`, `Content-Type: application/json`
- **Örnek Request Body:**

```json
{
  "urunler": [
    {
      "kahve_adi": "Latte",
      "boyut": "Orta",
      "adet": 2
    }
  ],
  "toplam_tutar": 95.00
}
```

- **Başarılı Sonuç:** `201 Created`
- **Kullanıcı Giriş Yapmamışsa:** `401 Unauthorized`

### 2. Cüzdan Bakiye Sorgulama Endpoint'i

- **HTTP Metodu:** GET
- **URL:** `/api/v1/kullanici/bakiye`
- **Header:** `Authorization: Bearer <token>`
- **Örnek Response:**

```json
{
  "bakiye": 185.50,
  "para_birimi": "TRY"
}
```

- **Sunucuda Beklenmeyen Hata:** `500 Internal Server Error`

### Mini Mülakat Sorusu

GET isteği idempotenttir çünkü sunucudaki veriyi değiştirmeden sadece okuma yapar, aynı isteği kaç kez tekrarlarsak tekrarlayalım sonuç ve sunucu durumu aynı kalır; POST isteği ise idempotent değildir çünkü her çağrıldığında yeni bir sipariş kaydı oluşturup sunucu durumunu (veritabanı, bakiye) değiştirir.

## GÖREV 3: Clean Code & SOLID Prensip Teşhisi

**1. SRP İhlali:**
`KahveSiparisYoneticisi` sınıfı; indirim hesaplama, ödeme tahsilatı, veritabanına kayıt ve SMS bildirimi gibi birbirinden bağımsız birden fazla sorumluluğu tek çatı altında topladığı için Single Responsibility Principle ihlal edilmiştir. Sınıf; `IndirimHesaplayici`, `OdemeIslemcisi`, `SiparisDepolama` ve `BildirimServisi` gibi her biri tek bir işten sorumlu ayrı sınıflara bölünmelidir.

**2. OCP İhlali:**
`indirimHesapla` fonksiyonu her yeni müşteri tipi (ör. "DOKTOR") eklendiğinde mevcut if-else zincirinin değiştirilmesini gerektirdiği için Open/Closed Principle'a aykırıdır — sınıf yeni davranışlara "genişlemeye açık, değişikliğe kapalı" olması gerekirken burada her genişleme mevcut kodun değiştirilmesini zorunlu kılıyor.

## GÖREV 4: Git, Branching & GitHub Release

Bu ödev `feature/kahvego-tasarim` branch'inde hazırlanmış, `v1.2.0` etiketiyle GitHub Release olarak yayınlanmıştır.

**Release linki:** _(GitHub Release'i yayınladıktan sonra buraya ekleyin)_
