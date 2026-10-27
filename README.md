# KUBI HUB V4.1

Stały loader pozostaje bez zmian:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kubibubi124269/script-kubi-hub-babft/main/main.lua"))()
```

## Co dodano

- **100 narzędzi i gotowych akcji** w nowej zakładce z kategoriami i wyszukiwaniem. To 30 nowych planów, 20 akcji warsztatu, 15 ustawień widoku, 15 efektów i 20 pomocników automatycznych. Katalog zawiera także warianty ustawień i makra. [Pełny opis wszystkich 100 wpisów](FEATURES.md).
- **Poprawki budowania:** schematy są wyśrodkowane z uwzględnieniem rozmiaru bloków, stan działki jest odczytywany ponownie, tytan nie jest domyślnie wymuszany, brak PaintingTool pomija kolory zamiast blokować budowę. Bloki o domyślnym rozmiarze nie potrzebują ScalingTool. Rzeczywiste skalowanie nadal wymaga tego narzędzia; koszt materiału uwzględnia objętość.
- Dłuższe oczekiwanie na pojawienie się bloku po odpowiedzi serwera, bez automatycznego powtarzania niepotwierdzonych żądań. Stary blok zwrócony przez RF nie jest uznawany za nowy. Pierwszy odrzucony lub niepotwierdzony blok zatrzymuje kolejkę i pokazuje pełny raport.
- **Klucz społeczności:** zakładka KLUCZ / PRO odblokowuje wybrane funkcje kodem ze społeczności. Przycisk kopiuje zaproszenie użytkownika: [Discord KUBI HUB](https://discord.gg/qmWGb4Q9p). To prosta blokada po stronie klienta; hub nie sprawdza członkostwa na Discordzie. Kod w publicznym skrypcie nie stanowi zabezpieczenia przed odczytaniem ani obejściem.
- Skalowane GUI z dwunastoma zakładkami, wyszukiwaniem schematów, ulubionymi i motywami. Prawy Ctrl lub pływający przycisk K pokazuje okno.
- Circle Maker: materiał, środek wybrany kliknięciem lub współrzędnymi, promień, liczba bloków obwodu, warstwy, odstępy, grubość, łuk, wypełnienie, trzy płaszczyzny, obrót i podgląd. Ustawienia można skopiować jako JSON.
- Shape Lab: kula, kopuła, spirala, ściana i szachownica.
- 52 zwykłe plany budowy i 2 pliki mechaniczne do podglądu. Nowe konstrukcje obejmują m.in. domek, labirynt, igloo, torus, lej, spiralne schody, studnię, altanę, hangar, przystań, bramki, serce, helisę, latarnię i akwedukt. Konstrukcje są statyczne; dodanie części pojazdu nie gwarantuje gotowego sterowania.
- Bomba: 1 TNT, 1 siedzenie obok i 3000 bloków drewna w jednym punkcie nad TNT. Liczbę drewna można zmniejszyć. Odpalanie i rozrzut obsługuje gra; skrypt nie gwarantuje wyniku fizyki.
- Kolejka z kontrolą materiałów i granic własnej działki, pauzą, anulowaniem i potwierdzeniem dużego planu. Oddzielne liczniki pokazują żądania oraz rzeczywiście zaobserwowane bloki.
- Szybsza kolejka: domyślna przerwa 0,04 s, tryby Fast / Turbo / Safe i malowanie partiami do 32 bloków. Czas obsługi żądań nadal zależy od serwera; nie deklarujemy konkretnego przyspieszenia w grze.
- Panel gracza i zabawy: wybór osoby, podejście, podążanie, orbita własnej postaci, obserwacja kamerą, obrót i skoki własnej postaci. Duch, konfetti i dyskoteka są lokalnymi efektami.
- Lot, prędkość, skok, noclip własnej postaci, anti AFK, zapamiętanie pozycji, powrót na działkę, statystyki farmy, diagnostyka narzędzi i STOP.
- Czytnik LP_BUILD oraz dwa znalezione modele z mechaniką dostępne do podglądu.
- Eksport geometrii własnej budowli oraz wybranego schematu do JSON, budowanie wczytanego pliku bez mechaniki, odbicia X/Z, obrót, wersja drewniana, budowanie od dołu i ramka wymiarów. Eksport nie zapisuje połączeń mechanicznych.
- Lokalny tęczowy ślad, mini i duże sobowtóry, armia klonów, ślady stóp, gwiazdy i aureola, cząstki, ustawienia kamery, dzień / noc, mniej efektów, ratunek po spadnięciu, ślady trasy i spacer między czterema własnymi punktami. STOP wyłącza automatykę, przerywa spacer i przywraca widok.

## WORM i SHREDDER: stan prac

Animacja WORM dotyczy podglądu lokalnego. Budowa jego zwykłego schematu stawia nieruchomą geometrię. Oryginalnego pliku WORM 9 ze zdjęcia nie znaleziono.

Zachowano dwa pobrane pliki społeczności:

- [Czerwony robak](https://luau.pro/catalog/build/70329a6b-4b82-4fd4-b0dd-aa89fcb5a44a): 2830 elementów, koszt 4184 bloków, w tym 6 serw i 8 tłoków. To podobny model, nie potwierdzony oryginał ze zdjęcia.
- [Working Shredder](https://luau.pro/catalog/build/8e8ea8d2-08d3-487e-8a31-298b2361bb3d): 960 elementów, koszt 973 bloków, 40 SpikeTrap, 2 koła, 4 dopalacze i fotel pilota. Nie potwierdzono, że to SHREDDER 5.0 z miniatury.

`worm-red.json` i `shredder.json` zachowują właściwości i połączenia modelu. KUBI HUB obecnie odczytuje je do podglądu. Budowanie tych mechanicznych plików jest zablokowane: odtwarzanie połączeń, właściwości narzędzi i sterowania nie zostało jeszcze zaimplementowane ani przetestowane w BABFT. Działające rozrywanie łodzi przez SHREDDER pozostaje niewykonane.

`Red_Worm.Build` i `Working_Shredder.Build` są plikami źródłowymi, czytanymi jako dane. Autorstwo modeli pozostaje przy ich twórcach. Uploader w katalogu jest opisany jako luau.pro; autorstwa konstrukcji nie zweryfikowano. Źródła podano powyżej.

## Sprawdzenie

Sprawdzono składnię Lua, ponad 15 tysięcy warunków geometrii, 30 nowych generatorów, rejestr 100 rzeczywistych akcji, poprawny i błędny klucz, 12 stron GUI, wyśrodkowany most na działce, budowę bez PaintingTool, koszt skalowania, opóźnione pojawienie się bloku, odrzucenia serwera, stare wyniki RF, automatykę, STOP i przywracanie widoku w uproszczonym środowisku. Użytkownik potwierdził uruchamianie V4.0, lecz zgłosił niedziałające schematy. Poprawki V4.1 wymagają teraz testu w aktualnym BABFT; nie potwierdzono zgodności narzędzi, fizyki ani replikacji w grze.

Pierwszy test: podejdź na własną działkę, otwórz NARZĘDZIA + i kliknij TEST 1 DREWNIANEGO BLOKU. Jeśli pojawi się blok, wybierz mały schemat lub Circle Maker: WoodBlock, promień 4, obwód 8, jedna warstwa. W razie błędu wybierz SKOPIUJ PEŁNY RAPORT i wklej go na czacie. Ustawienia pojazdów, połączenia i obsługa foteli nadal wymagają sprawdzenia w aktualnej wersji gry.

GUI i generatory znajdują się w `main.lua`. Skrypt nie uruchamia zewnętrznych bibliotek Lua. Wybranie mechanicznego modelu pobiera wyłącznie JSON z tego repozytorium i odczytuje go jako dane.
