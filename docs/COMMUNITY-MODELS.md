# Modele społeczności V6

Pobrano dane przez przyciski Download publicznego katalogu luau.pro. Nie pobierano ani nie uruchamiano skryptu tej strony. Katalog podpisuje pliki jako udostępnione przez luau.pro; autor pierwotnej konstrukcji nie został niezależnie potwierdzony.

- [Classic House](https://luau.pro/catalog/build/7ee4963f-44cd-43a7-b5f5-d0febfc0acb8): zachowany `assets/community/ClassicHouse.Build`; 568 elementów PlasticBlock. Wariant statyczny zachowuje wszystkie bloki geometrii, pozycje, obroty, rozmiary i kolory.
- [A_castle_i_made_Modified](https://luau.pro/catalog/build/a88a7dd1-c2cc-4a64-b6aa-3abe45ded27d): zachowany `assets/community/Castle.Build`; oryginał ma 8197 elementów. Wariant architektoniczny ma 8149 bloków: kamień, drewno, złoto, trawę i tkaninę. Pominięto 48 elementów wyposażenia / mechanizmów. Dokładny wykaz jest w `assets/community/index.json`.

Konwerter `tools/import-community.cjs` zachowuje tylko geometrię i kolor bloków z jawnej listy materiałów. Pomija połączenia, elektronikę, wyposażenie, przezroczystość, flagi fizyki oraz wartości stanu z zapisu. Plik wynikowy jest opisany jako model statyczny, a nie rekonstrukcja logiki oryginału. Oryginały pozostają w repozytorium do porównania.

Konwersja jest deterministyczna i uruchamiana podczas budowania klienta. Indeks zapisuje SHA-256 źródła po normalizacji końców linii do LF. Testy importują oba JSON-y, sprawdzają liczby elementów i dopasowanie do działki 120 × 200 × 120. Rzeczywiste stawianie, skalowanie i malowanie wymagają testu w BABFT oraz posiadanych materiałów i narzędzi.

Zbadano również pliki UFO, Dough_fruit, chess_board, GrowAgarden i wieżę Eiffla. Nie dodano ich jako gotowych działających projektów: zawierały nieobsługiwane mechanizmy / wyposażenie lub przekraczały przyjęty limit. Nie podmieniano ich na proste bryły pod oryginalnymi nazwami.
