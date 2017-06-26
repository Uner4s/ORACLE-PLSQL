creacion de la tabla AUX_ERROR

CREATE TABLE AUX_ERROR
( AUX_COD varchar2(20) NOT NULL,
  AUX_DESCRIP varchar2(100) NOT NULL,
  AUX_TRANS varchar2(1) NOT NULL,
  AUX_PROC varchar(50) NOT NULL,
  AUX_FECHA date NOT NULL
);
COMMENT ON COLUMN AUX_ERROR.AUX_COD  IS 'Código de error.';
COMMENT ON COLUMN AUX_ERROR.AUX_DESCRIP  IS 'Descripción del error.';
COMMENT ON COLUMN AUX_ERROR.AUX_TRANS  IS 'Tipo de transacción (́A ́,  ́E ́,  ́C ́)que origina el error.';
COMMENT ON COLUMN AUX_ERROR.AUX_PROC  IS 'Nombre del procedimiento donde se genera el error.';
COMMENT ON COLUMN AUX_ERROR.AUX_FECHA  IS 'Fecha de generación del error.';

COMMENT ON TABLE AUX_ERROR IS 'Registro de errores de transacciones en tablas básicas';

1.

create or replace procedure PRO_MANT_TCARRERA(p_codigo varchar2, p_nombre_tipo_carrera varchar2, p_trans varchar2) is
v_codigo_error number;
v_mensaje_error varchar(100);
ex_nombre_existente exception;
v_comprobar_nombre number;
begin

  case
    when upper(p_trans) = 'C' then
      select count(tcar_nombre) into v_comprobar_nombre from tcarrera
      where tcar_nombre = upper(p_nombre_tipo_carrera);  
      if v_comprobar_nombre != 0 then
        raise ex_nombre_existente;
      end if;
      insert into tcarrera (tcar_cod,tcar_nombre) values (p_codigo,upper(p_nombre_tipo_carrera));
      
    when upper(p_trans) = 'E' then
      delete from tcarrera
      where tcar_cod = p_codigo;  

    when upper(p_trans) = 'A' then
      select count(tcar_nombre) into v_comprobar_nombre from tcarrera
      where tcar_nombre = upper(p_nombre_tipo_carrera);
      if v_comprobar_nombre != 0 then
        raise ex_nombre_existente;
      end if;
      UPDATE tcarrera SET tcar_nombre = upper(p_nombre_tipo_carrera) WHERE tcar_cod = p_codigo;
  end case;
    
exception 
  when ex_nombre_existente then
    INSERT INTO AUX_ERROR VALUES ('-20300','El nombre del tipo de carrera ingresado ya se encuentra en la tabla TCARRERA',upper(p_trans),'PRO_MANT_TCARRERA',sysdate);
  when dup_val_on_index then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_TCARRERA',sysdate);
  when others then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_TCARRERA',sysdate);
end;

begin 
PRO_MANT_TCARRERA('ASDASDASDA','asdasdasdasdas','C');
end;

2

create or replace procedure PRO_MANT_FACULTAD(p_codigo varchar2, p_nombre_facultad  varchar2, p_presup number , p_trans varchar2) is
v_codigo_error number;
v_mensaje_error varchar(100);
ex_fac_existente exception;
ex_fac_presupalto exception;
v_comprobar_nombre number;
begin
  case
    when upper(p_trans) = 'C' then
      select count(fac_cod) into v_comprobar_nombre from facultad
      where upper(fac_nombre) = upper(p_nombre_facultad);  
      if v_comprobar_nombre != 0 then
        raise ex_fac_existente;
      end if;
      if p_presup > 700000000 then
        raise ex_fac_presupalto;
      end if;
      insert into facultad values (p_codigo,p_nombre_facultad,p_presup);
      
    when upper(p_trans) = 'E' then
      delete from facultad
      where fac_cod = p_codigo and
            fac_nombre = p_nombre_facultad;
            
    when upper(p_trans) = 'A' then
      select count(fac_cod) into v_comprobar_nombre from facultad
      where upper(fac_nombre) = upper(p_nombre_facultad);  
      if p_presup > 700000000 then
        raise ex_fac_presupalto;
      else
        UPDATE facultad SET fac_nombre = p_nombre_facultad, fac_presup = p_presup WHERE fac_cod = p_codigo;   
      end if;
  end case;
  
  exception 
    when ex_fac_existente then
      INSERT INTO AUX_ERROR VALUES ('-20300','El nombre de la facultad ingresado ya se encuentra en la tabla FACULTAD',upper(p_trans),'PRO_MANT_FACULTAD',sysdate);
    
    when ex_fac_presupalto then
      INSERT INTO AUX_ERROR VALUES ('-20301','El presupuesto a excedido los $700.000.000',upper(p_trans),'PRO_MANT_FACULTAD',sysdate);
   
    when dup_val_on_index then
      v_codigo_error := SQLCODE;
      v_mensaje_error := SQLERRM;
      INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_FACULTAD',sysdate);
    
    when others then
      v_codigo_error := SQLCODE;
      v_mensaje_error := SQLERRM;
      INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_FACULTAD',sysdate);
