// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../models/crypto.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Crypto>> _cryptoFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Inicia a busca pelos dados assim que a tela é carregada
    _cryptoFuture = _apiService.getCryptoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor Cripto'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Crypto>>(
        future: _cryptoFuture,
        builder: (context, snapshot) {
          // Enquanto os dados estão carregando, mostra um spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Se ocorreu um erro
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          // Se os dados chegaram com sucesso
          if (snapshot.hasData) {
            final cryptos = snapshot.data!;
            return ListView.builder(
              itemCount: cryptos.length,
              itemBuilder: (context, index) {
                final crypto = cryptos[index];
                final priceChangeColor =
                    crypto.priceChangePercentage24h >= 0 ? Colors.green : Colors.red;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    child: Text(
                      crypto.symbol.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(crypto.name),
                  subtitle: Text('Rank: ${crypto.marketCapRank}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${crypto.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
                        style: TextStyle(color: priceChangeColor),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          // Estado padrão (não deve ser alcançado)
          return const Center(child: Text('Nenhuma criptomoeda encontrada.'));
        },
      ),
    );
  }
}