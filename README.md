# KUBI HUB V6.0.0 — BABFT + MM2

Ten sam loader otwiera teraz wybór **BABFT / MM2**. Wybór sprawdza grę; oba huby mają osobne moduły, a funkcje zaczynają wyłączone. Przycisk powrotu zatrzymuje aktywne zadania i otwiera wybór ponownie.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/kubibubi124269/script-kubi-hub-babft/main/main.lua"))()
```

## BABFT

- Przywrócona autofarma: dziesięć CaveStage, skrzynia i oczekiwanie na powrót postaci. START / STOP / PAUZA / WZNÓW, sześć przerw 2–0,3 s, limit cykli, ograniczone ponowienia. Pauza nie zużywa limitu oczekiwania przy skrzyni. Nieoczekiwany respawn zatrzymuje zadanie.
- Licznik mierzy zaobserwowany powrót po trasie. Nie jest potwierdzeniem przyznania złota ani bloków.
- Pięć zakładek: **PRO, Builder, Autofarm, Circle Maker, Settings**. Zawartość Shapes — biblioteka, modele i generatory brył — jest teraz w Builderze. Dawne skróty nadal tam prowadzą.
- Builder: podgląd, warstwy, materiał, pozycja, obrót, skala, dopasowanie do działki, UNDO / REDO, import / eksport. Limit planu wzrósł do **10 000 elementów**; podgląd nadal ma ograniczenie zależne od profilu wydajności.
- Nowe modele z katalogu: **Classic House — 568 części** i **architektura zamku — 8149 bloków**. Są w Builder / Modele z internetu. Ładowane są pozycje, obroty, rozmiary i kolory. Mechanizmy i wyposażenie oryginału są pominięte. Oryginały, źródła i opis konwersji są w [katalogu plików](assets/community/index.json).
- Statyczne BUILD nadal wymaga jawnego **TEST 1 BLOKU**, odpowiednich materiałów oraz narzędzi skalowania / malowania. Wykrycie narzędzi samo nie odblokowuje budowania. STOP pozostawia już utworzone części.
- Zachowano WORM MK2, SHREDDER i plan dynamitu. Ich podgląd nie oznacza działającej mechaniki w BABFT. Połączenia WORM-a nie zostały dodane do publicznej gry.

## MM2

Pięć zakładek: **MM2, Autofarm, Combat, Player, Settings**.

- Monety / cukierki: najbliższy przedmiot, filtry BOTH / COIN / CANDY, NORMAL / FAST / TURBO. TURBO podejmuje kolejną próbę od 0,12 s, gdy poprzedni przedmiot zniknie. Widoczna pełna torba wstrzymuje kolejkę; brak postaci lub przedmiotów powoduje oczekiwanie. Przedmiot bez oznaczenia waluty może pasować do obu filtrów.
- Statystyki zbierania pokazują próby i zniknięcia obiektów po próbie, a nie saldo przyznanych monet / cukierków. Zniknięcie może mieć inną przyczynę niż odebranie nagrody przez użytkownika.
- Aimbot: obrót kamery po aktualizacji kamery gry, wybór wykrytego Murderera / najbliższego / nicku, zasięg ekranowy, płynność, przewidywanie i kontrola ścian.
- Auto Shot: zwykła aktywacja własnego pistoletu, tylko przy wybranym widocznym celu i z przerwą. Nie nadaje broni ani nie potwierdza trafienia.
- Kill all: ograniczony obieg widocznych żywych postaci z aktywacją własnego noża Murderera. Liczone są próby ciosu, nie zabójstwa.
- Murder Fling: eksperymentalna próba fizyki własnej postaci, do 1,5 s, z przywróceniem pozycji i prędkości. Skutek zależy od kolizji i serwera.
- Knife Aura: własny nóż i cel do 6 studów. ESP: kolor na podstawie widocznego wyposażenia; brak broni oznacza rolę nieznaną.
- Podnoszenie pistoletu ręcznie lub Auto Gun, własny WalkSpeed / skok / Fly, lokalne konfetti, wspólny STOP i raport błędów.
- Zbieranie, Fly i akcje przemieszczające postać wykluczają się. STOP i wyłączenie usuwają zdarzenia, wiązanie kamery, lokalne efekty oraz ESP.

Broń, obrażenia, odbiór przedmiotów i fizykę nadal rozstrzyga serwer. **Nowych modułów nie przetestowano w rzeczywistym MM2 / BABFT.** W szczególności nie gwarantujemy skutku Fling ani zabójstw z Kill all.

## Weryfikacja

Oficjalny Luau 0.744: **85 testów logiki, 110 sprawdzeń klienta w mocku, 4 importy modeli**, kompilacja 33 modułów i wygenerowanych pakietów. Sprawdzono m.in. STOP, długą pauzę przy skrzyni, oczekiwany i nieoczekiwany respawn, wykluczanie ruchu, pełną torbę, błąd aktywacji broni, przywracanie Fling, usuwanie ESP, sprzątanie nieudanego startu i dopasowanie obu nowych modeli do działki.

Mock nie renderuje Roblox i nie symuluje rzeczywistego serwera ani replikowanej fizyki. [Testy w grze i oczekiwane wyniki](docs/TESTING.md) · [Raport V6](docs/V6-REPORT.md) · [Źródła modeli](docs/COMMUNITY-MODELS.md) · [Historia zmian](CHANGELOG.md).

```text
node tools/build.cjs
LUAU_BIN=/path/to/luau LUAU_COMPILE=/path/to/luau-compile node tools/test.cjs
```

`main.lua` zawiera cały kod klienta. Nie pobiera zewnętrznych bibliotek Lua. Modele to JSON z tego repozytorium. Konwerter czyta wyłącznie dane LP_BUILD; metadane i pliki modeli nie są wykonywane jako kod.

Własny zestaw Studio nadal jest w `studio/KubiHubTestKit.rbxmx`; po Play wybierz BABFT. Odtwarza własny warsztat i demonstracyjne checkpointy, bez nagród BABFT. Klucz społeczności PRO pozostaje **6969**, [Discord](https://discord.gg/qmWGb4Q9p); kod lokalny nie weryfikuje członkostwa ani uprawnień serwera.
