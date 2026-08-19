class Caminhada {
  String data;
  String partida;
  String chegada;
  double distancia;
  double peso;

  Caminhada({
    required this.data,
    required this.partida,
    required this.chegada,
    required this.distancia,
    required this.peso,
  });

  String toCSV() {
    return '$data;$partida;$chegada;$distancia;$peso';
  }

  factory Caminhada.fromCSV(String csv) {
    List<String> partes = csv.split(';');

    return Caminhada(
      data: partes[0],
      partida: partes[1],
      chegada: partes[2],
      distancia: double.parse(partes[3]),
      peso: double.parse(partes[4]),
    );
  }
}