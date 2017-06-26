1.1
1.1.1
SELECT *
FROM V$VERSION
WHERE banner LIKE '%Oracle%';

Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production

1.1.2
SELECT name, created
FROM V$DATABASE;

XE  05/11/15

1.1.3
SELECT num, name
FROM V$PARAMETER
WHERE name = 'processes';

39 processes

1.1.4
SELECT name
FROM V$CONTROLFILE;

C:\ORACLEXE\APP\ORACLE\ORADATA\XE\SYSTEM.DBF
C:\ORACLEXE\APP\ORACLE\ORADATA\XE\SYSAUX.DBF
C:\ORACLEXE\APP\ORACLE\ORADATA\XE\UNDOTBS1.DBF
C:\ORACLEXE\APP\ORACLE\ORADATA\XE\USERS.DBF

extension DBF

--------------------------------------------------------
1.2
1.2.1
SELECT object_type AS objetos, COUNT(*) AS todos
FROM user_objects
GROUP BY object_type
ORDER BY todos DESC;

INDEX 33
TABLE 22
TRIGGER 14
LOB 9
SEQUENCE 5
FUNCTION 2



1.2.2
SELECT user_tab_columns.table_name AS tabla,
user_tab_comments.comments AS descripcion_tabla,
user_tab_columns.column_name AS columna,
user_col_comments.comments AS descripcion_columna,
data_type AS tipo_columna
FROM user_tab_columns
INNER JOIN user_objects ON user_tab_columns.table_name=object_name
AND object_type='TABLE'
INNER JOIN user_col_comments ON user_tab_columns.column_name=user_col_comments.column_name
INNER JOIN user_tab_comments ON user_tab_columns.table_name=user_tab_comments.table_name
ORDER BY user_tab_columns.table_name;

2.1
2.1.1

CREATE TABLE "BDATOS"."ALUMNO"
  (
    "ALU_RUN"     NUMBER(8,0) NOT NULL ENABLE,
    "ALU_NOMBRES" VARCHAR2(20 BYTE) NOT NULL ENABLE,
    "ALU_AP_PAT"  VARCHAR2(20 BYTE) NOT NULL ENABLE,
    "ALU_AP_MAT"  VARCHAR2(20 BYTE) NOT NULL ENABLE,
    "ALU_DIR"     VARCHAR2(100 BYTE) NOT NULL ENABLE,
    "ALU_EMAIL"   VARCHAR2(50 BYTE),
    CONSTRAINT "ALUMNO_PK" PRIMARY KEY ("ALU_RUN") USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE "USERS" ENABLE
  )

CREATE TABLE "BDATOS"."FACULTAD"
  (
    "FAC_COD"    VARCHAR2(4 BYTE) NOT NULL ENABLE,
    "FAC_NOMBRE" VARCHAR2(100 BYTE) NOT NULL ENABLE,
    "FAC_PRESUP" NUMBER(10,0) NOT NULL ENABLE,
    CONSTRAINT "FACULTAD_PK" PRIMARY KEY ("FAC_COD") USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE "USERS" ENABLE
  )

CREATE TABLE "BDATOS"."DEPARTAMENTO"
  (
    "DEP_COD"    VARCHAR2(5 BYTE) NOT NULL ENABLE,
    "DEP_NOMBRE" VARCHAR2(100 BYTE) NOT NULL ENABLE,
    "DEP_FAC"    VARCHAR2(4 BYTE) NOT NULL ENABLE,
    CONSTRAINT "DEPARTAMENTO_PK" PRIMARY KEY ("DEP_COD") USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE "USERS" ENABLE,
    CONSTRAINT "DEPARTAMENTO_FACULTAD_FK1" FOREIGN KEY ("DEP_FAC") REFERENCES "BDATOS"."FACULTAD" ("FAC_COD") ON
  DELETE CASCADE ENABLE
  )

CREATE TABLE "BDATOS"."CARRERA"
  (
    "CAR_COD"    NUMBER(4,0) NOT NULL ENABLE,
    "CAR_NOMBRE" VARCHAR2(100 BYTE) NOT NULL ENABLE,
    "CAR_DEPTO"  VARCHAR2(5 BYTE) NOT NULL ENABLE,
    CONSTRAINT "CARRERA_PK" PRIMARY KEY ("CAR_COD") USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE "USERS" ENABLE,
    CONSTRAINT "CARRERA_DEPARTAMENTO_FK1" FOREIGN KEY ("CAR_DEPTO") REFERENCES "BDATOS"."DEPARTAMENTO" ("DEP_COD") ON
  DELETE CASCADE ENABLE
  )

CREATE TABLE "BDATOS"."ALU_CAR"
  (
    "ACA_RUN"  NUMBER NOT NULL ENABLE,
    "ACA_CAR"  NUMBER(4,0) NOT NULL ENABLE,
    "ACA_AGNO" NUMBER(4,0) NOT NULL ENABLE,
    "ACA_SEM"  NUMBER(1,0) NOT NULL ENABLE,
    "ACA_FECHA" DATE NOT NULL ENABLE,
    CONSTRAINT "ALU_CAR" PRIMARY KEY ("ACA_RUN", "ACA_CAR") USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE "USERS" ENABLE,
    CONSTRAINT "ALU_CAR_CARRERA_FK1" FOREIGN KEY ("ACA_CAR") REFERENCES "BDATOS"."CARRERA" ("CAR_COD") DISABLE,
    CONSTRAINT "ALU_CAR_ALUMNO_FK1" FOREIGN KEY ("ACA_RUN") REFERENCES "BDATOS"."ALUMNO" ("ALU_RUN") DISABLE
  )

2.2.1

Declare
  usuario varchar2(20);
  dias number(3);
Begin
  select user into usuario
  from dual;
  
  dias:= MONTHS_BETWEEN('31/12/2015',sysdate);
  dias:=dias*30;
  dbms_output.put_line('¡hola '||usuario||' quedan ' ||dias||' dias para que termine el año 2015! ');
End;

2.2.2

Declare
  v_num_facultad number(10);
  fecha date;
Begin
  select count(*) into v_num_facultad
  from FACULTAD;
  fecha:=to_date(sysdate,'dd/mm/yyyy');
  
  dbms_output.put_line('¡La tabla FACULTAD tiene '||v_num_facultad||' registros al '||fecha);
End;

2.2.3

Declare
  alumno number(10);
Begin
  select count(ALU_RUN) into alumno
  from ALUMNO
  where ALU_EMAIL IS NULL;
  
  dbms_output.put_line('Actualmente existen '||alumno||' alumnos sin e-mail.');
  
End;

2.2.3

Declare
  presupuesto number(20);
Begin
  select avg(fac_presup) into presupuesto
  from facultad;
  
  dbms_output.put_line('El presupuesto promedio de las facultades es de $'||presupuesto);
  
End;

2.2.4

Declare
  alumnos number(20);
Begin
  select count(aca_run) into alumnos
  from alu_car
  where aca_car = '2356' and
        aca_agno between 1800 and 2015;
  
  dbms_output.put_line('Han ingresado '||alumnos||' alumnos hasta el año 2015');
  
End;

2.2.5

Declare
  impar number(20,0);
  modulo number(20,0);
Begin
  impar:=1;
  WHILE impar < 100 loop
    Select MOD (impar,2) into modulo
    From dual;
    if modulo <> 0 and impar <> 23 and impar <> 57 then
      INSERT INTO TABLA_NUMEROS VALUES(impar);
    end if;
    impar:=impar + 1;

  end loop;
End;

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