# Historia zmian

## 5.2.0 — 2026-10-30

Zgłoszenie: GUI otwiera się, lecz budowanie i autofarm nie działają. Przyczyna V5: klient obsługiwał tylko KubiHubAuthorizedBridgeV1, dostępny we własnej grze Studio. Dodano osobny tryb BABFT wykorzystujący własne narzędzia gracza według protokołu zachowanego w V4.1. Jednorazowy test drewna musi odczytać nowy blok we własnym folderze, zanim BUILD będzie dostępny. Następnie statyczna geometria jest wysyłana pojedynczo, z kontrolą pozycji, obrotu, rozmiaru bloków i kolorów. Niepotwierdzone żądanie nie jest ponawiane. Anulowanie zachowuje liczbę odczytanych części i pozostawia je na działce. Test jest unieważniany po respawnie. Siedzenia zachowują natywny rozmiar. Nie dodano odtwarzania zawiasów ani klina.

Odczyt materiałów obejmuje teraz podfoldery i jawne aliasy, bez łączenia metalu z tytanem. Dodano raport wykrytych narzędzi i działki oraz ograniczenie historii zakończonych budów. Autofarm BABFT nie został włączony: przywrócenie wcześniejszego sposobu wymaga wyjaśnienia zakresu z użytkownikiem. Weryfikacja offline: 74 testy logiki, 58 sprawdzeń klienta w mocku i dwa importy. Protokół narzędzi oraz zachowanie w aktualnym BABFT wymagają testu w grze; nie deklarujemy ich potwierdzenia.

## 5.1.1 — 2026-10-29

Poprawka problemów widocznych na zrzucie ekranu: sześć zakładek w siatce w wąskim oknie, automatyczna wysokość tekstu bez pustych obszarów i uciętych opisów oraz zwykłe znaki [+]/[-] w nagłówkach. Kliknięcie dolnego paska otwiera pełny komunikat. Skróty DEBUG/STATS/PERFORMANCE rozwijają właściwą sekcję Settings; raport odświeża się w tej zakładce.

Bez potwierdzonego dostępu do budowania przycisk otwiera instrukcję ręczną, a nie próbuje uruchamiać niedostępnej transakcji. Kontrolki budowy pojawiają się po potwierdzeniu uprawnienia przez serwer. Ta poprawka nie dodaje publicznego API BABFT. Weryfikacja offline: 63 testy logiki, 45 sprawdzeń kontraktu GUI oraz dwa importy modeli. Natywne renderowanie i fizyka nie były testowane.

## 5.1.0 — 2026-10-29

Najpierw odtworzono błędy V5.0 w testach, następnie poprawiono warstwy od pierwszej, walidację importowanych danych i flag, zachowanie obrotu i zawiasów w eksporcie, odrzucanie nieznanych materiałów ustawień, odzyskiwanie kopii po błędzie odczytu, stare komunikaty błędów oraz pełne granice obszaru. Nieznana odpowiedź na anulowanie nie jest już przedstawiana jako CANCELLED, a stan committed wymaga poprawnej liczby części.

Nowo generowane i importowane projekty zaczynają z neutralnymi przekształceniami; obrót i materiał poprzedniego modelu nie zmieniają nowego koła ani nie podwajają obrotu importu. Szybkie importy mają unikalne ID. Odświeżanie katalogu nie dopisuje bez końca tekstu wyszukiwarki. Kamera nie tworzy ponownie części podglądu przy każdym kliknięciu. Kontrolki odzwierciedlają cofanie i wczytane ustawienia.

Po naprawach dodano wyśrodkowanie X/Z, przesunięcia, skalowanie zwykłych planów 10–200%, dopasowanie do odczytanych lub ręcznych wymiarów, listę materiałów do skopiowania i przejście do konkretnego elementu. Dopasowanie jest jedną zmianą UNDO, a mechaniki nie skaluje. Nadal sześć zakładek i ten sam loader. Weryfikacja offline: 61 testów logiki, 30 sprawdzeń GUI, dwa importy modeli; testów w Roblox/Studio nie wykonano.

## 5.0.0 — 2026-10-28

Przebudowa V4.1 na 23 moduły z deterministycznym main.lua. Sześć zakładek, zwijane sekcje, wyszukiwanie funkcji i osobny Circle Maker. Osobne ID tytanu i metalu, wymagane/posiadane/brakujące materiały oraz stan nieznany. Stos: jeden Dynamite, jedno Seat i 3000 WoodBlock. WORM MK2 ma graf 14 zawiasów i jednego kierowcę. Własny adapter Studio, kontrolery budowania i cykli, profile JSON, raporty, 40 testów logiki i 18 sprawdzeń GUI w mocku.

Niepotwierdzone prywatne wywołania BABFT zastąpiono trybem asystenta. Budowa, farmienie i zmiany ruchu wymagają uprawnionego serwera. Fizyka WORM-a nie jest potwierdzona. Zachowano dawne modele i historię. Funkcje destrukcyjne przeciwko innym graczom nie są częścią wydania.

## 4.1 — 2026-10-27

Poprzedni stan: 7b73cfd09120fa86be5dc26bf5f8790a2eab844f. Monolityczny klient, 100 wpisów katalogu (także warianty i makra), 52 statyczne plany i dwa podglądy. Użytkownik zgłosił niedziałające schematy. Wcześniejsze testy uproszczone nie potwierdzały narzędzi, fizyki ani replikacji BABFT.
