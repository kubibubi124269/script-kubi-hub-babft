# Testy i oczekiwane wyniki

## V6.0.0 — 2026-11-03

Offline: 85 testów logiki, 110 sprawdzeń klienta i cztery importy — bez błędów. Sprawdzono również dopasowanie obu nowych modeli do obszaru 120 × 200 × 120, nie tylko liczbę elementów. Rzeczywiste działanie gry nadal nie zostało potwierdzone.

W grze — DO WYKONANIA:

1. Ten sam loader ma otworzyć wybór V6.0.0. Wybranie niewłaściwej gry ma zostawić czytelny powód i nie uruchamiać jej modułów.
2. BABFT: wybierz drużynę, Autofarm, NORMAL, limit 1, START. Oczekuj dziesięciu etapów, skrzyni i jednego powrotu postaci. Sprawdź PAUZA / WZNÓW i STOP w środku trasy; STOP ma usunąć podparcie oraz wrócić żywą postacią na start. Sprawdź też STOP przy skrzyni. Nie używaj samego licznika jako dowodu otrzymania nagród.
3. BABFT: pięć zakładek, brak Shapes. W Builderze wyszukaj dom i zamek, wczytaj podgląd, sprawdź materiały i dopasowanie. TEST 1 BLOKU i mały plan z dwóch części powinny poprzedzać kosztowny model. Skalowanie, malowanie i widoczność z drugiego klienta pozostają do osobnego potwierdzenia.
4. MM2: START zbierania w aktywnej rundzie; zacznij od NORMAL, następnie FAST / TURBO. Sprawdź przejście do rzeczywistego przedmiotu, zmianę stanu torby i faktyczny przyrost waluty w grze. Porównaj monety i przedmioty sezonowe oraz PAUZA / STOP. Przedmiot bez typu może pasować do obu filtrów.
5. MM2: Aimbot i Auto Shot sprawdź z własnym pistoletem i widocznym celem. Sprawdź kontrolę ścian i zwykłe odnowienie broni. Aktywacje w raporcie nie są dowodem trafienia.
6. Kill all / Knife Aura sprawdzaj wyłącznie z nożem dostarczonym graczowi w rundzie. Fling jest eksperymentalny; sprawdź przede wszystkim STOP, ograniczenie 1,5 s i przywrócenie własnej postaci. Nie deklaruj skutku na podstawie samego ruchu kamery lub licznika prób.
7. ESP, GunDrop i Auto Gun: sprawdź oznaczenia widocznego wyposażenia i odbiór upuszczonego pistoletu w grze. Następnie STOP WSZYSTKO, powrót do wyboru, ponowny loader i wyłączenie. Mają zniknąć stare GUI, ESP, wsparcie farmy i dodatkowe sterowanie kamerą.

W razie problemu kliknij powiadomienie i skopiuj pełny raport z Settings. Zanotuj grę, wersję, funkcję i stan modułu.

## Czytelność błędów V5.2.2 — 2026-11-03

Regresja powiadomienia odtwarza problem w opublikowanym V5.2.1: test wymaga przyczyny w dolnym pasku i okienku, lecz stary klient pokazuje tylko ogólne ogłoszenie. Po poprawce 79 testów logiki, 69 sprawdzeń klienta i dwa importy przechodzą. Sprawdzono pełne błędy przycisków i zdarzeń, Unicode, kliknięcie okienka przy ukrytym hubie, brak kamery oraz odłączanie zastąpionych i wygasłych okienek.

W grze — NIE WYKONANO: uruchom ten sam loader, potwierdź V5.2.2, otwórz Autofarm i odczytaj dostępność przed START. Gdy START jest niedostępny, okienko ma pokazać konkretną przyczynę. Kliknięcie go powinno otworzyć Settings / Ostatni komunikat z pełną treścią; ostatni błąd farmy powinien zawierać tę samą przyczynę. To nie jest test ukończenia cyklu BABFT; publiczna autofarma pozostaje wyłączona.

## Awaria startu V5.2.1 — 2026-10-30

