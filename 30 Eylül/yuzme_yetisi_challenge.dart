mixin YuzmeYetisi {
  void suyaDal() {
    print("Su altına daldı");
  }
}

class Denizci {
  final String ad;
  Denizci({required this.ad});
}

class DenizGezgini extends Denizci with YuzmeYetisi {
  DenizGezgini({required super.ad});
}

void main() {
  final gezgin = DenizGezgini(ad: "Kaşif");
  gezgin.suyaDal();
}
