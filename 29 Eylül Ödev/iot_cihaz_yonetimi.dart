enum CihazTipi { sensor, gateway, edgeServer, router }

class IoTCihaz {
  final String seriNo;
  final String cihazAdi;
  final CihazTipi tip;
  final double cpuYukYuzdesi;
  final int bellekMb;
  final Set<String> acikPortlar;
  final bool sslSertifikasiGecerliMi;
  final bool calisiyorMu; // false ise cihaz kapalı

  IoTCihaz({
    required this.seriNo,
    required this.cihazAdi,
    required this.tip,
    required this.cpuYukYuzdesi,
    required this.bellekMb,
    required this.acikPortlar,
    required this.sslSertifikasiGecerliMi,
    this.calisiyorMu = true,
  });

  // SSL geçersizse VEYA Telnet portu açıksa güvenlik açığı vardır
  bool get guvenlikAcigiVarMi =>
      !sslSertifikasiGecerliMi || acikPortlar.contains("23/TELNET");

  // Güvenlik açığı varsa VEYA CPU %85'ten büyükse riskli
  bool get riskliMi => guvenlikAcigiVarMi || cpuYukYuzdesi > 85;

  @override
  String toString() =>
      "$cihazAdi [$seriNo] (${tip.name}) - CPU: %$cpuYukYuzdesi, Bellek: $bellekMb MB";
}

class CihazErisilemezException implements Exception {
  final String mesaj;

  CihazErisilemezException(this.mesaj);

  @override
  String toString() => mesaj;
}

//Servis Katmanı

class IoTAgi {
  final List<IoTCihaz> cihazlar;

  IoTAgi(this.cihazlar);

  // where() ile sadece riskli cihazları seçilir
  List<IoTCihaz> riskliCihazlariBul() {
    return cihazlar.where((cihaz) => cihaz.riskliMi).toList();
  }

  // fold() ile toplam bellek hesaplanır
  int toplamBellekMb() {
    return cihazlar.fold<int>(0, (toplam, cihaz) => toplam + cihaz.bellekMb);
  }

  // Seri numarasına göre cihaz bilgisi (Record döner)
  // Bulunamazsa exception fırlatıyoruz.
  ({String cihazAdi, CihazTipi tip, bool alarmDurumu}) cihazBilgisiGetir(
    String seriNo,
  ) {
    final cihaz = cihazlar.firstWhere(
      (c) => c.seriNo == seriNo,
      orElse: () => throw CihazErisilemezException(
        "Seri no '$seriNo' olan bir cihaz ağda bulunamadı.",
      ),
    );

    return (
      cihazAdi: cihaz.cihazAdi,
      tip: cihaz.tip,
      alarmDurumu: cihaz.riskliMi,
    );
  }

  // Cihaza bağlanmayı dener; cihaz kapalıysa exception fırlatır
  void cihazaBaglan(String seriNo) {
    final cihaz = cihazlar.firstWhere(
      (c) => c.seriNo == seriNo,
      orElse: () => throw CihazErisilemezException(
        "Seri no '$seriNo' olan bir cihaz ağda bulunamadı.",
      ),
    );

    if (!cihaz.calisiyorMu) {
      throw CihazErisilemezException(
        "${cihaz.cihazAdi} (${cihaz.seriNo}) kapalı, bağlantı kurulamadı.",
      );
    }

    print("${cihaz.cihazAdi} cihazına başarıyla bağlanıldı.");
  }
}

// Switch Expression ile izolasyon bölgesi
String izolasyonBolgesiBelirle(CihazTipi tip) {
  return switch (tip) {
    CihazTipi.sensor => "ZONE-S",
    CihazTipi.gateway => "ZONE-G",
    CihazTipi.edgeServer => "ZONE-E",
    CihazTipi.router => "ZONE-R",
  };
}

