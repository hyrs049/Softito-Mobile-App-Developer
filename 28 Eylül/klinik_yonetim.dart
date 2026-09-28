//1.Enumları (derleme Zamanı güvenliği)
// Enum sabit seçenek listesi demek; kullanıcı istediğini yazamıyor, sadece listedeki seçeneklerden birini seçiyor
// Böylece "nkait" gibi yazım hatası yapma ihtimali kalmıyor, hata program çalışmadan önce (derleme zamanında) yakalanıyor
enum HizmetKategorisi { ciltYenileme, medikalEstetik, lazerEpilasyon, Lipo }
// Klinikteki 4 hizmet türünü tanımlar, başka bir kategori yazılamaz
// (Lipo'yu büyük harfle yazmışım, Dart kuralına göre küçük harfle başlaması daha doğru olurdu ama çalışmasına engel değil)

enum SeansDurumu { bekliyor, odadaIslemde, tamamlandi, iptalEdildi }
// Bir randevunun geçebileceği 4 durum, kargo takibindeki hazırlanıyor/yolda/teslim edildi gibi düşündüm

enum OdemeYontemi { krediKarti, havaleEft, nakit, klinikPaketKredisi }
// Ödemenin hangi yolla yapılabileceğini gösteren 4 seçenek

//Danışan (müşteri) Modeli
// Model = veriyi tutan kalıp, boş bir danışan kayıt formu gibi; her müşteri için bu formdan bir tane dolduracağım
class Danisan {
  // Danisan adında bir kalıp (sınıf) başlatır, içindeki her şey süslü parantezin içinde
  final String id;
  // Danışanın kimlik kodu (yazı); final olduğu için bir kere verilince bir daha değişemez
  final String adSoyad;
  // Danışanın adı soyadı (yazı), değişmez
  final String telefon;
  // Telefon numarası (yazı), değişmez
  final bool vipUyeMi;
  // bool sadece true ya da false tutar; VİP üye mi sorusunun cevabı evet/hayır
  final List<String> alerjiler; // boş olabilir ama null olamaz
  // Yazılardan oluşan bir liste; alerjisi yoksa boş liste olur ama "hiç yok (null)" olamaz, çünkü tipin sonunda ? yok
  final String? ozelCiltNotu; // Opsiyonel Null olabilir
  // Tipin sonundaki ? "boş bırakılabilir" demek, her danışan için özel not yazılmak zorunda değil

  const Danisan({
    // Constructor (yapıcı): yeni bir danışan oluştururken hangi bilgileri vereceğimi belirliyor; const = oluştuktan sonra değişmeyen nesne
    required this.id,
    // required = zorunlu, id verilmezse hata alırım; this.id gelen değeri bu nesnenin id alanına atıyor
    required this.adSoyad,
    // Ad soyad zorunlu
    required this.telefon,
    // Telefon zorunlu
    this.vipUyeMi = false,
    // Zorunlu değil; verilmezse otomatik false yani VİP değil sayılıyor
    this.alerjiler = const [],
    // Zorunlu değil; verilmezse boş liste oluyor
    this.ozelCiltNotu,
    // Zorunlu değil; verilmezse otomatik null oluyor
  });
  // Constructor burada bitiyor

  bool get hassasCiltMi => alerjiler.isNotEmpty;
  // Getter, alan gibi kullanılan ama arkada hesap yapan bir şey; alerji listesi boş DEĞİLSE true döner yani cilt hassas sayılıyor
  // (=> "şuna eşittir" anlamında; ama main'de bunu kullanmadım)

