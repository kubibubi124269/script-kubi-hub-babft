# KUBI HUB V6.4.0 — BABFT, MM2, Steal a Brainrot i Universal

Ten sam loader otwiera wybór BABFT / MM2 / Steal a Brainrot / Universal. Moduły zaczynają wyłączone.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kubibubi124269/script-kubi-hub-babft/main/main.lua"))()
```

**Nowe w V6.4:** Dołącz do [Steal a Brainrot](https://www.roblox.com/games/109983668079237/Steal-a-Brainrot), wybierz jego tryb i włącz AutoSteal. Gdy podejdziesz w zasięg widocznej akcji „Steal”, hub przytrzyma przycisk przez czas ustawiony w grze. Do bazy wracasz samodzielnie. STOP, odrodzenie i zamknięcie przerywają próbę. O wyniku decyduje serwer gry; przebieg sprawdzono w testach offline. [Test w grze](docs/TESTING.md#steal-a-brainrot).

**Poprawka V6.3:** Headless ukrywa również samą głowę i odnawia ukrycie po kamerze. Dodano 12 narzędzi: oznaczenia przedmiotów i skróty ról MM2, lokalne efekty oraz dwa tryby zoomu Universal. [Szczegóły i ograniczenia](docs/V6.3-REPORT.md). Potwierdzenie wyglądu Headless nadal wymaga testu w grze.

**Z V6.2:** Universal z FPS, FOV, celownikiem, lokalnym jasnym dniem, ruchem i punktami teleportu. MM2 / Trolling ma Fling z wyborem celu, Fake Headless, nogę w stylu Korblox i mały skin. Wygląd jest lokalny; płatne przedmioty nie są nadawane na konto. Zmniejszenie lokalnego korzenia nie gwarantuje mniejszego serwerowego hitboxa. [Raport V6.2](docs/V6.2-REPORT.md).

Menu BABFT / MM2: **Autofarm · Trolling · Teleport · Fight · Misc · Ustawienia**. Builder, schematy, generatory i Circle Maker są w Misc. Shapes nie ma osobnej zakładki.

**LPM** używa funkcji. **PPM / ⋯** otwiera jej ustawienia. **Prawy Ctrl** pokazuje / ukrywa okno. Wyszukiwarka znajduje funkcje i sekcje. Szczegóły komunikatu otwiera dolny pasek lub powiadomienie.

MM2 nie pomija już monety przez przezroczysty korzeń kolizji, gdy CoinVisual jest widoczny. BABFT przenosi całą postać przez etap, opuszcza siedzenie i czeka na wczytanie brakującego punktu. Są pauza, STOP i czytelne stany oczekiwania. **Odbiór nagród i działanie w aktualnej grze wymagają sprawdzenia; testy offline nie potwierdzają serwerowej waluty.**

Builder zachowuje bibliotekę, duże statyczne modele domu i zamku, podgląd, UNDO / REDO, import i eksport. Natywne budowanie wymaga TEST 1 BLOKU, działki, materiałów i odpowiednich narzędzi. Schemat mechaniczny ma jawną opcję osobnej nieruchomej kopii. **Zawiasy i sterowanie WORM-a nadal nie są obsługiwane w BABFT.** Stos dynamitu pozostaje planem asystenta.

MM2 zachowuje Aimbot, Auto Shot, ESP ról, Auto Gun, Knife Aura, obieg z własnym nożem i ograniczony Fling. Broń i skutki akcji zatwierdza gra. Teleport oferuje trzy punkty sesji i powrót. Funkcje przemieszczające postać wzajemnie się wykluczają.

Nowe w MM2: podgląd gracza z przywróceniem kamery, teleport do wybranego gracza i ostrzeżenie o bliskim Murdererze rozpoznanym po nożu. Opcje nicku i odległości są pod PPM.

Sprawdzenie: testy logiki i klienta, 4 importy modeli, 39 modułów (Luau 0.744). Bez natywnych testów renderowania, fizyki ani skutków kradzieży.

[Raport V6.1](docs/V6.1-REPORT.md) · [Testy w grze](docs/TESTING.md) · [Źródła modeli](docs/COMMUNITY-MODELS.md) · [Historia](CHANGELOG.md)

Budowanie pakietu: `node tools/build.cjs`. Testy: `LUAU_BIN=/path/to/luau LUAU_COMPILE=/path/to/luau-compile node tools/test.cjs`.

Kod klienta jest zawarty w main.lua; brak zewnętrznych bibliotek Lua. Modele są danymi JSON z tego repozytorium. PRO pozostaje lokalnym kluczem **6969**; [Discord](https://discord.gg/qmWGb4Q9p). Klucz nie weryfikuje członkostwa ani uprawnień serwera.
