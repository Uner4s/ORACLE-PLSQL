1)

CREATE OR REPLACE TRIGGER TRI_CTL_HORARIO_CARRERA
BEFORE 
INSERT OR DELETE 
ON CARRERA
FOR EACH ROW
BEGIN
  if to_char(sysdate,'D') not between 1 and 5 then
    if inserting then
      RAISE_APPLICATION_ERROR(-20002,'No está autorizado para crear carreras fuera del horario de oficina');
    elsif deleting then
      RAISE_APPLICATION_ERROR(-20003,'No está autorizado para eliminar carreras fuera del horario de oficina');
    end if;
  elsif to_char(sysdate,'HH24:MI') not between '09:00' and '18:00' then
    if inserting then
      RAISE_APPLICATION_ERROR(-20002,'No está autorizado para crear carreras fuera del horario de oficina');
    elsif deleting then
      RAISE_APPLICATION_ERROR(-20003,'No está autorizado para eliminar carreras fuera del horario de oficina');
    end if;  
  end if;
END;

2)

creacion de la tabla AUD_ALUMNO

CREATE TABLE AUD_ALUMNO
( AUD_ALU_RUN number(8) NOT NULL,
  AUD_TIPO_TRANS varchar2(1) NOT NULL,
  AUD_USUARIO varchar2(20) NOT NULL,
  AUD_IP varchar(15) NOT NULL,
  AUD_FECHA date NOT NULL
);
COMMENT ON COLUMN AUD_ALUMNO.AUD_ALU_RUN IS 'Run del alumno auditado.';
COMMENT ON COLUMN AUD_ALUMNO.AUD_TIPO_TRANS IS 'Tipo de transacción (I: insert, D: delete, U: update).';
COMMENT ON COLUMN AUD_ALUMNO.AUD_USUARIO IS 'Usuario (esquema) que ejecuta la transacción.';
COMMENT ON COLUMN AUD_ALUMNO.AUD_IP IS 'IP';
COMMENT ON COLUMN AUD_ALUMNO.AUD_FECHA IS 'Fecha de ejecución de la transacción .';

COMMENT ON TABLE AUD_ALUMNO IS 'Registra la auditoría de transacciones sobre la tabla alumno.';


CREATE OR REPLACE TRIGGER TRI_AUD_ALUMNO
BEFORE 
INSERT OR UPDATE OR DELETE 
ON ALUMNO
FOR EACH ROW
BEGIN
  if inserting then
    if INSTR(:new.alu_email,'@usach.cl') = 0 then
      RAISE_APPLICATION_ERROR(-20005,'El e-mail para el alumno run '|| :new.alu_run || ' ' ||:new.alu_ap_pat ||' '|| :new.alu_ap_mat ||' '|| :new.alu_nombres ||' '|| 'no esta permitido');
    else
      INSERT INTO AUD_ALUMNO
      VALUES (:new.alu_run,'I',user, sys_context ('userenv', 'ip_address'), sysdate);
    end if;
  
  elsif updating then
    if INSTR(:new.alu_email,'@usach.cl') = 0 then
      RAISE_APPLICATION_ERROR(-20005,'El e-mail para el alumno run '|| :new.alu_run || ' ' ||:new.alu_ap_pat ||' '|| :new.alu_ap_mat ||' '|| :new.alu_nombres ||' '|| 'no esta permitido');
    else
      INSERT INTO AUD_ALUMNO
      VALUES (:old.alu_run,'U',user, sys_context ('userenv', 'ip_address'), sysdate);
    end if;    
  elsif deleting then
      INSERT INTO AUD_ALUMNO
      VALUES (:old.alu_run,'D',user, sys_context ('userenv', 'ip_address'), sysdate);
  end if;
END;

3)

ALTER TABLE CARRERA ADD (CAR_VACANTE number(2) NULL);
COMMENT ON COLUMN CARRERA.CAR_VACANTE IS 'Vacantes disponibles';

CREATE OR REPLACE TRIGGER TRI_REBAJA_VACANTE
AFTER
INSERT ON ALU_CAR
FOR EACH ROW
BEGIN
  UPDATE CARRERA SET car_vacante = nvl(car_vacante,0) - 1
  WHERE car_cod = :new.aca_car;
END;

4)

CREATE OR REPLACE TRIGGER TRI_AUMENTA_VACANTE
AFTER
DELETE ON ALU_CAR
FOR EACH ROW
BEGIN
  UPDATE CARRERA SET car_vacante = nvl(car_vacante,0) + 1
  WHERE car_cod = :old.aca_car;
END;

5)

ALTER TRIGGER TRI_REBAJA_VACANTE DISABLE;
ALTER TRIGGER TRI_AUMENTA_VACANTE DISABLE;

CREATE OR REPLACE TRIGGER TRI_CTL_VACANTE
AFTER
INSERT OR DELETE ON ALU_CAR
FOR EACH ROW
BEGIN
  if inserting then
    UPDATE CARRERA SET car_vacante = nvl(car_vacante,0) - 1
    WHERE car_cod = :new.aca_car;
  elsif deleting then
    UPDATE CARRERA SET car_vacante = nvl(car_vacante,0) + 1
    WHERE car_cod = :old.aca_car;  
  end if;
END;

6)

ALTER TRIGGER TRI_CTL_VACANTE DISABLE;


CREATE OR REPLACE TRIGGER TRI_CTL_CARRERA_VACANTE
AFTER
INSERT OR DELETE ON ALU_CAR
FOR EACH ROW

DECLARE
v_vacantes_disponibles carrera.car_vacante%type;
v_nombres alumno.alu_nombres%type;
v_ap_pat alumno.alu_ap_pat%type;
v_ap_mat alumno.alu_ap_mat%type;
v_carrera carrera.car_nombre%type;
e_vacantes_no_disponibles exception;
BEGIN
  IF inserting then
    select car_vacante into v_vacantes_disponibles
    from CARRERA
    where car_cod = :new.aca_car;
    
    if v_vacantes_disponibles = 0 then
      select alu_nombres, alu_ap_pat, alu_ap_mat, car_nombre into v_nombres, v_ap_pat, v_ap_mat, v_carrera
      from carrera, alumno
      where :new.aca_run = alu_run and
            :new.aca_car = car_cod;
      raise e_vacantes_no_disponibles;
    end if;
    
    UPDATE CARRERA SET car_vacante = nvl(car_vacante,0) - 1
    WHERE car_cod = :new.aca_car;
    
  ELSIF deleting then
    UPDATE CARRERA SET car_vacante = nvl(car_vacante,0) + 1
    WHERE car_cod = :old.aca_car;  
  END IF;
  
EXCEPTION
  when e_vacantes_no_disponibles then
    RAISE_APPLICATION_ERROR(-20010, 'No es posible ingresar al alumno run '||:new.aca_run||' '||v_ap_pat||' '||v_ap_mat||' '||v_nombres||' en la carrera '|| v_carrera ||' porque no hay vacantes disponibles.');
END;

