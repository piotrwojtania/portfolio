/*Stworzenie kopii tabeli*/
create table sprzedawane_produkty_kopia1_surowa as select * from sprzedawane_produkty


/*Zmiana nazw kolumn na nazwy bez spacji*/
alter table sprzedawane_produkty
	change column `Numer zamówienia` Numer_zamówienia varchar(200)
	,change column `Numer dokumentu` Numer_dokumentu varchar(200)
	,change column `Rodzaj płatności` Rodzaj_płatności varchar(200)
	,change column `Zakończono` Data_transakcji varchar(200)
	,change column `Sprzedana ilość` Sprzedana_ilość int
	,change column `Suma VAT` Suma_VAT varchar(200)
	,change column `Średnia cena sprzedaży produktu netto` Śr_cena_sprzedaż_netto varchar(200)
	,change column `Średnia cena sprzedaży produktu brutto` Śr_cena_sprzedaż_brutto varchar(200)
	,change column `Wartość sprzedaży netto` Wartość_sprzedaż_netto varchar(200)
	,change column `Cena sprzedaży brutto` Cena_sprzedaż_brutto varchar(200)
	,change column `Rabaty brutto` Rabaty_brutto varchar(200)
	,change column `Cena jednost.` Cena_jednost varchar(200)
	
	
/*Zmiana typów kolumn i formatów na poprawne (liczny z częścią dziesiętną oddzielone przecinkiem w kolumnie typu tekst)*/
	/*Sprawdzenie czy zadziała zamiana "," na "." oraz zmiana typu z "varchar" na "decimal"*/
select 
	VAT 
	,REPLACE(VAT,',', '.') as VAT_tmp
	,cast(REPLACE(VAT, ',', '.') as decimal(10,2)) as VAT_dec
	,cast(REPLACE(Suma_VAT, ',', '.') as decimal(10,2)) as Suma_VAT_dec
from sprzedawane_produkty 


	/*Dodanie tymczasowych kolumn z docelowymi typami kolumn*/
alter table sprzedawane_produkty
	add column VAT_dec decimal(10,2)
	,add column Suma_VAT_dec decimal(10,2)
	,add column Śr_cena_sprzedaż_netto_dec decimal(10,2)
	,add column Śr_cena_sprzedaż_brutto_dec decimal(10,2)
	,add column Wartość_sprzedaż_netto_dec decimal(10,2)
	,add column Cena_sprzedaż_brutto_dec decimal(10,2)
	,add column Rabaty_brutto_dec decimal(10,2)
	,add column Cena_jednost_dec decimal(10,2)

	
	/*Wprowadzenie wartości z "." zamiast "," do nowych kolumn z poprawionymi typami danych*/	
update sprzedawane_produkty
	set VAT_dec = cast(REPLACE(VAT, ',', '.') as decimal(10,2))
	,Suma_VAT_dec = cast(REPLACE(Suma_VAT, ',', '.') as decimal(10,2))
	,Śr_cena_sprzedaż_netto_dec = cast(REPLACE(Śr_cena_sprzedaż_netto, ',', '.') as decimal(10,2))
	,Śr_cena_sprzedaż_brutto_dec = cast(REPLACE(Śr_cena_sprzedaż_brutto, ',', '.') as decimal(10,2))
	,Wartość_sprzedaż_netto_dec = cast(REPLACE(Wartość_sprzedaż_netto, ',', '.') as decimal(10,2))
	,Cena_sprzedaż_brutto_dec = cast(REPLACE(Cena_sprzedaż_brutto, ',', '.') as decimal(10,2))
	,Rabaty_brutto_dec = cast(REPLACE(Rabaty_brutto, ',', '.') as decimal(10,2))
	,Cena_jednost_dec = cast(REPLACE(Cena_jednost, ',', '.') as decimal(10,2))

	
		/*Usunięcie podmienionych kolumn*/	
alter table sprzedawane_produkty 
	drop column VAT 
	,drop column Suma_VAT 
	,drop column Śr_cena_sprzedaż_netto
	,drop column Śr_cena_sprzedaż_brutto
	,drop column Wartość_sprzedaż_netto
	,drop column Cena_sprzedaż_brutto 
	,drop column Rabaty_brutto
	,drop column Cena_jednost
	
	
		/*Przypisanie oryginalnych nazw kolumn nowym kolumną z poprawnym formatem*/	
