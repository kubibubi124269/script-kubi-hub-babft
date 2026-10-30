# KUBI HUB ULTIMATE V5.2.0

Sześć głównych zakładek: **PRO, Builder, Autofarm, Shapes, Circle Maker, Settings**. Sekcje są zwijane, a wyszukiwarka u góry znajduje funkcje i ustawienia. Prawy Ctrl lub pływający przycisk **K** pokazuje okno.

W wąskim oknie wszystkie zakładki mieszczą się w dwóch lub trzech rzędach. Opisy i statystyki rosną razem z tekstem. Kliknięcie dolnego paska otwiera pełny komunikat w Settings.

V5.2 dodaje tryb korzystający z własnych narzędzi BABFT. **Nie potwierdzono go jeszcze w aktualnej grze.** Wejdź do drużyny, otwórz Builder i uruchom **TEST 1 BLOKU**. Dopiero wykrycie nowego drewnianego bloku w folderze Twojej budowli odblokuje BUILD dla planów statycznych. Samo otwarcie huba niczego nie buduje. Testowy blok pozostaje na działce. Narzędzia skalowania i malowania są potrzebne odpowiednim projektom. Siedzenia zachowują rozmiar natywnego modelu gry. STOP pozostawia już postawione części.

Stały loader pozostaje bez zmian:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kubibubi124269/script-kubi-hub-babft/main/main.lua"))()
```

`main.lua` zawiera cały klient, bez pobierania zewnętrznych bibliotek Lua. Moduły są w `src/`; `node tools/build.cjs` odtwarza pakiety. Poprzednia wersja pozostaje w historii: `7b73cfd09120fa86be5dc26bf5f8790a2eab844f`.

## Zgodność z BABFT

W publicznym BABFT dostępne są podgląd 3D, biblioteka 53 planów, wyszukiwanie, ulubione, Circle Maker, generatory brył, ręczny asystent elementów, odczyt materiałów, import/eksport JSON, profile oraz lokalne efekty. V5.2 usuwa zależność budowania wyłącznie od własnego mostu Studio. Tryb BABFT używa protokołu narzędzi zachowanego w V4.1 i wymaga testu w grze. Nie jest oficjalnym publicznym API ani gwarancją zgodności z obecną wersją BABFT. Brak potwierdzenia zatrzymuje kolejkę bez ponowienia. **Autofarm BABFT, zmiany ruchu i odtwarzanie mechaniki WORM-a pozostają niedostępne w tym wydaniu.** Własny most Studio nadal obsługuje funkcje testowe. Podgląd nie jest przedstawiany jako budowla serwerowa.

Materiały są odczytywane z dokładnych nazw `LocalPlayer.Data` i podfolderów Inventory/Blocks/BlockInventory. Jawny alias Wood odpowiada WoodBlock; Metal i Titanium pozostają osobne. Brak danych oznacza **NIE ODCZYTANO**, nie zero. Koszt objętościowy `ceil(objętość/8)` jest modelem projektu i zestawu Studio, nie zweryfikowanym cennikiem aktualnego BABFT.

## Zmiany

- Circle Maker: środek X/Y/Z względem własnej działki, materiał, promień, segmenty, warstwy, odstęp, grubość, łuk, trzy płaszczyzny i wypełniony dysk; limit 6000 części.
- WORM MK2: 49 części, jeden kierowca, 14 zawiasów, graf połączeń oraz serwerowy kontroler ciała i paszczy do własnego środowiska. **Jazda, fizyka i replikacja wymagają testu w Studio.**
- Stos: **1 laska dynamitu + 1 siedzenie + 3000 drewna w jednym punkcie**. Plan/asystent; brak detonacji i wysyłania nakładających się części na publiczny serwer.
- Builder: kontrola planu i materiałów, podgląd z obrotem/zoomem/warstwami, historia 30 zmian, kolejka z pauzą i anulowaniem, potwierdzenia ID i rozstrzygnięcie wyścigu anulowanie/zatwierdzenie.
- Autofarm: START/STOP/PAUZA/WZNÓW/reset, sześć rzeczywistych przerw, ograniczone ponowienia i zmierzone potwierdzone cykle. Zestaw Studio ma dziesięć demonstracyjnych checkpointów bez nagród BABFT.
- PRO: własny ruch w uprawnionym środowisku, lokalne konfetti, tęczowy ślad i mini/duża kopia własnego awatara. Kod społeczności **6969** odblokowuje ślad. [Discord użytkownika](https://discord.gg/qmWGb4Q9p). Kod klienta nie sprawdza członkostwa i nie autoryzuje serwera.
- Settings: profile JSON z walidacją i kopią, wygląd, statystyki, raport błędów, profile wydajności podglądu oraz wyłączenie huba.

## Własny test w Studio

1. Otwórz własną pustą mapę i wstaw `studio/KubiHubTestKit.rbxmx` do Workspace przez **Insert from File**.
2. Naciśnij **Play**. Zestaw tworzy własną działkę, jawny testowy budżet materiałów i klienta.
3. Wybierz WORM MK2 → Builder → BUILD. Po potwierdzeniu usiądź w fotelu; WASD steruje, E otwiera paszczę. Sprawdź [checklistę](docs/TESTING.md).

Serwer domyślnie działa wyłącznie w Studio. Użycie we własnej opublikowanej grze wymaga świadomego wpisania użytkowników w serwerowym `ALLOWED_USER_IDS`, odbudowania pakietu i własnego wdrożenia. Publiczny klucz PRO nie daje tych uprawnień. Zestaw nie instaluje się w cudzych grach.

## Testy

Wykonano kompilację oficjalnym Luau 0.744, **74 testy logiki i 58 sprawdzeń kontraktu klienta w mocku** oraz oba importy modeli. Mock nie renderuje Roblox i nie symuluje fizyki ani prawdziwego serwera BABFT. **Nowego trybu narzędzi nie testowano w grze.**

```text
node tools/build.cjs
LUAU_BIN=/path/to/luau LUAU_COMPILE=/path/to/luau-compile node tools/test.cjs
```

[Raport trybu BABFT](docs/V5.2-REPORT.md) · [Raport poprawki GUI](docs/V5.1.1-REPORT.md) · [Testy i oczekiwane wyniki](docs/TESTING.md) · [Historia zmian](CHANGELOG.md) · [Układ funkcji](FEATURES.md).

## Modele społeczności

Zachowano `Red_Worm.Build`, `worm-red.json`, `Working_Shredder.Build` i `shredder.json`; Shapes może odczytać ich JSON do podglądu. Nie są potwierdzonymi oryginałami WORM 9 / SHREDDER 5.0 z miniaturek. Autorstwo pozostaje przy niezweryfikowanych twórcach modeli. Źródła: [czerwony robak](https://luau.pro/catalog/build/70329a6b-4b82-4fd4-b0dd-aa89fcb5a44a), [Working Shredder](https://luau.pro/catalog/build/8e8ea8d2-08d3-487e-8a31-298b2361bb3d).

Rekonstrukcja dawnych BindTable i tłoków nie została zaimplementowana. Niszczenie cudzych łodzi, ataki, obchodzenie zabezpieczeń i przeciążanie publicznych serwerów nie należą do V5, zgodnie z zakresem przebudowy. Wydanie nie reklamuje „100 nowych funkcji” przez liczenie wariantów jednego przycisku.
