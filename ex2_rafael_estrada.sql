host cls

set linesize 100;
set pagesize 100;

spool 'c:\nocloud\uh\bases de datos\parcial2/viajes_resultado.log'

prompt ========================================================================
prompt rafael estrada castillo // semana # 14 examen final
prompt Universidad Hispanoamericana
prompt Curso Bases de Datos
prompt Docente: Jonathan Morales Murillo
prompt ========================================================================

prompt ========================================================================
prompt sistema de Control de Viajes de Empleados
prompt ========================================================================

prompt ========================================================================
prompt version v1 19:01 14/4/2025 bloque 1: conexión y configuración
prompt ========================================================================

prompt ========================================================================
prompt versión v2 19:20 14/4/2025 bloque 2: manejo de tablespaces
prompt ========================================================================

prompt ========================================================================
prompt version v3 19:38 14/4/2025 bloque 3: creación de tablas
prompt ========================================================================

prompt ========================================================================
prompt versión v4 20:04 14/4/2025 bloque 4: definición de restricciones
prompt ========================================================================

prompt ========================================================================
prompt version v5 20:48 14/4/2025 bloque 5: creación de secuencias
prompt ========================================================================

prompt ========================================================================
prompt versión v6 21:17 14/4/2025 bloque 6: inserción de datos   
prompt ========================================================================

prompt ========================================================================
prompt version v7 21:35 14/4/2025 bloque 7: creación de vistas para reportes  
prompt ========================================================================

prompt ========================================================================
prompt versión v8 22:01 14/4/2025 bloque 8: procedimientos   
prompt ========================================================================

prompt ========================================================================
prompt version v9 22:19 14/4/2025 bloque 9: funciones  
prompt ========================================================================

prompt ========================================================================
prompt versión v10 22:43 14/4/2025 bloque 10: trigger que impide viajes
prompt duplicados por departamento 
prompt ========================================================================

prompt ========================================================================
prompt version v11 23:24 14/4/2025 bloque 11: triggers de auditoría
prompt (insert, update, delete)    
prompt ========================================================================

prompt ========================================================================
prompt versión v12 23:45 14/4/2025 bloque 12: triggers de bloqueo de operaciones    
prompt ========================================================================



prompt ========================================================================
prompt bloque 1: conexión y configuración
prompt ========================================================================

prompt ========================================================================
prompt conexión base de datos oracle bajo SYS para configuración inicial
prompt ========================================================================

conn sys/root as sysdba;
alter session set "_oracle_script"=true;

prompt ========================================================================
prompt creación de usuario rafael y asignación de permisos
prompt se utiliza el usuario SYS exclusivamente para crear el usuario y los tablespaces
prompt posteriormente, se cambia al usuario RAFAEL para ejecutar toda la lógica funcional
prompt esto es necesario para evitar errores al crear triggers y otros objetos
prompt ========================================================================

-- eliminar usuario si ya existe (opcional, solo para pruebas)
drop user rafael cascade;

create user rafael identified by rafael
default tablespace datos
temporary tablespace temp
quota unlimited on datos;

alter user rafael quota unlimited on indices;


grant connect, resource, create session, create table, create view,
create procedure, create sequence, create trigger to rafael;

prompt ========================================================================
prompt cambio de sesión a usuario rafael
prompt ========================================================================

conn rafael/rafael@orcl

-- reactivar spool después del cambio de usuario
spool 'c:\nocloud\uh\bases de datos\parcial2/viajes_resultado.log' append

prompt ************************************************************************


prompt ========================================================================
prompt bloque 2: manejo de tablespaces
prompt ========================================================================

-- eliminar tablespaces si existen
drop tablespace datos including contents and datafiles;
drop tablespace indices including contents and datafiles;

prompt ========================================================================
prompt crear tablespace DATOS
prompt ========================================================================

create tablespace datos
datafile 'c:\users\rafes\oracle\oradata\orcl\orclpdb\datos01.dbf'
size 100m autoextend on next 10m maxsize 500m;

