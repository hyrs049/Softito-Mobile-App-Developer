abstract class Canavar {
  final String isim;

  Canavar({required this.isim});

  void kukre();

  void ininGirisiniAc() {
    print("$isim inini terk etti ve avlanmaya çıktı");
  }
}

class Ejderha extends Canavar {
  Ejderha({required super.isim});

  @override
  void kukre() {
    print("$isim kükredi: KÜÜÜRRR! *ateş püskürtüyor*");
  }
}

class Zombi extends Canavar {
  Zombi({required super.isim});

  @override
  void kukre() {
    print("$isim inledi: Iyyhh... beyiiin...");
  }
}

class IskeletSavasci extends Canavar {
  IskeletSavasci({required super.isim});

  @override
  void kukre() {
    print("$isim kemiklerini takırdattı: *KLIK KLAK* Kılıcını çekti");
  }
}

void canavarSurusunuUyandir(List<Canavar> suru) {
  print("Ay ışığı altında canavarlar uyandı");
  for (var c in suru) {
    c.ininGirisiniAc();

    c.kukre();
  }
}

void main() {
  print("Canavar Sürüsü");
  final List<Canavar> canavarSurusu = [
    Ejderha(isim: "Smaug"),
    Zombi(isim: "Rotting Joe"),
    IskeletSavasci(isim: "Kemik Lord Vargus"),
  ];

  canavarSurusunuUyandir(canavarSurusu);
}
