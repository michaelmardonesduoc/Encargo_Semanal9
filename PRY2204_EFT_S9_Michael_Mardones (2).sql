-- ============================================================================
-- PRY2204 - MODELAMIENTO DE BASES DE DATOS
-- Evaluacion Final Transversal (EFT) - Semana 9
-- Caso: Asociacion Nacional de Futbol Profesional (ANFP)
-- Usuario: PRY2204_S9
-- ============================================================================

-- ============================================================================
-- LIMPIEZA (DROP) - permite re-ejecutar el script sin errores de "ya existe".
-- En la PRIMERA ejecucion sobre un esquema vacio, estos DROP arrojan
-- "ORA-00942 / ORA-02289 (no existe)": es normal y el script continua igual.
-- ============================================================================
DROP TABLE FORMACION        CASCADE CONSTRAINTS;
DROP TABLE JUGADOR_IDIOMA   CASCADE CONSTRAINTS;
DROP TABLE CLUB_JUGADOR     CASCADE CONSTRAINTS;
DROP TABLE PERSONAL_PLANTA  CASCADE CONSTRAINTS;
DROP TABLE JUGADOR          CASCADE CONSTRAINTS;
DROP TABLE TRABAJADOR       CASCADE CONSTRAINTS;
DROP TABLE CLUB_FUTBOL      CASCADE CONSTRAINTS;
DROP TABLE COMUNA           CASCADE CONSTRAINTS;
DROP TABLE PUESTO           CASCADE CONSTRAINTS;
DROP TABLE IDIOMA           CASCADE CONSTRAINTS;
DROP TABLE ESCUELA          CASCADE CONSTRAINTS;
DROP TABLE ASOCIACION       CASCADE CONSTRAINTS;
DROP TABLE NACIONALIDAD     CASCADE CONSTRAINTS;
DROP TABLE REGION           CASCADE CONSTRAINTS;
DROP SEQUENCE seq_club_futbol;

-- ============================================================================
-- FASE 3 - CREACION DE OBJETOS (DDL)
-- ============================================================================

-- Secuencia para CLUB_FUTBOL: inicia en 703 e incrementa de 4 en 4
CREATE SEQUENCE seq_club_futbol
    START WITH 703
    INCREMENT BY 4
    NOCACHE
    NOCYCLE;

-- ---------------------------------------------------------------------------
-- Tablas sin claves foraneas
-- ---------------------------------------------------------------------------

CREATE TABLE REGION (
    cod_region      NUMBER(4)    NOT NULL,
    nombre_region   VARCHAR2(50) NOT NULL,
    CONSTRAINT PK_region PRIMARY KEY (cod_region)
);

-- La PK se genera por columna IDENTITY: inicia en 210 e incrementa de 2 en 2
CREATE TABLE NACIONALIDAD (
    cod_nacionalidad    NUMBER(5) GENERATED ALWAYS AS IDENTITY (START WITH 210 INCREMENT BY 2),
    nombre_nacionalidad VARCHAR2(50) NOT NULL,
    CONSTRAINT PK_nacionalidad PRIMARY KEY (cod_nacionalidad)
);

CREATE TABLE ASOCIACION (
    cod_asociacion    NUMBER(5)    NOT NULL,
    nombre_asociacion VARCHAR2(60) NOT NULL,
    fecha_creacion    DATE         NOT NULL,
    tipo_asociacion   VARCHAR2(1)  NOT NULL,
    CONSTRAINT PK_asociacion PRIMARY KEY (cod_asociacion),
    CONSTRAINT CK_asoc_fecha CHECK (fecha_creacion >= DATE '1980-12-31'),
    CONSTRAINT CK_asoc_tipo  CHECK (tipo_asociacion IN ('P','A'))
);

CREATE TABLE ESCUELA (
    cod_escuela     NUMBER(5)    NOT NULL,
    nombre_escuela  VARCHAR2(60) NOT NULL,
    capacidad       NUMBER(5),
    fecha_fundacion DATE,
    CONSTRAINT PK_escuela PRIMARY KEY (cod_escuela)
);

CREATE TABLE IDIOMA (
    cod_idioma    NUMBER(4)    NOT NULL,
    nombre_idioma VARCHAR2(40) NOT NULL,
    CONSTRAINT PK_idioma PRIMARY KEY (cod_idioma)
);

CREATE TABLE PUESTO (
    cod_puesto    NUMBER(3)    NOT NULL,
    nombre_puesto VARCHAR2(30) NOT NULL,
    CONSTRAINT PK_puesto PRIMARY KEY (cod_puesto)
);

-- ---------------------------------------------------------------------------
-- Tablas con claves foraneas
-- ---------------------------------------------------------------------------

