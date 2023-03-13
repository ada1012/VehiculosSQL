create or replace procedure alquilar(arg_NIF_cliente varchar,
  arg_matricula varchar, arg_fecha_ini date, arg_fecha_fin date) is
begin
    if arg_fecha_fin < arg_fecha_ini then
        raise_application_error(-20003, 'El numero de dias sera mayor que 0');
    end if;
end;
/

set serveroutput on
exec test_alquila_coches;