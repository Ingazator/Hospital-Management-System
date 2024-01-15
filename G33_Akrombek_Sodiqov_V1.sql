-- G33_JM6_exam-v1
-- Akrombek Sodiqov
-- drawsql sayt linki : "https://drawsql.app/teams/java-18/diagrams/hospital-management-system"

CREATE TABLE "scheduled_appointments"
(
    "id"               BIGINT    NOT NULL,
    "patient_id"       bigserial NOT NULL,
    "appointment_date" DATE      NOT NULL
);
ALTER TABLE
    "scheduled_appointments"
    ADD PRIMARY KEY ("id");
CREATE TABLE "doctors"
(
    "id"                  BIGINT       NOT NULL,
    "first_name"          VARCHAR(255) NOT NULL,
    "last_name"           VARCHAR(255) NOT NULL,
    "years_of_experience" BIGINT       NOT NULL,
    "what_kind_of_doctor" VARCHAR(255) NOT NULL,
    "appointment_id"      bigserial    NOT NULL
);
ALTER TABLE
    "doctors"
    ADD PRIMARY KEY ("id");
CREATE TABLE "patients"
(
    "id"              bigserial    NOT NULL,
    "first_name"      VARCHAR(255) NOT NULL,
    "last_name"       VARCHAR(255) NOT NULL,
    "type_of_disease" VARCHAR(255) NOT NULL,
    "arrival_time"    DATE         NOT NULL,
    "doctor_id"       bigserial    NOT NULL,
    "phone_number"    VARCHAR(255) NOT NULL
);
ALTER TABLE
    "patients"
    ADD PRIMARY KEY ("id");
CREATE TABLE "hospital"
(
    "id"          BIGINT       NOT NULL,
    "name"        VARCHAR(255) NOT NULL,
    "doctors_id"  bigserial    NOT NULL,
    "patients_id" bigserial    NOT NULL,
    "condition"   VARCHAR(255) NOT NULL
);
ALTER TABLE
    "hospital"
    ADD PRIMARY KEY ("id");
ALTER TABLE
    "doctors"
    ADD CONSTRAINT "doctors_appointment_id_foreign" FOREIGN KEY ("appointment_id") REFERENCES "scheduled_appointments" ("id");
ALTER TABLE
    "hospital"
    ADD CONSTRAINT "hospital_doctors_id_foreign" FOREIGN KEY ("doctors_id") REFERENCES "doctors" ("id");
ALTER TABLE
    "hospital"
    ADD CONSTRAINT "hospital_patients_id_foreign" FOREIGN KEY ("patients_id") REFERENCES "patients" ("id");

create table scheduled_appointments_info
(
    id               bigint,
    patient_id       bigint,
    appointment_date date
);

create table appointments
(
    full_name          varchar,
    appointments_count int,
    month              date,
    year               date
);

insert into patients(id, first_name, last_name, type_of_disease, arrival_time, phone_number)
values (1, 'Oliver', 'Jake', 'stomach ache', '2024-01-15', '998975546655'),
       (2, 'Jack', 'Connor', 'back pain', '2023-12-18', '998975546654'),
       (3, 'Harry', 'Callum', 'leg pain', '2024-01-16', '998975546653'),
       (4, 'Jacob', 'Jacob', 'headache', '2024-02-23', '998975546652'),
       (5, 'Charlie', 'Kyle', 'arm pain', '2024-01-15', '998975546651'),
       (6, 'Thomas', 'Joe', 'osteochondrosis', '2023-12-01', '998975546650'),
       (7, 'George', 'Reece', 'stroke', '2023-11-24', '998975546659'),
       (8, 'Oscar', 'Rhys', 'heart attack', '2024-01-18', '998975546658'),
       (9, 'James', 'Charlie', 'heartache', '2024-03-31', '998975546657'),
       (10, 'William', 'Damian', 'brain injury', '2023-12-19', '998975546656');

insert into doctors(id, first_name, last_name, years_of_experience, what_kind_of_doctor, appointment_id)
values (1, 'Smith', 'Murphy', 4, 'stomach ache', 1),
       (2, 'Jones', 'O''Kelly', 6, 'stroke', 2),
       (3, 'Williams', 'O''Sullivan', 8, 'leg pain', 3),
       (4, 'Brown', 'Walsh', 10, 'osteochondrosis', 4),
       (5, 'Taylor', 'Smith', 1, 'brain injury', 5),
       (6, 'Davies', 'O''Brien', 2, 'headache', 6),
       (7, 'Wilson', 'Byrne', 3, 'heart attack', 7),
       (8, 'Evans', 'O''Ryan', 5, 'arm pain', 8),
       (9, 'Thomas', 'O''Connor', 7, 'heartache', 9),
       (10, 'Roberts', 'O''Neill', 9, 'back pain', 10);

insert into scheduled_appointments(id, patient_id, appointment_date)
values (1, 1, '2024-01-15'),
       (2, 2, '2023-12-18'),
       (3, 3, '2024-01-16'),
       (4, 4, '2024-02-23'),
       (5, 5, '2024-01-15'),
       (6, 6, '2023-12-01'),
       (7, 7, '2023-11-24'),
       (8, 8, '2024-01-18'),
       (9, 9, '2024-03-31'),
       (10, 10, '2023-12-19');

--Task 1:
create or replace function fn_search_patient_names(
    p_name varchar(255)
)
    returns table
            (
                id              bigint,
                first_name      varchar,
                last_name       varchar,
                type_of_disease varchar,
                arrival_time    date,
                doctor_id       bigint,
                phone_number    varchar
            )
    language plpgsql
as
$$
begin
    return query
        select * from patients where patients.first_name like '%' || p_name || '%';
end
$$;

select *
from fn_search_patient_names(p_name := 'Thomas');

--Task 2:
create or replace procedure pr_appointmnet_scheduling(
    i_id bigint,
    i_patient_id bigint,
    i_appointment_date date
)
    language plpgsql
as
$$
begin
    insert into scheduled_appointments_info(id, patient_id, appointment_date)
    values (i_id, i_patient_id, i_appointment_date);
end;
$$;

call pr_appointmnet_scheduling(1, 1, '2024-01-20');
call pr_appointmnet_scheduling(2, 2, '2023-12-20');
call pr_appointmnet_scheduling(3, 3, '2024-01-15');
select *
from scheduled_appointments_info;

--Task 3:
create or replace view scheduled_appointments_today
as
select *
from scheduled_appointments
where appointment_date = current_date;

select *
from scheduled_appointments_today;

--Task 4:
create materialized view patient_appointment_count_last_month as
select concat(p.first_name, ' ', p.last_name)  as patient_full_name,
       count(*)                                as appointment_count,
       extract(month from sa.appointment_date) as month,
       extract(year from sa.appointment_date)  as year
from scheduled_appointments sa
         inner join patients p on sa.patient_id = p.id
where sa.appointment_date >= (current_date - interval '1 month')
group by p.first_name,
         p.last_name,
         extract(month from sa.appointment_date),
         extract(year from sa.appointment_date);

refresh materialized view patient_appointment_count_last_month;

select *
from patient_appointment_count_last_month
order by year;