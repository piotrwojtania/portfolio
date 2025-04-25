# Analiza Danych - sprzedaż produktów restauracji

Wykorzystywane oprogramowanie: dBeaver (MySQL), PowerBI (+PowerQuery +DAX)

### Opis Projektu

Celem analizy jest dostarczenie informacji pomocnych przy zmianie menu lokalu, czyli np.: które pozycje należy usunąć z oferty, które zostawić, które zmodyfikować np. zoptymalizować foodcost, zmienić cenę, zaoferować w zestawie z innym produktem itp.

Dane wejściowe stanowiły informacje z systemu sprzedażowego POS lokalu. 

Pierwszym etapem pracy jest oczyszczenie i transformacja danych przy użyciu języka SQL w programie dBeaver. Następnie dane przenosimy do PowerBI w celu dalszej analizy i wizualizacji.

Na skróty:
- [SQL - Oczyszczenie i przygotowanie danych do analizy](#i-sql---oczyszczenie-i-przygotowanie-danych-do-analizy)
- [PowerBI - Analiza i wizualizacja danych](#ii-powerbi---analiza-i-wizualizacja-danych)
- [Interaktywne wykresy na portalu powerbi.com](https://app.powerbi.com/links/faiNBUn0f2?ctid=4b059d10-47b6-4296-b9c4-46a2b9526960&pbi_source=linkShare)

## I. SQL - Oczyszczenie i przygotowanie danych do analizy


1. Tworzymy kopię zapasową tabeli
```sql
create table sprzedawane_produkty_kopia1_surowa as select * from sprzedawane_produkty
```

2. Usuwamy spacje z nazw kolumn
```sql
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
```

3. Zmieniamy typy kolumn i formaty na poprawne (w kolumnach typu tekst znajdują się liczby z częściami dziesiętnymi oddzielonymi przecinkami)

- Sprawdzamy selectem
```sql
select 
	VAT 
	,REPLACE(VAT,',', '.') as VAT_tmp
	,cast(REPLACE(VAT, ',', '.') as decimal(10,2)) as VAT_dec
	,cast(REPLACE(Suma_VAT, ',', '.') as decimal(10,2)) as Suma_VAT_dec
from sprzedawane_produkty
```

- Dodajemy tymczasowe kolumny z docelowymi typami kolumn
```sql
alter table sprzedawane_produkty
	add column VAT_dec decimal(10,2)
	,add column Suma_VAT_dec decimal(10,2)
	,add column Śr_cena_sprzedaż_netto_dec decimal(10,2)
	,add column Śr_cena_sprzedaż_brutto_dec decimal(10,2)
	,add column Wartość_sprzedaż_netto_dec decimal(10,2)
	,add column Cena_sprzedaż_brutto_dec decimal(10,2)
	,add column Rabaty_brutto_dec decimal(10,2)
	,add column Cena_jednost_dec decimal(10,2)
```

- Wprowadzamy wartości z "." zamiast "," do nowych kolumn z poprawionymi typami danych
```sql
update sprzedawane_produkty
	set 
	VAT_dec = cast(REPLACE(VAT, ',', '.') as decimal(10,2))
	,Suma_VAT_dec = cast(REPLACE(Suma_VAT, ',', '.') as decimal(10,2))
	,Śr_cena_sprzedaż_netto_dec = cast(REPLACE(Śr_cena_sprzedaż_netto, ',', '.') as decimal(10,2))
	,Śr_cena_sprzedaż_brutto_dec = cast(REPLACE(Śr_cena_sprzedaż_brutto, ',', '.') as decimal(10,2))
	,Wartość_sprzedaż_netto_dec = cast(REPLACE(Wartość_sprzedaż_netto, ',', '.') as decimal(10,2))
	,Cena_sprzedaż_brutto_dec = cast(REPLACE(Cena_sprzedaż_brutto, ',', '.') as decimal(10,2))
	,Rabaty_brutto_dec = cast(REPLACE(Rabaty_brutto, ',', '.') as decimal(10,2))
	,Cena_jednost_dec = cast(REPLACE(Cena_jednost, ',', '.') as decimal(10,2))
```

- Usuwamy podmienione kolumn
```sql
alter table sprzedawane_produkty 
	drop column VAT 
	,drop column Suma_VAT 
	,drop column Śr_cena_sprzedaż_netto
	,drop column Śr_cena_sprzedaż_brutto
	,drop column Wartość_sprzedaż_netto
	,drop column Cena_sprzedaż_brutto 
	,drop column Rabaty_brutto
	,drop column Cena_jednost
```

- Przypisujemy oryginalne nazwy kolumn nowym kolumnom z poprawnym formatem
```sql
alter table sprzedawane_produkty 
	rename column VAT_dec to VAT 
	,rename column Suma_VAT_dec to Suma_VAT
	,rename column Śr_cena_sprzedaż_netto_dec to Śr_cena_sprzedaż_netto
	,rename column Śr_cena_sprzedaż_brutto_dec to Śr_cena_sprzedaż_brutto
	,rename column Wartość_sprzedaż_netto_dec to Wartość_sprzedaż_netto
	,rename column Cena_sprzedaż_brutto_dec to Cena_sprzedaż_brutto 
	,rename column Rabaty_brutto_dec to Rabaty_brutto
	,rename column Cena_jednost_dec	to Cena_jednost	
```

4. Wyciągamy daty i godziny z jednej kolumny i zmieniamy typu kolumny
- Dodajemy nowe kolumny na datę i godzinę
```sql
alter table sprzedawane_produkty
	add column data_trans date
	,add column godzina time
```

- Testujemy selectem rozdzielenie daty i godziny
```sql
select 
	Data_transakcji
	,cast(str_to_date(Data_transakcji, '%Y-%m-%d %H:%i') as date)
	,cast(str_to_date(Data_transakcji, '%Y-%m-%d %H:%i') as time)
from
	sprzedawane_produkty
```

- Wprowadzamy rozdzielone daty i godziny do nowych kolumn o poprawnym formacie
```sql
update sprzedawane_produkty set 
	data_trans = cast(str_to_date(Data_transakcji, '%Y-%m-%d %H:%i') as date)
	,godzina = cast(str_to_date(Data_transakcji, '%Y-%m-%d %H:%i') as time)
```

- Usuwamy niepotrzebne kolumny z datą i godziną
```sql
alter table sprzedawane_produkty
	drop column Data_transakcji
```

5. Tworzymy kolumnę z ID (Chcemy, żeby numeracja zaczynała się chronologicznie po dacie transakcji)
```sql
alter table sprzedawane_produkty
	add column id int
	
set @id = 0

update sprzedawane_produkty
	set id = (@id := @id+1)
order by data_trans, godzina
```
6. Scalamy powielone nazwy produktów (Nazwy produktów były zmieniane w czasie oraz nazwy niektórych produktów były nieco inne w sysyemia zamówień online od tych w systemie kasowym)
- Tworzymy kopię zapasową tabeli
```sql
create table sprzedawane_produkty_kopia2_przed_zmianą_kategorii as select * from sprzedawane_produkty
```

- Zgrupowanie produktów wg wytycznych
```sql
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
```

7. Zajmujemy się tylko kategorią "pizza". Filtrujemy pozostałe pozycje poprzez stworzenie kolumny "kategoria"

- Sprawdzamy czy nazwy produktów nie zawierają zbędnych spacji

```sql
select 
	nazwa
	,TRIM(nazwa)
	,CHAR_LENGTH(nazwa)
	,CHAR_LENGTH(trim(nazwa))
from 
	sprzedawane_produkty
```
- Dodatkowa korekta nazw
```sql
update sprzedawane_produkty set nazwa = TRIM(nazwa)
	
update kategorie set nazwa = TRIM(nazwa)
```

- Kopiujemy kolumny z kategorią z tabeli "kategorie" do tabeli "sprzedawane_produkty"

Sprawdzamy selectem  
```sql
select 
	sp.Nazwa 
	,k.kategoria
from 
	sprzedawane_produkty sp
left join kategorie k on sp.Nazwa = k.nazwa
```

Tworzymy nowe kolumny
```sql
alter table sprzedawane_produkty add column kategoria varchar(200)
```

Kopiujemy wartości do nowej kolumny z tabelki "kategorie"
```sql
update sprzedawane_produkty sp
left join kategorie k on sp.Nazwa = k.nazwa
set sp.kategoria = k.kategoria
```

8. Usuwamy zbędne lub puste kolumny

```sql
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
```

9. Obliczamy ile dni dany produkt był w sprzedaży
- Sprawdzamy selectem
```sql
select 
	nazwa
	,MIN(data_trans)
	,MAX(data_trans)
	,datediff(MAX(data_trans), MIN(data_trans))
from sprzedawane_produkty
where kategoria = 'pizza'
group by 1
```

- Tworzymy nowe kolumny
```sql
alter table sprzedawane_produkty 
	add column dni_w_ofercie varchar(200)
	,add column first_sale date
	,add column last_sale date
```

- Wprowadzamy wartości do kolumn w tym wyliczenie ilości dni w ofercie danego produktu
```sql
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
```

10. Poprawiamy błąd: rozdzielamy pozycję "Prosciutto Crudo". W ofercie jest pizza oraz dodatek do pizzy o tej samej nazwie
- sprawdzamy selectem
```sql
select
	nazwa
	,Cena_sprzedaż_brutto
	,kategoria
from sprzedawane_produkty
where nazwa='Prosciutto Crudo' and (Cena_sprzedaż_brutto between 0 and 16)
```

- Aktualizujemy tabelę
```sql
update sprzedawane_produkty 
set kategoria = '' 
where nazwa='Prosciutto Crudo' and (Cena_sprzedaż_brutto between 0 and 16)
```

11. Usuwamy transakcje testowe lub błędne np. te z cenami 0,01 zł
```sql
delete from sprzedawane_produkty where kategoria = 'pizza' and (Cena_sprzedaż_brutto between 0 and 16)
```

12. **WYCZYSZCZONE DANE GOTOWE DO ANALIZY**
```sql
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
	,last_siuale
from sprzedawane_produkty where kategoria = 'pizza'	
```

## II. PowerBI - Analiza i wizualizacja danych
*link do interaktywnych wykresów na portalu powerbi.com:* [klik](https://app.powerbi.com/links/faiNBUn0f2?ctid=4b059d10-47b6-4296-b9c4-46a2b9526960&pbi_source=linkShare)

1. Wczytujemy dane do PowerBI

2. Analizujemy i tworzymy wykresy

![wykres1_2](https://github.com/piotrwojtania/portfolio/blob/784994f89fd16e45a77c7166a7fc283a2c70d700/images/1_2.jpg)

Aby obliczyć średni dzienny wolumen sprzedaży tworzymy dwie dodatkowe kolumny obliczeniowe. Pierwsza kolumna z całkowitą ilością sprzedanych pizz danego rodzaju. Poniżej kod DAX pierwszej kolumny.
``` 
Il. sprzedanych rodzajów pizz total = 
CALCULATE(
	SUM(sprzedawane_produkty[Sprzedana_ilość]),
	ALLEXCEPT(sprzedawane_produkty,sprzedawane_produkty[Nazwa])
	)
```

Druga kolumna z ilością sprzedanych pizz danego rodzaju w przeliczeniu na jeden dzień w którym pizza była w ofercie. Czyli np. jeśli sprzedało się 50 pizz danego rodzaju i pizza była w menu przez 10 dni to wartość w kolumnie będzie wynosić 5. Poniżej kod DAX drugiej kolumny. 
```
il. sprzed. pizz na dzień w ofercie = 
DIVIDE(
	sprzedawane_produkty[Il. sprzedanych rodzajów pizz total],
	sprzedawane_produkty[dni_w_ofercie],
	0)
```

![wykres3_4](https://github.com/piotrwojtania/portfolio/blob/dd0e0efb75988550eb9c69dda9b36bc98087e635/images/3_4.jpg)

Grupujemy pokrewne pozycje za pomocą opcji "New group"
![groups](https://github.com/piotrwojtania/portfolio/blob/497e8f4c1bcb99fc4b224f76097b5a66c2328239/images/groups.jpg)

Musimy teraz obliczyć to co ostatnio (średni dzienny wolumen sprzedaży) ale dla zgrupowanych pizz. Czyli znów potrzebujemy dwóch dodatkowych kolumn. W pierwszej liczymy całkowitą liczbę sprzedanych pizz (po zgrupowaniu). DAX:
```
Il. sprzedanych grup pizz total = 
CALCULATE(
	SUM(sprzedawane_produkty[Sprzedana_ilość]),
	ALLEXCEPT(sprzedawane_produkty,sprzedawane_produkty[Nazwa (groups)])
	)
```
W drugiej kolumnie liczymy ilość sprzedanych grup pizz w przeliczeniu na jednen dzień w ofercie. DAX:
```
il. sprzed. grup pizz na dzień w ofercie = 
DIVIDE(
	sprzedawane_produkty[Il. sprzedanych grup pizz total],
	sprzedawane_produkty[dni_w_ofercie],
	0)
```
![wykres5_6](https://github.com/piotrwojtania/portfolio/blob/14382274eb49838b5444bdfe4a8ed55564be163f/images/5_6_.jpg)

Chcemy się dowiedzieć jaki zysk generują pizze (po zgrupowaniu) w przeliczeniu na jeden dzień w ofercie. Będziemy musieli wykonać kilka dodatkowych akcji. 

Zacznijmy od dodania kolumny z ilością dni w ofercie dla całych grup. Dla zgrupowanych pizz przyjmujemy ilość dni dla pizzy z grupy która była w ofercie najdłużej, czyli np. jeśli Margherita była w ofecie 100 dni a Margherita Lunch 50 dni to w wartość dla całej grupy przyjmiemy jako 100. 

```
Dni w ofercie (grupa) = 
CALCULATE(
    MAX(sprzedawane_produkty[dni_w_ofercie]),
    ALLEXCEPT(sprzedawane_produkty, sprzedawane_produkty[Nazwa (groups)])
	)
```

Następnie obliczamy ilość sprzedanych pizz (po zgrupowaniu) w przeliczeniu na jeden dzień w ofercie. 
```
il. sprzed. grup pizz na dzień w ofercie = 
DIVIDE(
	sprzedawane_produkty[Il. sprzedanych grup pizz total],
	sprzedawane_produkty[Dni w ofercie (grupa)],
	0)
```
Następnie liczymy marżę dla zgrupowanych pizz. W tabeli "kategorie_1" mamy podane marże dla poszczególnych pozycji. Marże dla grup obliczamy jako średnie ważone marż poszczególnych pizz które składają się na grupę, gdzie wagami będą ilości sprzedanych pizz.  

Przykład:  
Mamy grupę pizz "AB" na którą składają się pizze "A" i pizze "B".  
Pizza "A" ma marżę 10 zł i sprzedało się jej 20 sztuk.  
Pizza "B" ma marżę 15 zł i sprzedało się jej 5 sztuk.  
Licznik = 10x20 + 15x5 = 275  
Mianownik = 20 + 5 = 25  
licznik/mianownik = 275/25 = 11 = marża dla grupy pizz AB

```
marżaGrupa = 
VAR Grupa = sprzedawane_produkty[Nazwa (groups)]
VAR tabelaSprzedawaneProduktyMarza = 
    ADDCOLUMNS(FILTER(sprzedawane_produkty, Grupa = sprzedawane_produkty[Nazwa (groups)]), "Marża", RELATED(Kategorie_1[marża]))
VAR Licznik =
    SUMX(tabelaSprzedawaneProduktyMarza, [Marża] * sprzedawane_produkty[il. sprzed. pizz na dzień w ofercie])
VAR Mianownik = 
    SUMX(tabelaSprzedawaneProduktyMarza, sprzedawane_produkty[il. sprzed. pizz na dzień w ofercie])
RETURN DIVIDE(Licznik, Mianownik)
```
Finalnie obliczamy jaki zysk wypracowała średnio na dzień dana grupa pizz.

```
Zysk grupy na dzień = 
sprzedawane_produkty[il. sprzed. grup pizz na dzień w ofercie]*sprzedawane_produkty[marżaGrupa]
```

![wykres7_8](https://github.com/piotrwojtania/portfolio/blob/f6d4b806e124cd00c0b419ff377248e7509732a2/images/7_8_.jpg)

Poniżej matryca BCG (wolumen sprzedaży + marża) dla wszystkich analizowanych produktów. Objaśnienie pod wykresem. *(Uwaga - dla pełnego zrozumienia wykresu zalecane jest przeglądanie jego interaktywnej wersji [klik](https://app.powerbi.com/links/faiNBUn0f2?ctid=4b059d10-47b6-4296-b9c4-46a2b9526960&pbi_source=linkShare))*

![wykres9a](https://github.com/piotrwojtania/portfolio/blob/dc72112cab4f48a045c8f788fa982d7150d8c490/images/9a_.jpg)

![wykres9b](https://github.com/piotrwojtania/portfolio/blob/471fbd90112927092de167adf34e5ba67dfed91c/images/9b.jpg)