prompt ========================================================================
prompt crear tablespace INDICES
prompt ========================================================================

create tablespace indices
datafile 'c:\users\rafes\oracle\oradata\orcl\orclpdb\indices01.dbf'
size 100m autoextend on next 10m maxsize 500m;

prompt ************************************************************************

prompt ========================================================================
prompt bloque 3: creación de tablas
prompt ========================================================================

prompt ========================================================================
prompt crear tabla departamento
prompt ========================================================================

drop table departamento cascade constraints;

create table departamento (
id_departamento number(5) not null,
nombre varchar2(30) not null
) tablespace datos;

prompt ========================================================================
prompt crear tabla empleado
prompt ========================================================================

drop table empleado cascade constraints;

create table empleado (
id_empleado number(5) not null,
nombre varchar2(50) not null,
salario number(8,2) not null,
id_departamento number(5) not null
) tablespace datos;

prompt ========================================================================
prompt crear tabla localizacion
prompt ========================================================================

drop table localizacion cascade constraints;

create table localizacion (
id_localizacion number(5) not null,
nombre varchar2(50) not null
) tablespace datos;

prompt ========================================================================
prompt crear tabla viaje
prompt ========================================================================

drop table viaje cascade constraints;

create table viaje (
id_viaje number(5) not null,
id_empleado number(5) not null,
id_localizacion number(5) not null,
fecha_inicio date not null,
fecha_final date null,
presupuesto number(6) not null,
monto_gastado number(6) null,
comentario varchar2(200) null
) tablespace datos;

prompt ************************************************************************

prompt ========================================================================
prompt bloque 4: definición de restricciones
prompt ========================================================================

prompt ========================================================================
prompt clave primaria para departamento
prompt ========================================================================

alter table departamento add constraint
departamento_pk primary key (id_departamento)
using index tablespace indices;

prompt ========================================================================
prompt clave primaria para empleado
prompt ========================================================================

alter table empleado add constraint
empleado_pk primary key (id_empleado)
using index tablespace indices;

prompt ========================================================================
prompt clave foránea: departamento del empleado
prompt ========================================================================

alter table empleado add constraint
empleado_fk_departamento foreign key (id_departamento)
references departamento(id_departamento);

prompt ========================================================================
prompt clave primaria para localizacion
prompt ========================================================================

alter table localizacion add constraint
localizacion_pk primary key (id_localizacion)
using index tablespace indices;

prompt ========================================================================
prompt clave primaria para viaje
prompt ========================================================================

alter table viaje add constraint
viaje_pk primary key (id_viaje)
using index tablespace indices;

prompt ========================================================================
prompt clave foránea: empleado que viaja
prompt ========================================================================

alter table viaje add constraint
viaje_fk_empleado foreign key (id_empleado)
references empleado(id_empleado);

prompt ========================================================================
prompt clave foránea: localización del viaje
prompt ========================================================================

alter table viaje add constraint
viaje_fk_localizacion foreign key (id_localizacion)
references localizacion(id_localizacion);

prompt ========================================================================
prompt check constraint para presupuesto
prompt ========================================================================

alter table viaje add constraint
viaje_ck_presupuesto check (presupuesto between 0 and 999999);

prompt ========================================================================
prompt check constraint para monto gastado
prompt ========================================================================

alter table viaje add constraint
viaje_ck_monto check (monto_gastado between 0 and 999999);

prompt ************************************************************************

prompt ========================================================================
prompt bloque 5: creación de secuencias
prompt ========================================================================

prompt ========================================================================
prompt crear secuencia para departamento
prompt ========================================================================

drop sequence seq_departamento;

create sequence seq_departamento
start with 1
increment by 1;

prompt ========================================================================
prompt crear secuencia para empleado
prompt ========================================================================

drop sequence seq_empleado;

create sequence seq_empleado
start with 1
increment by 1;

prompt ========================================================================
prompt crear secuencia para localizacion
prompt ========================================================================

drop sequence seq_localizacion;