alter table sprzedawane_produkty 
	rename column VAT_dec to VAT 
	,rename column Suma_VAT_dec to Suma_VAT
	,rename column Śr_cena_sprzedaż_netto_dec to Śr_cena_sprzedaż_netto
	,rename column Śr_cena_sprzedaż_brutto_dec to Śr_cena_sprzedaż_brutto
	,rename column Wartość_sprzedaż_netto_dec to Wartość_sprzedaż_netto
	,rename column Cena_sprzedaż_brutto_dec to Cena_sprzedaż_brutto 
	,rename column Rabaty_brutto_dec to Rabaty_brutto
	,rename column Cena_jednost_dec	to Cena_jednost	
	
	
/*Wyciągnięcie daty i godziny z jednej kolumny i zmiana typu kolumny*/
	/*Dodanie nowych kolumn na datę i godzinę*/		
alter table sprzedawane_produkty
	add column data_trans date
	,add column godzina time
	
	
	/*Test rozdzielenia daty i godziny*/		
select 
	Data_transakcji
	,cast(str_to_date(Data_transakcji, '%Y-%m-%d %H:%i') as date)
	,cast(str_to_date(Data_transakcji, '%Y-%m-%d %H:%i') as time)
from
	sprzedawane_produkty
	
	
	/*Wprowadzenie rozdzielonej daty i godziny do nowych kolumn o poprawnym formacie*/	
update sprzedawane_produkty set 
	data_trans = cast(str_to_date(Data_transakcji, '%Y-%m-%d %H:%i') as date)
	,godzina = cast(str_to_date(Data_transakcji, '%Y-%m-%d %H:%i') as time)
	
	
	/*Usunięcie niepotrzebnej kolumny z dantą i godziną*/	
alter table sprzedawane_produkty
	drop column Data_transakcji

	
/*Stworzenie kolumny z ID. Chcemy, żeby numeracja zaczynała się chronologicznie po dacie transakcji*/	
alter table sprzedawane_produkty
	add column id int
	
set @id = 0

update sprzedawane_produkty
	set id = (@id := @id+1)
order by data_trans, godzina	
	

/*Scalenie powielonych nazw produktów. Nazwy produktów było korygowane w czasie. 
 Nazwy niektórych produktów były nieco inne w sysyemia zamówień online od tych w systemie kasowym*/
		/*Stworzenie kopii zapasowej tabeli*/
create table sprzedawane_produkty_kopia2_przed_zmianą_kategorii as select * from sprzedawane_produkty
	

		/*Zgrupowanie produktów wg wytycznych*/
update sprzedawane_produkty 
set Nazwa = case 	
	when Nazwa = 'Mortadella (pizza)' then 'Mortadella'
	when Nazwa = 'Tortufo (Trufla)' then 'Tortufo'
	when Nazwa = 'Rafano (Chrzan)' then 'Rafano'
	when Nazwa = 'Cipolla (Cebula)' then 'Cipolla'
	when Nazwa = 'PIZZA uniwersalna pozycja VIP' then 'uniwersalna'
	when Nazwa = 'PIZZA Patata (Ziemniak) lunch' then 'Patata lunch'
	when Nazwa = 'PIZZA Spianata lunch' then 'Spianata lunch'
	when Nazwa = 'PIZZA Capriciosa lunch' then 'Capriciosa lunch'
	when Nazwa = 'PIZZA Napoli lunch' then 'Napoli lunch'
	when Nazwa = 'PIZZA Margherita lunch' then 'Margherita lunch'
	when Nazwa = 'sezonowa z DYNIĄ' then 'Margherita lunch'
	when Nazwa = 'sezonowa z kurkami' then 'z Kurkami'
	when Nazwa = 'PIZZA Ziemniak lunch' then 'Patata'
	when Nazwa = 'Ziemniak' then 'Patata'
	when Nazwa = 'Patata (Ziemniak)' then 'Patata'
	when Nazwa = '○	Trufla ' then 'Tortufo'
	when Nazwa = 'Chrzan' then 'Rafano'
	when Nazwa = 'Cebula' then 'Cipolla'
	when Nazwa = '○	Prosciutto Crudo' then 'Prosciutto Crudo'
	when Nazwa = '○	Salame' then 'Salame'
	when Nazwa = '○	Margherita ' then 'Margherita'
	when Nazwa = '○	Nduja' then 'Nduja'
	when Nazwa = '○	Al formaggio ' then 'Al formaggio'
	when Nazwa = '○	Ananas ' then 'Ananas'
	when Nazwa = '○	Salsiccia' then 'Salsiccia'
	when Nazwa = 'PIZZA VIP' then 'uniwersalna'
	when Nazwa = 'Porro sezonowa' then 'Porro'
	when Nazwa = 'Carbonara (Pancetta)' then 'Carbonara'
	when Nazwa = 'Tonno (pizza z tuńczykiem)' then 'Tonno'
	else Nazwa
