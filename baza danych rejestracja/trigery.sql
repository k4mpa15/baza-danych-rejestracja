ALTER TRIGGER "WprowadzeniePojazdu" BEFORE INSERT
ORDER 1 ON "DBA"."Rejestracja"
REFERENCING NEW AS Rejestracja
FOR EACH ROW 
BEGIN
    DECLARE rok DATE;
        
    SET rok=(SELECT MAX(Pojazd.RokProdukcji) FROM Pojazd
    INNER JOIN Rejestracja ON Pojazd.VIN=Rejestracja.VIN);
     
	IF datediff(year, rok, GETDATE()) > 30 
    THEN RAISERROR 17001 'pojazd za stary do rejestracji';
    ENDIF;
END


ALTER TRIGGER "WadliwaMarka" AFTER INSERT
ORDER 1 ON "DBA"."Pojazd"
REFERENCING NEW AS Pojazdd
FOR EACH ROW 
BEGIN
    IF Pojazdd.IDMarki=WadliwaMarkaFunkcja() THEN
    MESSAGE 'uwaga! najbardziej wadliwa marka!' TO CLIENT;
    ENDIF
END



ALTER TRIGGER "CenaPojazdu" BEFORE INSERT
ORDER 1 ON "DBA"."Pojazd"
REFERENCING NEW AS Pojazd
FOR EACH ROW 
BEGIN
	IF Pojazd.Cena > 20000 AND datediff(year, Pojazd.RokProdukcji, GETDATE()) > 20 THEN
    RAISERROR 17001 'pojazd nie ma prawidlowej ceny';
    ENDIF;
END


ALTER TRIGGER "DuzaIloscNapraw" AFTER INSERT, UPDATE
ORDER 1 ON "DBA"."Naprawy"
REFERENCING NEW AS Napr
FOR EACH ROW 
BEGIN
	DECLARE ilosc INTEGER;
    SET ilosc = (SELECT TOP 1 Count(Naprawy.VIN) 
                FROM Naprawy 
                GROUP BY Naprawy.VIN
                 ORDER BY Count(Naprawy.VIN) DESC);
     
    IF ilosc > 4 THEN 
    DELETE FROM Rejestracja WHERE VIN=Napr.VIN;
  
    END IF;

END
