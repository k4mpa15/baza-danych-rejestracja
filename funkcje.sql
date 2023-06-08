ALTER FUNCTION "DBA"."WojewodztwoFunkcja"( IN NrRejestracyjny VARCHAR(8) )
RETURNS VARCHAR(50)
NOT DETERMINISTIC
BEGIN
	DECLARE "wojewodztwo" VARCHAR(50);
	CASE 
        WHEN NrRejestracyjny LIKE 'Z%' THEN SET wojewodztwo='wojewodztwo zachodniopomorskie'
        WHEN NrRejestracyjny LIKE 'G%' THEN SET wojewodztwo='wojewodztwo pomorskie'
        WHEN NrRejestracyjny LIKE 'N%' THEN SET wojewodztwo='wojewodztwo warminsko-mazurskie'
        WHEN NrRejestracyjny LIKE 'B%' THEN SET wojewodztwo='wojewodztwo podlaskie'
        WHEN NrRejestracyjny LIKE 'F%' THEN SET wojewodztwo='wojewodztwo lubuskie'
        WHEN NrRejestracyjny LIKE 'P%' THEN SET wojewodztwo='wojewodztwo wielkopolskie'
        WHEN NrRejestracyjny LIKE 'W%' THEN SET wojewodztwo='wojewodztwo mazowieckie'
        WHEN NrRejestracyjny LIKE 'L%' THEN SET wojewodztwo='wojewodztwo lubelskie'
        WHEN NrRejestracyjny LIKE 'E%' THEN SET wojewodztwo='wojewodztwo lodzkie'
        WHEN NrRejestracyjny LIKE 'S%' THEN SET wojewodztwo='wojewodztwo slaskie'
        WHEN NrRejestracyjny LIKE 'D%' THEN SET wojewodztwo='wojewodztwo dolnoslaskie'
        WHEN NrRejestracyjny LIKE 'K%' THEN SET wojewodztwo='wojewodztwo malopolskie'
        WHEN NrRejestracyjny LIKE 'R%' THEN SET wojewodztwo='wojewodztwo podkarpackie'
        WHEN NrRejestracyjny LIKE 'T%' THEN SET wojewodztwo='wojewodztwo swietokrzyskie'
        WHEN NrRejestracyjny LIKE 'O%' THEN SET wojewodztwo='wojewodztwo opolskie'
        WHEN NrRejestracyjny LIKE 'C%' THEN SET wojewodztwo='wojewodztwo kujawsko-pomorskie'
        WHEN NrRejestracyjny LIKE 'H%' THEN SET wojewodztwo='sluzby specialne'
       
    ELSE SET wojewodztwo='blad w rejestracji'
    END;


	RETURN "wojewodztwo";
END



ALTER FUNCTION "DBA"."WJakimMiescieProdukcjaFunkcja"(IN vin1 CHAR(17), miejscowosctest CHAR(15))
RETURNS CHAR(1)//zwraca czy tam zostal wykonany pojazd
DETERMINISTIC
BEGIN
	DECLARE czyTak CHAR(1);
    DECLARE miejscowosc1 CHAR(15);

    DECLARE kursor CURSOR FOR 
    (SELECT Fabryka.Miejscowosc FROM Fabryka 
     INNER JOIN Pojazd ON Fabryka.IDFabryki = Pojazd.IDFabryki
     INNER JOIN Rejestracja ON Rejestracja.VIN=Pojazd.VIN
     WHERE Pojazd.VIN = vin1);

    SET czyTak = 'F';

    OPEN kursor;
        petla1: LOOP
        FETCH NEXT kursor INTO miejscowosc1;
        IF SQLCODE <> 0 THEN
            LEAVE petla1;
        ENDIF;

        IF miejscowosc1 = miejscowosctest THEN
            SET czyTak = 'T';
            LEAVE petla1;
        ENDIF;
    END LOOP;
    CLOSE kursor;
    RETURN czyTak;
END




ALTER FUNCTION "DBA"."WaznoscRejestracjiFunkcja"(IN NrVIN VARCHAR(17))
RETURNS CHAR(10)
NOT DETERMINISTIC
BEGIN
	DECLARE CzyZmieniono CHAR(10);
    DECLARE dataRej DATE;
    DECLARE dataWaz DATE;
    DECLARE dataWazZTab DATE;
    SET dataRej = (SELECT Rejestracja.DataRejestracji FROM Rejestracja WHERE Rejestracja.VIN=NrVIN);
    SET dataWaz = DATEADD(YEAR,5,dataRej);
    SET dataWazZTab = (SELECT Rejestracja.WaznoscRejestracji FROM Rejestracja WHERE Rejestracja.VIN=NrVIN);
    IF dataWazZTab=dataWaz THEN 
        SET CzyZmieniono='Nie zmieniono';
    ENDIF; 
    IF dataWazZTab<>dataWaz THEN 
        UPDATE Rejestracja
            SET Rejestracja.WaznoscRejestracji = dataWaz WHERE Rejestracja.VIN=NrVIN;
        SET CzyZmieniono='Zmieniono';
    ENDIF;
	RETURN CzyZmieniono;
END




ALTER FUNCTION "DBA"."WadliwaMarkaFunkcja"()
RETURNS INTEGER
BEGIN
	DECLARE @marka INTEGER;

    SET @marka=
    (SELECT TOP 1 Marka.IDMarki
     FROM Marka 
        INNER JOIN Pojazd ON Pojazd.IDMarki=Marka.IDMarki
        INNER JOIN Naprawy ON Naprawy.IDPojazdu = Pojazd.IDPojazdu
     GROUP BY Marka.IDMarki
     ORDER BY COUNT(Pojazd.IDMarki) DESC);
        
	RETURN @marka;
END





ALTER FUNCTION "DBA"."UsunFabrykeFunkcja"()
RETURNS INTEGER
AS
BEGIN
    BEGIN TRANSACTION Usuniecie 

	DECLARE @ileWyprodukowano INTEGER
    DECLARE @idF INTEGER
    SET @ileWyprodukowano =(SELECT TOP 1 COALESCE( COUNT(Pojazd.IDFabryki), 0) AS Ilosc
    FROM Fabryka LEFT JOIN Pojazd ON Fabryka.IDFabryki=Pojazd.IDFabryki
    GROUP BY Fabryka.IDFabryki
    ORDER BY Ilosc)

    SET @idF = (SELECT TOP 1 Fabryka.IDFabryki
    FROM Fabryka LEFT JOIN Pojazd ON Fabryka.IDFabryki=Pojazd.IDFabryki
    GROUP BY Fabryka.IDFabryki
    HAVING COALESCE(COUNT(Pojazd.IDFabryki), 0) = 0)

    DELETE FROM Fabryka WHERE IDFabryki=@idF
    
    UPDATE Pojazd
        SET IDFabryki=0 WHERE IDFabryki=@idF

    IF @ileWyprodukowano <> 0
    BEGIN 
        ROLLBACK TRANSACTION Usuniecie
    END 

    IF @ileWyprodukowano = 0
    BEGIN
        COMMIT TRANSACTION Usuniecie
    END
    RETURN @idF
END