  //Bilgi özet kartı
  // Danışanın bütün bilgilerini tek cümlede toplayan getter
  String get bilgiOzeti {
    // Sonucu yazı (String) olarak geri verecek
    final String alerjiBilgisi = alerjiler.isEmpty
        // Alerji listesi boş mu diye bakıyor
        ? "Kayıtlı Alerji Yok"
        // ? işaretinden sonrası: liste boşsa bu yazı seçilir (üçlü operatör: koşul ? doğruysa : yanlışsa)
        : "Alerjiler: ${alerjiler.join(', ')}";
    // : işaretinden sonrası: liste doluysa alerjileri araya virgül koyarak tek yazıya birleştirir (join)
    // ${} yazının içine değişken gömmemi sağlıyor
    final String notBilgisi = ozelCiltNotu ?? "Özel medikal not girilmemiş";
    // ?? "soldaki null ise sağdakini kullan" demek; not yazılmışsa onu alır, yazılmamışsa "Özel medikal not girilmemiş" yazar
    final String vipRozeti = vipUyeMi ? "VİP" : "Standart";
    // VİP üyeyse "VİP", değilse "Standart" yazısını seçer
    return "$vipRozeti $adSoyad ($telefon) | $alerjiBilgisi | Not: $notBilgisi";
    // Yukarıdaki parçaları tek cümlede birleştirip geri verir; $ ile değişkenlerin değerini yazının içine koyuyorum
  }

  // Getter burada bitiyor
}
// Danisan sınıfı burada bitiyor

// Seans (randevu) Modeli
// Randevu fişinin kalıbı; üzerinde danışan, işlem, fiyat, seans sayısı, indirim, uzman ve durum yazıyor

class SeansKaydi {
  // SeansKaydi adında randevu fişi kalıbı başlatır
  final String seansKodu;
  // Fişin numarası (SNS-2026-1 gibi), değişmez
  final Danisan danisan;
  // Tipi Danisan; yani fişin içine danışanın bütün kartını koyuyorum (bir sınıfın içinde başka bir sınıf kullanmış oluyorum)
  final HizmetKategorisi kategori;
  // Tipi yukarıda yazdığım enum; sadece o 4 kategoriden biri olabilir
  final String islemAdi;
  // Yapılacak işlemin adı
  final double birimFiyat;
  // double ondalıklı sayı demek; tek bir seansın fiyatı
  final int seansSayisi;
  // int tam sayı demek; kaç seans alındığı
  final double indirimOrani; // Örn 10.0
  // İndirim yüzdesi, 10.0 yazarsam %10 demek
  final String? sorumluUzman;
  // Uzmanın adı; ? var çünkü randevu alınmış ama uzman henüz atanmamış olabilir
  SeansDurumu durum;
  // Burada final yok çünkü durum zamanla değişecek (bekliyor -> tamamlandı gibi)
  OdemeYontemi? odemeTipi;
  // Bunda da final yok ve ? var, çünkü ödeme sonradan yapılıyor, başta boş kalıyor

  SeansKaydi({
    // Constructor: fiş yazarken hangi bilgilerin verileceğini belirliyor
    required this.seansKodu,
    // Zorunlu: fiş kodu
    required this.danisan,
    // Zorunlu: danışan
    required this.kategori,
    // Zorunlu: kategori
    required this.islemAdi,
    // Zorunlu: işlem adı
    required this.birimFiyat,
    // Zorunlu: birim fiyat
    this.seansSayisi = 1,
    // Verilmezse 1 seans sayılıyor
    this.indirimOrani = 0.0,
    // Verilmezse indirim yok
    this.sorumluUzman,
    // Verilmezse uzman boş (null) kalıyor
    this.durum = SeansDurumu.bekliyor,
    // Verilmezse durum otomatik "bekliyor" oluyor
    this.odemeTipi,
    // Verilmezse ödeme tipi boş kalıyor
  });
  // Constructor burada bitiyor

  double get brutTutar => birimFiyat * seansSayisi;
  // Brüt tutar = indirim uygulanmadan önceki toplam = tek seans fiyatı x seans sayısı

  double get indirimTutari {
    // İndirimin kaç TL olduğunu hesaplayan getter
    double toplamOran = indirimOrani;
    // Başlangıçta toplam oran, fişteki indirim yüzdesine eşit
    if (danisan.vipUyeMi) {
      // Fişteki danışan VİP üyeyse
      toplamOran += 10.0;
      // += "mevcut değerin üstüne ekle" demek; VİP'e ekstra %10 indirim ekliyorum
    }
    // if burada bitiyor
    return brutTutar * (toplamOran / 100.0);
    // Yüzdeyi 100'e bölüp (%15 -> 0.15) brüt tutarla çarpıyorum, çıkan sonuç indirimin TL karşılığı
  }
  // Getter burada bitiyor

