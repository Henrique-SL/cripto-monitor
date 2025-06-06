# Monitor de Criptomoedas (Trabalho)

> **DEMONSTRAÇÃO EM VÍDEO:** Para uma demonstração do projeto em funcionamento, assista a este vídeo: [COLOQUE O LINK PARA O SEU VÍDEO DO YOUTUBE/GOOGLE DRIVE AQUI]

## Sobre o Projeto

Este projeto consiste em um sistema completo para monitoramento de criptomoedas, utilizando uma arquitetura de microsserviços e um aplicativo frontend.

## Tecnologias Utilizadas

* **Coletor de Dados:** Rust
* **Backend (API e Orquestrador):** Go
* **Frontend (Aplicativo):** Dart & Flutter

## Pré-requisitos

Para rodar este projeto localmente, é necessário ter o seguinte software instalado e configurado no PATH do sistema:

1.  **Git:** [https://git-scm.com/downloads](https://git-scm.com/downloads)
2.  **Go (versão 1.21+):** [https://go.dev/dl/](https://go.dev/dl/)
3.  **Flutter (versão 3.19+):** [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
4.  **Compilador C/C++ (para o Go):** Foi utilizado o **TDM-GCC**, que pode ser baixado aqui: [https://jmeub.github.io/tdm-gcc/](https://jmeub.github.io/tdm-gcc/)
    * *Durante a instalação do TDM-GCC, é crucial marcar a opção "Add to PATH".*

## Configuração do Ambiente

Após instalar os pré-requisitos, alguns passos manuais de configuração são necessários.

### 1. Conexão Backend-Frontend

O aplicativo Flutter precisa saber o endereço de IP da máquina onde o servidor Go está rodando.

1.  Encontre o endereço IPv4 da máquina do servidor rodando o comando `ipconfig` (no Windows).
2.  Abra o projeto Flutter e edite o arquivo `lib/services/api_service.dart`.
3.  Altere a variável `_baseUrl` para o endereço de IP encontrado. Exemplo:
    ```dart
    static const String _baseUrl = "[http://192.168.3.10:8080](http://192.168.3.10:8080)";
    ```

### 2. Firewall

Pode ser necessário criar uma regra de entrada no Firewall do Windows para permitir conexões na porta `8080` (TCP), para que o app Flutter consiga se conectar à API Go.

## Como Rodar o Projeto

O sistema precisa de dois terminais rodando simultaneamente.

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git](https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git)
    cd SEU_REPOSITORIO
    ```

2.  **Rode o Backend (API em Go):**
    * Abra um terminal na pasta raiz do projeto.
    * Navegue para a pasta da API: `cd go-api`
    * Execute o servidor com o CGO habilitado:
        ```powershell
        $env:CGO_ENABLED="1"; go run main.go
        ```
    * Aguarde a mensagem "Servidor iniciado na porta 8080..." e **deixe este terminal aberto**.

3.  **Rode o Frontend (App em Flutter):**
    * Abra um **segundo terminal** na pasta raiz do projeto.
    * Navegue para a pasta do Flutter: `cd nome-da-sua-pasta-flutter`
    * Instale as dependências do Flutter:
        ```bash
        flutter pub get
        ```
    * Execute o aplicativo (recomendado para Web para testes rápidos):
        ```bash
        flutter run -d chrome
        ```