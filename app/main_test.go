package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestLandingPage_OK(t *testing.T) {
	req := httptest.NewRequest("GET", "/", nil)
	w := httptest.NewRecorder()

	landingHandler(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Expected status 200, got %d", w.Code)
	}
}

func TestLandingPage_Content(t *testing.T) {
	req := httptest.NewRequest("GET", "/", nil)
	w := httptest.NewRecorder()

	landingHandler(w, req)

	body := w.Body.String()
	if body == "" {
		t.Error("Expected non-empty body")
	}
}

func TestLandingPage_NotFound(t *testing.T) {
	req := httptest.NewRequest("GET", "/invalid", nil)
	w := httptest.NewRecorder()

	landingHandler(w, req)

	if w.Code != http.StatusNotFound {
		t.Errorf("Expected status 404, got %d", w.Code)
	}
}

func TestHealthHandler_OK(t *testing.T) {
	req := httptest.NewRequest("GET", "/-/health", nil)
	w := httptest.NewRecorder()

	healthHandler(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("Expected status 200, got %d", w.Code)
	}

	if ct := w.Header().Get("Content-Type"); ct == "" {
		t.Error("Expected Content-Type header")
	}

	if w.Body.Len() == 0 {
		t.Error("Expected non-empty body")
	}
}

func TestReadyHandler_OK(t *testing.T) {
	req := httptest.NewRequest("GET", "/-/ready", nil)
	w := httptest.NewRecorder()

	readyHandler(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("Expected status 200, got %d", w.Code)
	}

	if w.Body.Len() == 0 {
		t.Error("Expected non-empty body")
	}
}

func TestInfoHandler_OK(t *testing.T) {
	req := httptest.NewRequest("GET", "/-/info", nil)
	w := httptest.NewRecorder()

	infoHandler(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("Expected status 200, got %d", w.Code)
	}

	body := w.Body.String()
	if body == "" {
		t.Error("Expected non-empty body")
	}
}

func BenchmarkLandingPageParallel(b *testing.B) {
	req := httptest.NewRequest("GET", "/", nil)

	b.RunParallel(func(pb *testing.PB) {
		for pb.Next() {
			w := httptest.NewRecorder()
			landingHandler(w, req)

			if w.Code != http.StatusOK {
				b.Fatalf("Expected 200, got %d", w.Code)
			}
		}
	})
}
