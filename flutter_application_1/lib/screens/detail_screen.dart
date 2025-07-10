import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/crypto.dart';
import '../services/api_service.dart';
import 'analysis_screen.dart';

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
    _chartDataFuture = _apiService.getChartData(widget.crypto.id, "1");
  }

  String _formatLargeNumber(double number) {
    final formatter = NumberFormat.compactSimpleCurrency(locale: 'pt_BR');
    return formatter.format(number);
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[700],
                  backgroundImage: (widget.crypto.imageUrl != null &&
                          widget.crypto.imageUrl!.isNotEmpty)
                      ? NetworkImage(widget.crypto.imageUrl!)
                      : null,
                  child: (widget.crypto.imageUrl == null ||
                          widget.crypto.imageUrl!.isEmpty)
                      ? const Icon(Icons.question_mark,
                          size: 30, color: Colors.white70)
                      : null,
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    widget.crypto.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white24),

            _buildInfoTile('Preço Atual',
                NumberFormat.simpleCurrency(locale: 'pt_BR').format(widget.crypto.currentPrice)),
            _buildInfoTile('Rank de Mercado', '#${widget.crypto.marketCapRank}'),
            _buildInfoTile('Variação (24h)',
                NumberFormat.decimalPercentPattern(locale: 'pt_BR', decimalDigits: 2).format(widget.crypto.priceChangePercentage24h / 100),
                valueColor: priceChangeColor),
            
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),

            const SizedBox(height: 16),
            const Text("Análise de Mercado",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            _buildInfoTile('Volume (24h)',
                _formatLargeNumber(widget.crypto.totalVolume)),
            _buildInfoTile('Preço Máximo Histórico (ATH)',
                NumberFormat.simpleCurrency(locale: 'pt_BR').format(widget.crypto.ath)),
            _buildInfoTile('% desde o Máximo Histórico',
                NumberFormat.decimalPercentPattern(locale: 'pt_BR', decimalDigits: 2).format(widget.crypto.athChangePercentage / 100),
                valueColor: Colors.red),
            
            const SizedBox(height: 24),

            // BOTÃO COM ESTILO
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Ver Análise de Investimento'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,                
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnalysisScreen(crypto: widget.crypto),
                    ),
                  );
                },
              ),
            ),
            
            
            const SizedBox(height: 24),
            const Divider(color: Colors.white24),

            const SizedBox(height: 16),
            const Text("Gráfico de Preços (Últimas 24h)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<FlSpot>>(
                future: _chartDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("Não foi possível carregar o gráfico"));
                  }
                  return LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final currencyFormatter = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2);
                              return LineTooltipItem(
                                currencyFormatter.format(spot.y),
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            }).toList();
                          },
                        ),
                      ),
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
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}