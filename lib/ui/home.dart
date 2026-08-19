import 'package:flutter/material.dart';
import '../models/caminhada.dart';
import '../root/file.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Caminhada> caminhadas = [];
  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  void carregarDados() async {
    final arquivo = await GerenciarArquivo.abrir();
    if (arquivo.isEmpty) return;
    setState(() {
      caminhadas = arquivo
          .split('\n')
          .where((linha) => linha.isNotEmpty)
          .map((linha) => Caminhada.fromCSV(linha))
          .toList();
    });
  }

  void salvarDados() {
    final dados = caminhadas.map((c) => c.toCSV()).join('\n');
    GerenciarArquivo.salvar(dados);
  }

  double calorias(Caminhada caminhada) {
    return 0.7 * caminhada.peso * caminhada.distancia;
  }

  double distanciaTotal() {
    return caminhadas.fold(
      0,
      (total, caminhada) => total + caminhada.distancia,
    );
  }

  double caloriasTotais() {
    return caminhadas.fold(
      0,
      (total, caminhada) => total + calorias(caminhada),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caminhadas')),
      body: Column(children: [resumo(), lista()]),
      floatingActionButton: FloatingActionButton(
        onPressed: cadastrar,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget resumo() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    const Icon(Icons.directions_walk, color: Colors.green),
                    const Text('Distância total'),
                    Text(
                      '${distanciaTotal().toStringAsFixed(2)} km',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                    const Text('Calorias'),
                    Text(
                      '${caloriasTotais().toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget lista() {
    if (caminhadas.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Nenhuma caminhada cadastrada.')),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: caminhadas.length,
        itemBuilder: (context, i) {
          final caminhada = caminhadas[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              onTap: () => editar(i),
              leading: const CircleAvatar(child: Icon(Icons.directions_walk)),
              title: Text('${caminhada.partida} → ${caminhada.chegada}'),
              subtitle: Text(
                '${caminhada.data}\n'
                '${caminhada.distancia.toStringAsFixed(2)} km • '
                '${caminhada.peso.toStringAsFixed(1)} kg • '
                '${calorias(caminhada).toStringAsFixed(1)} kcal',
              ),
              isThreeLine: true,
              trailing: IconButton(
                onPressed: () => excluir(i),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }

  void cadastrar() {
    mostrarModal();
  }

  void editar(int indice) {
    mostrarModal(indice: indice);
  }

  void mostrarModal({int? indice}) {
    Caminhada? caminhada;
    if (indice != null) {
      caminhada = caminhadas[indice];
    }
    final partida = TextEditingController(text: caminhada?.partida ?? '');
    final chegada = TextEditingController(text: caminhada?.chegada ?? '');
    final distancia = TextEditingController(
      text: caminhada?.distancia.toString() ?? '',
    );
    final peso = TextEditingController(text: caminhada?.peso.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(indice == null ? 'Nova caminhada' : 'Editar caminhada'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: partida,
                  decoration: const InputDecoration(labelText: 'Partida'),
                ),
                TextField(
                  controller: chegada,
                  decoration: const InputDecoration(labelText: 'Chegada'),
                ),
                TextField(
                  controller: distancia,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Distância (km)',
                  ),
                ),
                TextField(
                  controller: peso,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                salvarCaminhada(
                  indice,
                  caminhada,
                  partida.text,
                  chegada.text,
                  distancia.text,
                  peso.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void salvarCaminhada(
    int? indice,
    Caminhada? antiga,
    String partida,
    String chegada,
    String distanciaTexto,
    String pesoTexto,
  ) {
    final distanciaValor = double.tryParse(distanciaTexto.replaceAll(',', '.'));
    final pesoValor = double.tryParse(pesoTexto.replaceAll(',', '.'));
    if (partida.isEmpty ||
        chegada.isEmpty ||
        distanciaValor == null ||
        pesoValor == null) {
      return;
    }
    final nova = Caminhada(
      data: antiga?.data ?? DateTime.now().toString().substring(0, 16),
      partida: partida,
      chegada: chegada,
      distancia: distanciaValor,
      peso: pesoValor,
    );
    setState(() {
      if (indice == null) {
        caminhadas.add(nova);
      } else {
        caminhadas[indice] = nova;
      }
    });
    salvarDados();
  }

  void excluir(int indice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir caminhada'),
          content: const Text('Deseja realmente excluir esta caminhada?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  caminhadas.removeAt(indice);
                });
                salvarDados();
                Navigator.pop(context);
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