CREATE TABLE COMUNA (
    cod_comuna    NUMBER(5)    NOT NULL,
    nombre_comuna VARCHAR2(50) NOT NULL,
    cod_region    NUMBER(4)    NOT NULL,
    CONSTRAINT PK_comuna PRIMARY KEY (cod_comuna),
    CONSTRAINT FK_comuna_region FOREIGN KEY (cod_region) REFERENCES REGION (cod_region)
);

-- nombre_club es UNICO (UNIQUE); tipo_club valida 'Profesional'/'Amateur' (CHECK)
CREATE TABLE CLUB_FUTBOL (
    cod_club       NUMBER(6)     NOT NULL,
    nombre_club    VARCHAR2(60)  NOT NULL,
    patrimonio     NUMBER(15)    NOT NULL,
    direccion_club VARCHAR2(100) NOT NULL,
    tipo_club      VARCHAR2(15)  NOT NULL,
    cod_comuna     NUMBER(5)     NOT NULL,
    CONSTRAINT PK_club PRIMARY KEY (cod_club),
    CONSTRAINT UQ_club_nombre UNIQUE (nombre_club),
    CONSTRAINT CK_club_tipo CHECK (tipo_club IN ('Profesional','Amateur')),
    CONSTRAINT FK_club_comuna FOREIGN KEY (cod_comuna) REFERENCES COMUNA (cod_comuna)
);

CREATE TABLE TRABAJADOR (
    cod_inscripcion  NUMBER(8)     NOT NULL,
    rut              NUMBER(8)     NOT NULL,
    dv               VARCHAR2(1)   NOT NULL,
    nombres          VARCHAR2(50)  NOT NULL,
    apellidos        VARCHAR2(50)  NOT NULL,
    sueldo_base      NUMBER(10)    NOT NULL,
    fecha_nacimiento DATE          NOT NULL,
    genero           VARCHAR2(1)   NOT NULL,
    estado_civil     VARCHAR2(20)  NOT NULL,
    telefono_movil   VARCHAR2(15)  NOT NULL,
    direccion        VARCHAR2(100) NOT NULL,
    cod_comuna       NUMBER(5)     NOT NULL,
    CONSTRAINT PK_trabajador PRIMARY KEY (cod_inscripcion),
    CONSTRAINT FK_trab_comuna FOREIGN KEY (cod_comuna) REFERENCES COMUNA (cod_comuna)
);

-- Subtipo JUGADOR: comparte la PK con TRABAJADOR (relacion 1:1 identificadora)
CREATE TABLE JUGADOR (
    cod_inscripcion  NUMBER(8)  NOT NULL,
    monto_premios    NUMBER(12),
    cod_nacionalidad NUMBER(5)  NOT NULL,
    cod_asociacion   NUMBER(5)  NOT NULL,
    cod_puesto       NUMBER(3)  NOT NULL,
    CONSTRAINT PK_jugador PRIMARY KEY (cod_inscripcion),
    CONSTRAINT FK_jug_trabajador   FOREIGN KEY (cod_inscripcion)  REFERENCES TRABAJADOR (cod_inscripcion),
    CONSTRAINT FK_jug_nacionalidad FOREIGN KEY (cod_nacionalidad) REFERENCES NACIONALIDAD (cod_nacionalidad),
    CONSTRAINT FK_jug_asociacion   FOREIGN KEY (cod_asociacion)   REFERENCES ASOCIACION (cod_asociacion),
    CONSTRAINT FK_jug_puesto       FOREIGN KEY (cod_puesto)       REFERENCES PUESTO (cod_puesto)
);

-- Subtipo PERSONAL_PLANTA: comparte la PK con TRABAJADOR
CREATE TABLE PERSONAL_PLANTA (
    cod_inscripcion  NUMBER(8) NOT NULL,
    horas_trabajadas NUMBER(5),
    valor_hora_extra NUMBER(8),
    CONSTRAINT PK_personal PRIMARY KEY (cod_inscripcion),
    CONSTRAINT FK_pers_trabajador FOREIGN KEY (cod_inscripcion) REFERENCES TRABAJADOR (cod_inscripcion)
);

-- Tabla puente: historial de clubes de un jugador (PK compuesta)
CREATE TABLE CLUB_JUGADOR (
    cod_club        NUMBER(6) NOT NULL,
    cod_inscripcion NUMBER(8) NOT NULL,
    fecha_inicio    DATE      NOT NULL,
    fecha_termino   DATE,
    CONSTRAINT PK_club_jugador PRIMARY KEY (cod_club, cod_inscripcion),
    CONSTRAINT FK_cj_club    FOREIGN KEY (cod_club)        REFERENCES CLUB_FUTBOL (cod_club),
    CONSTRAINT FK_cj_jugador FOREIGN KEY (cod_inscripcion) REFERENCES JUGADOR (cod_inscripcion)
);

