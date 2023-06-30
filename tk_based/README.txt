==============================
       O projekcie
==============================

Przygotowane przezemnie skrypty pozwalają na interaktywną symulację projektów Verilog.

Zamiast standardowej procedury symulacji, uruchamiany jest skrypt (emulator.do).
Interpreter Questy pozwala na tworzenie skryptów w języku "tcl". Można do tego podpiąć bibliotekę graficzną, co też zrobiłem
Co określony odstęp czasu uruchamiana jest symulacja, na zadaną liczbę jednostek czasu, po czym GUI jest aktualizowane.
Domyślnie Questa nie posiada jednak biblioteki graficznej do TCL, dlatego trzeba osobno poprać interpreter tego języka, z biblioteką

Interfejs graficzny można obsługiwać za pomocą myszki, lub klawiatury.
Skruty klawiszowe:
    q,w,e,r,t,y,u,i,o,p - przełączenie przełączników bi-stabilnych
    a,s,d,f             - przyciski mono-stabilne
Można także zmienić konfigurację symulacji, co należy potwierdzić przyciskiem "Update Configuration"

==============================
        Wymagania
==============================

1. Questa Intel FPGA lub QuestaSim
2. Interpreter TCL/TK - na windowsie do poprania np. z "https://www.magicsplat.com/tcl-installer/index.html"

==============================
    Test czy działa
==============================

Można szybko sprawdzić, czy emulator działa poprawnie

Domyślnie skonfigurowany jest pod projekt "example_dut.v"

Możesz uruchomić poprzez wpisanie w cmd komendy:
    "tclsh run_emulator.tcl"
,będąc oczywiśćie w folderze, w którym ten skrypt się znajduje. Nie można go uruchomić, będąc w innym folderze

Powinno na ekranie się pokazać okno GUI, i na nim coś migać.
Można się pobawić, czy wszystko działa.

==============================
      JAK KORZYSTAĆ
(wersja dla prostych projektów, złożonych jedynie z plików verilog w jednym folderze)
==============================

1.  Skopiuj folder "emulator" oraz plik "run_emulator.tcl" do folderu testowanego projektu

2.  W folderze "emulator", W pliku "emulator.v" w sekcji oznaczonej "TU WSTAW TESTOWANY MODUŁ" wstaw instancję modułu, który chcesz testować.

3.  Uruchom skrypt "run_emulator.tcl" poprzez komendę z cmd: "tclsh run_emulator.tcl"

==============================
      JAK KORZYSTAĆ
(wersja dla projektów Quartus, złożonych np. z plików bdf, oprócz samego veriloga)
==============================

    =======
    Najpierw trzeba jednorazowo przeklikać trochę quartusa, przed pierwszym uruchomieniem emulatora
    =======

1.  Skopiuj folder "emulator" oraz plik "run_emulator.tcl" do folderu testowanego projektu

2.  Otwieramy projekt w Quartus.

3.  Podpinamy Questę, jeśli jeszcze tego nie zrobiliśmy 
    (Tools >> Options >> EDA Tool Options, W rubrykę Questa Intel FPGA wpisujemy ścierzkę do folderu win64, np "C:/intelFPGA_lite/21.1/questa_fse/win64")

4.  Idziemy do Assigments >> Settings >> Simulation

5. Idziemy do "More NativeLink Settings...". Zaznaczamy tam opcje:
    - "Generate Third Party EDA..." na "ON"
    - "Lunch third party EDA in command line mode" na "ON"

6. Tworzymy testbench EMULATOR z plikiem emulator.v:
    Wybieramy "Compile test bench"
    "Test Benches..." >> New.
    Ustawiamy "Test bench Name" i "Top Level Module in test bench" na "EMULATOR"
    W okienku na dole dodajemy plik "emulator.v" z folderu "emulator"
    Klikamy OK i wracamy do Quartusa

7.  Uruchamiamy Analysis, Fitter i EDA Netlist Writter
    Krok ten trzeba wykonać, za każdym razem jak zmienimi zawartość plików projektu

8.  Klikamy Tools >> Run Simulation Tool >> Gate Level Simulation
    Ten krok wystarczy wykonać tylko raz

    =======
    Po przeklikaniu Quartusa
    =======

Znajdując się w katalogu z projektem Quartusa, uruchomy skrypt "run_emulator.tcl" poprzez komendę w cmd:
    "tclsh run_emulator.tcl"

Postępujemy zgodnie z komendami na ekranie, jeśli wykryto jakiś problem

Skrypt powinien automatycznie wykryć top-level module w projekcie quartus i podpiąć go w emulator.v, w folderze "emulator"
Jeśli nazwy portów w top-level module są dość normalne (jak HEX0, LED, SW), to automatycznie zostaną odpowiednio podpięte
Jeśli nie są normalne, trzeba otworzyć plik emulator.v w folderze "emulator" i w sekcji "TU WSTAW TESTOWANY MODUŁ" je naprawić.

Można też tutaj dodać więcej sygnałów, jak np. zegar, który domyślnie nie jest podpięty pod żaden port




