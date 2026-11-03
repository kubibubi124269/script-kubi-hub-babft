# V6.0.0 — dwa huby i przywrócona trasa BABFT

## Zakres

Główny plik nadal jest pod dotychczasowym adresem. Wybór BABFT / MM2 powstaje przed uruchomieniem modułów. Rozpoznanie miejsca / uniwersum blokuje uruchomienie niewłaściwego huba. Zmiana huba zatrzymuje moduły, usuwa GUI i zdarzenia, a nieudana inicjalizacja sprząta częściowo utworzone zasoby. Własne Studio może otworzyć wybór do testowania klienta.

BABFT ma pięć zakładek. SCHEMATICS i SHAPES prowadzą do sekcji biblioteki w Builderze. Zachowano generatory, import / eksport i istniejące plany. Limit schematu wynosi 10000 części; podgląd nadal próbkuje geometrię zgodnie z profilem wydajności. Dodano dwa pliki społeczności: 568 elementów domu i 8149 bloków statycznej architektury zamku. Oryginalne dane, źródła i jawna lista pominiętego wyposażenia są w [opisie modeli](COMMUNITY-MODELS.md). Konwerter nie uruchamia zawartości pliku.

## Autofarma BABFT

Przywrócono wcześniej używaną metodę przenoszenia własnej postaci po dziesięciu etapach CaveStage i końcowej skrzyni, po jednoznacznym wyborze użytkownika. Nie jest zależna od mostu Studio. Dostępność wymaga odczytania wszystkich punktów trasy; START odświeża stan. Zwykłe wczytanie huba niczego nie uruchamia.

Jeden kontroler obsługuje przerwy, pauzę, limit cykli, ponowienia i STOP. Lokalne podparcie jest usuwane na końcu / po anulowaniu. STOP lub błąd wraca tą samą żywą postacią do punktu startu; nie przenosi nowej postaci po respawnie. Końcowy etap do 35 sekund aktywnego oczekiwania wypatruje nowej żywej postaci. Pauza nie zużywa tego czasu. Oczekiwany respawn po skrzyni pozwala zakończyć cykl; inny respawn zatrzymuje trasę.

Pozycja etapu jest wynikiem działania klienta, a zakończenie jest obserwacją respawnu po trasie. Żaden z tych sygnałów nie potwierdza przyznania złota. Nie wysyła się żądań dodających nagrody ani nie wyświetla wymyślonego salda.

## MM2

Osobny klient ma pięć zakładek i własny kontroler. Monety / cukierki są znajdowane w CoinContainer. Wyszukiwanie jest ograniczone i odświeżane; filtr odczytuje dostępny typ waluty. Brak typu oznacza kategorię nieznaną, pasującą do obu filtrów. TURBO dopuszcza kolejną próbę od 0,12 s po zniknięciu poprzedniego przedmiotu. Brak mapy / postaci oraz pełna widoczna torba powodują oczekiwanie. Przedmiot bez potwierdzonego zniknięcia ma czas oczekiwania i przerwę przed ponowieniem. Statystyki rozróżniają próby i zniknięcia obiektów od salda waluty.

Aimbot ustawia kamerę po standardowej aktualizacji kamery gry. Wybór celu uwzględnia ekran, widoczne wyposażenie, nick i opcjonalną przeszkodę z Raycast. Auto Shot oraz akcje noża używają posiadanych Tool i zwykłej aktywacji. Nie przechwytują metod ani nie nadają broni. Odnowienie, obrażenia i wynik rozstrzyga gra. Próba aktywacji nie jest raportowana jako trafienie lub zabójstwo.

Kill all jest ograniczonym obiegiem celów z własnym nożem. Fling to eksperyment własnej fizyki do 1,5 s z przywróceniem stanu. Nie gwarantuje przemieszczenia przeciwnika. Dodano Knife Aura, ESP kolorowane po widocznym nożu / pistolecie, ręczne i automatyczne podnoszenie GunDrop, własny ruch, Fly, efekty lokalne i STOP. Zbieranie, Fly i akcje przemieszczające postać używają wspólnej blokady. Błąd ruchu zatrzymuje zadanie i pokazuje powód bez wyłączania harmonogramu całego GUI.

## Walidacja i granice

Oficjalny Luau 0.744: 33 moduły; 85 testów logiki, 110 sprawdzeń klienta w mocku i cztery importy plików. Sprawdzono wybór gry, brak samoczynnego startu, trasy i respawn, pauzę dłuższą niż limit końcowego oczekiwania, STOP, pełną torbę i ukryte elementy GUI, ograniczenie Auto Shot, błędy broni, blokady ruchu, powrót Fling, usunięcie ESP, wiązania kamery i częściowego GUI. Oba nowe modele poprawnie importują się i dopasowują do działki 120 × 200 × 120 w testach geometrii.

Nie wykonano testów w natywnym Roblox / MM2 / BABFT. Mock nie renderuje, nie symuluje serwera ani replikowanej fizyki. Protokół budowania, faktyczne odbieranie przedmiotów, aktywacja obecnego modelu broni, nagrody i skutek Fling nadal wymagają próby w grze. WORM z połączeniami nie został zaimplementowany w publicznym BABFT.

Sprawdzono publiczny kod [RabbitCoreHub/MM2](https://github.com/RabbitCoreHub/MM2/blob/main/MM2_Main.lua) i [MM2-Candy-Farm](https://github.com/vexroxd/My-Script-/blob/main/MM2-Candy-Farm) jako wskazówki organizacji widocznych obiektów. Nie są dokumentacją obecnego serwera. Korzystano z kontraktów [Tool:Activate](https://create.roblox.com/docs/reference/engine/classes/Tool#Activate) i [RunService:BindToRenderStep](https://create.roblox.com/docs/reference/engine/classes/RunService#BindToRenderStep). Kod tych hubów nie jest pobierany ani wykonywany przez KUBI HUB.
