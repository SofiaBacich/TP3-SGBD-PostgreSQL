--Realizar las siguientes consultas en SQL:


--3.2.1. La población de Argentina:

SELECT population, name FROM country 
	WHERE name = 'Argentina';

--3.2.2. Todos los continentes (sin repeticiones)

SELECT DISTINCT continent FROM country;


--3.2.3. Nombres de los paises de America del Sur con mas de 15 millones de habitantes

SELECT name, continent, population FROM country
	WHERE continent = 'South America'
	  AND population > 15000000;


--3.2.4. Nombre y producto bruto de los diez paises con mayor producto bruto (gnp)

SELECT name, gnp FROM country
	ORDER BY gnp DESC
	LIMIT 10

--3.2.5. Forma de gobierno y cantidad de paises con dicha forma de gobierno ordenados por cantidad de modo descendente

SELECT governmentform, COUNT(*) FROM country
	GROUP BY governmentform
	ORDER BY 2 DESC;


--3.2.6. Los nombres de los continentes con sus respectivas superficies ordenados de forma descendentes por superficie

SELECT SUM(surfacearea), continent FROM country
	GROUP BY continent
	ORDER BY 1 DESC;


--3.2.7. Los continentes y la cantidad de paises que los componen de aquellos continentes con mas de 15 paises. Que los paises que se tengan en cuenta tengan una poblacion de mas de 20 millones de personas

SELECT * FROM(
	SELECT continent, COUNT(name) AS cantidadPaises FROM country
		WHERE population > 20000000
		GROUP BY continent 
		ORDER BY cantidadPaises DESC
	)
	WHERE cantidadPaises > 15;


--3.2.8. Que hace la siguiente consulta?

SELECT name, lifeexpectancy FROM country
	WHERE lifeexpectancy = (SELECT MIN(lifeexpectancy) FROM country)


--Esta query va a devolver nombre y expectativa de vida de los paises cuya esperanza de vida sea la minima

--3.2.9 Nombre del pais y la expectativa de vida de el/los paises con mayor y menor expectativa de vida

SELECT name, lifeexpectancy FROM country
	WHERE lifeexpectancy = (SELECT MIN(lifeexpectancy) FROM country)
	   OR lifeexpectancy = (SELECT MAX(lifeexpectancy) FROM country)

--Esta query va a devolver nombre y expectativa de vida de los paises cuya esperanza de vida sea la minima o maxima

--3.2.10. Nombre de los paises y anio de independencia que pertenecen al continente del pais que se independizo hace mas tiempo

SELECT name, indepyear, continent FROM country
	WHERE continent = (
		SELECT continent FROM country 
			WHERE indepyear = (SELECT MIN(indepyear) FROM country)
		);
						

--3.2.11. Nombres de los continentes que no pertenencen al conjunto de los continentes mas pobres

SELECT SUM(gnp) AS gnpContinente, continent FROM country
	GROUP BY continent
	ORDER BY gnpContinente DESC
	LIMIT 4;


--3.2.12. Los paises y las lenguas de los paises de Oceania

SELECT name, continent, language FROM country
	INNER JOIN countrylanguage ON country.code = countrylanguage.countrycode
	WHERE continent = 'Oceania'
	ORDER BY name ASC;

--3.2.13. Los paises y la cantidad de lenguas de los paises en los que se habla mas de una lengua (ordenar por cantidad de lenguas de forma descendente)

SELECT * FROM (
	SELECT COUNT(language) AS cantidadLenguas, name FROM country
		INNER JOIN countrylanguage ON country.code = countrylanguage.countrycode
		GROUP BY name 
	)
	WHERE cantidadLenguas > 1
	ORDER BY cantidadLenguas DESC;


--3.2.14. Las lenguas que se hablan en el continente mas pobre (sin considerar a Antarctica)

SELECT continent, language  FROM country
	INNER JOIN countrylanguage ON country.code = countrylanguage.countrycode
	WHERE continent = ( 
		SELECT continent FROM (
			SELECT SUM(gnp) AS gnpContinent, continent FROM country
				GROUP BY continent HAVING continent <> 'Antarctica'
				ORDER BY gnpContinent ASC
				LIMIT 1
		)
	);

 
--3.2.15. Los nombres de los paises y sus respectivas poblaciones calculadas de formas distintas: 
--              1) de acuerdo al campo de la tabla country
--              2) como suma de las polaciones de sus ciudades correspondientes, 
--              ademas se pide calcular el porcentaje de poblacion urbana (de las ciudades), ordenar por porcentaje de modo descendente

SELECT *, Round(countryUrbanPop * 100 / totalCountryPop :: numeric) AS urbanPopPercentage 
	FROM (
		SELECT country.name, SUM(city.population) AS countryUrbanPop, country.population AS totalCountryPop 
			FROM country
			INNER JOIN city ON country.code = city.countrycode
			GROUP BY country.name, country.population
	)
	ORDER BY urbanPopPercentage DESC;

