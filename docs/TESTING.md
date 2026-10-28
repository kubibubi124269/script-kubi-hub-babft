# Testy i oczekiwane wyniki

## Wykonane offline

Oficjalny Luau 0.744 i Node z bibliotekami wbudowanymi. SHA256 Windows ZIP: fde3e22c557aac6afe20a34e8050b7d8c290fa42638c04274a307ed5d0ef0db8. CI przypina Linux ZIP i sprawdza SHA256. Wynik tools/test.cjs: 40 testów logiki i 18 sprawdzeń kontraktu GUI, bez niepowodzeń. Log trafia do .test-output/results.txt.

tests/core.luau podaje nazwy, wejścia i asercje. Przykłady: 3000 metalu + 20 tytanu, wymagane 40 tytanu → brak 20; Seat=29 → wymagane 1; brak odczytu → nieznany; STOP przed odpowiedzią → zero nowych cykli; anulowanie po commit → COMPLETED; zły ID → ERROR bez postępu. Sprawdzane są również graf WORM-a, geometria, profile, cofanie, przerwy, limit ponowień, nieznane API i timeout.

tests/RobloxMock.lua i uiSmoke.lua uruchamiają pełny klient, sześć zakładek, wyszukiwarkę, otwarcie sekcji, limit części podglądu, ponowne uruchomienie i sprzątanie. Sprawdzono układ przy szerokości 320/760/1280. Mock nie odwzorowuje natywnego renderowania, CFrame ani fizyki. Podczas implementacji usunięto kolizję konstruktora GUI z metodą tworzenia kontrolek, nazwaną teraz create. Kompilowane są wszystkie moduły, main.lua i serwer.

## Do wykonania w BABFT — NIE WYKONANO

1. Ten sam loader: oczekiwane V5.0 i sześć zakładek.
2. Wpisz „promień” u góry; wynik Circle Maker otwiera właściwą sekcję.
3. Wygeneruj WoodBlock, promień 4, 8 segmentów, jedna warstwa: osiem części podglądu i jawny stan materiałów.
4. Bez mostu BUILD wyjaśnia brak uprawnionego API i nie liczy podglądu jako postawionych części.
5. Plan stosu wymaga 1 Seat, 1 Dynamite i 3000 WoodBlock. Ponowne uruchomienie zostawia jedno GUI. Raport znajduje się w Settings.

## Do wykonania w Studio — NIE WYKONANO

Wstaw zestaw według README. Mała budowa: części istnieją na serwerze, a potwierdzony licznik odpowiada ich ID. Anulowanie w połowie usuwa tylko własną otwartą transakcję i oddaje rezerwację raz. Anulowanie po commit zwraca committed i zachowuje budowlę.

Po budowie WORM MK2 uruchom IntegrationChecks.lua w serwerowym command barze. Oczekuj 49 części, 14 HingeConstraint, jednego VehicleSeat, wyrównanych attachmentów i braku zakotwiczonych części mechanizmu. Osobiście sprawdź jazdę do przodu, zakręt, ruch ciała, pięć płatów paszczy po E, STOP, respawn, działkę i brak narastających oscylacji przez 60 s. Drugi gracz powinien widzieć tę samą konstrukcję i ruch oraz nie móc sterować cudzym rig-iem. Może być potrzebne dostrojenie geometrii, kolizji i momentów.

Farm: własne dziesięć checkpointów, wszystkie profile, pauza, STOP podczas żądania, respawn i limit jednego cyklu. Oczekuj rzeczywistych czasów i braku sztucznego złota. Ruch i Fly: tylko dozwolone środowisko; wyłączenie przywraca oryginalne własności. GUI: komputer/telefon, dotyk, przewijanie, resize, kamera i pola po imporcie profilu.
