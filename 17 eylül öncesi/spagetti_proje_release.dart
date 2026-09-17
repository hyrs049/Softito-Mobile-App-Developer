abstract class Urun {
  final String id;
  final String ad;
  final double fiyat;
  int stok;

  Urun({
    required this.id,
    required this.ad,
    required this.fiyat,
    required this.stok,
  });

  double kargoUcretiHesapla();
}

class FizikselUrun extends Urun {
  static const double _standartKargoUcreti = 29.90;

  FizikselUrun({
    required super.id,
    required super.ad,
    required super.fiyat,
    required super.stok,
  });

  @override
  double kargoUcretiHesapla() => _standartKargoUcreti;
}

class DijitalUrun extends Urun {
  DijitalUrun({
    required super.id,
    required super.ad,
    required super.fiyat,
    required super.stok,
  });

  /* LSP düzeltmesi: exception fırlatmak yerine dijital ürünün
   gerçek davranışını (kargo ücretsizdir) döndürüyor.*/
  @override
  double kargoUcretiHesapla() => 0.0;
}

/* düzeltilmiş solid  (ISP) hatası:
 Tek bir dev arayüz yerine, her biri tek bir işten sorumlu
küçük arayüzler.
*/

abstract class ISiparisKaydedici {
  void kaydet(String orderId, double tutar);
}

abstract class IOdemeStratejisi {
  String get kod;
  void ode(double tutar);
}

abstract class IKargoServisi {
  void gonder(String orderId, String adres);
}

abstract class IBildirimServisi {
  void mailGonder(String email, String mesaj);
  void smsGonder(String tel, String mesaj);
}

abstract class IFaturaServisi {
  void yazdir(String orderId);
}

class SqliteSiparisKaydedici implements ISiparisKaydedici {
  @override
  void kaydet(String orderId, double tutar) {
    print(
      "DB calistirildi: INSERT INTO siparisler VALUES ('$orderId', $tutar)",
    );
  }
}

class MngKargoServisi implements IKargoServisi {
  @override
  void gonder(String orderId, String adres) {
    print("MNG Kargo takip fis basildi: $adres");
  }
}

class SmtpNetgsmBildirimServisi implements IBildirimServisi {
  @override
  void mailGonder(String email, String mesaj) {
    print("SMTP Mail gonderildi: $email");
  }

  @override
  void smsGonder(String tel, String mesaj) {
    print("SMS iletildi: $tel");
  }
}

class PdfFaturaServisi implements IFaturaServisi {
  @override
  void yazdir(String orderId) {
    print("Fatura PDF cikarildi: $orderId");
  }
}

// ============================================================
// ÖDEME STRATEJİLERİ (OCP)
// Yeni bir ödeme yöntemi eklemek için bu dosyadaki hiçbir
// mevcut sınıfı değiştirmeden yeni bir strateji sınıfı yazıp
// listeye eklemek yeterlidir.
// ============================================================

class KrediKartiOdeme implements IOdemeStratejisi {
  @override
  String get kod => "KREDI_KARTI";

  @override
  void ode(double tutar) => print("$tutar TL Kredi kartindan POS ile cekildi.");
}

class HavaleOdeme implements IOdemeStratejisi {
  @override
  String get kod => "HAVALE";

  @override
  void ode(double tutar) => print("$tutar TL Havale kontrol edildi.");
}

class KapidaOdeme implements IOdemeStratejisi {
  static const double _komisyon = 15.0;

  @override
  String get kod => "KAPIDA_ODEME";

  @override
  void ode(double tutar) => print(
    "${tutar + _komisyon} TL Kapida odeme tahsil edilecek (Komisyon +$_komisyon TL).",
  );
}

class CryptoOdeme implements IOdemeStratejisi {
  @override
  String get kod => "CRYPTO";

  @override
  void ode(double tutar) => print("$tutar TL USDT transferi onaylandi.");
}

// ============================================================
// İNDİRİM STRATEJİLERİ (OCP)
// Yeni bir kupon eklemek için mevcut kod değişmez, sadece yeni
// bir strateji eklenir.
// ============================================================

abstract class IIndirimStratejisi {
  double uygula(double tutar);
}

class YuzdeIndirim implements IIndirimStratejisi {
  final double oran;
  YuzdeIndirim(this.oran);

  @override
  double uygula(double tutar) => tutar * (1 - oran);
}

class SabitIndirim implements IIndirimStratejisi {
  final double miktar;
  SabitIndirim(this.miktar);

  @override
  double uygula(double tutar) => (tutar - miktar).clamp(0, double.infinity);
}

