import '../root/file.dart';
import '../models/caminhada.dart';
import 'package:flutter/material.dart';

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

  // CARREGAR DADOS DO ARQUIVO
  void carregarDados() async {
    String conteudo = await GerenciarArquivo.abrir();

    if (conteudo.trim().isEmpty) {
      return;
    }

    List<String> linhas = conteudo
        .split('\n')
        .where((linha) => linha.trim().isNotEmpty)
        .toList();

    setState(() {
      caminhadas = linhas.map((linha) => Caminhada.fromCSV(linha)).toList();
    });
  }

  // SALVAR DADOS
  void salvarDados() {
    String conteudo = caminhadas
        .map((caminhada) => caminhada.toCSV())
        .join('\n');

    GerenciarArquivo.salvar(conteudo);
  }

  // CALCULAR CALORIAS
  double calcularCalorias(Caminhada caminhada) {
    return 0.7 * caminhada.peso * caminhada.distancia;
  }

  @override
  Widget build(BuildContext context) {
    double caloriasTotais = caminhadas.fold(
      0,
      (total, caminhada) => total + calcularCalorias(caminhada),
    );

    double distanciaTotal = caminhadas.fold(
      0,
      (total, caminhada) => total + caminhada.distancia,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Caminhadas"),
        actions: [
          IconButton(onPressed: cadastrar, icon: const Icon(Icons.add)),
        ],
      ),

      body: Column(
        children: [
          // RESUMO
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.directions_walk,
                            color: Colors.green,
                          ),

                          const SizedBox(height: 5),

                          const Text("Distância"),

                          Text(
                            "${distanciaTotal.toStringAsFixed(2)} km",
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                          ),

                          const SizedBox(height: 5),

                          const Text("Calorias"),

                          Text(
                            "${caloriasTotais.toStringAsFixed(0)} kcal",
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
          ),

          // LISTA
          Expanded(
            child: caminhadas.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhuma caminhada cadastrada.",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),

                    itemCount: caminhadas.length,

                    separatorBuilder: (_, _) => const Divider(),

                    itemBuilder: (context, i) {
                      final caminhada = caminhadas[i];

                      final calorias = calcularCalorias(caminhada);

                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.directions_walk),
                        ),

                        title: Text(
                          "${caminhada.partida} → ${caminhada.chegada}",
                        ),

                        subtitle: Text(
                          "${caminhada.data}\n"
                          "Distância: "
                          "${caminhada.distancia.toStringAsFixed(2)} km\n"
                          "Peso: "
                          "${caminhada.peso.toStringAsFixed(1)} kg\n"
                          "Calorias: "
                          "${calorias.toStringAsFixed(1)} kcal",
                        ),

                        isThreeLine: true,

                        trailing: IconButton(
                          onPressed: () => excluir(i),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: cadastrar,
        child: const Icon(Icons.add),
      ),
    );
  }

  // CADASTRAR CAMINHADA
  void cadastrar() {
    final partidaController = TextEditingController();

    final chegadaController = TextEditingController();

    final distanciaController = TextEditingController();

    final pesoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nova caminhada"),

        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: partidaController,
                decoration: const InputDecoration(
                  labelText: "Partida",
                  hintText: "Ex: Minha casa",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: chegadaController,
                decoration: const InputDecoration(
                  labelText: "Chegada",
                  hintText: "Ex: Parque",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: distanciaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Distância (km)",
                  hintText: "Ex: 4.5",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: pesoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Peso atual (kg)",
                  hintText: "Ex: 69",
                ),
              ),
            ],
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),

          TextButton(
            onPressed: () {
              double? distancia = double.tryParse(
                distanciaController.text.replaceAll(',', '.'),
              );

              double? peso = double.tryParse(
                pesoController.text.replaceAll(',', '.'),
              );

              if (partidaController.text.isEmpty ||
                  chegadaController.text.isEmpty ||
                  distancia == null ||
                  peso == null) {
                return;
              }

              String data = DateTime.now().toString().substring(0, 16);

              setState(() {
                caminhadas.add(
                  Caminhada(
                    data: data,
                    partida: partidaController.text,
                    chegada: chegadaController.text,
                    distancia: distancia,
                    peso: peso,
                  ),
                );
              });

              salvarDados();

              Navigator.pop(context);
            },
            child: const Text("Cadastrar"),
          ),
        ],
      ),
    );
  }

  // EXCLUIR
  void excluir(int indice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir caminhada"),

        content: const Text("Deseja realmente excluir esta caminhada?"),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),

          TextButton(
            onPressed: () {
              setState(() {
                caminhadas.removeAt(indice);
              });

              salvarDados();

              Navigator.pop(context);
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