create sequence seq_localizacion
start with 1
increment by 1;

prompt ========================================================================
prompt crear secuencia para viaje
prompt ========================================================================

drop sequence seq_viaje;

create sequence seq_viaje
start with 1
increment by 1;

prompt ************************************************************************

prompt ========================================================================
prompt bloque 6: inserción de datos
prompt ========================================================================

prompt ========================================================================
prompt insertar departamentos
prompt ========================================================================

insert into departamento (id_departamento, nombre) values (seq_departamento.nextval, 'finanzas');
insert into departamento (id_departamento, nombre) values (seq_departamento.nextval, 'recursos humanos');
insert into departamento (id_departamento, nombre) values (seq_departamento.nextval, 'tecnología');
insert into departamento (id_departamento, nombre) values (seq_departamento.nextval, 'logística');

prompt ========================================================================
prompt insertar empleados
prompt ========================================================================

insert into empleado (id_empleado, nombre, salario, id_departamento) 
values (seq_empleado.nextval, 'silvana cercone', 750000.00, 1);

insert into empleado (id_empleado, nombre, salario, id_departamento) 
values (seq_empleado.nextval, 'miguel estrada', 620000.00, 2);

insert into empleado (id_empleado, nombre, salario, id_departamento) 
values (seq_empleado.nextval, 'jose soto', 800000.00, 3);

insert into empleado (id_empleado, nombre, salario, id_departamento) 
values (seq_empleado.nextval, 'laura mendoza', 700000.00, 4);

prompt ========================================================================
prompt insertar localizaciones
prompt ========================================================================

insert into localizacion (id_localizacion, nombre) values (seq_localizacion.nextval, 'san josé');
insert into localizacion (id_localizacion, nombre) values (seq_localizacion.nextval, 'liberia');
insert into localizacion (id_localizacion, nombre) values (seq_localizacion.nextval, 'puntarenas');
insert into localizacion (id_localizacion, nombre) values (seq_localizacion.nextval, 'limón');

prompt ========================================================================
prompt insertar viajes
prompt ========================================================================

insert into viaje (id_viaje, id_empleado, id_localizacion, fecha_inicio, fecha_final, presupuesto, monto_gastado, comentario)
values (seq_viaje.nextval, 1, 2, to_date('10-03-2025', 'dd-mm-yyyy'),
 to_date('15-03-2025', 'dd-mm-yyyy'), 300000, 285000, 'visita a sucursal');

insert into viaje (id_viaje, id_empleado, id_localizacion, fecha_inicio, fecha_final, presupuesto, monto_gastado, comentario)
values (seq_viaje.nextval, 2, 3, to_date('20-03-2025', 'dd-mm-yyyy'),
 to_date('25-03-2025', 'dd-mm-yyyy'), 400000, 390000, 'inspección de oficina');

insert into viaje (id_viaje, id_empleado, id_localizacion, fecha_inicio, fecha_final, presupuesto, monto_gastado, comentario)
values (seq_viaje.nextval, 3, 1, to_date('01-04-2025', 'dd-mm-yyyy'),
 to_date('05-04-2025', 'dd-mm-yyyy'), 250000, 200000, 'reunión ejecutiva');

insert into viaje (id_viaje, id_empleado, id_localizacion, fecha_inicio, fecha_final, presupuesto, monto_gastado, comentario)
values (seq_viaje.nextval, 4, 4, to_date('10-04-2025', 'dd-mm-yyyy'),
 null, 350000, null, null);

prompt ************************************************************************


prompt ========================================================================
prompt bloque 7: creación de vistas para reportes
prompt ========================================================================

prompt ========================================================================
prompt vista resumen de viajes por empleado
prompt ========================================================================

create or replace view vw_resumen_empleado as
select 
    e.id_empleado,
    e.nombre,
    count(v.id_viaje) as cantidad_viajes,
    sum(nvl(v.monto_gastado, 0)) as total_viaticos