/*
 solid ihali olan(SRP) hatası düzeltildi:
 Her sınıf tek bir işten sorumlu.
*/
class StokServisi {
  bool stokKontrolEt(List<Urun> sepet) {
    for (final urun in sepet) {
      if (urun.stok <= 0) {
        print("Hata: ${urun.ad} tukenmis!");
        return false;
      }
    }
    return true;
  }

  void stoktanDus(List<Urun> sepet) {
    for (final urun in sepet) {
      urun.stok--;
    }
  }
}

class FiyatHesaplayici {
  static const double _kdvOrani = 0.20;

  double araToplamHesapla(List<Urun> sepet) {
    var toplam = 0.0;
    for (final urun in sepet) {
      toplam += urun.fiyat;
      toplam += urun.kargoUcretiHesapla();
    }
    return toplam;
  }

  double kdvEkle(double tutar) => tutar + (tutar * _kdvOrani);
}

/* solid ihlali (DIP) hatası düzeltildi:
 Somut sınıflara değil soyutlamalara bağımlı;
 bağımlılıklar dışarıdan elde ediliyor.
*/
class SiparisYoneticisi {
  final ISiparisKaydedici kaydedici;
  final IKargoServisi kargoServisi;
  final IBildirimServisi bildirimServisi;
  final IFaturaServisi faturaServisi;
  final StokServisi stokServisi;
  final FiyatHesaplayici fiyatHesaplayici;
  final Map<String, IOdemeStratejisi> odemeStratejileri;
  final Map<String, IIndirimStratejisi> indirimStratejileri;

  SiparisYoneticisi({
    required this.kaydedici,
    required this.kargoServisi,
    required this.bildirimServisi,
    required this.faturaServisi,
    required this.stokServisi,
    required this.fiyatHesaplayici,
    required List<IOdemeStratejisi> odemeYontemleri,
    required Map<String, IIndirimStratejisi> indirimKurallari,
  }) : odemeStratejileri = {
         for (final yontem in odemeYontemleri) yontem.kod: yontem,
       },
       indirimStratejileri = indirimKurallari;

  void siparisTamamla({
    required String orderId,
    required List<Urun> sepet,
    required String odemeTipi,
    required String musteriAdi,
    required String email,
    required String tel,
    required String adres,
    String? kuponKodu,
  }) {
    if (!stokServisi.stokKontrolEt(sepet)) return;

    var toplam = fiyatHesaplayici.araToplamHesapla(sepet);

    final indirim = indirimStratejileri[kuponKodu];
    if (indirim != null) {
      toplam = indirim.uygula(toplam);
    }

    final sonTutar = fiyatHesaplayici.kdvEkle(toplam);

    final odeme = odemeStratejileri[odemeTipi];
    if (odeme == null) {
      print("Gecersiz odeme yontemi");
      return;
    }
    odeme.ode(sonTutar);

    stokServisi.stoktanDus(sepet);
    kaydedici.kaydet(orderId, sonTutar);
    faturaServisi.yazdir(orderId);
    bildirimServisi.mailGonder(
      email,
      "Sayin $musteriAdi, siparisiniz alindi. Tutar: $sonTutar TL",
    );
    bildirimServisi.smsGonder(tel, "Siparisiniz onaylandi: $orderId");
    kargoServisi.gonder(orderId, adres);
  }
}

//bağımlılıkların kurulumu
void main() {
  final siparisYoneticisi = SiparisYoneticisi(
    kaydedici: SqliteSiparisKaydedici(),
    kargoServisi: MngKargoServisi(),
    bildirimServisi: SmtpNetgsmBildirimServisi(),
    faturaServisi: PdfFaturaServisi(),
    stokServisi: StokServisi(),
    fiyatHesaplayici: FiyatHesaplayici(),
    odemeYontemleri: [
      KrediKartiOdeme(),
      HavaleOdeme(),
      KapidaOdeme(),
      CryptoOdeme(),
    ],
    indirimKurallari: {
      "INDIRIM10": YuzdeIndirim(0.10),
      "YAZ20": YuzdeIndirim(0.20),
      "SEPETTE50": SabitIndirim(50),
    },
  );

  final urun1 = FizikselUrun(
    id: "1",
    ad: "Kablosuz Mouse",
    fiyat: 450.0,
    stok: 5,
  );
  final urun2 = DijitalUrun(
    id: "2",
    ad: "Flutter Kursu E-Kitap",
    fiyat: 150.0,
    stok: 100,
  );

  final sepet = <Urun>[urun1, urun2];

  siparisYoneticisi.siparisTamamla(
    orderId: "SP-9921",
    sepet: sepet,
    odemeTipi: "KREDI_KARTI",
    musteriAdi: "Selahaddin",
    email: "selahaddin@kodvance.com",
    tel: "05551112233",
    adres: "Kadikoy / Istanbul",
    kuponKodu: "INDIRIM10",
  );
}
