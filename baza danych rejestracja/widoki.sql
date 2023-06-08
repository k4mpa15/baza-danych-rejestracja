ALTER VIEW "DBA"."UrzednikW"
AS
SELECT Osoba.Imie, Osoba.Nazwisko, 
       Rejestracja.NrRejestracyjny, Rejestracja.VIN, datediff(year, Rejestracja.DataRejestracji, 
       GETDATE()) AS "IleLatZarejestrowany" 
FROM Osoba
    INNER JOIN Rejestracja ON Rejestracja.PESEL = Osoba.PESEL
ORDER BY 1


ALTER VIEW "DBA"."InfoOPojezdzieW"
AS
SELECT Osoba.Nazwisko+' '+Osoba.Imie AS Wlasciciel, Pojazd.Cena,Marka.NazwaMarki, Fabryka.IDFabryki 
FROM Osoba 
    INNER JOIN Rejestracja ON Rejestracja.PESEL=Osoba.PESEL
    INNER JOIN Pojazd ON Pojazd.VIN=Rejestracja.VIN
    INNER JOIN Marka ON Marka.IDMarki=Pojazd.IDMarki
    INNER JOIN Fabryka ON Fabryka.IDFabryki=Pojazd.IDFabryki

ORDER BY Rejestracja.PESEL ASC


ALTER VIEW "DBA"."KtoIleWydalW"
AS
SELECT Osoba.PESEL, MAX(Osoba.Nazwisko), MAX(Osoba.Imie), COALESCE(MAX(Pojazd.Cena),0) AS "Cena Pojazdu", 
    SUM(COALESCE(Naprawy.KwotaNaprawy,0)) AS "Laczna Kwota Napraw"
FROM Osoba
LEFT JOIN Rejestracja ON Rejestracja.PESEL = Osoba.PESEL
LEFT JOIN Pojazd ON Pojazd.VIN = Rejestracja.VIN
LEFT JOIN Naprawy ON Naprawy.VIN=Pojazd.VIN

GROUP BY Osoba.PESEL,Pojazd.VIN




CREATE MATERIALIZED VIEW "DBA"."FabrykaW"
AS
SELECT Fabryka.IDFabryki, COUNT(Pojazd.IDFabryki) AS "LiczbaWyprodukowanych", 
Fabryka.Miejscowosc, COUNT(DodatkoweWyposazenie.IDWyposazenia) AS "LiczbaDodatkowego"
FROM Fabryka 
    LEFT JOIN Pojazd ON Pojazd.IDFabryki = Fabryka.IDFabryki
    LEFT JOIN DodatkoweWyposazenie ON DodatkoweWyposazenie.VIN=Pojazd.VIN

GROUP BY Fabryka.IDFabryki,Fabryka.Miejscowosc

ORDER BY Fabryka.IDFabryki
