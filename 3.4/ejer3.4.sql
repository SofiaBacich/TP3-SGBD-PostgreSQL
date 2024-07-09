DROP TABLE IF EXISTS sitio;

CREATE TABLE sitio (
	id integer NOT NULL PRIMARY KEY, 
	entidad varchar, 
	tipo_entidad varchar, 
	pais varchar, 
	countrycode character(3) NOT NULL REFERENCES country(code)
);

SELECT * FROM sitio
	ORDER BY id;





