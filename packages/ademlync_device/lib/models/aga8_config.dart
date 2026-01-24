class Aga8Config {
  late final double methane;
  late final double nitrogen;
  late final double carbonDioxide;
  late final double ethane;
  late final double propane;
  late final double water;
  late final double hydrogenSulphide;
  late final double hydrogen;
  late final double carbonMonoxide;
  late final double oxygen;
  late final double isoButane;
  late final double nButane;
  late final double isoPentane;
  late final double nPentane;
  late final double nHexane;
  late final double nHeptane;
  late final double nOctane;
  late final double nNonane;
  late final double nDecane;
  late final double helium;
  late final double argon;

  double get total =>
      methane +
      nitrogen +
      carbonDioxide +
      ethane +
      propane +
      water +
      hydrogenSulphide +
      hydrogen +
      carbonMonoxide +
      oxygen +
      isoButane +
      nButane +
      isoPentane +
      nPentane +
      nHexane +
      nHeptane +
      nOctane +
      nNonane +
      nDecane +
      helium +
      argon;

  Aga8Config(List<double> list) {
    methane = list[0];
    nitrogen = list[1];
    carbonDioxide = list[2];
    ethane = list[3];
    propane = list[4];
    water = list[5];
    hydrogenSulphide = list[6];
    hydrogen = list[7];
    carbonMonoxide = list[8];
    oxygen = list[9];
    isoButane = list[10];
    nButane = list[11];
    isoPentane = list[12];
    nPentane = list[13];
    nHexane = list[14];
    nHeptane = list[15];
    nOctane = list[16];
    nNonane = list[17];
    nDecane = list[18];
    helium = list[19];
    argon = list[20];
  }

  static Aga8Config? from(String? data) {
    if (data != null && data.length == 85) {
      data = data.trim();

      final list = <double>[];

      // Add the first group of 5 characters
      list.add(double.parse(data.substring(0, 5)) / 100);

      // Split the rest of the string into groups of 4 characters
      for (int i = 5; i < data.length; i += 4) {
        list.add(double.parse(data.substring(i, i + 4)) / 100);
      }

      return Aga8Config(list);
    } else {
      return null;
    }
  }
}
