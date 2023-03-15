create or replace procedure alquilar(arg_NIF_cliente varchar,
  arg_matricula varchar, arg_fecha_ini date, arg_fecha_fin date) is
  l_id_modelo modelos.id_modelo%TYPE;
  l_nombre modelos.nombre%TYPE;
  l_precio_cada_dia modelos.precio_cada_dia%TYPE;
  l_capacidad_deposito modelos.capacidad_deposito%TYPE;
  l_tipo_combustible modelos.tipo_combustible%TYPE;
  l_precio_por_litro precio_combustible.precio_por_litro%TYPE;
  
  n_days number;
  precio_dias number;
  precio_deposito number;
  total number;
  l_nro_factura number;
  
  e_parent_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_parent_not_found, -2291);
  
  cursor c1 is 
    select * from reservas;

  c1_values c1%ROWTYPE;
begin
  if arg_fecha_fin < arg_fecha_ini then
    raise_application_error(-20003, 'El numero de dias sera mayor que 0');
  else
    select m.id_modelo, m.nombre, m.precio_cada_dia, m.capacidad_deposito, m.tipo_combustible, pc.precio_por_litro
    into l_id_modelo, l_nombre, l_precio_cada_dia, l_capacidad_deposito, l_tipo_combustible, l_precio_por_litro
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
    
    if arg_fecha_fin is null then
        n_days := 4;
    else
        n_days := arg_fecha_fin - arg_fecha_ini;
    end if;
    
    precio_dias := n_days * l_precio_cada_dia;
    precio_deposito := l_capacidad_deposito * l_precio_por_litro;
    total := precio_dias + precio_deposito;
    l_nro_factura := seq_num_fact.nextval;
    
    insert into facturas (nroFactura, importe, cliente)
    values(l_nro_factura, total, arg_NIF_cliente);
    
    insert into lineas_factura (nroFactura, concepto, importe)
    values (l_nro_factura, n_days || ' dias de alquiler, vehiculo modelo ' || l_id_modelo, precio_dias);
    insert into lineas_factura (nroFactura, concepto, importe)
    values (l_nro_factura, 'Deposito lleno de ' || l_capacidad_deposito || ' litros de ' || l_tipo_combustible, precio_deposito);
    
    
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