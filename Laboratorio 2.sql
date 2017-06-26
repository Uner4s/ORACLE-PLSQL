1.1

CREATE TABLE TCARRERA
( TCAR_COD varchar2(4) NOT NULL,
  TCAR_NOMBRE varchar2(50) NOT NULL,
  CONSTRAINT TCAR_COD PRIMARY KEY (TCAR_COD)
);
COMMENT ON COLUMN "BDATOS"."TCARRERA"."TCAR_COD"
IS
  'Código';
  COMMENT ON COLUMN "BDATOS"."TCARRERA"."TCAR_NOMBRE"
IS
  'Nombre';
  COMMENT ON TABLE "BDATOS"."TCARRERA"
IS
  'tipos de carrera';


1.2

ALTER TABLE TCARRERA ADD CONSTRAINT TCAR_NOMBRE  
CHECK(TCAR_NOMBRE=upper(TCAR_NOMBRE))

1.3

-------------------------
ALTER TABLE CARRERA ADD CAR_TIPO varchar2(4) default 'PREG' NOT NULL;

COMMENT ON COLUMN "CARRERA"."CAR_TIPO"
IS
  'Tipo de carrera';
-------------------------
  
ALTER TABLE CARRERA
ADD CONSTRAINT FK_CAR_TIPO
  FOREIGN KEY (CAR_TIPO)
  REFERENCES TCARRERA(TCAR_COD);


1.4

poblamiento tabla nueva

--------
INSERT INTO TCARRERA (TCAR_COD,TCAR_NOMBRE) VALUES ('PREG','PREGRADO');
INSERT INTO TCARRERA (TCAR_COD,TCAR_NOMBRE) VALUES ('POSG','POSTGRADO');
INSERT INTO TCARRERA (TCAR_COD,TCAR_NOMBRE) VALUES ('DIPL','DIPLOMADO');
--------

Poblamiento columna nueva

UPDATE CARRERA
SET CAR_TIPO = 'POSG' 
WHERE CAR_COD = '4601';

UPDATE CARRERA
SET CAR_TIPO = 'DIPL'
WHERE CAR_COD = '6534';

UPDATE CARRERA
SET CAR_TIPO = 'POSG'
WHERE CAR_COD = '3001';

UPDATE CARRERA
SET CAR_TIPO = 'PREG' 
WHERE CAR_COD = '4501';

UPDATE CARRERA
SET CAR_TIPO = 'DIPL' 
WHERE CAR_COD = '7410';

UPDATE CARRERA
SET CAR_TIPO = 'PREG'
WHERE CAR_COD = '5741';

UPDATE CARRERA
SET CAR_TIPO = 'DIPL'
WHERE CAR_COD = '2356';

------

2.1

create or replace function FUN_NRO_ALU_CAR (v_codigo number(4)) return number is
v_cantidad number;
begin
  select count(ACA_RUN) into v_cantidad
  from ALU_CAR
  where ACA_CAR = v_codigo;
  
  return v_cantidad;
end;

select FUN_NRO_ALU_CAR(2356) from dual;


2.2

create or replace function FUN_MAYOR_ING_CAR (v_codigo number) return number is
cursor c_años is select aca_agno from alu_car where aca_car = v_codigo group by aca_agno order by aca_agno asc;
v_cantidad number;
v_año number(4);
v_cantidad_aux number := 0;
v_año_aux number(4);
begin

  for v_año in c_años loop
    select count(aca_run) into v_cantidad
    from alu_car
    where aca_agno = v_año.aca_agno and 
          aca_car = v_codigo;
    
    if v_cantidad > v_cantidad_aux then
      v_cantidad_aux := v_cantidad;
      v_año_aux := v_año.aca_agno;
    end if;
  
  end loop;
   return v_año_aux;
end;

select FUN_MAYOR_ING_CAR(3001) from dual; 

2.3

create or replace function FUN_NRO_MAT_CAR (v_codigo number(4)) return number is
v_cantidad number;
begin
    select count(aca_run)
    into v_cantidad
    from alu_car, dual
    where to_char(sysdate,'yyyy') = to_char(aca_fecha,'yyyy') and
          v_codigo = aca_car;
  
    return v_cantidad;
end;

select fun_nro_mat_car(3001) from dual; 


2.4

create or replace function FUN_AGNOS_MAT_CAR (v_codigo number(4)) return number is
v_fecha_minima date;
v_fecha_maxima date;
v_años number;
begin
  select max(aca_fecha), min(aca_fecha)
  into  v_fecha_maxima, v_fecha_minima
  from alu_car
  where v_codigo = aca_car;
  
  v_años := to_char(v_fecha_maxima,'yyyy') - to_char(v_fecha_minima,'yyyy');
  return v_años;
end;

select FUN_AGNOS_MAT_CAR(3001) from dual; 



3

3.1

