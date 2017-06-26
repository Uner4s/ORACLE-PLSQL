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
  end loop;
  commit;
end;

begin
  PRO_ACT_PRESUP_FAC;
end;