Przed naprawą zaostrzony mock FindFirstChild(name, recursive) kończył pełny start V5.2.0 komunikatem „FindFirstChild recursive must be a boolean”; stos prowadził przez Inventory.readPlayer i observePlayer do Application.new, przed tworzeniem GUI. Poprzedni mock ignorował dodatkowy argument i nie odtwarzał tej awarii. [Kontrakt API Roblox](https://create.roblox.com/docs/reference/engine/classes/Instance#FindFirstChild) wymaga boolean jako opcjonalnego drugiego argumentu. gsub zwraca także liczbę zamian, dlatego zapisano sam alias w zmiennej przed wywołaniem.

Po naprawie: 77 testów logiki, 58 sprawdzeń pełnego klienta w mocku oraz oba importy przechodzą. Trzy nowe regresje używają sprawdzającego argumenty obiektu: brak innych materiałów nie przerywa odczytu, aliasy Wood/Metal/Titanium pozostają osobne, a dokładny WoodBlock ma pierwszeństwo nad Wood. Start klienta sprawdzono w trybie asystenta i w fixture BABFT. Nie jest to natywny test Roblox; użytkownik powinien uruchomić ten sam loader i potwierdzić nagłówek V5.2.1.

## Tryb narzędzi BABFT V5.2 — 2026-10-30

Offline: 74 testy logiki, 58 sprawdzeń kontraktu klienta w mocku, dwa importy i kompilacja 25 modułów. Nowe przypadki sprawdzają wybór trybu po PlaceId, brak samoczynnego budowania, blokadę przed testem, jeden jawny test drewna, odrzucenie niepotwierdzonego wyniku, limity wywołań, kolejność części, anulowanie w trakcie odpowiedzi, dokładną liczbę części i odmowę udawania mechanicznego WORM-a. Fixture narzędzia tworzy obiekty testowe; nie jest serwerem Roblox. Sprawdzono również jedno siedzenie o natywnym rozmiarze, podfoldery materiałów, alias drewna, zmiany liczb, brak mieszania metalu z tytanem, unieważnienie próby po respawnie i sprzątanie po wyłączeniu.

W BABFT — NIE WYKONANO: ten sam loader → V5.2.0 → dołącz do drużyny → Builder → TEST 1 BLOKU. Oczekuj jednego rzeczywistego drewna na własnej działce i dopiero wtedy aktywnego BUILD. W razie błędu kliknij dolny pasek i skopiuj pełny komunikat oraz Settings / Raport błędów. Przetestuj mały plan z dwóch zwykłych bloków, jedno siedzenie, dopiero potem skalowanie/malowanie, STOP w trakcie żądania i respawn. STOP nie usuwa już utworzonych bloków. Potwierdź widoczność z drugiego klienta, zanim nazwiesz replikację sprawdzoną. Nie potwierdzono obecnego protokołu BABFT ani cennika materiałów.

## Poprawka GUI V5.1.1 — 2026-10-29

63 testy logiki, 45 sprawdzeń kontraktu GUI, oba importy modeli oraz kompilacja klienta i serwera przeszły offline. Regresje sprawdzają pomieszczenie sześciu zakładek przy szerokościach 300–699 px, położenie treści poniżej nawigacji, pełny długi komunikat, kierowanie do właściwej sekcji Settings, odświeżanie raportu i przejście do instrukcji ręcznej bez rozpoczynania budowy. Mock kontroluje właściwości AutomaticSize i wyrównanie tekstu; nie dowodzi wyglądu natywnego interfejsu Roblox.

Do sprawdzenia przez użytkownika w BABFT: nagłówek V5.1.1; po zmniejszeniu okna wszystkie sześć zakładek w dwóch/trzech rzędach; brak dużych pustych przestrzeni między opisami; pełny komunikat po kliknięciu dolnego paska; przycisk ASYSTENT rozwija instrukcję ręczną. Automatyczna budowa w publicznym BABFT nadal nie jest dostępna.

## Aktualizacja V5.1 — 2026-10-29

61 testów logiki, 30 sprawdzeń kontraktu GUI oraz oba importy modeli. Nowe regresje odtwarzają błędy: numer pierwszej warstwy, błędne BindTable, eksport i ponowny import obróconego projektu, nieznane materiały, niedostępny główny profil, fałszywe anulowanie, mały projekt poza działką, wzrost tekstu wyszukiwarki i nadpisanie szybkiego importu. Dodatkowe testy sprawdzają wyśrodkowanie z UNDO, przesunięcie pivotów wraz z częściami, dopasowanie obróconego dużego planu, zachowanie źródła oraz odmowę skalowania mechaniki.

W grze należy osobno sprawdzić: V5.1.0 w nagłówku, warstwę 1 podłogi, eksport/import po obrocie 90°, utworzenie drewnianego koła po wybraniu tytanu w poprzednim planie, wyśrodkowanie mostu, dopasowanie zwykłego projektu i UNDO. Ręczne wymiary są pomocą w planowaniu, nie potwierdzeniem wymiarów publicznego BABFT. Ograniczenia API i brak testu natywnej fizyki pozostają aktualne.

## Wykonane offline

Oficjalny Luau 0.744 i Node z bibliotekami wbudowanymi. SHA256 Windows ZIP: fde3e22c557aac6afe20a34e8050b7d8c290fa42638c04274a307ed5d0ef0db8. CI przypina Linux ZIP i sprawdza SHA256. Wynik tools/test.cjs: 40 testów logiki i 18 sprawdzeń kontraktu GUI, bez niepowodzeń. Log trafia do .test-output/results.txt.

tests/core.luau podaje nazwy, wejścia i asercje. Przykłady: 3000 metalu + 20 tytanu, wymagane 40 tytanu → brak 20; Seat=29 → wymagane 1; brak odczytu → nieznany; STOP przed odpowiedzią → zero nowych cykli; anulowanie po commit → COMPLETED; zły ID → ERROR bez postępu. Sprawdzane są również graf WORM-a, geometria, profile, cofanie, przerwy, limit ponowień, nieznane API i timeout.

tests/RobloxMock.lua i uiSmoke.lua uruchamiają pełny klient, sześć zakładek, wyszukiwarkę, otwarcie sekcji, limit części podglądu, ponowne uruchomienie i sprzątanie. Sprawdzono układ przy szerokości 320/760/1280. Mock nie odwzorowuje natywnego renderowania, CFrame ani fizyki. Podczas implementacji usunięto kolizję konstruktora GUI z metodą tworzenia kontrolek, nazwaną teraz create. Kompilowane są wszystkie moduły, main.lua i serwer.

## Do wykonania w BABFT — NIE WYKONANO

1. Ten sam loader: oczekiwane V5.1.1 i sześć zakładek.
2. Wpisz „promień” u góry; wynik Circle Maker otwiera właściwą sekcję.
3. Wygeneruj WoodBlock, promień 4, 8 segmentów, jedna warstwa: osiem części podglądu i jawny stan materiałów.
4. Bez mostu ASYSTENT otwiera instrukcję ręczną i nie liczy podglądu jako postawionych części.
5. Plan stosu wymaga 1 Seat, 1 Dynamite i 3000 WoodBlock. Ponowne uruchomienie zostawia jedno GUI. Raport znajduje się w Settings.

## Do wykonania w Studio — NIE WYKONANO

Wstaw zestaw według README. Mała budowa: części istnieją na serwerze, a potwierdzony licznik odpowiada ich ID. Anulowanie w połowie usuwa tylko własną otwartą transakcję i oddaje rezerwację raz. Anulowanie po commit zwraca committed i zachowuje budowlę.

Po budowie WORM MK2 uruchom IntegrationChecks.lua w serwerowym command barze. Oczekuj 49 części, 14 HingeConstraint, jednego VehicleSeat, wyrównanych attachmentów i braku zakotwiczonych części mechanizmu. Osobiście sprawdź jazdę do przodu, zakręt, ruch ciała, pięć płatów paszczy po E, STOP, respawn, działkę i brak narastających oscylacji przez 60 s. Drugi gracz powinien widzieć tę samą konstrukcję i ruch oraz nie móc sterować cudzym rig-iem. Może być potrzebne dostrojenie geometrii, kolizji i momentów.

Farm: własne dziesięć checkpointów, wszystkie profile, pauza, STOP podczas żądania, respawn i limit jednego cyklu. Oczekuj rzeczywistych czasów i braku sztucznego złota. Ruch i Fly: tylko dozwolone środowisko; wyłączenie przywraca oryginalne własności. GUI: komputer/telefon, dotyk, przewijanie, resize, kamera i pola po imporcie profilu.
