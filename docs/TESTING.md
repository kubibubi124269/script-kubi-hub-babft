# Testy V6.5.0

## MM2 i Narzędzia

1. W MM2 włącz **Autofarm → Monety / cukierki**. Wybierz typ pod PPM. Przy **Ruch: Lot** postać powinna przemieścić się płynnie i opadać przy pobliskim przedmiocie. Przełącz na **Chód**, żeby sprawdzić zwykłe podejście. Przy pełnej torbie zbieranie czeka, a STOP i odrodzenie je wyłączają. Sprawdź, czy klawisze ruchu przejmują sterowanie.
2. W każdym trybie otwórz **Narzędzia**. Włącz dwie linie HUD-u, zamień sepię na inny filtr, użyj stopera i minutnika oraz zapisz znacznik miejsca. Globalny STOP usuwa efekty, HUD i znacznik.

Testy offline sprawdzają ograniczoną prędkość lotu, usuwanie siły po przełączeniu trybu i zwalnianie sterowania. Zachowanie publicznego serwera MM2, fizyka lotu i odbiór przedmiotów wymagają sprawdzenia w grze. [Dokumentacja ruchu Roblox](https://create.roblox.com/docs/reference/engine/classes/Humanoid#Move).

## Steal a Brainrot

1. Uruchom dotychczasowy loader w oryginalnym Steal a Brainrot. Sprawdź wersję V6.4.0 i wybierz nowy tryb. AutoSteal powinien być wyłączony.
2. Włącz AutoSteal i podejdź do celu. Jeśli „Steal” było widoczne przed otwarciem huba, odejdź i podejdź jeszcze raz. Gdy gra pokaże „Steal”, sprawdź, czy rozpoczyna się przytrzymanie. Potem samodzielnie wróć do bazy. Sygnał interakcji nie potwierdza, że serwer przekazał Brainrota.
3. Podczas przytrzymania użyj STOP lub odejdź poza zasięg. Przytrzymanie powinno się zakończyć. Funkcja nie powinna nacisnąć „Buy”. Odrodzenie ma wyłączyć AutoSteal.

Testy offline sprawdzają wybór gry, obsługę widocznych akcji Roblox, zasięg, czas, przerwę między próbami i sprzątanie. Nie uruchamiają publicznego serwera Steal a Brainrot. [Dokumentacja akcji Roblox](https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt).

## V6.3.0

Offline: 86 testów logiki, 210 sprawdzeń klienta, 4 importy i 38 modułów — bez błędów. Natywnego wyglądu nadal nie potwierdzono.

1. Uruchom ten sam loader; nagłówek V6.3.0. W MM2 / Trolling włącz Fake Headless. W trzeciej osobie głowa powinna zniknąć. Przełącz kamerę blisko / daleko i sprawdź, czy nie wraca. Wyłącz: ma wrócić zwykła głowa i twarz. Potwierdzenie użytkownika jest wymagane do uznania poprawki wizualnej za sprawdzoną w grze.
2. Sprawdź, że dotychczas działający Korblox zachował kształt i sposób włączania.
3. Misc MM2: włącz osobno oznaczanie monet i GunDrop. Sprawdź rzeczywisty przedmiot, zasięg i wyłączenie. Włączenie nie powinno ruszyć postaci ani farmy.
4. Podgląd Murderera / Sheriffa działa tylko przy rozpoznanej broni. Ponowne kliknięcie ma oddać kamerę. Teleport do tych ról ma zgłosić konflikt, gdy aktywna jest farma albo Fly.
5. Efekty bez akcesoriów, bez twarzy i Duch są lokalne. Wyłącz i sprawdź wcześniejszą widoczność. Latarka ma zniknąć po STOP i respawnie.
6. Universal / Widok: daleki zoom i pierwsza osoba. Kliknięcie aktywnej funkcji ma ją wyłączyć i przywrócić oryginalny tryb. STOP również przywraca zoom.

Wcześniejsze scenariusze:


Offline: 86 testów logiki, 181 sprawdzeń klienta, 4 importy modeli, 38 modułów — bez błędów. To nie jest potwierdzenie natywnej fizyki ani renderowania.

1. Ten sam loader: nagłówek V6.2.0, trzy przyciski BABFT / MM2 / Universal. Universal powinien otwierać się także w innej grze.
2. MM2 / Trolling / Fling: PPM wybiera NEAREST, MURDERER albo SELECTED + nick, czas 0,5–3 s. Zatrzymanie, zniknięcie celu i limit czasu powinny zakończyć próbę i oddać sterowanie. Skutek odrzutu zależy od gry.
3. Fake Headless i noga: sprawdź wygląd w trzeciej osobie. R6 i R15 wymagają osobnego testu. Wyłącz i sprawdź przywrócenie twarzy, głowy, dodatków oraz nogi. To lokalne efekty, bez własności przedmiotów.
4. Mały skin: zacznij od 0,6. Wyłączenie ma przywrócić rozmiar i wysokość postaci. Sprawdź chodzenie i animacje. Serwer może cofnąć skalę.
5. Mniejszy hitbox: to wyłącznie lokalny rozmiar HumanoidRootPart. Nie traktuj go jako ochrony przed obrażeniami. Wyłączenie ma przywrócić korzeń także przy aktywnym małym skinie.
6. Universal / Widok: włącz FOV, celownik i jasny dzień. Wyłącz albo użyj STOP; poprzedni FOV i oświetlenie mają wrócić, a celownik zniknąć.
7. Universal / Postać i Teleport: sprawdź własny ruch, Fly oraz zapis i powrót do punktu. Niektóre gry korygują pozycję i ruch. Nie uruchamiaj dwóch modułów ruchu jednocześnie.
8. Respawn i ponowne uruchomienie: wygląd ma zacząć wyłączony; stare nogi, GUI, celownik i zdarzenia mają zniknąć.

Poprzedni plan sprawdzenia autofarm i Buildera:


Offline: 86 testów logiki, 139 sprawdzeń klienta, 4 importy modeli, 35 modułów — bez błędów. Mock nie potwierdza renderowania ani serwerowych efektów.

1. Uruchom ten sam loader. Wybierz właściwą grę. Nagłówek ma pokazać V6.1.0 i sześć kategorii w pionie.
2. PPM na autofarmie ma otworzyć jej opcje bez uruchamiania. ⋯ ma działać tak samo. Wróć / Escape / inna kategoria zamyka panel. Zmień opcję, wróć i sprawdź zachowanie.
3. MM2: w aktywnej rundzie uruchom zbieranie. Sprawdź ruch do przedmiotu i rzeczywisty licznik waluty w grze. Torba pełna, oczekiwanie na rundę i brak postaci mają osobne stany. Zmień filtr na COIN / CANDY zgodnie z wydarzeniem. Jeśli utknie, zapisz stan, znalezioną liczbę i pełny raport.
4. BABFT: uruchom profil NORMAL. Sprawdź kolejne etapy, skrzynię i powrót postaci. Przy problemie zwiększ Czas przejścia do 1,5–2 s. STOP ma usunąć podparcie i przerwać ruch. Zapisz faktyczną zmianę złota w grze; hub jej nie deklaruje.
5. Builder / Misc: TEST 1 BLOKU ma postawić jeden drewniany blok. Dla mechanicznego WORM-a powinno być oznaczenie MECHANIKA i opcja nieruchomej kopii. Kopia nie może ruszać się ani otwierać paszczy. Budowa rusza dopiero po odrębnym BUILD.
6. Circle Maker / Misc: PPM pozwala ustawić materiał, środek, promień i warstwy. LPM generuje podgląd i listę materiałów. Sprawdź liczbę warstw.
7. Zapisz punkt teleportu, przesuń się, wróć do punktu i użyj powrotu. Włączona farma powinna blokować ręczny teleport.
8. Zamknij hub i uruchom ponownie. Nie powinny zostać stare aktywne zadania, ESP, efekty ani dodatkowe okna.

Niepotwierdzone natywnie: odbiór waluty, obecna fizyka i serwerowe efekty MM2 / BABFT. Raporty historyczne: [V6](V6-REPORT.md), [V6.1](V6.1-REPORT.md).
