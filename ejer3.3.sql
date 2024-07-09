DROP TABLE IF EXISTS stats;

CREATE TABLE stats (
	countrycode character(3) NOT NULL PRIMARY KEY REFERENCES country(code),
	cant_lenguas integer,
	pop_urbana integer
);



SELECT * FROM stats;



INSERT INTO stats (countrycode, cant_lenguas)	
SELECT country.code, COUNT(language) AS cant_lenguas
	FROM country
	INNER JOIN countryLanguage ON country.code = countryLanguage.countrycode
	GROUP BY country.code
	ORDER BY country.code ASC;

UPDATE stats SET pop_urbana = subquery.pop_urbana
	FROM(
		SELECT country.code AS countrycode, SUM(city.population) AS pop_urbana
			FROM country
			INNER JOIN city ON country.code = city.countrycode
			GROUP BY country.code
			ORDER BY country.code ASC
	) AS subquery
	WHERE stats.countrycode = subquery.countrycode;






-- _______________________________________________________________________________________________________
-- Da resultados raros, parecieran duplicados o mas
SELECT country.code, COUNT(countrylanguage.language) AS cant_lenguas, COALESCE(SUM(city.population), 0) AS pop_urbana
	FROM country
	INNER JOIN city ON country.code = city.countrycode
	INNER JOIN countryLanguage ON country.code = countryLanguage.countrycode
	GROUP BY country.code
	ORDER BY country.code;

SELECT country.code AS countrycode, COUNT(countrylanguage.language) AS cant_lenguas, COALESCE(SUM(city.population), 0) AS pop_urbana
	FROM country
	LEFT JOIN countrylanguage ON country.code = countrylanguage.countrycode
	LEFT JOIN city ON country.code = city.countrycode
	GROUP BY country.code
	ORDER BY country.code;