-- Tabla puente: idiomas que domina un jugador (PK compuesta)
CREATE TABLE JUGADOR_IDIOMA (
    cod_idioma      NUMBER(4) NOT NULL,
    cod_inscripcion NUMBER(8) NOT NULL,
    nivel_dominio   NUMBER(2),
    CONSTRAINT PK_jugador_idioma PRIMARY KEY (cod_idioma, cod_inscripcion),
    CONSTRAINT FK_ji_idioma  FOREIGN KEY (cod_idioma)      REFERENCES IDIOMA (cod_idioma),
    CONSTRAINT FK_ji_jugador FOREIGN KEY (cod_inscripcion) REFERENCES JUGADOR (cod_inscripcion)
);

-- Tabla puente: formacion escolar del jugador (PK compuesta)
CREATE TABLE FORMACION (
    cod_escuela      NUMBER(5) NOT NULL,
    cod_inscripcion  NUMBER(8) NOT NULL,
    anio_amateurismo NUMBER(4),
    CONSTRAINT PK_formacion PRIMARY KEY (cod_escuela, cod_inscripcion),
    CONSTRAINT FK_form_escuela FOREIGN KEY (cod_escuela)     REFERENCES ESCUELA (cod_escuela),
    CONSTRAINT FK_form_jugador FOREIGN KEY (cod_inscripcion) REFERENCES JUGADOR (cod_inscripcion)
);

-- ============================================================================
-- FASE 3 - POBLAMIENTO (DML)
-- Orden de dependencia: REGION -> COMUNA -> ASOCIACION -> NACIONALIDAD -> CLUB_FUTBOL
-- ============================================================================

-- REGION (se incluyen las regiones 8 y 16, requeridas por las comunas)
INSERT INTO REGION (cod_region, nombre_region) VALUES (1,  'ARICA Y PARINACOTA Y TARAPACA');
INSERT INTO REGION (cod_region, nombre_region) VALUES (2,  'ANTOFAGASTA');
INSERT INTO REGION (cod_region, nombre_region) VALUES (3,  'ATACAMA Y COQUIMBO');
INSERT INTO REGION (cod_region, nombre_region) VALUES (5,  'VALPARAISO');
INSERT INTO REGION (cod_region, nombre_region) VALUES (8,  'BIOBIO');
INSERT INTO REGION (cod_region, nombre_region) VALUES (13, 'METROPOLITANA');
INSERT INTO REGION (cod_region, nombre_region) VALUES (16, 'NUBLE');

-- COMUNA
INSERT INTO COMUNA (cod_comuna, nombre_comuna, cod_region) VALUES (101, 'Santiago',    13);
INSERT INTO COMUNA (cod_comuna, nombre_comuna, cod_region) VALUES (102, 'Valparaiso',   5);
INSERT INTO COMUNA (cod_comuna, nombre_comuna, cod_region) VALUES (103, 'Concepcion',   8);
INSERT INTO COMUNA (cod_comuna, nombre_comuna, cod_region) VALUES (104, 'Antofagasta',  2);
INSERT INTO COMUNA (cod_comuna, nombre_comuna, cod_region) VALUES (105, 'Chillan',     16);

-- ASOCIACION
INSERT INTO ASOCIACION (cod_asociacion, nombre_asociacion, fecha_creacion, tipo_asociacion) VALUES (25, 'Asociacion de Futbol de Santiago',      DATE '2001-05-15', 'P');
INSERT INTO ASOCIACION (cod_asociacion, nombre_asociacion, fecha_creacion, tipo_asociacion) VALUES (26, 'Asociacion Nacional de Futbol Amateur', DATE '1998-03-10', 'A');
INSERT INTO ASOCIACION (cod_asociacion, nombre_asociacion, fecha_creacion, tipo_asociacion) VALUES (27, 'Asociacion de Futbol de Valparaiso',    DATE '1987-07-21', 'P');
INSERT INTO ASOCIACION (cod_asociacion, nombre_asociacion, fecha_creacion, tipo_asociacion) VALUES (28, 'Asociacion de Futbol de Concepcion',    DATE '1995-11-30', 'A');
INSERT INTO ASOCIACION (cod_asociacion, nombre_asociacion, fecha_creacion, tipo_asociacion) VALUES (29, 'Asociacion de Futbol de Antofagasta',   DATE '2003-06-25', 'P');
INSERT INTO ASOCIACION (cod_asociacion, nombre_asociacion, fecha_creacion, tipo_asociacion) VALUES (30, 'Asociacion de Futbol de Temuco',        DATE '2010-01-12', 'A');
INSERT INTO ASOCIACION (cod_asociacion, nombre_asociacion, fecha_creacion, tipo_asociacion) VALUES (31, 'Asociacion de Futbol de Rancagua',      DATE '1999-09-08', 'A');
INSERT INTO ASOCIACION (cod_asociacion, nombre_asociacion, fecha_creacion, tipo_asociacion) VALUES (32, 'Asociacion de Futbol de Puerto Montt',  DATE '2005-04-20', 'P');
INSERT INTO ASOCIACION (cod_asociacion, nombre_asociacion, fecha_creacion, tipo_asociacion) VALUES (33, 'Asociacion de Futbol de La Serena',     DATE '2012-08-14', 'P');
INSERT INTO ASOCIACION (cod_asociacion, nombre_asociacion, fecha_creacion, tipo_asociacion) VALUES (34, 'Asociacion de Futbol de Chillan',       DATE '2018-12-01', 'A');

