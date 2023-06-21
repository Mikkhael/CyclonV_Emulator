==============================
       O projekcie
==============================

Przygotowane przezemnie skrypty pozwalają na interaktywną symulację projektów Verilog.

Zamiast standardowej procedury symulacji, uruchamiany jest skrypt (emulator.do), który tworzy 
połączenie z lokalnym serwerem TCP, do którego periodycznie wysyła stan wyjść z FPGA

Skrypt w Node.js (emulator.js) służy do uruchamienia owego serwera. Serwer udostępnia także 
lokalnie poprzez HTTP interfejs graficzny, do którego można wejść poprzez przeglądarkę, 
i interaktywnie zmieniać stany przycisków i podglądać stany diod LED.

Interfejs graficzny można obsługiwać za pomocą myszki, lub klawiatury.
Skruty klawiszowe:
    1,2,3,4,5,6,7,8,9,0 - włączenie  przełączników bi-stabilnych
    q,w,e,r,t,y,u,i,o,p - wyłączenie przełączników bi-stabilnych
    v,b,n,m             - przyciski mono-stabilne

==============================
        Wymagania
==============================

1. Questa Intel FPGA lub QuestaSim
2. Node.js - do pobrania ze strony https://nodejs.org/en

==============================
      JAK KORZYSTAĆ
==============================

0.  (opcjonalne) Dokonaj konfiguracji, jeśli jest taka potrzeba. Można zostawić wartośći domyślne.

    W pliku "emulator.do":
        TCP_PORT        - port, na którym serwer będzie nasłuchiwał na zdarzenia emulatora
        RUN_FOR         - ile króków symulacji ma być wykonane pomiędzy każdym odświerzeniem stanu wyjsć w emulatorze
        UPDATE_INTERVAL - ile milisekund przerwy ma być pomiędzy każdym odświerzeniem stanu wyjsć w emulatorze
        
    W pliku "emulator.js":
        TCP_PORT  - port, na którym serwer będzie nasłuchiwał na zdarzenia emulatora (musi być taki sam jak w "emulator.do")
        HTTP_PORT - port, na którym uruchomiony zostanie serwer HTTP z interfejsem graficznym

    W pliku "emulator.html":
        UPDATE_INTERVAL_MS (w linijce 174) - ile milisekund przerwy ma być pomiędzy każdym odświerzeniem stanu wejść w emulatorze

1.  Uruchom "emulator.js" za wpisując do cmd komendę "node emulator.js". Wymaga zainstalowania Node.js

2.  Wejdź w przeglądarce na stronę "localhost:5002/" (Lub na inny port niż 5002, jeśli zmieniłeś HTTP_PORT w "emulator.js")

    Powinienieś zobaczyć interfejs graficzny.
    Kliknij myszką na przyciski i switche, sprawdź czy w oknie terminala serwera,
    uruchomionego w poprzednim kroku, pojawiają się komunikaty zmiany wejścia. Jeśli tak, to jest wszystko git.

3.  Skopiuj pliki "emulator.do" oraz "emulator.v" do folderu testowanego projektu

4.  W pliku "emulator.v" w sekcji oznaczonej "TU WSTAW TESTOWANY MODUŁ" wstaw instancję modułu, który chcesz testować.

    Podepnij do niego odpowiednie wejścia i wyjścia, reprezentujące przyciski na LEDy na płytce Cyclon V.
    Można także tutaj dopisać np. generator sygnału zegaroego, jak i dowolnie inne elementy języka Verilog, aby ułatwić sobie życie
    Domyślnie, podpięty jest przykładowy moduł testowy o nazwie "example_dut".


==============================
    Rozpoczęcie Emulacji 
    (dla małych projektów)
==============================

Jeśli nasz projekt jest dość mały i zawiera tylko pliki Verilog, można skorzystać z przygotowanego przezemnie skryptu "run_emulation.bat"
Kompiluje on wszystkie pliki z rozszerzeniem ".v" w danym folderze i uruchamia emulację.
Należy oczywiście pamiętać, aby przekopiować ten plik do folderu projektu.


==============================
    Rozpoczęcie Emulacji 
  (dla większych projektów)
==============================

Jeśli projekt jest bardziej zaawansowany, np. z plikami ".bdf", trzeba zawalczyć z Quartusem:

0a.  Otwieramy projekt w Quartus.

0b.  Podpinamy Questę, jeśli jeszcze tego nie zrobiliśmy 
    (Tools >> Options >> EDA Tool Options, W rubrykę Questa Intel FPGA wpisujemy ścierzkę do folderu win64, np "C:/intelFPGA_lite/21.1/questa_fse/win64")

0c.  Idziemy do Assigments >> Settings >> Simulation

0d. Idziemy do "More NativeLink Settings...". Zaznaczamy tam opcje:
    - "Generate Third Party EDA..." na "ON"
    - "Lunch third party EDA in command line mode" na "ON"

0e. Tworzymy testbench
    Wybieramy "Compile test bench"
    "Test Benches..." >> New.
    Ustawiamy Top Level Module in test bench na "EMULATOR"
    W okienku na dole dodajemy plik "emulator.v"
    Klikamy OK i wracamy do Quartusa

1.  Uruchamiamy Analysis, Fitter i EDA Netlist Writter
    Krok ten trzeba wykonać, za każdym razem jak zmienimi zawartość plików projektu

2.  Klikamy Tools >> Run Simulation Tool >> Gate Level Simulation
    Ten krok wystarczy wykonać tylko raz + za każdym razem, jeśli dodamy jakiś plik do projektu (chyba)

3.  W folderze projektu Quartusa, idziemy do "simulation/modelsim" i otwieramy w notatniku plik kończacy się na "...gate_verilog.do"
    Podmieniamy w nim linijkę "run -all" na "do ../../emulator.do"
    Ten krok trzeba wykonać za każdym razem, jak klikniemy Gate Level Simulation w kroku 5

4.  URUCHAMIAMY SYMULACJĘ: w folderze z plikiem "...gate_verilog.do" otwieramy cmd i wpisujemy:
    "vsim -c -do <nazwa pliku *.do>" (np. "vsim -c -do lab2_run_msim_gate_verilog.do")


Podsumowując:
    Na początku wykonujemy wszystkie kroki
    Jeśli zmieniliśmy zawartość plików projektu, wykonujemy kroki 1 oraz 4
    Jeśli dodaliśmy pliki do projektu, wykonujemy kroki 1,2,3,4

==============================
    Zamukanie Emulacji
==============================

Aby zatrzymać emulację, należy naciśnąć na oknie konsoli emulacji kliknac Enter. (Jak się coś zawiesi, to jeszcze trzeba wpisać "quit" albo "exit)
Aby zamknąć serwer "emulator.js", należy naciśnąć na oknie konsoli Ctrl+C