  double get netTutar => brutTutar - indirimTutari;
  // Net tutar = müşterinin gerçekten ödeyeceği para = brüt tutar - indirim tutarı
}
// SeansKaydi sınıfı burada bitiyor

// Yönetim Servisi
// Bu sınıf resepsiyon görevlisi gibi; danışanları ve randevu fişlerini toplayıp yönetiyor, gün sonunda rapor çıkarıyor

class KlinikYoneticisi {
  // Klinik yöneticisi kalıbını başlatır
  final String subeAdi;
  // Şubenin adı (şimdilik sadece saklıyorum, raporda yazdırmadım)
  final List<SeansKaydi> _seanslar = [];
  // Başta boş olan randevu defteri; ismin başındaki _ "özel" demek, yani dışarıdan doğrudan erişilemiyor, sadece bu sınıfın içinden kullanılabiliyor
  final Map<String, Danisan> _danisanRehberi = {};
  // Map sözlük gibi çalışıyor; anahtar olarak danışanın id'si (yazı), karşılığında da Danisan kartı tutuyor, telefon rehberi gibi

  KlinikYoneticisi({required this.subeAdi});
  // Constructor: yönetici oluştururken şube adını vermek zorunlu

  //Danışan kaydetme
  // Danışanı rehbere ekleyen fonksiyon
  void danisanKaydet(Danisan danisan) {
    // void = bu fonksiyon bir iş yapıyor ama geriye değer döndürmüyor; parametre olarak bir Danisan kartı alıyor
    _danisanRehberi[danisan.id] = danisan;
    // Rehbere ekliyor: anahtar danışanın id'si, değer danışanın kendisi
    print(
      // print ekrana yazdırır
      "Rehbere Eklendi: ${danisan.adSoyad} (${danisan.vipUyeMi ? "VİP" : "Standart"})",
      // Ekranda "Rehbere Eklendi: Ahmet Yılmaz (VİP)" gibi görünür; parantezin içinde de üçlü operatör kullandım
    );
  }
  // Fonksiyon burada bitiyor

  void randevuOlustur(SeansKaydi seans) {
    // Bir randevu fişini alıp deftere yazan fonksiyon
    _seanslar.add(seans);
    // add listeye ekler; fişi randevu defterinin sonuna yazıyor
    print(
      // Ekrana bilgi mesajı yazdırır
      "Randevu Kaydedildi [${seans.seansKodu}]: ${seans.danisan.adSoyad}->${seans.islemAdi}",
      // seans.danisan.adSoyad şu demek: fişin içindeki danışana gir, onun adını al; nokta nokta içeri girebiliyorum
    );
  }
  // Fonksiyon burada bitiyor

  void seansiTamamla({required String seansKodu, required OdemeYontemi odeme}) {
    // Süslü parantez içindeki parametreler isimli parametre; çağırırken seansKodu: ..., odeme: ... diye adını yazıyorum, okunması kolay oluyor
    for (var seans in _seanslar) {
      // Döngü: defterdeki fişleri sırayla tek tek eline alıyor, her birine "seans" diyorum
      if (seans.seansKodu == seansKodu) {
        // Elimdeki fişin kodu aradığım kodla aynı mı diye karşılaştırıyor (== karşılaştırma demek)
        seans.durum = SeansDurumu.tamamlandi;
        // Bulunan seansın durumunu "tamamlandı" yapar
        seans.odemeTipi = odeme;
        // Ödeme yöntemini fişe kaydeder
        print(
          // Ekrana tahsilat mesajını yazdırır
          "Seans Tamamlandı: [${seans.seansKodu}]: ${seans.netTutar.toStringAsFixed(2)} tahsil edildi (${odeme.name})",
          // toStringAsFixed(2) sayıyı virgülden sonra 2 basamakla yazıyor (11050.00 gibi); odeme.name enum'un adını yazıya çeviriyor
        );
      }
      // if burada bitiyor
    }
    // for döngüsü burada bitiyor
    print("Hata [$seansKodu] kodlu seans bulunamadı");
    // Dikkat: bu satır if'in dışında olduğu için seans bulunsa bile her zaman çalışıyor, o yüzden tamamlanan seanslardan sonra da ekrana bu hata yazısı çıkıyor
    return;
    // Fonksiyonu bitirir; asıl doğrusu bu return'ün if bloğunun içinde olması (bulunca hemen çıkması)
  }
  // Fonksiyon burada bitiyor