-- NACIONALIDAD (la columna IDENTITY genera 210, 212, 214, 216, 218)
INSERT INTO NACIONALIDAD (nombre_nacionalidad) VALUES ('Chilena');
INSERT INTO NACIONALIDAD (nombre_nacionalidad) VALUES ('Argentina');
INSERT INTO NACIONALIDAD (nombre_nacionalidad) VALUES ('Peruana');
INSERT INTO NACIONALIDAD (nombre_nacionalidad) VALUES ('Boliviana');
INSERT INTO NACIONALIDAD (nombre_nacionalidad) VALUES ('Brasilena');

-- CLUB_FUTBOL (la secuencia genera 703, 707, 711, 715, 719)
INSERT INTO CLUB_FUTBOL (cod_club, nombre_club, patrimonio, direccion_club, tipo_club, cod_comuna) VALUES (seq_club_futbol.NEXTVAL, 'Colo-Colo',            500000000, 'Av. Marathon 5300',                'Profesional', 101);
INSERT INTO CLUB_FUTBOL (cod_club, nombre_club, patrimonio, direccion_club, tipo_club, cod_comuna) VALUES (seq_club_futbol.NEXTVAL, 'Universidad de Chile', 450000000, 'Av. El Parron 0931',               'Profesional', 101);
INSERT INTO CLUB_FUTBOL (cod_club, nombre_club, patrimonio, direccion_club, tipo_club, cod_comuna) VALUES (seq_club_futbol.NEXTVAL, 'Deportes Antofagasta', 180000000, 'Avenida Angamos 01606',            'Profesional', 104);
INSERT INTO CLUB_FUTBOL (cod_club, nombre_club, patrimonio, direccion_club, tipo_club, cod_comuna) VALUES (seq_club_futbol.NEXTVAL, 'Huachipato',           220000000, 'Avenida Desiderio Garcia 909',     'Profesional', 103);
INSERT INTO CLUB_FUTBOL (cod_club, nombre_club, patrimonio, direccion_club, tipo_club, cod_comuna) VALUES (seq_club_futbol.NEXTVAL, 'Nublense',             170000000, 'Avenida Pedro Aguirre Cerda 1003', 'Profesional', 105);

COMMIT;

-- ============================================================================
-- FASE 4 - RECUPERACION DE DATOS (SELECT)
-- ============================================================================

-- INFORME 1: Asociaciones de futbol profesional (P) creadas despues del ano 2000,
--            ordenadas de forma descendente por fecha de creacion.
SELECT cod_asociacion                        AS "Codigo",
       nombre_asociacion                     AS "Asociacion",
       TO_CHAR(fecha_creacion, 'DD/MM/YYYY') AS "Fecha Creacion",
       tipo_asociacion                       AS "Tipo"
FROM   ASOCIACION
WHERE  tipo_asociacion = 'P'
AND    fecha_creacion > DATE '2000-12-31'
ORDER BY fecha_creacion DESC;

-- INFORME 2: Patrimonio de clubes en pesos y en dolares (1 USD = $955),
--            solo clubes profesionales cuyo nombre contenga la letra 'a' y
--            cuyo patrimonio supere los $200.000.000, ordenados por codigo DESC.
SELECT cod_club                   AS "Codigo",
       nombre_club                AS "Club",
       patrimonio                 AS "Patrimonio (CLP)",
       ROUND(patrimonio / 955, 2) AS "Patrimonio (USD)"
FROM   CLUB_FUTBOL
WHERE  LOWER(nombre_club) LIKE '%a%'
AND    patrimonio > 200000000
AND    tipo_club = 'Profesional'
ORDER BY cod_club DESC;
