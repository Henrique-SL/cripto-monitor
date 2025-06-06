// lib/services/api_service.dart

import 'package:http/http.dart' as http;
import '../models/crypto.dart';

class ApiService {
  // ATENÇÃO: Substitua pelo IP do seu computador na rede local.
  // 'localhost' ou '127.0.0.1' não funciona no emulador/celular.
  // Para descobrir seu IP, use 'ipconfig' (Windows) ou 'ifconfig' (Mac/Linux).
  static const String _baseUrl = "http://192.168.3.10:8080";

  // Função para buscar a lista de criptos do seu backend Go
  Future<List<Crypto>> getCryptoList() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/cryptos"));

      if (response.statusCode == 200) {
        // Se a chamada for bem-sucedida, decodifica o JSON.
        final List<Crypto> cryptos = cryptoFromJson(response.body);
        return cryptos;
      } else {
        // Se o servidor retornar um erro.
        throw Exception('Falha ao carregar os dados das criptomoedas');
      }
    } catch (e) {
      // Em caso de erro de conexão ou outro.
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }

  // --- PLACEHOLDER PARA O FUTURO ---
  // Você precisará criar estes endpoints no seu backend Go

  /*
  Future<ChartData> getChartData(String cryptoId) async {
    // Exemplo de como seria a chamada para o gráfico:
    // final response = await http.get(Uri.parse("$_baseUrl/cryptos/$cryptoId/chart?days=7"));
    // ...
    throw UnimplementedError("Endpoint de gráfico não implementado no backend");
  }

  Future<void> createAlert(String cryptoId, double targetPrice) async {
    // Exemplo de como seria a chamada para criar um alerta:
    // final response = await http.post(
    //   Uri.parse("$_baseUrl/alerts"),
    //   body: jsonEncode({'crypto_id': cryptoId, 'target_price': targetPrice}),
    //   headers: {'Content-Type': 'application/json'},
    // );
    // ...
    throw UnimplementedError("Endpoint de alerta não implementado no backend");
  }
  */
}