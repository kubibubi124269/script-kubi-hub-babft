# Testy V6.1.0

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