create or replace procedure PRO_ACT_PRESUP_FAC is
v_presupuesto number(10);
v_cantidad number;
begin
  for v_facultad_cod in (select * from facultad)
  loop
    select count(aca_run) into v_cantidad
    from alu_car, facultad, departamento, carrera
    where v_facultad_cod.fac_cod = fac_cod and
          fac_cod = dep_fac and
          dep_cod = car_depto and
          car_cod = aca_car and
          to_char(aca_fecha,'yyyy') = to_char(sysdate,'yyyy');
    
    if v_cantidad > 60 then
      v_presupuesto := v_facultad_cod.fac_presup * 1.15;
      UPDATE facultad
      SET fac_presup = v_presupuesto
      WHERE fac_cod = v_facultad_cod.fac_cod;
    end if;
    
    v_cantidad :=0;
  end loop;
end;

begin
  PRO_ACT_PRESUP_FAC;
end;


3.2

create table RESUMEN_CARRERAS(
  RSC_COD_CAR NUMBER(4) NOT NULL,
  RSC_NOM_CAR VARCHAR2(100) NOT NULL,
  RSC_NRO_ALU NUMBER (10) NOT NULL,
  RSC_MAYOR_ING NUMBER(10) NOT NULL,
  RSC_NRO_MAT NUMBER (6)NOT NULL,
  RSC_AGNOS_MAT NUMBER(2)NOT NULL,
  RSC_USUARIO VARCHAR2(100)NOT NULL,
  RSC_IP VARCHAR2(15)NOT NULL,
  RSC_FECHA DATE NOT NULL,
  CONSTRAINT PK_RESUMEN_CARRERA PRIMARY KEY(RSC_COD_CAR)
)

COMMENT ON TABLE RESUMEN_CARRERAS IS 'Estadístico de alumnos por carrera';
COMMENT ON COLUMN RESUMEN_CARRERAS.RSC_COD_CAR IS 'Código de la carrera';
COMMENT ON COLUMN RESUMEN_CARRERAS.RSC_NOM_CAR IS 'Nombre de la carrera';
COMMENT ON COLUMN RESUMEN_CARRERAS.RSC_NRO_ALU IS 'Cantidad de alumnos';
COMMENT ON COLUMN RESUMEN_CARRERAS.RSC_MAYOR_ING IS 'Año de ingreso con mayor cantidad de alumnos';
COMMENT ON COLUMN RESUMEN_CARRERAS.RSC_NRO_MAT IS 'Cantidad de alumnos matriculados en el presete año';
COMMENT ON COLUMN RESUMEN_CARRERAS.RSC_AGNOS_MAT IS 'Años transcurridos entre la primera y última matrícula';
COMMENT ON COLUMN RESUMEN_CARRERAS.RSC_USUARIO IS 'Usuario(esquema) que ejecuta procedimieto';
COMMENT ON COLUMN RESUMEN_CARRERAS.RSC_IP IS 'IP';
COMMENT ON COLUMN RESUMEN_CARRERAS.RSC_FECHA IS 'Fecha de ejecución procedimiento';

commit;

create or replace procedure PRO_RESUMEN_CARRERAS is
  v_nro_carrera number(4,0);
  v_nro_agno number(4,0);
  v_num_matriculados number(6,0);
  v_agnos_carreras number(3,0);
  v_ip varchar2(15);
  cursor c_carrera is
  select * from CARRERA;
  reg_carrera c_carrera%rowtype;
begin 
    open c_carrera;
    loop
      fetch c_carrera into reg_carrera;
      exit when c_carrera%notfound;
      Select sys_context ('USERENV' , 'IP_ADDRESS') into v_ip
      FROM DUAL;
      v_nro_carrera:=fun_nro_alu_car(reg_carrera.car_cod);
      v_nro_agno:=fun_mayor_ing_car(reg_carrera.car_cod);
      v_num_matriculados:=fun_nro_mat_car(reg_carrera.car_cod);
      v_agnos_carreras:=fun_agnos_mat_car(reg_carrera.car_cod);
      INSERT INTO RESUMEN_CARRERAS(RSC_COD_CAR, RSC_NOM_CAR, RSC_NRO_ALU, RSC_MAYOR_ING, RSC_NRO_MAT, RSC_AGNOS_MAT, RSC_USUARIO, RSC_IP, RSC_FECHA ) VALUES(reg_carrera.car_cod, reg_carrera.car_nombre, v_nro_carrera, v_nro_agno, v_num_matriculados, v_agnos_carreras, user, v_ip, sysdate);
      dbms_output.put_line(reg_carrera.car_cod||' '||reg_carrera.car_nombre||' '||v_nro_carrera||' '||v_nro_agno||' '||v_num_matriculados||' '||v_agnos_carreras||' '||user||' '|| v_ip ||' '|| sysdate);
     end loop;
    close c_carrera;
    commit;
end PRO_RESUMEN_CARRERAS;