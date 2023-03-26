CREATE OR REPLACE PROCEDURE crearViaje (
    m_idRecorrido INT,
    m_idAutocar INT,
    m_fecha DATE,
    m_conductor VARCHAR
) AS
    v_plazas INTEGER;
    v_modelo INTEGER;
    v_ocupadas INTEGER;
BEGIN

    -- Validar la existencia del recorrido
    SELECT COUNT(*) INTO v_modelo FROM recorridos WHERE idRecorrido = m_idRecorrido;
    IF v_modelo = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'RECORRIDO_INEXISTENTE');
    END IF;

    -- Validar la existencia del autocar
    SELECT COUNT(*) INTO v_modelo FROM autocares WHERE idAutocar = m_idAutocar;
    IF v_modelo = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'AUTOCAR_INEXISTENTE');
    END IF;

    -- Validar que el autocar no esté ocupado en la fecha especificada
    SELECT COUNT(*) INTO v_ocupadas FROM viajes
    WHERE idAutocar = m_idAutocar AND fecha = m_fecha;
    IF v_ocupadas > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'AUTOCAR_OCUPADO');
    END IF;

    -- Validar que no haya un viaje duplicado para el recorrido en la misma fecha
    SELECT COUNT(*) INTO v_modelo FROM viajes
    WHERE idRecorrido = m_idRecorrido AND fecha = m_fecha;
    IF v_modelo > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'VIAJE_DUPLICADO');
    END IF;
    
    -- Obtener el número de plazas del modelo del autocar
    SELECT modelos.nplazas
    INTO v_plazas
    FROM autocares
    JOIN modelos ON autocares.modelo = modelos.idModelo
    WHERE autocares.idAutocar = m_idAutocar;

    -- Si el autocar no tiene modelo asociado, se toman 25 plazas libres por defecto
    IF v_plazas IS NULL THEN
        v_plazas := 25;
    END IF;

    -- Insertar el nuevo viaje
    INSERT INTO viajes (idViaje, idAutocar, idRecorrido, fecha, nPlazasLibres, conductor)
    VALUES (seq_viajes.NEXTVAL, m_idAutocar, m_idRecorrido, m_fecha, v_plazas, m_conductor);

END;

/

begin
  test_crearViaje;
end;