from empleado e
left join viaje v on e.id_empleado = v.id_empleado
group by e.id_empleado, e.nombre;

prompt ========================================================================
prompt vista empleados sin viajes
prompt ========================================================================

create or replace view vw_empleados_sin_viajes as
select 
    e.id_empleado,
    e.nombre
from empleado e
where e.id_empleado not in (select distinct id_empleado from viaje);

prompt ========================================================================
prompt vista viajes activos
prompt ========================================================================

create or replace view vw_viajes_activos as
select 
    v.id_viaje,
    e.nombre as empleado,
    l.nombre as localizacion,
    v.fecha_inicio,
    v.presupuesto
from viaje v
join empleado e on v.id_empleado = e.id_empleado
join localizacion l on v.id_localizacion = l.id_localizacion
where v.fecha_final is null;

prompt ========================================================================
prompt vista presupuesto vs gasto
prompt ========================================================================

create or replace view vw_presupuesto_vs_gasto as
select 
    v.id_viaje,
    e.nombre as empleado,
    l.nombre as localizacion,
    v.presupuesto,
    v.monto_gastado,
    (v.presupuesto - nvl(v.monto_gastado, 0)) as diferencia
from viaje v
join empleado e on v.id_empleado = e.id_empleado
join localizacion l on v.id_localizacion = l.id_localizacion;

prompt ************************************************************************

prompt ========================================================================
prompt consultas de prueba sobre las vistas
prompt ========================================================================

select * from vw_resumen_empleado;
select * from vw_empleados_sin_viajes;
select * from vw_viajes_activos;
select * from vw_presupuesto_vs_gasto;

prompt ************************************************************************

prompt ========================================================================
prompt bloque 8: procedimientos
prompt ========================================================================

prompt ========================================================================
prompt procedimiento PRC_INSERTA_VIAJE
prompt ========================================================================

create or replace procedure prc_inserta_viaje (
    p_id_empleado in number,
    p_id_localizacion in number,
    p_fecha_inicio in date,
    p_presupuesto in number,
    p_comentario in varchar2 default null
)
as
begin
    insert into viaje (
        id_viaje,
        id_empleado,
        id_localizacion,
        fecha_inicio,
        presupuesto,
        comentario
    )
    values (
        seq_viaje.nextval,
        p_id_empleado,
        p_id_localizacion,
        p_fecha_inicio,
        p_presupuesto,
        p_comentario
    );
    
    dbms_output.put_line('viaje insertado correctamente.');
exception
    when others then
        dbms_output.put_line('error al insertar el viaje: ' || sqlerrm);
end;
/

prompt ************************************************************************

prompt ========================================================================
prompt prueba de procedimiento PRC_INSERTA_VIAJE
prompt ========================================================================

begin
    prc_inserta_viaje(1, 3, to_date('18-04-2025', 'dd-mm-yyyy'), 320000, 'viaje a puntarenas');
    prc_inserta_viaje(2, 1, to_date('20-04-2025', 'dd-mm-yyyy'), 280000); -- sin comentario
end;
/

prompt ************************************************************************


prompt ========================================================================
prompt procedimiento PRC_ACTUALIZA_MONTO
prompt ========================================================================

create or replace procedure prc_actualiza_monto (
    p_id_viaje in number,
    p_monto_gastado in number
)
as
    v_count number;
    v_existente number;
begin
    -- validar si el viaje existe
    select count(*) into v_count from viaje where id_viaje = p_id_viaje;

    if v_count = 0 then
        raise_application_error(-20001, 'el viaje no existe.');
    end if;

    -- verificar si ya tiene monto_gastado registrado
    select count(*) into v_existente from viaje 
    where id_viaje = p_id_viaje and monto_gastado is not null;

    if v_existente > 0 then
        raise_application_error(-20002, 'el viaje ya tiene un monto registrado.');
    end if;

    -- si pasa validaciones, actualizar
    update viaje
    set monto_gastado = p_monto_gastado
    where id_viaje = p_id_viaje;

    dbms_output.put_line('monto actualizado correctamente para el viaje ' || p_id_viaje);