void main() {
  final ag = IoTAgi([
    IoTCihaz(
      seriNo: "SN-1001",
      cihazAdi: "Sıcaklık Sensörü",
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 23.5,
      bellekMb: 256,
      acikPortlar: {"1883/MQTT"},
      sslSertifikasiGecerliMi: true,
    ),
    IoTCihaz(
      seriNo: "SN-1002",
      cihazAdi: "Nem Sensörü",
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 41.0,
      bellekMb: 128,
      acikPortlar: {"1883/MQTT", "23/TELNET"}, // Telnet açık -> riskli
      sslSertifikasiGecerliMi: true,
    ),
    IoTCihaz(
      seriNo: "SN-2001",
      cihazAdi: "Ana Gateway",
      tip: CihazTipi.gateway,
      cpuYukYuzdesi: 67.2,
      bellekMb: 1024,
      acikPortlar: {"443/HTTPS", "8883/MQTT-TLS"},
      sslSertifikasiGecerliMi: true,
    ),
    IoTCihaz(
      seriNo: "SN-3001",
      cihazAdi: "Edge Sunucu 1",
      tip: CihazTipi.edgeServer,
      cpuYukYuzdesi: 91.8, // CPU %85 üstü -> riskli
      bellekMb: 8192,
      acikPortlar: {"22/SSH", "443/HTTPS"},
      sslSertifikasiGecerliMi: true,
    ),
    IoTCihaz(
      seriNo: "SN-4001",
      cihazAdi: "Ofis Router",
      tip: CihazTipi.router,
      cpuYukYuzdesi: 35.0,
      bellekMb: 512,
      acikPortlar: {"22/SSH", "80/HTTP"},
      sslSertifikasiGecerliMi: false, // SSL geçersiz -> riskli
    ),
    IoTCihaz(
      seriNo: "SN-4002",
      cihazAdi: "Depo Router",
      tip: CihazTipi.router,
      cpuYukYuzdesi: 55.5,
      bellekMb: 512,
      acikPortlar: {"443/HTTPS"},
      sslSertifikasiGecerliMi: true,
      calisiyorMu: false, // Cihaz kapalı
    ),
  ]);

  print("===== IoT AĞ YÖNETİM PANELİ =====\n");

  // 4. Riskli cihazlar
  final riskliler = ag.riskliCihazlariBul();
  print("Riskli cihazlar (${riskliler.length} adet):");
  for (final cihaz in riskliler) {
    print(" * $cihaz");
  }

  // 5. Toplam bellek
  print("\nAğdaki toplam bellek: ${ag.toplamBellekMb()} MB");

  // 6. Record ile cihaz sorgulama
  print("\n--- Seri numarasıyla sorgulama ---");
  try {
    final bilgi = ag.cihazBilgisiGetir("SN-3001");
    print("Cihaz adı : ${bilgi.cihazAdi}");
    print("Cihaz tipi: ${bilgi.tip.name}");
    print("Alarm     : ${bilgi.alarmDurumu ? 'ALARM VAR' : 'Normal'}");
  } on CihazErisilemezException catch (e) {
    print("Hata: $e");
  }

  // Olmayan seri numarası
  try {
    ag.cihazBilgisiGetir("SN-9999");
  } on CihazErisilemezException catch (e) {
    print("Hata: $e");
  }

  // 7. İzolasyon bölgeleri
  print("\n--- İzolasyon bölgeleri ---");
  for (final cihaz in ag.cihazlar) {
    print(
      "${cihaz.cihazAdi.padRight(18)} -> ${izolasyonBolgesiBelirle(cihaz.tip)}",
    );
  }

  // 8. Kapalı cihaza bağlanma
  print("\n--- Bağlantı testleri ---");
  try {
    ag.cihazaBaglan("SN-2001"); // açık, başarılı
    ag.cihazaBaglan("SN-4002"); // kapalı, exception fırlatır
  } on CihazErisilemezException catch (e) {
    print("Bağlantı hatası: $e");
  } finally {
    print("Bağlantı testleri tamamlandı.");
  }
}
