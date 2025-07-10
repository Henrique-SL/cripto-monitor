import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/crypto.dart';

class AnalysisScreen extends StatelessWidget {
  final Crypto crypto;

  const AnalysisScreen({super.key, required this.crypto});

  String _getShortTermSentiment() {
    final formattedChange = NumberFormat.decimalPercentPattern(locale: 'pt_BR', decimalDigits: 2)
        .format(crypto.priceChangePercentage24h / 100);

    if (crypto.priceChangePercentage24h > 2) {
      return "Otimista, com uma variação de $formattedChange nas últimas 24h, indicando um forte momento de compra recente.";
    } else if (crypto.priceChangePercentage24h < -2) {
      return "Pessimista, com uma variação de $formattedChange nas últimas 24h, indicando uma pressão de venda recente.";
    } else {
      return "Neutro, com uma variação de $formattedChange nas últimas 24h, mostrando pouca variação de preço.";
    }
  }

  String _getHistoricalPotential() {
    final athDistance = NumberFormat.decimalPercentPattern(locale: 'pt_BR', decimalDigits: 2)
        .format(crypto.athChangePercentage.abs() / 100);
    final formattedAth = NumberFormat.simpleCurrency(locale: 'pt_BR').format(crypto.ath);

    if (crypto.athChangePercentage > -15) {
      return "O preço atual está próximo da sua máxima histórica de $formattedAth, a apenas $athDistance de distância. Isso pode indicar uma forte consolidação de valor ou um potencial rompimento para novas máximas.";
    } else {
      return "Ainda há um espaço considerável para crescimento. O preço atual está $athDistance abaixo da sua máxima histórica de $formattedAth, sugerindo um bom potencial de valorização caso a tendência de alta retorne.";
    }
  }

  String _getLiquidityAnalysis() {
    final formattedVolume = NumberFormat.compactSimpleCurrency(locale: 'pt_BR', decimalDigits: 2).format(crypto.totalVolume);

    if (crypto.totalVolume > 1000000000) {
      return "A liquidez é considerada altíssima, com um volume de $formattedVolume nas últimas 24h, facilitando a execução de grandes ordens de compra e venda.";
    } else if (crypto.totalVolume > 100000000) {
      return "A liquidez é saudável, com um volume de $formattedVolume nas últimas 24h, permitindo negociações eficientes para a maioria dos investidores.";
    } else {
      return "A liquidez é mais baixa, com um volume de $formattedVolume nas últimas 24h, o que pode resultar em maiores variações de preço ao negociar grandes volumes.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Análise de ${crypto.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalysisCard(
              icon: Icons.trending_up,
              title: 'Tendência de Curto Prazo (24h)',
              analysisText: _getShortTermSentiment(),
              context: context
            ),
            const SizedBox(height: 24),
            _buildAnalysisCard(
              icon: Icons.history_toggle_off,
              title: 'Potencial Histórico (vs. ATH)',
              analysisText: _getHistoricalPotential(),
              context: context
            ),
            const SizedBox(height: 24),
            _buildAnalysisCard(
              icon: Icons.water_drop_outlined,
              title: 'Liquidez e Volume',
              analysisText: _getLiquidityAnalysis(),
              context: context
            ),
            const SizedBox(height: 32),
            const Text(
              'Aviso: Esta é uma análise técnica gerada automaticamente e não constitui uma recomendação de investimento.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard({
    required IconData icon,
    required String title,
    required String analysisText,
    required BuildContext context
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // --- ÍCONE COM A COR VERDE DO TEMA ---
                Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 28),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            Text(
              analysisText,
              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}