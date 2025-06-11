import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/crypto.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final Crypto crypto;

  const DetailScreen({super.key, required this.crypto});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<List<FlSpot>> _chartDataFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Busca os dados do gráfico para as últimas 24 horas (usando "1")
    _chartDataFuture = _apiService.getChartData(widget.crypto.id, "1");
  }

  @override
  Widget build(BuildContext context) {
    final priceChangeColor =
        widget.crypto.priceChangePercentage24h >= 0 ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crypto.name),        
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [                  
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[700],
                    backgroundImage: (widget.crypto.imageUrl != null && widget.crypto.imageUrl!.isNotEmpty)
                        ? NetworkImage(widget.crypto.imageUrl!)
                        : null,
                    child: (widget.crypto.imageUrl == null || widget.crypto.imageUrl!.isEmpty)
                        ? const Icon(Icons.question_mark, size: 30, color: Colors.white70)
                        : null,
                  ),                                  
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      widget.crypto.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Preço Atual', style: TextStyle(color: Colors.white70)),
                trailing: Text(
                  '\$${widget.crypto.currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Market Cap Rank', style: TextStyle(color: Colors.white70)),
                trailing: Text(
                  '#${widget.crypto.marketCapRank}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Variação (24h)', style: TextStyle(color: Colors.white70)),
                trailing: Text(
                  '${widget.crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: priceChangeColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Gráfico de Preços (Últimas 24h)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: FutureBuilder<List<FlSpot>>(
                  future: _chartDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text("Não foi possível carregar o gráfico"));
                    }
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: snapshot.data!,
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.yellow.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const Center(child: Text("Sem dados para o gráfico"));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