end;


3


create or replace procedure PRO_MANT_DEPARTAMENTO(p_codigo varchar2, p_nombre_departamento varchar2,p_frac_resp varchar2, p_trans varchar2) is
v_codigo_error number;
v_mensaje_error varchar(100);
ex_dep_existente exception;
v_comprobar_nombre number;
begin
  case
    when upper(p_trans) = 'C' then
      select count(dep_cod) into v_comprobar_nombre from departamento
      where upper(dep_nombre) = upper(p_nombre_departamento);  
      if v_comprobar_nombre != 0 then
        raise ex_dep_existente;
      end if;
      insert into departamento values (p_codigo,p_nombre_departamento,p_frac_resp);
      
    when upper(p_trans) = 'E' then
      delete from departamento
      where upper(dep_cod) = upper(p_codigo) and
            upper(dep_nombre) = upper(p_nombre_departamento);


    when upper(p_trans) = 'A' then
      select count(dep_cod) into v_comprobar_nombre from departamento
      where upper(dep_nombre) = upper(p_nombre_departamento);  
      if v_comprobar_nombre != 0 then
        raise ex_dep_existente;
      end if;
      UPDATE departamento SET dep_nombre = p_nombre_departamento, dep_fac = p_frac_resp WHERE dep_cod = p_codigo;
  end case;
    
exception 
  when ex_dep_existente then
    INSERT INTO AUX_ERROR VALUES ('-20300','El nombre del departamento ingresado ya se encuentra en la tabla DEPARTAMENTO',upper(p_trans),'PRO_MANT_DEPARTAMENTO',sysdate);
  when dup_val_on_index then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_DEPARTAMENTO',sysdate);
  when others then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_DEPARTAMENTO',sysdate);
end;

begin 
PRO_MANT_DEPARTAMENTO('DOBT','Departamento de Obstetricia','FMED','E');
end;


4



create or replace procedure PRO_MANT_CARRERA(p_codigo number, p_nombre_carrera varchar2,p_dep_resp varchar2,p_tipo_carrera varchar2, p_trans varchar2) is
v_codigo_error number;
v_mensaje_error varchar(100);
ex_car_existente exception;
ex_codigo_invalido exception;
v_comprobar_nombre number;
begin
  case
    when upper(p_trans) = 'C' then
      select count(car_cod) into v_comprobar_nombre from carrera
      where upper(car_nombre) = upper(p_nombre_carrera);  
      if v_comprobar_nombre != 0 then
        raise ex_car_existente; 
      elsif p_codigo < 1000 or p_codigo > 9999 then
        raise ex_codigo_invalido;
      end if;
      insert into carrera values (p_codigo,p_nombre_carrera,upper(p_dep_resp),upper(p_tipo_carrera));
    when upper(p_trans) = 'E' then
      delete from carrera
      where car_cod = p_codigo;
    when upper(p_trans) = 'A' then
      select count(car_cod) into v_comprobar_nombre from carrera
      where upper(car_nombre) = upper(p_nombre_carrera);  
      if v_comprobar_nombre != 0 then
        raise ex_car_existente;
      end if;
      UPDATE carrera SET car_nombre = p_nombre_carrera, car_depto = upper(p_dep_resp), car_tipo = upper(p_tipo_carrera) WHERE car_cod = p_codigo;
  end case;
exception 
  when ex_car_existente then
    INSERT INTO AUX_ERROR VALUES ('-20300','El nombre  ingresado ya se encuentra en la tabla CARRERA',upper(p_trans),'PRO_MANT_DEPARTAMENTO',sysdate);
  when ex_codigo_invalido then
    INSERT INTO AUX_ERROR VALUES ('-20700','El codigo ingresado no cumple con los requisitos',upper(p_trans),'PRO_MANT_DEPARTAMENTO',sysdate);
  when dup_val_on_index then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_DEPARTAMENTO',sysdate);
  when others then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_DEPARTAMENTO',sysdate);
end;

begin 
PRO_MANT_CARRERA(4501,'ingenieria civil mecanica','DMEC','PREG','E');
end;