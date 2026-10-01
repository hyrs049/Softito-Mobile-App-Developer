class Kasa {
  final String oyuncuAdi;
  double _altinMiktari = 0.0;

  Kasa({required this.oyuncuAdi});

  double get altinMiktari => _altinMiktari;

  set altinMiktari(double yeniAltin) {
    if (yeniAltin < 0) {
      print("Sahte altın eklenemez!");
    } else {
      _altinMiktari = yeniAltin;
    }
  }
}

void main() {
  final kasa = Kasa(oyuncuAdi: "Ali Ay");

  kasa.altinMiktari = 50;
  print("${kasa.oyuncuAdi} altını: ${kasa.altinMiktari}"); // 50.0

  kasa.altinMiktari = -20; // Sahte altın eklenemez!
  print("${kasa.oyuncuAdi} altını: ${kasa.altinMiktari}"); // 50.0
}
