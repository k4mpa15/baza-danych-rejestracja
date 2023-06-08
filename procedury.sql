ALTER PROCEDURE "DBA"."DodajOsobeProcedura"(IN pesel CHAR(11), imie VARCHAR(15), 
nazwisko VARCHAR(15), kodPoczt CHAR(5), poczt VARCHAR(15), miejscowosc VARCHAR(15), 
Ul VARCHAR(15), NrDom INTEGER, NrLok INTEGER, NrPrJ VARCHAR(15), NrDow VARCHAR(9), DataUrodz DATE, plec CHAR(1))
AS
BEGIN
    BEGIN TRANSACTION Dodawanie
    INSERT INTO Osoba 
        VALUES(pesel,imie,nazwisko,kodPoczt, poczt,miejscowosc,Ul, NrDom, NrLok,
        NrPrJ, NrDow,DataUrodz,plec)

    IF datediff(year, dataUrodz, GETDATE()) < 15
    BEGIN 
        ROLLBACK TRANSACTION Dodawanie
    END 

    IF datediff(year, dataUrodz, GETDATE()) >= 15
    BEGIN
      COMMIT TRANSACTION Dodawanie    
    END
END




ALTER PROCEDURE "DBA"."WyswietlPojazdyProcedura"( IN pesel1 VARCHAR(11) )

BEGIN
	DECLARE wojewodztwo CHAR(30);
  FOR petla1 AS kursor1 CURSOR FOR  
    (SELECT Osoba.PESEL, Osoba.Nazwisko, Rejestracja.VIN, 
    Rejestracja.NrRejestracyjny, Marka.NazwaMarki
    FROM Osoba 
    INNER JOIN Rejestracja ON Osoba.PESEL=Rejestracja.PESEL
    INNER JOIN Pojazd ON Pojazd.VIN = Rejestracja.VIN
    INNER JOIN Marka ON Pojazd.IDMarki=Marka.IDMarki
    WHERE Osoba.PESEL=pesel1)
  DO 
    MESSAGE 'Nazwisko: '||Nazwisko||' VIN: '||VIN||' Nr Rejestracyjny: '||NrRejestracyjny||' Marka: '||NazwaMarki TO CLIENT  ;                   
    MESSAGE 'Wojewodztwo: '||WojewodztwoFunkcja(NrRejestracyjny) TO CLIENT;
  END FOR;
END






ALTER PROCEDURE "DBA"."PrzegladProcedura"(VINN VARCHAR(17))
AS
BEGIN
    DECLARE @RokProd CHAR(4)
    
    SET @RokProd = (SELECT Pojazd.RokProdukcji FROM Pojazd WHERE Pojazd.VIN=VINN)    

    IF @RokProd < 2000
    BEGIN
        DECLARE @nrrej VARCHAR(8)
        DECLARE @idpoj INTEGER

        SET @nrrej = (SELECT NrRejestracyjny FROM Pojazd WHERE VIN=VINN)
        SET @idpoj = (SELECT IDPojazdu FROM Pojazd WHERE VIN=VINN)
   
        UPDATE Naprawy
        	SET Naprawy.CzescSamochodu = 'przeglad',Naprawy.DataNaprawy = GETDATE() WHERE Naprawy.VIN = VINN 
    END
    IF @RokProd >= 2000
    MESSAGE 'jeszcze nie czas na przeglad' TO CLIENT
END





ALTER PROCEDURE "DBA"."SprawdzaniePeseluProcedura"(IN pesel1 char(11))
BEGIN
    DECLARE rok INTEGER;
    DECLARE miesiac INTEGER;
    DECLARE dzien INTEGER;
    DECLARE dataUr DATE;
    DECLARE dataPESEL CHAR(8);
    DECLARE dataPESELdata DATE;
    
    SET dataUr=(SELECT DataUrodzenia FROM Osoba WHERE PESEL=pesel1);

    SET rok=LEFT(pesel1, 2);
    SET miesiac=RIGHT(LEFT(pesel1, 4),2);
    SET dzien=RIGHT(LEFT(pesel1, 6),2);
   
    IF miesiac>20 THEN
        SET rok=rok+2000;
        SET miesiac=miesiac-20;
    ELSE 
        SET rok=rok+1900;
    END IF;

    IF miesiac<10 AND dzien>10 THEN
        SET dataPESEL=rok||'0'||miesiac||dzien;
    END IF;  

    IF miesiac<10 AND dzien<10 THEN
        SET dataPESEL=rok||'0'||miesiac||'0'||dzien;
    END IF; 

    IF miesiac>10 AND dzien<10 THEN
        SET dataPESEL=rok||miesiac||'0'||dzien;
    END IF; 

    SET dataPESELdata = CONVERT(date,dataPESEL);

    IF dataPESELdata<>DataUr THEN 
        UPDATE Osoba
            SET DataUrodzenia=dataPESELdata
        WHERE PESEL=pesel1;
    END IF;
END




ALTER PROCEDURE "DBA"."SprawdzaniePlciProcedura"(IN pesel1 CHAR(11))

BEGIN
    DECLARE plecc CHAR(1);
    DECLARE plecprawidlowa CHAR(1);
    DECLARE imie1 CHAR(15);

    SET imie1 = (SELECT Imie FROM Osoba WHERE PESEL=pesel1);
    SET plecc = (SELECT Plec FROM Osoba WHERE PESEL=pesel1);
    IF imie1 LIKE '%a' THEN SET plecprawidlowa = 'k';
    END IF;

    IF imie1 NOT LIKE '%a' THEN SET plecprawidlowa = 'm';
    END IF;

    IF plecc <> plecprawidlowa THEN
        UPDATE Osoba
            SET Plec=plecprawidlowa 
            WHERE PESEL = pesel1;

    END IF;
END
