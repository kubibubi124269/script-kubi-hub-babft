# Funkcje V6.6.0

## 6.6.0 — Studio skórek MM2

- W Misc są modele 3D noża i pistoletu. Style: Zorza, Rubin, Złoty, Lód, Obsydian i Laser. Podgląd można obrócić i wylosować inny kolor.
- Przymiarka nakłada lokalny efekt koloru na widoczną broń gracza. Oryginalna skórka pozostaje bez zmian.
- **Załóż broń z tej rundy** wybiera wyłącznie broń, którą gra już dała graczowi. Skórki, które da się przekazać, wymienia się przez okno wymiany w MM2.

## 6.5.0 — Narzędzia w każdym trybie

- **HUD (7):** FPS, czas sesji, pozycja XYZ, zdrowie, prędkość, liczba graczy i odległość do znacznika. Każdą linię można włączyć osobno.
- **Filtry (6):** czarno-biały, sepia, wyższy kontrast, nasycone kolory, chłodny obraz i przyciemnienie. Jeden filtr naraz.
- **Czas (4):** stoper, zapis międzyczasu, reset stopera i minutnik z powiadomieniem. Czas minutnika ustawisz pod PPM / ⋯.
- **Znacznik (3):** zapisz bieżącą pozycję, pokaż lub schowaj etykietę i usuń znacznik. To wskazówka widoczna u Ciebie.

**MM2:** w zakładce Autofarm wybierz monety, cukierki lub oba typy. Postać leci do pobliskich celów lub podchodzi w trybie **Chód**. Klawisze ruchu mają pierwszeństwo, a zablokowane cele są czasowo pomijane.

## 6.4.0 — Steal a Brainrot

- Osobny tryb z przełącznikiem **AutoSteal** oraz stanem ostatniej próby.
- Gdy gra pokazuje aktywną akcję kradzieży w zasięgu, AutoSteal przytrzymuje ją zgodnie z czasem gry. Wybiera najbliższą akcję i robi przerwę pomiędzy próbami.
- **STOP** lub wyjście z huba od razu zwalnia przycisk. AutoSteal wyłącza się po odrodzeniu. Brainrota zanosisz do bazy samodzielnie.

## 6.3.0 — 2026-11-04

Poprawka Headless po zgłoszeniu, że cała głowa pozostaje widoczna mimo aktywnego efektu. Teraz głowa i jej części mają lokalnie Transparency=1 oraz LocalTransparencyModifier=1. Zmiana Transparency jest korygowana zdarzeniem, a osobny etap renderowania po priorytecie Last odnawia ukrycie po kamerze. Widoczność nie zależy od modułu celowania. Wyłączenie odłącza zdarzenia i przywraca zapamiętane wartości. Geometria Korblox pozostaje bez zmian.

Dwanaście nowych narzędzi w istniejących kategoriach: cztery wspólne efekty (bez akcesoriów, bez twarzy, Duch i latarka), MM2 podświetlanie monet oraz upuszczonej broni, dwa skróty podglądu ról i dwa skróty teleportu, a w Universal daleki zoom oraz pierwsza osoba.

Luau 0.744: **86 testów logiki, 210 sprawdzeń klienta, 4 importy modeli i 38 modułów**, bez błędów. To testy offline; Headless wymaga potwierdzenia wyglądu w grze użytkownika.


## 6.2.0 — 2026-11-04

Universal jest trzecim przyciskiem obok BABFT i MM2 na ekranie wyboru. Ma własne pięć pionowych kategorii: Główne, Postać, Widok, Teleport i Ustawienia. Oferuje FPS, własny ruch / Fly, trzy punkty teleportu, FOV, celownik, lokalny jasny dzień i lokalny wygląd. Gra może przywracać swoją kamerę, oświetlenie, rozmiar i ruch; brak obietnicy działania ruchu we wszystkich grach.

MM2 / Trolling: Fling ma cel NEAREST / MURDERER / SELECTED oraz czas 0,5–3 s. Są osobne przełączniki Fake Headless, nogi w stylu Korblox, małego skina i lokalnego korzenia hitboxa. Ustawienia pod PPM / ⋯; przywracanie po STOP, respawnie i wyłączeniu. Efekty nie nadają płatnych przedmiotów na konto. Lokalny HumanoidRootPart nie jest potwierdzeniem zmniejszenia serwerowego obszaru trafień.

Luau 0.744: **86 testów logiki, 181 sprawdzeń klienta, 4 importy modeli, 38 modułów**. Wszystkie offline; natywna fizyka, wygląd i serwerowe efekty wymagają testu w grze.


- Autofarm: osobne kontrolery BABFT i MM2, pauza i STOP, opcje pod PPM.
- Trolling: Fling w MM2 oraz lokalne efekty; kopia awatara i ślad w BABFT.
- Teleport: trzy punkty sesji, powrót; MM2 również rzeczywisty GunDrop.
- Fight: MM2 Aimbot, Auto Shot, Knife Aura i obieg z własnym nożem. BABFT wskazuje dostępność walki w MM2.
- Misc: MM2 ESP, Auto Gun, podgląd gracza, ostrzeżenie o Murdererze i ruch; BABFT Builder, schematy, Circle Maker, generatory i narzędzia.
- Ustawienia: wygląd, pełny komunikat, raport, powrót do wyboru gry i STOP.

PPM i ⋯ otwierają opcje funkcji bez jej uruchomienia. Builder oznacza plany statyczne, mechaniczne i podglądy. Konwersja mechaniki tworzy oddzielny nieruchomy model zwykłych bloków. Nie dodaje zawiasów do BABFT.

Status wydania i granice weryfikacji: [raport V6.1](docs/V6.1-REPORT.md). Rzeczywista gra nadal wymaga testu użytkownika.
