-- =========================================
-- PROJEKT: SYSTEM ZARZĄDZANIA FARMĄ DRUKAREK 3D
-- =========================================

-- 1. Raport stanów magazynowych materiałów (szpul) według typu i koloru
SELECT 
    t.nazwa_typu AS Typ_Filamentu,
    s.kolor_nazwa AS Kolor,
    s.producent AS Producent,
    COUNT(s.id_szpuli) AS Ilosc_Szpul,
    SUM(s.aktualna_waga_g) AS Laczna_Dostepna_Masa_g
FROM szpule_magazyn s
JOIN materialy_typy t ON s.id_typu = t.id_typu
WHERE s.czy_widoczna = 1 AND s.status != 'PUSTA'
GROUP BY t.nazwa_typu, s.kolor_nazwa, s.producent
ORDER BY Laczna_Dostepna_Masa_g DESC;

-- 2. Statystyki skuteczności wydruków dla poszczególnych maszyn wraz z modelem
SELECT 
    d.nazwa_drukarki,
    md.nazwa_modelu,
    COUNT(w.id_wydruku) AS Calkowita_Liczba_Wydrukow,
    SUM(CASE WHEN w.status = 'SUKCES' THEN 1 ELSE 0 END) AS Udane_Wydruki,
    SUM(CASE WHEN w.status = 'BLAD' THEN 1 ELSE 0 END) AS Bledne_Wydruki,
    ROUND((SUM(CASE WHEN w.status = 'SUKCES' THEN 1 ELSE 0 END) / NULLIF(COUNT(w.id_wydruku), 0)) * 100, 2) AS Skutecznosc_Procent
FROM drukarki d
JOIN modele_drukarki md ON d.id_modelu = md.id_modelu
LEFT JOIN wydruki_log w ON d.id_drukarki = w.id_drukarki
GROUP BY d.id_drukarki, d.nazwa_drukarki, md.nazwa_modelu;

-- 3. Analiza rentowności: Cena sugerowana wariantów kontra narzut procentowy
SELECT 
    p.nazwa_produktu,
    wp.nazwa_wariantu,
    wp.kolory,
    wp.cena_sugerowana,
    wp.narzut_procent,
    ROUND(wp.cena_sugerowana * (wp.narzut_procent / 100), 2) AS Zakladany_Zysk_Jednostkowy
FROM warianty_produktu wp
JOIN produkty p ON wp.id_produktu = p.id_produktu
ORDER BY Zakladany_Zysk_Jednostkowy DESC;

-- 4. Kalkulacja zużycia materiału dla konkretnego pliku G-Code
SELECT 
    pg.nazwa_pliku,
    ROUND(pg.czas_estymowany_sek / 3600, 2) AS Czas_Godziny,
    t.nazwa_typu AS Rodzaj_Materialu,
    s.kolor_nazwa AS Kolor,
    gz.zuzyta_masa_g AS Zuzycie_Materialu_g
FROM gcode_zuzycie_materialu gz
JOIN projekty_gcode pg ON gz.id_gcode = pg.id_gcode
JOIN szpule_magazyn s ON gz.id_szpuli = s.id_szpuli
JOIN materialy_typy t ON s.id_typu = t.id_typu;

-- 5. Stany magazynowe wyrobów gotowych przygotowanych do wysyłki
SELECT 
    p.nazwa_produktu,
    wp.nazwa_wariantu,
    wp.kolory,
    mwg.ilosc_dostepna
FROM magazyn_wyrobow_gotowych mwg
JOIN warianty_produktu wp ON mwg.id_wariantu = wp.id_wariantu
JOIN produkty p ON wp.id_produktu = p.id_produktu
WHERE mwg.ilosc_dostepna > 0
ORDER BY mwg.ilosc_dostepna DESC;