# KUBI HUB V4.0

Stały loader pozostaje bez zmian:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kubibubi124269/script-kubi-hub-babft/main/main.lua"))()
```

## Co dodano

- Skalowane GUI z dziewięcioma zakładkami, wyszukiwaniem schematów i motywami. Prawy Ctrl lub pływający przycisk K pokazuje okno.
- Circle Maker: materiał, środek wybrany kliknięciem lub współrzędnymi, promień, liczba bloków obwodu, warstwy, odstępy, grubość, łuk, wypełnienie, trzy płaszczyzny, obrót i podgląd. Ustawienia można skopiować jako JSON.
- Shape Lab: kula, kopuła, spirala, ściana i szachownica.
- 22 plany budowy: rozbudowane łodzie, czołg z 8 kołami i armatą, samolot i statek z fotelem pilota i dopalaczami, duża łódź podwodna, forteca z podłogą i wieżami, most, figury robota i smoka, nowy wygląd WORM, portal, UFO, wieża, schody, piramida i TNT_STACK. Figury robota i smoka są konstrukcjami dekoracyjnymi.
- Bomba: 1 TNT, 1 siedzenie obok i 3000 bloków drewna w jednym punkcie nad TNT. Liczbę drewna można zmniejszyć. Odpalanie i rozrzut obsługuje gra; skrypt nie gwarantuje wyniku fizyki.
- Kolejka z kontrolą materiałów i granic własnej działki, pauzą, anulowaniem i potwierdzeniem dużego planu. Oddzielne liczniki pokazują żądania oraz rzeczywiście zaobserwowane bloki.
- Szybsza kolejka: domyślna przerwa 0,04 s, tryby Fast / Turbo / Safe i malowanie partiami do 32 bloków. Czas obsługi żądań nadal zależy od serwera; nie deklarujemy konkretnego przyspieszenia w grze.
- Panel gracza i zabawy: wybór osoby, podejście, podążanie, orbita własnej postaci, obserwacja kamerą, obrót i skoki własnej postaci. Duch, konfetti i dyskoteka są lokalnymi efektami.
- Lot, prędkość, skok, noclip własnej postaci, anti AFK, zapamiętanie pozycji, powrót na działkę, statystyki farmy, diagnostyka narzędzi i STOP.
- Czytnik LP_BUILD oraz dwa znalezione modele z mechaniką dostępne do podglądu.

## WORM i SHREDDER: stan prac

Animacja WORM dotyczy podglądu lokalnego. Budowa jego zwykłego schematu stawia nieruchomą geometrię. Oryginalnego pliku WORM 9 ze zdjęcia nie znaleziono.

Zachowano dwa pobrane pliki społeczności:

- [Czerwony robak](https://luau.pro/catalog/build/70329a6b-4b82-4fd4-b0dd-aa89fcb5a44a): 2830 elementów, koszt 4184 bloków, w tym 6 serw i 8 tłoków. To podobny model, nie potwierdzony oryginał ze zdjęcia.
- [Working Shredder](https://luau.pro/catalog/build/8e8ea8d2-08d3-487e-8a31-298b2361bb3d): 960 elementów, koszt 973 bloków, 40 SpikeTrap, 2 koła, 4 dopalacze i fotel pilota. Nie potwierdzono, że to SHREDDER 5.0 z miniatury.

`worm-red.json` i `shredder.json` zachowują właściwości i połączenia modelu. KUBI HUB obecnie odczytuje je do podglądu. Budowanie tych mechanicznych plików jest zablokowane: odtwarzanie połączeń, właściwości narzędzi i sterowania nie zostało jeszcze zaimplementowane ani przetestowane w BABFT. Działające rozrywanie łodzi przez SHREDDER pozostaje niewykonane.

`Red_Worm.Build` i `Working_Shredder.Build` są plikami źródłowymi, czytanymi jako dane. Autorstwo modeli pozostaje przy ich twórcach. Uploader w katalogu jest opisany jako luau.pro; autorstwa konstrukcji nie zweryfikowano. Źródła podano powyżej.

## Sprawdzenie

Sprawdzono składnię Lua, geometrię, materiały, warstwy i stos TNT, inicjalizację GUI w uproszczonym środowisku, kontrolę działki, kolejkę, odrzucenia serwera, blokadę po przekroczeniu czasu i przywracanie postaci. Nie uruchomiono skryptu w Robloxie; zgodność narzędzi BABFT, fizyka i replikacja wymagają testu w grze.

Pierwszy test: w Circle Maker ustaw WoodBlock, promień 4, obwód 8 bloków, jedną warstwę i środek własnej działki. Najpierw pokaż podgląd, a następnie zbuduj. W razie błędu wybierz Ustawienia → Sprawdź narzędzia BABFT → Skopiuj log diagnostyczny. Ustawienia pojazdów, połączenia i obsługa foteli wymagają sprawdzenia w aktualnej wersji gry; modele nie są oznaczane jako potwierdzone działające pojazdy.

GUI i generatory znajdują się w `main.lua`. Skrypt nie uruchamia zewnętrznych bibliotek Lua. Wybranie mechanicznego modelu pobiera wyłącznie JSON z tego repozytorium i odczytuje go jako dane.
