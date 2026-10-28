# Raport V5.0 — 2026-10-28

## Audyt

Zbadano wszystkie osiem plików commita 7b73cfd: klient, loader, dwie dokumentacje i cztery dane modeli. [Manifest audytu](baseline-audit.json) podaje rozmiary, skróty i materiały. Skróty dotyczą kopii Windows z CRLF, nie surowych blobów Git. Repo nie miało modułów, testów ani CI. main.lua: 1520 linii, 132 konstrukcje funkcji, cztery miejsca task.spawn.

Ustalono: niepotwierdzony kontrakt prywatnego BuildingTool.RF; WORM jako lokalna geometria bez natywnych połączeń; brak pełnego PAUZA/WZNÓW i rozstrzygnięcia późnych odpowiedzi; brak walidowanego zapisu profili; niejednoznaczne etykiety materiałów i statystyki. Dawne testy nie uruchamiały silnika Roblox. Zgłoszenie „29 siedzeń” nie zawierało raportu, więc jego pierwotna przyczyna pozostaje nieustalona. Nowy test sprawdza dokładnie wymagane 1 / posiadane 29 / brakujące 0.

## Stan

| Obszar | Status | Dowód / ograniczenie |
| --- | --- | --- |
| Sześć zakładek, wyszukiwanie, zwijanie | NAPRAWIONE | Pełny klient startuje w mocku; wynik otwiera sekcję. Wygląd natywny do sprawdzenia. |
| Metal/tytan | NAPRAWIONE | 3000 metalu + 20 tytanu przy wymaganych 40 tytanu → brakuje 20 tytanu. |
| Nieznany stan materiałów | NAPRAWIONE | Brak odczytu nie staje się zerem. |
| Stos | NAPRAWIONE | Dynamite=1, Seat=1, WoodBlock=3000 we wspólnym punkcie. Wyłącznie plan. |
| Circle Maker | DZIAŁA w testach | Bez zdublowanego końca pierścienia i środka dysku. Limit 6000 części. |
| Biblioteka | DZIAŁA w walidacji | 53 plany, zero błędów normalizacji. Dawne pojazdy mają geometrię, bez gwarancji sterowania. |
| Budowa przez adapter | WYMAGA TESTU W GRZE | Walidacja, partie i potwierdzenia; odrzucenia i wyścigi testowane offline. |
| Publiczny BABFT | OGRANICZENIE | Brak potwierdzonego uprawnionego API: podgląd i asystent. |
| WORM MK2 | WYMAGA TESTU W GRZE | 49 części, 14 zawiasów, 1 kierowca, spójny graf; jazda, paszcza i replikacja niepotwierdzone. |
| Stare pliki WORM/SHREDDER | OGRANICZENIE | Zachowane dane, podgląd; brak rekonstrukcji dawnych BindTable/tłoków i ataków. |
| Autofarm | DZIAŁA jako automat logiki | 6 przerw, STOP/PAUZA/WZNÓW, ograniczone ponowienia i pomiary. Trasa Studio bez złota. |
| Profile | DZIAŁA w testach logiki | Walidacja, kopia, rollback i ograniczona nazwa pliku. Bez funkcji plikowych: pamięć sesji i eksport. |
| Sprzątanie | NAPRAWIONE w mocku | Jedno GUI, rozłączone stare zdarzenia, oryginalny ruch zachowany. |
| Szybkość dużych budów | OGRANICZENIE pomiaru | Partia do 16 elementów; brak pomiaru czasu w Roblox i obietnic mnożnika. |
| Obsługa błędów | NAPRAWIONE w testach | Timeout, złe ID, odrzucenie, zły JSON i niedobory nie są sukcesem. |

## Implementacja i granice

core: cykl życia, most i aplikacja; ui: układ, nawigacja, kontrolki i ViewportFrame; modules: inventory/builder/farm/movement/tools/debug; schematics: generatory, walidator i rig; config: profile; tools: budowanie i testy; studio: własny serwer.

Most potwierdza sesję, protokół, użytkownika i miejsce. Serwer ponownie sprawdza plan, budżet i granice własnej działki, potwierdza kolejność ID, zwraca rezerwację po anulowaniu i usuwa otwartą transakcję po 30 s. buildStatus(cancel=true) rozstrzyga anulowanie względem zakończonego zatwierdzenia. Limit: 16 transakcji na sesję, budżet testowy 50000 każdego materiału. Nie są to materiały/złoto BABFT. Klucz 6969 nie autoryzuje mostu.

Koszt objętościowy jest modelem projektu, a nie potwierdzoną ceną BABFT. Profile korzystają wyłącznie z katalogu KubiHubUltimateV5 i zwalidowanych nazw. Nie odczytuje się haseł, tokenów ani danych przeglądarki. Aktualizacje sprawdzają JSON tego repozytorium bez podmiany kodu. Import JSON nigdy nie jest wykonywany.

Pozostają testy natywnego GUI, dotyku, jazdy, paszczy, stabilności WORM-a, dwóch graczy, przerwania podczas replikacji i rzeczywistego czasu budowy. Użytkownik ma tylko Roblox/BABFT. Dostarczony zestaw Studio nie oznacza wykonania tych testów. Liczba „100 nowych funkcji” nie jest deklaracją tego wydania; priorytetem jest uporządkowanie i rzetelny stan działania.
