# CriptoDuelo

Este é um projeto full-stack de monitoramento de criptomoedas, desenvolvido como trabalho acadêmico, que integra um backend em Go, um coletor de dados em Rust e um aplicativo multiplataforma em Flutter.

> **DEMONSTRAÇÃO EM VÍDEO:** https://www.youtube.com/watch?v=Am2q5IpKHXk
> **APRESENTAÇÃO FINAL** [Clique aqui para ver a apresentação final do projeto em PDF](./docs/presentacaoFinalLP.pdf)

## Funcionalidades Principais

* **Ranking em Tempo Real:** Lista de criptomoedas obtida da API da CoinGecko, ordenada por capitalização de mercado.
* **Busca Instantânea:** Filtre a lista de moedas por nome ou símbolo.
* **Análise Detalhada:** Tela de detalhes para cada moeda com gráfico de preço das últimas 24h, máxima histórica (ATH), volume e outros indicadores.
* **Análise de Investimento:** Textos gerados dinamicamente que interpretam os indicadores técnicos (tendência, potencial, liquidez) para auxiliar o usuário.
* **Portfólio Pessoal:** Sistema de favoritos salvo na nuvem com **Firebase Firestore**. As escolhas do usuário são sincronizadas em tempo real entre dispositivos.
* **Autenticação:** Sistema de login e cadastro de usuários com **Firebase Authentication**, garantindo que cada usuário tenha seu próprio portfólio.

## Tecnologias Utilizadas

* **Backend:** Go (API REST com Gorilla/Mux e persistência com SQLite).
* **Coletor de Dados:** Rust (responsável pela coleta inicial dos dados).
* **Frontend:** Dart & Flutter (para Web e Android).
* **Banco de Dados na Nuvem:** Google Firebase (Firestore para o portfólio e Authentication para login).

## Pré-requisitos

Para rodar este projeto, você precisará ter instalado:
* [Git](https://git-scm.com/)
* [Go](https://go.dev/dl/) (versão 1.21+)
* [Flutter](https://docs.flutter.dev/get-started/install) (versão 3.19+)
* Um compilador C de 64-bits (ex: [TDM-GCC](https://jmeub.github.io/tdm-gcc/))
* **Conta no Firebase:** É necessário criar um projeto gratuito no [Firebase Console](https://console.firebase.google.com/).

## Como Rodar o Projeto

### 1. Configuração do Firebase
   a. Após criar seu projeto no Firebase, habilite os serviços **Authentication** (com o provedor "E-mail/Senha") e **Firestore Database** (iniciando em "modo de teste").
   b. Instale as ferramentas de linha de comando: `dart pub global activate flutterfire_cli` e `npm install -g firebase-tools`.
   c. Na pasta do app Flutter, rode `flutterfire configure` para conectar o projeto ao Firebase.

### 2. Configuração do Frontend (Flutter)
   a. Na pasta `flutter_application_1`, rode `flutter pub get` para baixar as dependências.
   b. **MUITO IMPORTANTE:** Abra o arquivo `lib/services/api_service.dart` e altere a variável `_baseUrl` para o endereço de IP da máquina onde o servidor Go estará rodando. Encontre o IP com `ipconfig` (Windows). Ex: `http://192.168.1.10:8080`.

### 3. Execução
O sistema precisa de **dois terminais rodando simultaneamente**.

* **Terminal 1 - Ligar o Backend (Go):**
    ```powershell
    # Navegue até a pasta da API
    cd go-api

    # Instale as dependências
    go mod tidy

    # Delete o banco de dados antigo para garantir uma nova criação
    del cryptos.db

    # Rode o servidor
    $env:CGO_ENABLED="1"; go run main.go
    ```
    *Aguarde a mensagem "Servidor iniciado na porta 8080..." e deixe este terminal aberto.*

* **Terminal 2 - Ligar o Frontend (Flutter):**
    ```bash
    # Navegue até a pasta do app
    cd flutter_application_1

    # Rode o aplicativo (no Chrome, por exemplo)
    flutter run -d chrome
    ```

### 4. Uso de IA
Usamos ChatGPT e Gemini
   a. Estuturação
   b. Configuração do Go, Dart, Flutter e banco de dados FireBase
   c. Aprimoramento do código