# Historia zmian

## 6.3.0 — 2026-11-04

Poprawka Headless po zgłoszeniu, że cała głowa pozostaje widoczna mimo aktywnego efektu. Teraz głowa i jej części mają lokalnie Transparency=1 oraz LocalTransparencyModifier=1. Zmiana Transparency jest korygowana zdarzeniem, a osobny etap renderowania po priorytecie Last odnawia ukrycie po kamerze. Widoczność nie zależy od modułu celowania. Wyłączenie odłącza zdarzenia i przywraca zapamiętane wartości. Geometria Korblox pozostaje bez zmian.

Dwanaście nowych narzędzi w istniejących kategoriach: cztery wspólne efekty (bez akcesoriów, bez twarzy, Duch i latarka), MM2 podświetlanie monet oraz upuszczonej broni, dwa skróty podglądu ról i dwa skróty teleportu, a w Universal daleki zoom oraz pierwsza osoba.

Luau 0.744: **86 testów logiki, 210 sprawdzeń klienta, 4 importy modeli i 38 modułów**, bez błędów. To testy offline; Headless wymaga potwierdzenia wyglądu w grze użytkownika.


## 6.2.0 — 2026-11-04

Universal jest trzecim przyciskiem obok BABFT i MM2 na ekranie wyboru. Ma własne pięć pionowych kategorii: Główne, Postać, Widok, Teleport i Ustawienia. Oferuje FPS, własny ruch / Fly, trzy punkty teleportu, FOV, celownik, lokalny jasny dzień i lokalny wygląd. Gra może przywracać swoją kamerę, oświetlenie, rozmiar i ruch; brak obietnicy działania ruchu we wszystkich grach.

MM2 / Trolling: Fling ma cel NEAREST / MURDERER / SELECTED oraz czas 0,5–3 s. Są osobne przełączniki Fake Headless, nogi w stylu Korblox, małego skina i lokalnego korzenia hitboxa. Ustawienia pod PPM / ⋯; przywracanie po STOP, respawnie i wyłączeniu. Efekty nie nadają płatnych przedmiotów na konto. Lokalny HumanoidRootPart nie jest potwierdzeniem zmniejszenia serwerowego obszaru trafień.

Luau 0.744: **86 testów logiki, 181 sprawdzeń klienta, 4 importy modeli, 38 modułów**. Wszystkie offline; natywna fizyka, wygląd i serwerowe efekty wymagają testu w grze.


## 6.1.0 — 2026-11-04

Sześć pionowych kategorii, PPM / ⋯ na opcje funkcji, poprawione przezroczyste monety MM2 i przechodzenie całej postaci przez etapy BABFT, trzy punkty teleportu i jawna nieruchoma kopia schematu mechanicznego. 86 testów logiki, 139 sprawdzeń klienta, 4 importy modeli. Nagrody i natywna fizyka wymagają sprawdzenia w grze. [Szczegóły](docs/V6.1-REPORT.md).


## 6.0.0 — 2026-11-03

Ekran wyboru BABFT / MM2 z osobnymi hubami, kontrolą gry i sprzątaniem przełączenia. Przywrócona trasa autofarmy BABFT: dziesięć etapów, skrzynia, pauza, oczekiwany respawn i STOP z powrotem żywej postaci. Shapes przeniesione do Buildera. Limit 10000 części, dom z katalogu (568) i statyczna architektura zamku (8149); oryginalne pliki i opis pominiętej mechaniki zachowano.

MM2: zbieranie monet / cukierków z trzema przerwami, pełna torba, Aimbot, Auto Shot, wybór celu i ściany, Kill all z własnym nożem, ograniczony eksperymentalny Murder Fling, Knife Aura, ESP widocznych ról, GunDrop / Auto Gun, własny ruch i wspólny STOP. Statystyki pokazują obserwacje i aktywacje, bez wymyślonych nagród lub trafień. Testy offline: 85 logiki, 110 klienta, cztery importy i kompilacja 33 modułów. Rzeczywisty serwer, obecne bronie i fizyka wymagają testów w grze. [Raport](docs/V6-REPORT.md).

## 5.2.2 — 2026-11-03

Powiadomienia i dolny pasek pokazują przyczynę zamiast samego „Nowy komunikat”. Kliknięcie okienka otwiera pełną treść i przywraca ukryty hub. Zachowano kompletne wyjątki, poprawny UTF-8, obsługę chwilowego braku kamery i sprzątanie zdarzeń. Panel Autofarm pokazuje rzeczywistą dostępność przed START; odmowa trafia do ostatniego błędu bez naliczania cyklu. Autofarma publicznego BABFT pozostaje wyłączona; to poprawka diagnostyki. Testy offline: 79 logiki, 69 kontraktu klienta i dwa importy. Test nowego komunikatu odtwarza zgłoszenie na V5.2.1 przed poprawką. [Raport zakresu](docs/V5.2.2-REPORT.md).

## 5.2.1 — 2026-10-30

Naprawiono awarię przed utworzeniem GUI. Przy braku dokładnej nazwy materiału wywołanie FindFirstChild otrzymywało dwa wyniki gsub: alias oraz liczbę zamian. Drugi argument API wymaga boolean, więc Roblox przerywał start. Alias jest teraz przypisany do osobnej zmiennej przed wywołaniem. Mock weryfikuje typ drugiego argumentu; na V5.2.0 odtworzył błąd podczas inicjalizacji odczytu materiałów. Dodano trzy regresje brakujących materiałów, zagnieżdżonych aliasów i pierwszeństwa dokładnych nazw. Po poprawce: 77 testów logiki, 58 sprawdzeń klienta i oba importy przechodzą. Nie zmieniano zakresu budowania ani autofarmy; test w rzeczywistej grze nadal jest potrzebny.

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
