import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'portfolio_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(        
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [                
                const SizedBox(height: 40),

                // 1. Logo Principal
                Image.asset(
                  'assets/images/1.png',
                  height: 200,
                ),
                const SizedBox(height: 48),

                // 2. Botões de Navegação
                _buildNavButton(
                  context: context,
                  icon: Icons.bar_chart_rounded,
                  title: 'Ranking de Moedas',
                  subtitle: 'Acompanhe preços e variações',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                _buildNavButton(
                  context: context,
                  icon: Icons.star_border_rounded,
                  title: 'Portfólio',
                  subtitle: 'Veja suas moedas favoritas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PortfolioScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                _buildNavButton(
                  context: context,
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Análise de Investimento',
                  subtitle: 'Opinião: é hora de investir?',
                  onTap: () {},
                ),                
                
                const SizedBox(height: 64),

                // 3. Imagem do Nome na Parte de Baixo
                Image.asset(
                  'assets/images/2.png',
                  height: 60, 
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.deepPurpleAccent),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}