  void seansiIptalEt(String seansKodu, {String? iptalNedeni}) {
    // İlk parametre normal, iptalNedeni ise isimli ve isteğe bağlı (? olduğu için boş bırakılabilir)
    for (var seans in _seanslar) {
      // Defterdeki her fişe sırayla bakıyor
      if (seans.seansKodu == seansKodu) {
        // Kod eşleşti mi diye kontrol ediyor
        seans.durum = SeansDurumu.iptalEdildi;
        // Durumu "iptal edildi" yapar
        print(
          // Ekrana iptal mesajını yazdırır
          "Seans İptal Edildi [${seans.seansKodu}]: ${iptalNedeni ?? "Gerekçe Belirtilmedi"}",
          // ?? sayesinde gerekçe yazılmadıysa "Gerekçe Belirtilmedi" çıkıyor
        );
        return;
        // İşimiz bitti, fonksiyondan hemen çıkıyor; bu return burada doğru yerde
      }
      // if burada bitiyor
    }
    // for burada bitiyor; kod hiç eşleşmezse ekrana hiçbir şey yazılmıyor
  }
  // Fonksiyon burada bitiyor

  // Finansal Rapor Metotları(fonksiyonel dart)
  // Aşağıdakiler bir sürü fişi süzgeçten geçirip toplama işleri
  double get toplamTahsilEdilenCiro => _seanslar
      // Bütün fişlerden başlıyor
      .where((s) => s.durum == SeansDurumu.tamamlandi)
      // where filtre gibi; her fişe s diyor ve sadece durumu "tamamlandı" olanları bırakıyor
      .fold(0.0, (toplam, s) => toplam + s.netTutar);
  // fold toplama makinesi; 0'dan başlıyor, kalan her fişin net tutarını üstüne ekliyor, sonuçta kasadaki para çıkıyor

  double get beklenenPotansiyelCiro => _seanslar
      // Henüz kasaya girmemiş, beklenen paranın hesabı; yine bütün fişlerden başlıyor
      .where(
        // Filtre başlıyor
        (s) =>
            // Her fiş için (adı s)
            s.durum == SeansDurumu.bekliyor ||
            // Durum "bekliyor" VEYA (|| veya demek)
            s.durum == SeansDurumu.odadaIslemde,
        // durum "odada işlemde" olanlar kalsın
      )
      // Filtre burada bitiyor
      .fold(0.0, (toplam, s) => toplam + s.netTutar);
  // Süzülen fişlerin net tutarlarını 0'dan başlayarak topluyor

  // kategori bazlı seans sayıları
  // Hangi kategoriden kaç seans olduğunu bulan fonksiyon (main'de çağırmadım ama hazır duruyor)

  Map<HizmetKategorisi, int> kategoriBazliSeansDagilimi() {
    // Sonucu bir sözlük olarak veriyor: kategori -> seans sayısı
    final Map<HizmetKategorisi, int> dagilim = {};
    // Başta boş bir sözlük açıyorum
    for (var kat in HizmetKategorisi.values) {
      // .values enum'daki bütün seçenekleri verir, hepsini sırayla geziyorum
      dagilim[kat] = 0;
      // Her kategorinin sayacını 0'a ayarlıyorum ki hiç seansı olmayan kategori de listede 0 olarak görünsün
    }
    // for burada bitiyor
    for (var s in _seanslar) {
      // Bu sefer bütün randevu fişlerini geziyorum
      dagilim[s.kategori] = (dagilim[s.kategori] ?? 0) + 1;
      // Fişin kategorisinin sayacını 1 artırıyorum; ?? 0 sayaç boş çıkarsa 0 say demek, ekstra güvenlik
    }
    // for burada bitiyor
    return dagilim;
    // Doldurulmuş sayaç sözlüğünü geri veriyor
  }
  // Fonksiyon burada bitiyor

