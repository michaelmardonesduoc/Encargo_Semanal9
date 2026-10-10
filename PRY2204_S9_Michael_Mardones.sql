-- ============================================================
-- Fase 4: Informes (SELECT)
-- ============================================================

-- INFORME 1: Asociaciones profesionales creadas después del año 2000
SELECT cod_asociacion                        AS "Código",
       nombre_asociacion                     AS "Asociación",
       TO_CHAR(fecha_creacion, 'DD/MM/YYYY') AS "Fecha Creación",
       tipo_asociacion                       AS "Tipo"
FROM   ASOCIACION
WHERE  tipo_asociacion = 'P'
AND    fecha_creacion > DATE '2000-12-31'
ORDER BY fecha_creacion DESC;


-- INFORME 2: Patrimonio de clubes en pesos y dólares (1 USD = $955)
SELECT cod_club                       AS "Código",
       nombre_club                    AS "Club",
       patrimonio                     AS "Patrimonio (CLP)",
       ROUND(patrimonio / 955, 2)     AS "Patrimonio (USD)"
FROM   CLUB_FUTBOL
WHERE  LOWER(nombre_club) LIKE '%a%'
AND    patrimonio > 200000000
AND    tipo_club = 'Profesional'
ORDER BY cod_club DESC;