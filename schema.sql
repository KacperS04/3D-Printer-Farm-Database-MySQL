-- =========================================
-- PROJEKT: SYSTEM ZARZĄDZANIA FARMĄ DRUKAREK 3D
-- =========================================

CREATE TABLE klienci (
    id_klienta INT AUTO_INCREMENT PRIMARY KEY,
    imie VARCHAR(50),
    nazwisko VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE produkty (
    id_produktu INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_produktu VARCHAR(100)
);

CREATE TABLE modele_drukarki (
    id_modelu INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_modelu VARCHAR(100)
);

CREATE TABLE materialy_typy (
    id_typu INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_typu VARCHAR(25),
    gestosc DECIMAL(5,3)
);

CREATE TABLE projekty_glowne (
    id_glowne INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_projektu VARCHAR(255),
    data_utworzenia TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ilosc INT
);


CREATE TABLE drukarki (
    id_drukarki INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_drukarki VARCHAR(50),
    licznik_godzin_total DECIMAL(10,2),
    czy_widoczna TINYINT(1),
    adres_ip VARCHAR(50),
    access_code VARCHAR(50),
    numer_seryjny VARCHAR(50),
    id_modelu INT,
    FOREIGN KEY (id_modelu) REFERENCES modele_drukarki(id_modelu)
);

CREATE TABLE szpule_magazyn (
    id_szpuli INT AUTO_INCREMENT PRIMARY KEY,
    id_typu INT,
    producent VARCHAR(50),
    kolor_nazwa VARCHAR(30),
    kod_hex_koloru VARCHAR(10),
    waga_poczatkowa_g DECIMAL(10,2),
    aktualna_waga_g DECIMAL(10,2),
    cena_szpuli DOUBLE,
    status ENUM('NOWA', 'W_UZYCIU', 'PUSTA', 'USZKODZONA') DEFAULT 'NOWA',
    czy_widoczna TINYINT(1),
    FOREIGN KEY (id_typu) REFERENCES materialy_typy(id_typu)
);

CREATE TABLE zamowienia (
    id_zamowienia INT AUTO_INCREMENT PRIMARY KEY,
    id_klienta INT,
    data_zamowienia DATETIME,
    wartosc_zamowienia DECIMAL(10,2),
    status_zamowienia VARCHAR(30),
    FOREIGN KEY (id_klienta) REFERENCES klienci(id_klienta)
);


CREATE TABLE konfiguracja_ams (
    id_konfiguracji INT AUTO_INCREMENT PRIMARY KEY,
    id_drukarki INT,
    slot_nr INT,
    id_szpuli INT,
    FOREIGN KEY (id_drukarki) REFERENCES drukarki(id_drukarki),
    FOREIGN KEY (id_szpuli) REFERENCES szpule_magazyn(id_szpuli)
);

CREATE TABLE projekty_gcode (
    id_gcode INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_pliku VARCHAR(255),
    czas_estymowany_sek INT,
    warstwy_ogolem INT,
    id_glowne INT,
    id_drukarki INT,
    FOREIGN KEY (id_glowne) REFERENCES projekty_glowne(id_glowne),
    FOREIGN KEY (id_drukarki) REFERENCES drukarki(id_drukarki)
);


CREATE TABLE warianty_produktu (
    id_wariantu INT AUTO_INCREMENT PRIMARY KEY,
    id_produktu INT,
    nazwa_wariantu VARCHAR(100),
    id_gcode INT,
    cena_sugerowana DECIMAL(10,2),
    narzut_procent INT,
    kolory VARCHAR(255),
    FOREIGN KEY (id_produktu) REFERENCES produkty(id_produktu),
    FOREIGN KEY (id_gcode) REFERENCES projekty_gcode(id_gcode)
);

CREATE TABLE gcode_zuzycie_materialu (
    id_zuzycia INT AUTO_INCREMENT PRIMARY KEY,
    id_gcode INT,
    id_szpuli INT,
    zuzyta_masa_g DECIMAL(10,2),
    FOREIGN KEY (id_gcode) REFERENCES projekty_gcode(id_gcode),
    FOREIGN KEY (id_szpuli) REFERENCES szpule_magazyn(id_szpuli)
);


CREATE TABLE pozycje_zamowienia (
    id_pozycji INT AUTO_INCREMENT PRIMARY KEY,
    id_zamowienia INT,
    id_wariantu INT,
    cena_sprzedazy DECIMAL(10,2),
    status_pozycji VARCHAR(50),
    FOREIGN KEY (id_zamowienia) REFERENCES zamowienia(id_zamowienia),
    FOREIGN KEY (id_wariantu) REFERENCES warianty_produktu(id_wariantu)
);

CREATE TABLE magazyn_wyrobow_gotowych (
    id_wpisu INT AUTO_INCREMENT PRIMARY KEY,
    id_wariantu INT,
    ilosc_dostepna INT,
    uzyte_kolory TEXT,
    uzyte_szpule TEXT,
    nazwa_projektu_wolna VARCHAR(255),
    id_gcode INT,
    FOREIGN KEY (id_wariantu) REFERENCES warianty_produktu(id_wariantu),
    FOREIGN KEY (id_gcode) REFERENCES projekty_gcode(id_gcode)
);


CREATE TABLE wydruki_log (
    id_wydruku INT AUTO_INCREMENT PRIMARY KEY,
    id_gcode INT,
    id_drukarki INT,
    data_startu DATETIME,
    status ENUM('OCZEKUJE', 'DRUKOWANIE', 'SUKCES', 'ANULOWANY', 'BLAD'),
    procent_postepu INT,
    id_zamowienia INT,
    id_pozycji INT,
    FOREIGN KEY (id_gcode) REFERENCES projekty_gcode(id_gcode),
    FOREIGN KEY (id_drukarki) REFERENCES drukarki(id_drukarki),
    FOREIGN KEY (id_zamowienia) REFERENCES zamowienia(id_zamowienia),
    FOREIGN KEY (id_pozycji) REFERENCES pozycje_zamowienia(id_pozycji)
);

CREATE TABLE wydruk_mapowanie_materialu (
    id_mapowania INT AUTO_INCREMENT PRIMARY KEY,
    id_wydruku INT,
    indeks_narzedzia INT,
    id_szpuli INT,
    planowana_masa_g DECIMAL(10,2),
    FOREIGN KEY (id_wydruku) REFERENCES wydruki_log(id_wydruku),
    FOREIGN KEY (id_szpuli) REFERENCES szpule_magazyn(id_szpuli)
);