  Set<String> gorevliUzmanKadrosu() {
    // Set aynı elemandan iki tane tutmayan bir küme; görevli uzmanların isimlerini tekrarsız verecek
    return _seanslar.map((s) => s.sorumluUzman).whereType<String>().toSet();
    // map: her fişten sadece uzman adını çekiyor
    // whereType<String>(): null olanları eliyor, sadece gerçek isimler kalıyor
    // toSet(): kümeye çeviriyor, aynı uzman birden fazla fişte olsa bile listede bir kere görünüyor
  }
  // Fonksiyon burada bitiyor

  //Uzmansız kalan seanslar
  // Uzmanı henüz atanmamış fişleri bulan fonksiyon
  List<SeansKaydi> uzmansizSeanslariGetir() {
    // Sonucu fişlerden oluşan bir liste olarak veriyor
    return _seanslar.where((s) => s.sorumluUzman == null).toList();
    // Uzmanı null olan fişleri süzüp liste haline getiriyor
  }
  // Fonksiyon burada bitiyor

  void gunSonuRaporuYazdir() {
    // Günün sonunda tüm raporu ekrana yazdıran fonksiyon
    print("Günlük Seans ve İşlem Çizelgesi");
    // Raporun başlığını yazdırır
    print("---------------------------------------");
    // Ayırıcı çizgi
    print(
      // Tablonun başlık satırını yazdırıyor
      "${'Kod'.padRight((10))} | "
      // padRight(10) yazıyı sağdan boşlukla 10 karaktere tamamlıyor, böylece sütunlar alt alta hizalı görünüyor
      "${'Danışan'.padRight(16)} | "
      // Danışan sütunu 16 karakter genişliğinde
      "${'İşlem'.padRight(20)} | "
      // İşlem sütunu 20 karakter genişliğinde
      "${'Uzman'.padRight(18)} | "
      // Uzman sütunu 18 karakter genişliğinde
      "${'Tutar'.padRight(10)} | "
      // Tutar sütunu 10 karakter genişliğinde
      "${'Durum'} | ",
      // Durum sütunu; yan yana yazdığım tırnaklı yazılar Dart'ta otomatik birleşiyor
    );
    print("---------------------------------------");
    // Başlıktan sonra ayırıcı çizgi

    for (var s in _seanslar) {
      // Her randevu için tabloya bir satır yazacağım
      final String uzman = s.sorumluUzman ?? " Nöbetçi Bekliyor";
      // Uzman atanmamışsa (null) yerine " Nöbetçi Bekliyor" yazıyor
      final String durumRozet = switch (s.durum) {
        // switch çoklu seçim gibi; durum neyse ona göre bir yazı seçiyor
        SeansDurumu.tamamlandi => "Tamamlandı",
        // Durum tamamlandıysa "Tamamlandı"
        SeansDurumu.odadaIslemde => "İşlemde",
        // Odada işlemdeyse "İşlemde"
        SeansDurumu.bekliyor => "Bekliyor",
        // Bekliyorsa "Bekliyor"
        SeansDurumu.iptalEdildi => "İptal",
        // İptal edildiyse "İptal"; enum'un 4 seçeneğinin hepsini yazmak zorundayım, biri eksik olursa Dart hata veriyor
      };
      // switch burada bitiyor

      print(
        // Tablonun bir satırını yazdırıyor
        "${s.seansKodu.padRight(10)} | "
        // Seans kodunu 10 karaktere tamamlıyor
        "${s.danisan.adSoyad.padRight(10)} | "
        // Danışan adı; burada 10 yazmışım ama başlıkta 16'ydı, isim 10 harften uzunsa padRight kesmiyor sadece uzatıyor, sütun kayıyor
        "${s.islemAdi.padRight(10)} | "
        // İşlem adı; başlıkta 20 yazmıştım burada 10 kalmış
        "${uzman.padRight(10)} | "
        // Uzman adı; başlıkta 18 yazmıştım burada 10 kalmış
        "${s.netTutar.toStringAsFixed(2).padRight(10)} | "
        // Net tutarı 2 basamaklı yazıya çevirip 10 karaktere tamamlıyor
        "$durumRozet",
        // Yukarıda seçtiğim durum yazısını ekliyor
      );
    }
    // for burada bitiyor

    print("---------------------------------------");
    // Ayırıcı çizgi
    print("Finansal Özet:");
    // Özet bölümünün başlığı
    print(
      // Kasadaki parayı yazdırıyor
      " * Gerçekleşen (kasadaki net ciro) : ${toplamTahsilEdilenCiro.toStringAsFixed(2)}",
      // Yukarıdaki getter'ı çağırıp tahsil edilen toplamı 2 basamaklı yazıyor
    );
    print(
      // Bekleyen parayı yazdırıyor
      " * Bekleyen Potansiyen Alacak : ${beklenenPotansiyelCiro.toStringAsFixed(2)}",
      // Beklenen toplamı 2 basamaklı yazıyor
    );
    print(" * Toplam Seans : ${_seanslar.length} Randevu");
    // .length listedeki eleman sayısı, yani toplam kaç randevu var
    print("---------------------------------------");
    // Ayırıcı çizgi
    print("Aktif Uzmanlar");
    // Uzman bölümünün başlığı
    final uzmanlar = gorevliUzmanKadrosu();
    // Uzman isimlerinden oluşan kümeyi alıyorum (tipi kendisi anlıyor)
    if (uzmanlar.isEmpty) {
      // Küme boşsa
      print("Kayıtlı Uzman Bulunamadı");
      // Bu mesajı yazdırıyor
    } else {
      // Boş değilse
      print(" ${uzmanlar.join(', ')}");
      // Uzman isimlerini araya virgül koyarak tek satırda yazdırıyor
    }
    // if-else burada bitiyor
    final uzmansizlar = uzmansizSeanslariGetir();
    // Uzmanı atanmamış fişleri alıyorum
    if (uzmansizlar.isNotEmpty) {
      // Böyle bir fiş varsa uyarı yazdıracağım
      print(
        // Uyarı mesajını yazdırıyor
        "Dikkat: ${uzmansizlar.length} adet seansa henüz uzman atanmamıştır",
        // Kaç tane uzmansız seans olduğunu da yazıyor
      );
      for (var u in uzmansizlar) {
        // Uzmansız fişlerin hepsini tek tek geziyor
        print("->[${u.seansKodu}] ${u.danisan.adSoyad} (${u.islemAdi})");
        // Her birinin kodunu, danışan adını ve işlem adını alt alta listeliyor
      }
      // for burada bitiyor
    }
    // if burada bitiyor
    print("---------------------------------------");
    // Raporun son çizgisi
  }