exception
    when others then
        dbms_output.put_line('error: ' || sqlerrm);
end;
/

prompt ************************************************************************

prompt ========================================================================
prompt prueba de procedimiento PRC_ACTUALIZA_MONTO
prompt ========================================================================

begin
    -- ejemplo correcto
    prc_actualiza_monto(4, 330000); 
    
    -- ejemplo con error: ya tiene monto
    prc_actualiza_monto(1, 350000); 
    
    -- ejemplo con error: no existe el viaje
    prc_actualiza_monto(99, 100000); 
end;
/



prompt ************************************************************************


prompt ========================================================================
prompt bloque 9: funciones
prompt ========================================================================

prompt ========================================================================
prompt función FN_TOTAL_VIATICOS
prompt ========================================================================

create or replace function fn_total_viaticos (
    p_id_empleado in number
) return number
as
    v_total number;
begin
    select sum(nvl(monto_gastado, 0))
    into v_total
    from viaje
    where id_empleado = p_id_empleado;

    return v_total;
exception
    when no_data_found then
        return 0;
end;
/

prompt ========================================================================
prompt prueba FN_TOTAL_VIATICOS
prompt ========================================================================

select fn_total_viaticos(1) as total_viaticos_empleado_1 from dual;

prompt ************************************************************************

prompt ========================================================================
prompt función FN_CANTIDAD_VIAJES
prompt ========================================================================

create or replace function fn_cantidad_viajes (
    p_id_empleado in number
) return number
as
    v_cantidad number;
begin
    select count(*)
    into v_cantidad
    from viaje
    where id_empleado = p_id_empleado;

    return v_cantidad;
exception
    when no_data_found then
        return 0;
end;
/

prompt ========================================================================
prompt prueba FN_CANTIDAD_VIAJES
prompt ========================================================================

select fn_cantidad_viajes(1) as cantidad_viajes_empleado_1 from dual;

prompt ************************************************************************

prompt ========================================================================
prompt función FN_SUMA_SALARIOS
prompt ========================================================================

create or replace function fn_suma_salarios return number
as
    v_total_salario number;
begin
    select sum(salario) into v_total_salario from empleado;
    return v_total_salario;
exception
    when others then
        return 0;
end;
/

prompt ========================================================================
prompt prueba FN_SUMA_SALARIOS
prompt ========================================================================

select fn_suma_salarios() as total_salarios from dual;

prompt ************************************************************************

prompt ========================================================================
prompt bloque 10: trigger que impide viajes duplicados por departamento
prompt ========================================================================

create or replace trigger trg_bloquea_viajes_repetidos
before insert on viaje
for each row
declare
    v_departamento number;
    v_conflicto number;
begin
    -- obtener el departamento del empleado que intenta viajar
    select id_departamento into v_departamento
    from empleado
    where id_empleado = :new.id_empleado;

    -- contar si ya existe un viaje activo a esa localización por otro compa del mismo depto
    select count(*) into v_conflicto
    from viaje v
    join empleado e on v.id_empleado = e.id_empleado
    where v.id_localizacion = :new.id_localizacion
      and e.id_departamento = v_departamento
      and v.id_empleado != :new.id_empleado
      and v.fecha_final is null;

    if v_conflicto > 0 then
        raise_application_error(-20010, 'ya hay un viaje activo a esa localización por otro empleado del mismo departamento.');
    end if;
end;
/

prompt ************************************************************************

prompt ========================================================================
prompt prueba del trigger (debe fallar si se repite localización en mismo depto)
prompt ========================================================================

-- este viaje debería fallar si alguien del mismo departamento ya tiene viaje activo ahí
begin
    prc_inserta_viaje(1, 3, to_date('25-04-2025', 'dd-mm-yyyy'), 290000, 'viaje duplicado');
end;
/

prompt ************************************************************************

prompt ========================================================================
prompt bloque 11: triggers de auditoría (insert, update, delete)
prompt ========================================================================

