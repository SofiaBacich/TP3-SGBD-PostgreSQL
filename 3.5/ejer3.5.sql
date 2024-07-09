SELECT *
FROM sitio s1, sitio s2
WHERE s1.countrycode = s2.countrycode
AND s1.entidad LIKE 'a%' AND s2.entidad like 'b%'
LIMIT 100


-- WHERE s1.countrycode = s2.countrycode hace que el pais de ambos sea el mismo
-- AND s1.entidad LIKE 'a%' quiere decir que la entidad de s1 tiene que empezar con a
-- AND s2.entidad like 'b%' quiere decir que la entidad de s2 tiene que empezar con b

-- Matchea entonces todos los resultados de uno con el otro, como se ve, bigjav se repite para varios resultados de s1, y probablemente luego atgds se repita
-- para varios resultados de s2

EXPLAIN ANALYZE SELECT *
FROM sitio s1, sitio s2
WHERE s1.countrycode = s2.countrycode
AND s1.entidad LIKE 'a%' AND s2.entidad like 'b%'
LIMIT 100

DROP INDEX countrycodeindex;
CREATE INDEX countrycodeindex ON sitio (countrycode);