  // gunSonuRaporuYazdir burada bitiyor
}
// KlinikYoneticisi sınıfı burada bitiyor

void main() {
  // Dart programı her zaman main fonksiyonundan başlıyor, kod çalışmaya buradan giriyor
  print("Klinik yönetim sistemi başlatılıyor....");
  // Program başlarken ekrana bu mesajı yazdırıyor
  final yonetici = KlinikYoneticisi(subeAdi: "Softito Bağcılar Şubesi");
  // KlinikYoneticisi kalıbından bir nesne üretip adını yonetici koyuyorum, yani resepsiyon görevlisini işe aldım

  //danışanları oluşturalım
  // Şimdi 4 tane danışan kartı dolduracağım
  final d1 = Danisan(
    // 1. danışan kartı
    id: "DAN-101",
    // Kimlik kodu
    adSoyad: "Ahmet Yılmaz",
    // Ad soyad
    telefon: "0555 555 55 55",
    // Telefon
    vipUyeMi: true,
    // VİP üye
    alerjiler: ["Retinol,Aspirin"],
    // Dikkat: virgül tırnağın içinde olduğu için liste tek elemanlı oluyor; iki ayrı alerji olsun istersem ["Retinol", "Aspirin"] yazmam gerekir
    ozelCiltNotu: "Cilt bariyeri hassas",
    // Özel cilt notu
  );
  // d1 burada bitiyor
  final d2 = Danisan(
    // 2. danışan kartı
    id: "DAN-102",
    // Kimlik kodu
    adSoyad: "Ahmet Yılan",
    // Ad soyad
    telefon: "0555 555 55 55",
    // Telefon
    vipUyeMi: false,
    // VİP değil
    alerjiler: [],
    // Alerjisi yok, boş liste; özel not vermediğim için o alan null kalıyor
  );
  // d2 burada bitiyor
  final d3 = Danisan(
    // 3. danışan kartı
    id: "DAN-103",
    // Kimlik kodu
    adSoyad: "Mehmet Yılmaz",
    // Ad soyad
    telefon: "0555 555 55 55",
    // Telefon
    vipUyeMi: true,
    // VİP üye
    alerjiler: ["Retinol,Aspirin"],
    // Burada da d1'deki gibi tek elemanlı liste oluyor
  );
  // d3 burada bitiyor
  final d4 = Danisan(
    // 4. danışan kartı
    id: "DAN-104",
    // Kimlik kodu
    adSoyad: "Ahmet Mehmet Yılmaz",
    // Ad soyad
    telefon: "0555 555 55 55",
    // Telefon
    vipUyeMi: true,
    // VİP üye
    alerjiler: [],
    // Alerjisi yok
    ozelCiltNotu: "Cilt bariyeri hassas",
    // Özel cilt notu
  );
  // d4 burada bitiyor

  yonetici.danisanKaydet(d1);
  // 1. kartı resepsiyona teslim ediyorum, ekrana "Rehbere Eklendi" yazılıyor
  yonetici.danisanKaydet(d2);
  // 2. kart
  yonetici.danisanKaydet(d3);
  // 3. kart
  yonetici.danisanKaydet(d4);
  // 4. kart

  print("Danışan güvenlik kontrolü");
  // Bölüm başlığı yazdırıyor
  print(d1.bilgiOzeti);
  // d1'in bilgi özetini (VİP, alerjiler, not) ekrana yazdırıyor
  print(d2.bilgiOzeti);
  // d2'nin bilgi özetini yazdırıyor; alerjisi ve notu olmadığı için "Kayıtlı Alerji Yok" ve "Özel medikal not girilmemiş" görünecek
  print("----------------------------------");
  // Ayırıcı çizgi

  // randevular oluşturuluyor
  // Şimdi 4 randevu fişi yazıyorum
  final seans1 = SeansKaydi(
    // 1. randevu fişi
    seansKodu: "SNS-2026-1",
    // Fiş kodu
    danisan: d1,
    // Fişe d1 danışanının kartını bağlıyorum
    kategori: HizmetKategorisi.Lipo,
    // Enum'dan Lipo kategorisini seçtim
    islemAdi: "Lipo gerisini bilmiyorum",
    // İşlem adı
    birimFiyat: 6500.0,
    // Tek seans 6500 TL
    seansSayisi: 2,
    // 2 seans
    indirimOrani: 5.0,
    // %5 indirim; danışan VİP olduğu için toplam %15 olacak
    sorumluUzman: "Sümeyye Arab",
    // Atanan uzman
  );
  // seans1 burada bitiyor (brüt 13000, indirim 1950, net 11050)
  final seans2 = SeansKaydi(
    // 2. randevu fişi
    seansKodu: "SNS-2026-2",
    // Fiş kodu
    danisan: d2,
    // d2 danışanı, VİP değil
    kategori: HizmetKategorisi.ciltYenileme,
    // Cilt yenileme kategorisi
    islemAdi: "Siverex ile tyüz temizleme",
    // İşlem adı (tyüz diye yazmışım, yüz olacaktı, yazım hatası)
    birimFiyat: 2500.0,
    // Tek seans 2500 TL
    seansSayisi: 5,
    // 5 seans
    indirimOrani: 15.0,
    // %15 indirim
    sorumluUzman: null,
    // Uzman henüz atanmadı (null), raporda "Nöbetçi Bekliyor" olarak görünecek
  );
  // seans2 burada bitiyor (brüt 12500, indirim 1875, net 10625)
  final seans3 = SeansKaydi(
    // 3. randevu fişi
    seansKodu: "SNS-2026-3",
    // Fiş kodu
    danisan: d3,
    // d3 danışanı, VİP
    kategori: HizmetKategorisi.lazerEpilasyon,
    // Lazer epilasyon kategorisi
    islemAdi: "Tüm Vücut",
    // İşlem adı
    birimFiyat: 25000.0,
    // Tek seans 25000 TL
    seansSayisi: 15,
    // 15 seans
    indirimOrani: 0.0,
    // Fişte indirim yok, sadece VİP'ten gelen %10 uygulanacak
    sorumluUzman: "Tuba Aydın",
    // Atanan uzman
  );
  // seans3 burada bitiyor (brüt 375000, indirim 37500, net 337500)
  final seans4 = SeansKaydi(
    // 4. randevu fişi
    seansKodu: "SNS-2026-4",
    // Fiş kodu (aşağıda iptal ederken "SNS-2026-04" yazmışım, ikisi aynı değil)
    danisan: d4,
    // d4 danışanı, VİP
    kategori: HizmetKategorisi.medikalEstetik,
    // Medikal estetik kategorisi
    islemAdi: "Burun Estetiği",
    // İşlem adı
    birimFiyat: 1500.0,
    // Tek seans 1500 TL
    seansSayisi: 3,
    // 3 seans
    sorumluUzman: "Alaaddin Odabaşı",
    // Atanan uzman; indirimOrani vermediğim için varsayılan 0.0 kullanılıyor
  );
  // seans4 burada bitiyor (brüt 4500, indirim 450, net 4050)
  yonetici.randevuOlustur(seans1);
  // 1. fişi deftere ekliyor
  yonetici.randevuOlustur(seans2);
  // 2. fişi deftere ekliyor
  yonetici.randevuOlustur(seans3);
  // 3. fişi deftere ekliyor
  yonetici.randevuOlustur(seans4);
  // 4. fişi deftere ekliyor
  print("Seanslar Gönderiliyor");
  // Bilgi mesajı yazdırıyor

  //seans 1 başarıyla tamamlanıyor (kredi kartı ile ödeme);
  // Şimdi 1. seansı tamamlıyorum
  yonetici.seansiTamamla(
    // Fonksiyonu isimli parametrelerle çağırıyorum
    seansKodu: "SNS-2026-1",
    // Hangi seansın tamamlanacağı
    odeme: OdemeYontemi.krediKarti,
    // Ödeme yöntemi kredi kartı
  );
  // Çağrı burada bitiyor (return'ün yeri yüzünden bunun ardından ekrana bir de "Hata... bulunamadı" yazısı çıkıyor)
  //seans 2 başarıyla tamamlanıyor (nakit ödeme);
  // 2. seansı tamamlıyorum
  yonetici.seansiTamamla(seansKodu: "SNS-2026-2", odeme: OdemeYontemi.nakit);
  // 2. seans nakit ödemeyle tamamlanıyor
  //seans 4 iptal ediliyor
  // 4. seansı iptal edeceğim
  yonetici.seansiIptalEt(
    // İptal fonksiyonunu çağırıyorum
    "SNS-2026-04",
    // Seans kodunu "SNS-2026-04" yazmışım ama seans4'ün kodu "SNS-2026-4"; eşleşmediği için bu iptal gerçekleşmiyor ve ekrana da bir şey yazılmıyor
    iptalNedeni: "Danışanın şehir dışından tanıdığı geldiği için gelemedi",
    // İptal gerekçesi (isimli parametre olarak verdim)
  );
  // Çağrı burada bitiyor

  yonetici.gunSonuRaporuYazdir();
  // Gün sonu raporunu ekrana yazdırıyor: tablo, finansal özet, uzmanlar ve uzmansız seanslar
}

// main burada bitiyor, program sona eriyor
