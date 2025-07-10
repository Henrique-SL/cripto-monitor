// lib/services/api_service.dart
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../models/crypto.dart';

class ApiService {
  // Substitua pelo IP do seu computador na rede local.

  static const String _baseUrl = "http://192.168.3.10:8080";

  // Função para buscar a lista de criptos do seu backend Go
  Future<List<Crypto>> getCryptoList() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/cryptos"));

      if (response.statusCode == 200) {        
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
  Future<List<FlSpot>> getChartData(String cryptoId, String days) async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/cryptos/$cryptoId/market_chart?days=$days"));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final List<dynamic> prices = decodedData['prices'];      
        
        List<FlSpot> spots = prices.map((pricePoint) {
          return FlSpot(
            (pricePoint[0] as int).toDouble(), 
            (pricePoint[1] as num).toDouble(), 
          );
        }).toList();
      
        return spots;
      } else {
        throw Exception('Falha ao carregar dados do gráfico');
      }
    } catch (e) {
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }
}