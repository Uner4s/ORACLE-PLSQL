create or replace procedure PRO_MANT_TCARRERA(p_codigo varchar2, p_nombre_tipo_carrera varchar2, p_trans varchar2) is
v_codigo_error number;
v_mensaje_error varchar(100);
ex_largo_parametro exception;

begin

  case
    when upper(p_trans) = 'C' then
      if length(p_codigo) > 4 then
        raise ex_largo_parametro;
      elsif length(p_nombre_tipo_carrera) > 50 then
        raise ex_largo_parametro;
      end if;
      insert into tcarrera (tcar_cod,tcar_nombre) values (p_codigo, upper(p_nombre_tipo_carrera));
      commit;

    when upper(p_trans) = 'E' then
      delete from tcarrera
      where tcar_cod = p_codigo;
      commit;

      when upper(p_trans) = 'A' then
        if length(p_nombre_tipo_carrera) > 50 then
          raise ex_largo_parametro;
        end if;
        UPDATE tcarrera 
        SET tcar_nombre = upper(p_nombre_tipo_carrera) WHERE tcar_cod = p_codigo;
        commit;
  end case;
    
exception 

  when dup_val_on_index then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_TCARRERA',sysdate);
    commit;
    raise_application_error(v_codigo_error,v_mensaje_error);

  when ex_largo_parametro then
    v_codigo_error := -20899;
    v_mensaje_error := 'El largo de algun parametro ingresado es inválido(Codigo o nombre) ';
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_TCARRERA',sysdate);
    commit;
    raise_application_error(v_codigo_error,v_mensaje_error);

  when others then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_TCARRERA',sysdate);
    dbms_output.put_line('error '|| v_codigo_error || ': ' || v_mensaje_error );
    commit;
end;



create or replace procedure PRO_MANT_FACULTAD(p_codigo varchar2, p_nombre_facultad  varchar2, p_presup number , p_trans varchar2) is
v_codigo_error number;
v_mensaje_error varchar(100);
ex_fac_existente exception;
ex_fac_presupalto exception;

begin

  case
    when upper(p_trans) = 'C' then
      if p_presup > 700000000 then
        raise ex_fac_presupalto;
      end if;
      insert into facultad values (p_codigo,p_nombre_facultad,p_presup);
      commit;
   
    when upper(p_trans) = 'E' then
      delete from facultad
      where fac_cod = p_codigo;
      commit;
         
    when upper(p_trans) = 'A' then
      if p_presup > 700000000 then
        raise ex_fac_presupalto;
      else
        UPDATE facultad 
        SET fac_nombre = p_nombre_facultad, fac_presup = p_presup
        WHERE fac_cod = p_codigo;
        commit;   
      end if;

  end case;

exception 
        
    
  when ex_fac_presupalto then
    v_codigo_error := -20301;
    v_mensaje_error := 'El presupuesto a excedido los $700.000.000';  
    INSERT INTO AUX_ERROR VALUES (v_codigo_error,v_mensaje_error,upper(p_trans),'PRO_MANT_FACULTAD',sysdate);
    commit;
    raise_application_error(v_codigo_error,v_mensaje_error);

  when dup_val_on_index then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;   
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error), v_mensaje_error,upper(p_trans),'PRO_MANT_FACULTAD',sysdate);
    dbms_output.put_line('error '|| v_codigo_error || ': ' || v_mensaje_error );
    commit;
    
  when others then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_FACULTAD',sysdate);
    dbms_output.put_line('error '|| v_codigo_error || ': ' || v_mensaje_error );
    commit;

end;



create or replace procedure PRO_MANT_DEPARTAMENTO(p_codigo varchar2, p_nombre_departamento varchar2,p_frac_resp varchar2, p_trans varchar2) is

v_codigo_error number;
v_mensaje_error varchar(100);
ex_dep_existente exception;
v_comprobar_nombre number;

begin

  case
    when upper(p_trans) = 'C' then
      insert into departamento values (p_codigo,p_nombre_departamento,p_frac_resp);
      commit;

    when upper(p_trans) = 'E' then
      delete from departamento
      where dep_cod = p_codigo;
      commit;

    when upper(p_trans) = 'A' then
      UPDATE departamento 
      SET dep_nombre = p_nombre_departamento, dep_fac = p_frac_resp WHERE dep_cod = p_codigo;
      commit;
  end case;
    
exception 

  when dup_val_on_index then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;
    INSERT INTO AUX_ERROR VALUES(to_char(v_codigo_error),v_mensaje_error, upper(p_trans),'PRO_MANT_DEPARTAMENTO',sysdate);
    dbms_output.put_line('error '|| v_codigo_error || ': ' || v_mensaje_error );
    commit;

  when others then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_DEPARTAMENTO',sysdate);
    dbms_output.put_line('error '|| v_codigo_error || ': ' || v_mensaje_error );
    commit;


end;



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
      commit;

    when upper(p_trans) = 'E' then
      delete from carrera
      where car_cod = p_codigo;
      commit;

    when upper(p_trans) = 'A' then
      select count(car_cod) into v_comprobar_nombre from carrera
      where upper(car_nombre) = upper(p_nombre_carrera);  
      if v_comprobar_nombre != 0 then
        raise ex_car_existente;
      end if;
      UPDATE carrera 
      SET car_nombre = p_nombre_carrera, car_depto = upper(p_dep_resp), car_tipo = upper(p_tipo_carrera) 
      WHERE car_cod = p_codigo;
      commit;

  end case;

exception 

  when ex_car_existente then
    v_codigo_error := -20300;
    v_mensaje_error := 'El nombre  ingresado ya se encuentra en la tabla CARRERA';
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_DEPARTAMENTO',sysdate);
    commit;
    raise_application_error(v_codigo_error,v_mensaje_error);

  when ex_codigo_invalido then
    v_codigo_error := -20700;
    v_mensaje_error := 'El codigo ingresado no cumple con los requisitos';
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_DEPARTAMENTO',sysdate);
    commit;
    raise_application_error(v_codigo_error,v_mensaje_error);

  when dup_val_on_index then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;
    INSERT INTO AUX_ERROR VALUES(to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_DEPARTAMENTO',sysdate);
    dbms_output.put_line('error '|| v_codigo_error || ': ' || v_mensaje_error );
    commit;

  when others then
    v_codigo_error := SQLCODE;
    v_mensaje_error := SQLERRM;
    INSERT INTO AUX_ERROR VALUES (to_char(v_codigo_error),v_mensaje_error,upper(p_trans),'PRO_MANT_DEPARTAMENTO',sysdate);
    dbms_output.put_line('error '|| v_codigo_error || ': ' || v_mensaje_error );
    commit;

end;
  

