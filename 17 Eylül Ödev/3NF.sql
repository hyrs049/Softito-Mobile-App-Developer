/* 
   ÖĞRENCİ - BÖLÜM - DERS İLİŞKİSİNİN 3NF'YE NORMALİZASYONU
   

  Normalize edilmemiş = 1NF tek tablo :

   Kayitlar (
       OgrenciNo, OgrenciAdi, OgrenciSoyadi,
       BolumKodu, BolumAdi, BolumBaskani,
       DersKodu, DersAdi, DersKredisi,
       AlinanNot
   )

   Bu tabloda tekrar eden gruplar yoktur (her hücre tek bir değer
   tutuyor), bu yüzden zaten 1NF kuralını sağlıyor. Ama şu sorunlar var:

   1)2NF İhlali(kısmi bağımlılık):
      Bu tablonun asıl anahtarı (OgrenciNo, DersKodu) ikilisidir çünkü
      bir öğrenci birden fazla ders alabilir. Ama OgrenciAdi, sadece
      OgrenciNo'ya bağlıdır, DersKodu'na hiç ihtiyacı yoktur. Yani
      anahtarın SADECE BİR PARÇASINA bağlı bir bilgi var → bu "kısmi
      bağımlılık"tır ve 2NF'yi ihlal eder.

   2) 3NF İhlali(geçişli bağımlılık):
      BolumAdi ve BolumBaskani, öğrenciye değil, BolumKodu'na bağlıdır.
      Yani zincir şöyledir: OgrenciNo -> BolumKodu -> BolumAdi.
      BolumAdi, anahtar olmayan bir sütun (BolumKodu) üzerinden dolaylı
      yoldan anahtara bağlanıyor. Buna "geçişli bağımlılık" denir ve
      3NF bunu yasaklar. Aynı sorun DersKodu -> DersAdi, DersKredisi
      için de geçerlidir.

   Kısacası: "Bir bölümün adı değişirse, o bölümdeki HER öğrencinin
   satırında bu bilgiyi tek tek güncellemek gerekir" — bu, verinin
   gereksiz yere tekrar ettiğinin işaretidir. 3NF'nin
   amacı tam olarak bunu önlemektir: her bilgi sadece bir yerde,
   "kendi ait olduğu" tabloda tutulmalıdır.

   
   
  Fonksiyonel Bağımlılıklar;
   OgrenciNo              -> OgrenciAdi, OgrenciSoyadi, BolumKodu
   BolumKodu              -> BolumAdi, BolumBaskani
   DersKodu               -> DersAdi, DersKredisi
   (OgrenciNo, DersKodu)  -> AlinanNot

   
   3NF Sonucu;

   Bolum(BolumKodu PK, BolumAdi, BolumBaskani)
   Ogrenci(OgrenciNo PK, OgrenciAdi, OgrenciSoyadi, BolumKodu FK)
   Ders(DersKodu PK, DersAdi, DersKredisi)
   Kayit(OgrenciNo FK, DersKodu FK, AlinanNot)  -- Öğrenci-Ders ilişkisi (M:N)

   Artık her tabloda "anahtar olmayan her sütun, doğrudan ve sadece o
   tablonun anahtarına bağlı" — 3NF kuralı tam olarak budur.
   
*/

-- 1) BÖLÜM TABLOSU
--    Her bölüm tek bir satırda tutulur, bölüm bilgisi hiçbir
--    yerde tekrar etmez.

CREATE TABLE Bolum (
    BolumKodu     VARCHAR(10)  PRIMARY KEY,
    BolumAdi      VARCHAR(100) NOT NULL,
    BolumBaskani  VARCHAR(100)
);



-- 2) Öğrenci Tablosu
--    Her öğrenci bir bölüme bağlıdır (BolumKodu foreign key).

CREATE TABLE Ogrenci (
    OgrenciNo      VARCHAR(15) PRIMARY KEY,
    OgrenciAdi     VARCHAR(50) NOT NULL,
    OgrenciSoyadi  VARCHAR(50) NOT NULL,
    BolumKodu      VARCHAR(10) NOT NULL,
    CONSTRAINT fk_ogrenci_bolum
        FOREIGN KEY (BolumKodu) REFERENCES Bolum(BolumKodu)
);



-- 3) Ders Tablosu
--    Ders bilgisi (ad, kredi) sadece burada, tek satırda tutulur.
CREATE TABLE Ders (
    DersKodu      VARCHAR(10)  PRIMARY KEY,
    DersAdi       VARCHAR(100) NOT NULL,
    DersKredisi   INT          NOT NULL CHECK (DersKredisi > 0)
);



-- 4) Kayıt Tablosu (Öğrenci-Ders ara/ilişki tablosu)
--    Bir öğrenci birden fazla ders alabilir, bir ders birden
--    fazla öğrenci tarafından alınabilir (M:N ilişki).


CREATE TABLE Kayit (
    OgrenciNo   VARCHAR(15)   NOT NULL,
    DersKodu    VARCHAR(10)   NOT NULL,
    AlinanNot   DECIMAL(5,2),
    PRIMARY KEY (OgrenciNo, DersKodu),
    CONSTRAINT fk_kayit_ogrenci
        FOREIGN KEY (OgrenciNo) REFERENCES Ogrenci(OgrenciNo),
    CONSTRAINT fk_kayit_ders
        FOREIGN KEY (DersKodu) REFERENCES Ders(DersKodu)
);
