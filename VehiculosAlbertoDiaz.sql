create or replace procedure alquilar(arg_NIF_cliente varchar,
  arg_matricula varchar, arg_fecha_ini date, arg_fecha_fin date) is
  l_nombre modelos.nombre%TYPE;
  l_precio_cada_dia modelos.precio_cada_dia%TYPE;
  l_capacidad_deposito modelos.capacidad_deposito%TYPE;
  l_tipo_combustible modelos.tipo_combustible%TYPE;
  l_precio_por_litro precio_combustible.precio_por_litro%TYPE;
  
  e_parent_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_parent_not_found, -2291);
  
  cursor c1 is 
    select * from reservas;

  c1_values c1%ROWTYPE;
begin
  if arg_fecha_fin < arg_fecha_ini then
    raise_application_error(-20003, 'El numero de dias sera mayor que 0');
  else
    select m.nombre, m.precio_cada_dia, m.capacidad_deposito, m.tipo_combustible, pc.precio_por_litro
    into l_nombre, l_precio_cada_dia, l_capacidad_deposito, l_tipo_combustible, l_precio_por_litro
    from modelos m, precio_combustible pc, vehiculos v
    where v.matricula=arg_matricula and m.id_modelo=v.id_modelo and pc.tipo_combustible=m.tipo_combustible;
    
    open c1;
    loop
        fetch c1 into c1_values;
        EXIT WHEN c1%NOTFOUND;
        if arg_fecha_ini < c1_values.fecha_fin and arg_fecha_fin > c1_values.fecha_ini then
            raise_application_error(-20004, 'El vehiculo no esta disponible');
            EXIT;
        end if;
    end loop;

   close c1;
    
    insert into reservas (idreserva, cliente, matricula, fecha_ini, fecha_fin)
    values(seq_reservas.nextval, arg_NIF_cliente, arg_matricula, arg_fecha_ini, arg_fecha_fin);
  end if;

exception
  when no_data_found then
    raise_application_error(-20002, 'Vehículo inexistente');
  when e_parent_not_found then
    raise_application_error(-20001, 'Cliente inexistente');
  
end;
/

set serveroutput on
exec test_alquila_coches;