prompt ========================================================================
prompt crear tabla de auditoría AUD_VIAJE
prompt ========================================================================

drop table aud_viaje cascade constraints;

create table aud_viaje (
    id_aud number generated always as identity,
    usuario varchar2(30),
    fecha_evento date,
    accion varchar2(10),
    id_viaje number
) tablespace datos;

prompt ========================================================================
prompt trigger AFTER INSERT en VIAJE
prompt ========================================================================

create or replace trigger trg_aud_viaje_insert
after insert on viaje
for each row
begin
    insert into aud_viaje (usuario, fecha_evento, accion, id_viaje)
    values (user, sysdate, 'insert', :new.id_viaje);
end;
/

prompt ========================================================================
prompt trigger AFTER UPDATE en VIAJE
prompt ========================================================================

create or replace trigger trg_aud_viaje_update
after update on viaje
for each row
begin
    insert into aud_viaje (usuario, fecha_evento, accion, id_viaje)
    values (user, sysdate, 'update', :new.id_viaje);
end;
/

prompt ========================================================================
prompt trigger AFTER DELETE en VIAJE
prompt ========================================================================

create or replace trigger trg_aud_viaje_delete
after delete on viaje
for each row
begin
    insert into aud_viaje (usuario, fecha_evento, accion, id_viaje)
    values (user, sysdate, 'delete', :old.id_viaje);
end;
/

prompt ========================================================================
prompt prueba de auditoría
prompt ========================================================================

-- insertar un nuevo viaje
begin
    prc_inserta_viaje(3, 4, to_date('30-04-2025', 'dd-mm-yyyy'), 310000, 'prueba auditoría');
end;
/

-- actualizar su monto
begin
    prc_actualiza_monto(5, 310000);  -- asumimos que el id insertado fue 5
end;
/

-- eliminar el viaje
delete from viaje where id_viaje = 5;

select * from aud_viaje;

prompt ************************************************************************


prompt ========================================================================
prompt bloque 12: triggers de bloqueo de operaciones
prompt ========================================================================

prompt ========================================================================
prompt trigger: bloquear DELETE de empleados con viajes registrados
prompt ========================================================================

create or replace trigger trg_bloquea_delete_empleado
before delete on empleado
for each row
declare
    v_viajes number;
begin
    select count(*) into v_viajes
    from viaje
    where id_empleado = :old.id_empleado;

    if v_viajes > 0 then
        raise_application_error(-20020, 'no se puede eliminar un empleado con viajes registrados.');
    end if;
end;
/

prompt ========================================================================
prompt trigger: bloquear UPDATE de fecha_inicio si ya existe fecha_final
prompt ========================================================================

create or replace trigger trg_bloquea_update_fecha
before update of fecha_inicio on viaje
for each row
begin
    if :old.fecha_final is not null then
        raise_application_error(-20021, 'no se puede cambiar la fecha de inicio de un viaje finalizado.');
    end if;
end;
/

prompt ========================================================================
prompt trigger: bloquear INSERT si presupuesto supera 999999
prompt ========================================================================

create or replace trigger trg_bloquea_presupuesto_excesivo
before insert on viaje
for each row
begin
    if :new.presupuesto > 999999 then
        raise_application_error(-20022, 'el presupuesto excede el límite permitido.');
    end if;
end;
/

prompt ========================================================================
prompt prueba de triggers de bloqueo
prompt ========================================================================

-- eliminar empleado con viajes (debe fallar)
delete from empleado where id_empleado = 1;

-- actualizar fecha_inicio de un viaje ya finalizado (debe fallar)
update viaje set fecha_inicio = to_date('01-01-2025','dd-mm-yyyy') where id_viaje = 1;

-- insertar viaje con presupuesto excesivo (debe fallar)
begin
    prc_inserta_viaje(2, 2, to_date('01-05-2025','dd-mm-yyyy'), 1500000, 'presupuesto loco');
end;
/

prompt ************************************************************************



commit;

spool off;