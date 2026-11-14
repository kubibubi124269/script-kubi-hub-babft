# KUBI HUB DELUXE 7.0

Ten sam loader otwiera wybór języka, kartę społeczności i menu BABFT / MM2 / Steal a Brainrot / Bike Universe / Universal. Automaty zaczynają wyłączone.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kubibubi124269/script-kubi-hub-babft/main/main.lua"))()
```

**Nowe w 7.0:** Na ekranie startowym i w podstawowych kontrolkach wybierzesz polski, angielski, rosyjski, ukraiński, chiński uproszczony, hiszpański, niemiecki, portugalski, francuski lub włoski. Starsze opisy i część komunikatów mogą pozostać po polsku.

- **Tempo:** osobny wybór w BABFT, MM2, Steal a Brainrot i Bike Universe. W BABFT wybierz **Autofarm → Tryb trasy → Teleport szybki**, jeśli chcesz pojedynczy skok do każdego etapu. Nadal czeka na trasę i powrót od skrzyni.
- **Bike Universe:** automatyczny gaz, sekwencja wheelie i trików, boost gazu i zatrzymanie przy wykrytej przeszkodzie. **F8** zwalnia klawisze. Zapisz start i checkpointy, przyjmij zaproszenie w grze, a po starcie uruchom trasę. Gra nalicza kasę i wynik; sterowania i zaliczenia nie potwierdzono w publicznej grze.
- **Konfiguracje konta:** wpisz nazwę w Ustawieniach i zapisz. Hub przywraca ostatni profil zapisany dla aktualnego UserId i trybu gry. Używa plików, jeśli środowisko je udostępnia; w przeciwnym razie to pamięć sesji. Zapis dotyczy ustawień, a nie danych logowania.
- **Społeczność:** kartę [Discord](https://discord.gg/qmWGb4Q9p) / [YouTube](https://www.youtube.com/@Kubi_Bubi1242) można pominąć. O kod PRO zapytaj twórcę. Hub nie sprawdza subskrypcji ani członkostwa.

**Z V6.6:** **MM2 → Misc → Studio skórek MM2** pokazuje nóż i pistolet w 3D w sześciu wzorach. Możesz obracać model, losować styl, przymierzyć kolor na własnej broni z rundy lub założyć broń, którą już masz w plecaku. Podgląd i kolor są lokalne. Prawdziwe wymiany odbywają się w grze.

**Z V6.5:** Farma MM2 leci płynnie do pobliskich monet lub cukierków, a w opcji **Ruch** można zmienić Lot na Chód. Podejdź bliżej, gdy nie ma celu w zasięgu. W każdym trybie zakładka **Narzędzia** zawiera 20 funkcji: HUD, filtry obrazu, stoper, minutnik i znacznik miejsca. [Lista](FEATURES.md).

**Z V6.4:** Dołącz do [Steal a Brainrot](https://www.roblox.com/games/109983668079237/Steal-a-Brainrot), wybierz jego tryb i włącz AutoSteal. Gdy podejdziesz w zasięg widocznej akcji „Steal”, hub przytrzyma przycisk przez czas ustawiony w grze. Do bazy wracasz samodzielnie. STOP, odrodzenie i zamknięcie przerywają próbę. O wyniku decyduje serwer gry; przebieg sprawdzono w testach offline. [Test w grze](docs/TESTING.md#steal-a-brainrot).

**Poprawka V6.3:** Headless ukrywa również samą głowę i odnawia ukrycie po kamerze. Dodano 12 narzędzi: oznaczenia przedmiotów i skróty ról MM2, lokalne efekty oraz dwa tryby zoomu Universal. [Szczegóły i ograniczenia](docs/V6.3-REPORT.md). Potwierdzenie wyglądu Headless nadal wymaga testu w grze.

**Z V6.2:** Universal z FPS, FOV, celownikiem, lokalnym jasnym dniem, ruchem i punktami teleportu. MM2 / Trolling ma Fling z wyborem celu, Fake Headless, nogę w stylu Korblox i mały skin. Wygląd jest lokalny; płatne przedmioty nie są nadawane na konto. Zmniejszenie lokalnego korzenia nie gwarantuje mniejszego serwerowego hitboxa. [Raport V6.2](docs/V6.2-REPORT.md).

Menu BABFT / MM2: **Autofarm · Trolling · Teleport · Fight · Misc · Narzędzia · Ustawienia**. Builder, schematy, generatory i Circle Maker są w Misc. Shapes nie ma osobnej zakładki.

**LPM** używa funkcji. **PPM / ⋯** otwiera jej ustawienia. **Prawy Ctrl** pokazuje / ukrywa okno. Wyszukiwarka znajduje funkcje i sekcje. Szczegóły komunikatu otwiera dolny pasek lub powiadomienie.

MM2 nie pomija już monety przez przezroczysty korzeń kolizji, gdy CoinVisual jest widoczny. BABFT przenosi całą postać przez etap, opuszcza siedzenie i czeka na wczytanie brakującego punktu. Są pauza, STOP i czytelne stany oczekiwania. **Odbiór nagród i działanie w aktualnej grze wymagają sprawdzenia; testy offline nie potwierdzają serwerowej waluty.**

Builder zachowuje bibliotekę, duże statyczne modele domu i zamku, podgląd, UNDO / REDO, import i eksport. Natywne budowanie wymaga TEST 1 BLOKU, działki, materiałów i odpowiednich narzędzi. Schemat mechaniczny ma jawną opcję osobnej nieruchomej kopii. **Zawiasy i sterowanie WORM-a nadal nie są obsługiwane w BABFT.** Stos dynamitu pozostaje planem asystenta.

MM2 zachowuje Aimbot, Auto Shot, ESP ról, Auto Gun, Knife Aura, obieg z własnym nożem i ograniczony Fling. Broń i skutki akcji zatwierdza gra. Teleport oferuje trzy punkty sesji i powrót. Funkcje przemieszczające postać wzajemnie się wykluczają.

Nowe w MM2: podgląd gracza z przywróceniem kamery, teleport do wybranego gracza i ostrzeżenie o bliskim Murdererze rozpoznanym po nożu. Opcje nicku i odległości są pod PPM.

Sprawdzenie: testy logiki i klienta, 4 importy modeli, 46 modułów (Luau 0.744). Nie testowano w natywnym kliencie Roblox ani na publicznych serwerach.

[Raport V6.1](docs/V6.1-REPORT.md) · [Testy w grze](docs/TESTING.md) · [Źródła modeli](docs/COMMUNITY-MODELS.md) · [Historia](CHANGELOG.md)

Budowanie pakietu: `node tools/build.cjs`. Testy: `LUAU_BIN=/path/to/luau LUAU_COMPILE=/path/to/luau-compile node tools/test.cjs`.

Kod klienta jest zawarty w main.lua; brak zewnętrznych bibliotek Lua. Modele są danymi JSON z tego repozytorium. Kod PRO odblokowuje funkcje lokalnie i nie nadaje uprawnień na serwerze.
