package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"time"
)

var startTime = time.Now()

type Quote struct {
	Text   string
	Author string
}

var quotes = []Quote{
	{"Simplicity is the soul of efficiency.", "Austin Freeman"},
	{"First, solve the problem. Then, write the code.", "John Johnson"},
	{"Programs must be written for people to read.", "Harold Abelson"},
	{"Any sufficiently advanced technology is indistinguishable from magic.", "Arthur C. Clarke"},
	{"Make it work, make it right, make it fast.", "Kent Beck"},
	{"Talk is cheap. Show me the code.", "Linus Torvalds"},
	{"Premature optimization is the root of all evil.", "Donald Knuth"},
	{"Stay hungry, stay foolish.", "Steve Jobs"},
}

// Go 1.20+ auto-seeds RNG → no rand.Seed needed
func randomQuote() Quote {
	return quotes[rand.Intn(len(quotes))]
}

// ---------- Landing Page ----------
func landingHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	q := randomQuote()

	w.Header().Set("Content-Type", "text/html; charset=utf-8")

	if _, err := fmt.Fprintf(w, `<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Ops Inspiration</title>

<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">

<style>
body {
	margin: 0;
	font-family: "JetBrains Mono", monospace;
	height: 100vh;
	display: flex;
	align-items: center;
	justify-content: center;

	background: linear-gradient(
		135deg,
		#fbc2eb,
		#a6c1ee,
		#ffd6e0,
		#d0f4de
	);
	background-size: 400%% 400%%;
	animation: gradient 20s ease infinite;
}

@keyframes gradient {
	0%% { background-position: 0%% 50%%; }
	50%% { background-position: 100%% 50%%; }
	100%% { background-position: 0%% 50%%; }
}

.panel {
	background: rgba(255, 255, 255, 0.45);
	backdrop-filter: blur(18px);
	border-radius: 22px;
	padding: 65px;
	width: 760px;
	text-align: center;
	box-shadow:
	0 25px 80px rgba(0,0,0,0.15),
	inset 0 1px 0 rgba(255,255,255,0.7);
}

h1 {
	margin-top: 0;
	font-size: 1.6rem;
	font-weight: 600;
	color: #374151;
	letter-spacing: 1px;
	text-shadow: 0 0 18px rgba(255,255,255,0.9);
}

.quote {
	font-size: 1.5rem;
	line-height: 1.7;
	margin: 50px 0;
	color: #111827;
	text-shadow: 0 0 12px rgba(255,255,255,0.8);
}

.author {
	font-size: 1rem;
	color: #6b7280;
}

.quote::before {
	content: "> ";
	color: #ec4899;
	text-shadow: 0 0 10px rgba(236,72,153,0.8);
}
</style>
</head>

<body>
<div class="panel">
	<h1>✨ Ops Inspiration Console</h1>
	<div class="quote">%s</div>
	<div class="author">— %s</div>
</div>
</body>
</html>`,
		q.Text,
		q.Author,
	); err != nil {
		log.Printf("write error: %v", err)
	}
}

// ---------- Health ----------
func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if err := json.NewEncoder(w).Encode(map[string]string{
		"status": "healthy",
	}); err != nil {
		http.Error(w, "encoding error", http.StatusInternalServerError)
		log.Printf("health encode error: %v", err)
	}
}

// ---------- Ready ----------
func readyHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if err := json.NewEncoder(w).Encode(map[string]string{
		"status": "ready",
	}); err != nil {
		http.Error(w, "encoding error", http.StatusInternalServerError)
		log.Printf("ready encode error: %v", err)
	}
}

// ---------- Info ----------
func infoHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if err := json.NewEncoder(w).Encode(map[string]interface{}{
		"service":   "quote-service",
		"uptime":    time.Since(startTime).String(),
		"timestamp": time.Now().Format(time.RFC3339),
	}); err != nil {
		http.Error(w, "encoding error", http.StatusInternalServerError)
		log.Printf("info encode error: %v", err)
	}
}

// ---------- Main ----------
func main() {
	http.HandleFunc("/", landingHandler)
	http.HandleFunc("/-/health", healthHandler)
	http.HandleFunc("/-/ready", readyHandler)
	http.HandleFunc("/-/info", infoHandler)

	fmt.Println("⚡ Server running on :8080")

	log.Fatal(http.ListenAndServe(":8080", nil))
}