-----------------------------------------------------------
-- 1 - Número de empregados por departamento e localidade
-----------------------------------------------------------

CREATE VIEW vw_empregados_por_departamento_localidade AS
SELECT 
    d.Dname AS Departamento,
    dl.Dlocation AS Localidade,
    COUNT(e.Ssn) AS NumeroEmpregados
FROM Department d
JOIN Dept_locations dl 
    ON dl.Dnumber = d.Dnumber
LEFT JOIN Employee e 
    ON e.Dno = d.Dnumber
GROUP BY d.Dname, dl.Dlocation;

-----------------------------------------------------------
-- 2 Lista de departamentos e seus gerentes
-----------------------------------------------------------
CREATE VIEW vw_dept_managers AS
SELECT
    d.Dname AS Departamento,
    e.Fname as Gerentes
    e.Lname as SobrenomeGerente
FROM Department d
JOIN Employee e
    ON d.Mgr_ssn = e.Ssn;

----------------------------------------------------------------------------
-- 3 - Projetos com maior numero de empregados ( por ordenacao descendente)
----------------------------------------------------------------------------

CREATE VIEW vw_project_quantity AS
SELECT
    p.Pname AS Projeto,
    p.Pnumber AS NumeroDoProjeto,
    COUNT(w.Essn) AS QuantidadeDeColaboradores
FROM Project p
LEFT JOIN Works_on w
    ON p.Pnumber = w.Pno
GROUP BY p.Pname, p.Pnumber
ORDER BY QuantidadeDeColaboradores DESC;

----------------------------------------------------------------------------
-- 4 - Lista de projetos, departamentos e gerentes
----------------------------------------------------------------------------

CREATE VIEW vw_projects_dept_mngrs AS
SELECT 
    p.Pname AS Projeto,
    p.Pnumber AS NumeroProjeto,
    d.Dname AS Departamento,
    e.Fname AS GerenteNome,
    e.Lname AS GerenteSobrenome
FROM Project p
JOIN Department d
    ON p.Dnum = d.Dnumber
JOIN Employee e
    ON d.Mgr_ssn = e.Ssn;

----------------------------------------------------------------------------
-- 5 - Quais empregados possuem dependentes e se são gerentes
----------------------------------------------------------------------------

CREATE VIEW vw_emp_dependent_manager AS
SELECT
    e.Ssn,
    CONCAT (e.Fname, ' ', e.Minit, ' ', e.Lname) as Nome,
    CASE
        WHEN e.Ssn = dpt.mgr_ssn THEN 'SIM'
        ELSE 'NAO'
    END AS GERENTE,
COUNT (dep.Depedent_name) AS qtd_dependentes
    FROM employee e
LEFT JOIN Dependent dep
    ON e.ssn = dep.Essn
LEFT JOIN Department dpt
    ON e.ssn = dpt.mgr_ssn
GROUP BY e.ssn, e.fname, e.minit, e.lname, dpt.mgr_ssn;

----------------------------------------------------------------------------
-- 5 - Criar usuario de gestão com acesso as tabelas de funcionário e departamento, e um usuário de colaborador com
-- acesso a todas as tabelas, menos departamento e de gerentes
----------------------------------------------------------------------------

CREATE USER 'gestao' @localhost IDENTIFIED BY '123';
GRANT SELECT ON company.Employee TO 'gestao'@localhost;
GRANT SELECT ON company.Department TO 'gestao'@localhost;


CREATE USER 'colaborador' @localhost IDENTIFIED BY '456';
GRANT SELECT ON company.Employee TO 'colaborador' @localhost;
GRANT SELECT ON company.Dependent TO 'colaborador' @localhost;
GRANT SELECT ON company.Project TO 'colaborador' @localhost;
GRANT SELECT ON company.Works_on TO 'colaborador' @localhost;

-- before update statement
-- Atribuindo aumento de salario para um dept especifico = 1 salary = salary * 1.20
CREATE TRIGGER aumentar_salario
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
        IF NEW.Dno = 5 THEN
        IF NEW.Salary = OLD.Salary THEN
        SET NEW.Salary = OLD.Salary * 1.20;
    END IF;
    END IF;
END;

CREATE TABLE Fired_Employee(

    Frd_name       VARCHAR(30),
    Frd_minit          CHAR(1),
    Frd_last_name  VARCHAR(30),
    Frd_ssn            CHAR(9) PRIMARY KEY,
    Frd_bdate          DATE,
    Frd_address        VARCHAR(100),
    Frd_dno            INT,

    FOREIGN KEY (Frd_ssn) REFERENCES Employee(Ssn),
    FOREIGN KEY (Frd_dno) REFERENCES Department(Dnumber)
);

-- before delete statement
-- Salvar em outra tabela os employees demitidos
CREATE TRIGGER trg_before_delete_employee
BEFORE DELETE ON Employee
FOR EACH ROW
BEGIN   
        INSERT INTO Fired_Employee(
            Frd_name,
            Frd_minit,
            Frd_last_name,
            Frd_ssn,
            Frd_bdate,
            Frd_address,
            Frd_dno
        )
        VALUES (
        OLD.Fname,
        OLD.Minit,
        OLD.Lname,
        OLD.Ssn,
        OLD.Bdate,
        OLD.Address,
        OLD.Dno
        );

END;        
