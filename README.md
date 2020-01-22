# PWIR
 Concurrent and distributed programming course. AGH, EAIiIB 

# Authors
* Jakub Ficoń 
* Katarzyna Nyznar

# PL
Projekt zaliczeniowy na kurs Programowanie Współbieżne i Rozproszone.

Wykonany w języku Ada.

# Opis programu

## Moduły
### Stock
Pełni rolę “magazynu”. Zawiera pola: NumberOfPickles, NumberOfCleanPickles, NumberOfJars, NumberOfCleanJars, NumberOfReadyJars. Odpowiadają one odpowiednio: liczbie dostępnych ogórków, liczbie ogórków umytych - gotowych do dalszej produkcji, liczbie słoików, liczbie umytych słoików oraz liczbie gotowych słoików po skończonym przetwarzaniu. Dostępne procedury służą do zarządzania wymienionymi zasobami.
### Pickle Handler
Jest to zbiór kilku tasków zajmujących się poszczególnymi etapami produkcji oraz typu Slot. 
Slot zawiera wejścia AddPickle, SetJar, AddVinegar, AddSpices, StoreJar wywoływane z uwzględnieniem odpowiednich warunków w taskach. Jego prywatne zmienne to Vinegar, Jar, Pickle, Spices, InMachine
Jego częścią jest też procedura Check służąca do śledzenia pracy programu poprzez odpowiednie komunikaty. 

Taski działające w PickleHandler są to:
JarSetter - Jest pierwszym w kolejności wywoływanym taskiem z PickleAddera. Wywołuje procedurę SetJar, a następnie task PickleAdder.
PickleAdder - Wywołuje procedurę AddPickle, a następnie task SpiceAdder
SpiceAdder - Wywołuje procedurę AddSpices, a następnie task VinegarAdder
VinegarAdder - Wywołuje procedurę AddVinegar, a następnie task JarStorer
JarStorer - wywołuje procedurę StoreJar

### Pickle Cleaner
Jest taskiem działającym niezależnie od pozostałych. Jego zadaniem jest pobieranie z magazynu ogórków (GetNumberOfPickles) i “mycie ich” - inkrementowanie zmiennej NumberOfCleanPickles.

### Jar Cleaner
Działa w sposób analogiczny do Pickle Cleanera - pobiera z magazynu słoik (GetNumberOfJars) i “myje go” - inkrementuje zmienną NumberOfCleanJars.
Supervising Machine
Maszyna nadzorująca, wyświetlająca komunikaty o pracy systemu na bieżąco. Wywołuje procedurę Check, wyświetlającą stan każdego Slotu.

## Sygnały sterujące.
Komunikacja pomiędzy modułami jest zrealizowana z użyciem sygnałów.
Główna wymiana informacji odbywa się pomiędzy modułem pasywnym jakim jest Stock, a poszczególnymi modułami aktywnymi.

- Pickle Cleaner → Stock
  - GetPickle
  - AddCleanPickle
- Jar Cleaner → Stock
  - GetJar
  - AddCleanJar
- Pickle Handler -> Stock
  - GetCleanJar
  - GetCleanPickle
  - StoreReadyJar

Komunikacja odbywa się również pomiędzy zadaniami wewnątrz modułu Pickle Handler.
Poszczególne moduły informują się nawzajem o gotowości Slotu do dalszego etapu przetwarzania.

* Jar Setter → Pickle Adder
* Pickle Adder →  Spice Adder
* Spice Adder →  Vinegar Adder
* Vinegar Adder →  Jar Storer

## Schemat programu.

https://drive.google.com/file/d/1TpwUHMYQzIT1UTcay50CjZJ5vqG-_s2a/view?usp=sharing
(rys. 1)