end


/*Zajmujemy się tylko kategorią "pizza". Odfiltrujemy pozostałe pozycje poprzez stworzenie kolumny "kategoria" */
	/*Sprawdzenie czy nazwy produktów nie zawierają zbędnych spacji*/
select 
	nazwa
	,TRIM(nazwa)
	,CHAR_LENGTH(nazwa)
	,CHAR_LENGTH(trim(nazwa))
from 
	sprzedawane_produkty

	
	/*Dodatkowa korekta nazw*/
update sprzedawane_produkty set nazwa = TRIM(nazwa)
	
update kategorie set nazwa = TRIM(nazwa)	


	/*Dodanie kolumny z kategorią produktu z tabeli "kategorie" do tabeli "sprzedawane_produkty"*/
	/*Sprawdzenie selectem*/
select 
	sp.Nazwa 
	,k.kategoria
from 
	sprzedawane_produkty sp
left join kategorie k on sp.Nazwa = k.nazwa


	/*Stworzenie nowej kolumny*/
alter table sprzedawane_produkty add column kategoria varchar(200)


 	/*Skopiowanie wartości do stworzonej kolumny z tabelki "kategorie"*/
update sprzedawane_produkty sp
left join kategorie k on sp.Nazwa = k.nazwa
set sp.kategoria = k.kategoria

/*Usuwamy zbędne lub puste kolumny*/
alter table sprzedawane_produkty 
	drop column Etykiety 
	,drop column `ID transakcji płatniczych` 
	,drop column Podtytuł
	,drop column PLU 
	,drop column EAN 
	,drop column `Oznaczenie zewnętrzne`
	,drop column `Numer pracownika`
	,drop column Pracownik
	,drop column REGON 
	,drop column`Jednostkowa cena zakupu netto`
	,drop column `Łączna cena zakupu netto`
	,drop column `Numer kasy`
	,drop column Kasa


/*Obliczenie ile dni dany produkt był w sprzedaży*/
	/*Sprawdzenie selectem*/
select 
	nazwa
	,MIN(data_trans)
	,MAX(data_trans)
	,datediff(MAX(data_trans), MIN(data_trans))
from sprzedawane_produkty
where kategoria = 'pizza'
group by 1

	/*Modyfikacja tabeli - stworzenie nowych kolumn*/
alter table sprzedawane_produkty 
	add column dni_w_ofercie varchar(200)
	,add column first_sale date
	,add column last_sale date

	/*Modyfikacja tabeli - wprowadzenie wartości do kolumn w tym wyliczenie ilości dni w ofercie danego produktu*/
	update sprzedawane_produkty sp
join 
	(
	select 
		nazwa
		,MIN(data_trans) as first_sale
		,MAX(data_trans) as last_sale
		,datediff(MAX(data_trans), MIN(data_trans)) as dni_w_ofercie
	from sprzedawane_produkty
	where kategoria = 'pizza'
	group by 1
	) sf on sp.nazwa = sf.nazwa 
	set sp.first_sale = sf.first_sale
		,sp.last_sale = sf.last_sale
		,sp.dni_w_ofercie = sf.dni_w_ofercie
	
		
	/*Poprawa błędu: rozdzielenie pozycji "Prosciutto Crudo". W ofercie jest pizza oraz dodatek do pizzy o tej samej nazwie*/
	/*sprawdzenie selectem*/
select
	nazwa
	,Cena_sprzedaż_brutto
	,kategoria
	from sprzedawane_produkty
where nazwa='Prosciutto Crudo' and (Cena_sprzedaż_brutto between 0 and 16)


	/*Aktualizacja tabeli*/
update sprzedawane_produkty 
set kategoria = '' 
where nazwa='Prosciutto Crudo' and (Cena_sprzedaż_brutto between 0 and 16)

	
/*Usunięcie transakcji testowych lub błędnych np. z cenami 0,01 zł*/		
delete from sprzedawane_produkty where kategoria = 'pizza' and (Cena_sprzedaż_brutto between 0 and 16)



/*WYCZYSZCZONE DANE GOTOWE DO ANALIZY*/
select
	Numer_zamówienia
	,Rodzaj_płatności
	,Nazwa
	,Sprzedana_ilość
	,VAT
	,Suma_VAT
	,Wartość_sprzedaż_netto
	,Cena_sprzedaż_brutto
	,Rabaty_brutto
	,Cena_jednost
	,data_trans
	,godzina
	,id
	,kategoria
	,dni_w_ofercie
	,first_sale
	,last_sale
from sprzedawane_produkty where kategoria = 'pizza'