package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"monitor-cripto/go-api/database"
	"monitor-cripto/go-api/handlers"
	"monitor-cripto/go-api/models"

	"github.com/gorilla/mux"
)

// Função para buscar uma única página de moedas da CoinGecko
func fetchCryptoPage(page int, perPage int) ([]models.CryptoData, error) {
	url := fmt.Sprintf("https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=%d&page=%d&sparkline=false", perPage, page)

	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var data []models.CryptoData
	err = json.NewDecoder(resp.Body).Decode(&data)
	if err != nil {
		return nil, err
	}

	return data, nil
}

// Função para buscar várias páginas de moedas
func fetchAllCryptos() ([]models.CryptoData, error) {
	var allData []models.CryptoData
	pages := []int{1, 2, 3} // Busca as 3 primeiras páginas (300 moedas)
	perPage := 100
	for _, p := range pages {
		data, err := fetchCryptoPage(p, perPage)
		if err != nil {
			return nil, err
		}
		allData = append(allData, data...)
	}
	return allData, nil
}

// Função para postar os dados para nosso próprio endpoint de armazenamento
func postCryptoData(data []models.CryptoData) error {
	jsonData, err := json.Marshal(data)
	if err != nil {
		return err
	}

	resp, err := http.Post("http://localhost:8080/receive-data", "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("falha ao enviar dados: %s", resp.Status)
	}
	return nil
}

// Versão melhorada que busca os dados imediatamente e depois a cada intervalo
func startAutoUpdate(interval time.Duration) {
	fetchAndPost := func() {
		log.Println("Buscando dados atualizados das criptomoedas...")
		// VOLTAMOS A USAR A FUNÇÃO fetchAllCryptos
		data, err := fetchAllCryptos()
		if err != nil {
			log.Println("Erro ao buscar dados:", err)
			return
		}

		err = postCryptoData(data)
		if err != nil {
			log.Println("Erro ao enviar dados para /receive-data:", err)
			return
		}

		log.Println("Dados atualizados com sucesso!")
	}

	go fetchAndPost()

	ticker := time.NewTicker(interval)
	go func() {
		for range ticker.C {
			fetchAndPost()
		}
	}()
}

// Middleware de CORS
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func main() {
	database.InitDB()
	fmt.Println("Banco de dados inicializado com sucesso!")

	r := mux.NewRouter()
	r.Use(corsMiddleware)

	r.HandleFunc("/receive-data", handlers.ReceiveCryptoData).Methods("POST")
	r.HandleFunc("/cryptos", handlers.GetCryptos).Methods("GET")
	r.HandleFunc("/cryptos/{id}/market_chart", handlers.GetMarketChart).Methods("GET")

	startAutoUpdate(10 * time.Minute)

	log.Println("Servidor iniciado na porta 8080...")
	log.Fatal(http.ListenAndServe(":8080", r))
}
