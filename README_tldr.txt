Instrukcja dla prostych projektów, z samymi plikami verilog w jednym folderze:

0.  Instalujemy Node.js z internetu, jeśli tego nie mamy
1.  kopiujemy wszystko do folderu projektu
2.  w "emulator.v" podmieniamy moduł EXAMPLE_DUT na ten, który chcemy testować, podpinając doń odpowiednio sygnały
3.  w konsoli cmd uruchamiamy "node emulator.js"
4.  w innej konsoli cmd uruchamiamy "run_emulation.bat"
5.  wchodzimy w przeglądarce na "localhost:5002/"