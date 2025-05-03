DROP DATABASE Remote_Work_Impact

CREATE DATABASE Remote_Work_Impact
ON PRIMARY 
(
    NAME = 'Remote_Work_Impact_Data',
    FILENAME = 'D:\DB\Remote_Work_Impact_Data.mdf',
    SIZE = 100MB,
    MAXSIZE = 1000MB,
    FILEGROWTH = 10MB
)
LOG ON 
(
    NAME = 'Remote_Work_Impact_Log',
    FILENAME = 'D:\DB\Remote_Work_Impact_Log.ldf',
    SIZE = 50MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 5MB
);

USE Remote_Work_Impact;

-- Tạo bảng Employees (Thông tin nhân viên)
CREATE TABLE Employees (
    employee_id NVARCHAR(10) PRIMARY KEY, -- Mã nhân viên, ví dụ: EMP0001
	name NVARCHAR(50), -- Tên nhân viên, đủ dài để chứa họ tên
    date_of_birth DATE, -- Ngày tháng năm sinh
    gender NVARCHAR(20), -- Giới tính: Female, Male, Non-binary, Prefer not to say
    region NVARCHAR(20) -- Khu vực: Europe, Asia, North America, ...
);

-- Tạo bảng Job_Details (Chi tiết công việc)
CREATE TABLE Job_Details (
    employee_id NVARCHAR(10), -- Liên kết với Employees
    job_role NVARCHAR(50), -- Vai trò công việc: HR, Data Scientist, ...
    industry NVARCHAR(50), -- Ngành: Healthcare, IT, ...
    years_of_experience INT, -- Số năm kinh nghiệm
    CONSTRAINT PK_Job_Details PRIMARY KEY (employee_id), -- Khóa chính
    CONSTRAINT FK_Job_Details_Employees FOREIGN KEY (employee_id) 
        REFERENCES Employees(employee_id) -- Khóa ngoại liên kết với Employees
);

-- Tạo bảng Work_Conditions (Điều kiện làm việc)
CREATE TABLE Work_Conditions (
    employee_id NVARCHAR(10), -- Liên kết với Employees
    work_location NVARCHAR(20), -- Nơi làm việc: Remote, Onsite, Hybrid
    hours_worked_per_week INT, -- Số giờ làm việc mỗi tuần
    number_of_virtual_meetings INT, -- Số cuộc họp ảo
    company_support_for_remote_work INT, -- Mức hỗ trợ làm việc từ xa (1-5)
    CONSTRAINT PK_Work_Conditions PRIMARY KEY (employee_id), -- Khóa chính
    CONSTRAINT FK_Work_Conditions_Employees FOREIGN KEY (employee_id) 
        REFERENCES Employees(employee_id) -- Khóa ngoại liên kết với Employees
);

-- Tạo bảng Mental_Health_and_Habits (Sức khỏe tinh thần và thói quen)
CREATE TABLE Mental_Health_and_Habits (
    employee_id NVARCHAR(10), -- Liên kết với Employees
    work_life_balance_rating INT, -- Đánh giá cân bằng công việc-cuộc sống (1-5)
    stress_level NVARCHAR(10), -- Mức độ căng thẳng: Low, Medium, High
    mental_health_condition NVARCHAR(20), -- Tình trạng sức khỏe tinh thần: Depression, Anxiety, Burnout, None
    access_to_mental_health_resources NVARCHAR(5), -- Có tài nguyên sức khỏe tinh thần: Yes/No
    productivity_change NVARCHAR(20), -- Thay đổi năng suất: Increase, Decrease, No Change
    social_isolation_rating INT, -- Đánh giá cô lập xã hội (1-5)
    satisfaction_with_remote_work NVARCHAR(20), -- Mức hài lòng làm việc từ xa: Satisfied, Neutral, Unsatisfied
    physical_activity NVARCHAR(20), -- Hoạt động thể chất: None, Weekly, Daily
    sleep_quality NVARCHAR(20), -- Chất lượng giấc ngủ: Poor, Average, Good
    CONSTRAINT PK_Mental_Health_and_Habits PRIMARY KEY (employee_id), -- Khóa chính
    CONSTRAINT FK_Mental_Health_and_Habits_Employees FOREIGN KEY (employee_id) 
        REFERENCES Employees(employee_id) -- Khóa ngoại liên kết với Employees
);

CREATE VIEW vw_Remote_Work_Impact AS
SELECT 
    e.employee_id AS Employee_ID,
    e.name AS Name, -- Cột mới, không có trong CSV gốc
    DATEDIFF(YEAR, e.date_of_birth, '2025-04-13') AS Age, -- Tính tuổi từ date_of_birth
    e.gender AS Gender,
    e.region AS Region,
    jd.job_role AS Job_Role,
    jd.industry AS Industry,
    jd.years_of_experience AS Years_of_Experience,
    wc.work_location AS Work_Location,
    wc.hours_worked_per_week AS Hours_Worked_Per_Week,
    wc.number_of_virtual_meetings AS Number_of_Virtual_Meetings,
    wc.company_support_for_remote_work AS Company_Support_for_Remote_Work,
    mh.work_life_balance_rating AS Work_Life_Balance_Rating,
    mh.stress_level AS Stress_Level,
    mh.mental_health_condition AS Mental_Health_Condition,
    mh.access_to_mental_health_resources AS Access_to_Mental_Health_Resources,
    mh.productivity_change AS Productivity_Change,
    mh.social_isolation_rating AS Social_Isolation_Rating,
    mh.satisfaction_with_remote_work AS Satisfaction_with_Remote_Work,
    mh.physical_activity AS Physical_Activity,
    mh.sleep_quality AS Sleep_Quality
FROM Employees e
INNER JOIN Job_Details jd ON e.employee_id = jd.employee_id
INNER JOIN Work_Conditions wc ON e.employee_id = wc.employee_id
INNER JOIN Mental_Health_and_Habits mh ON e.employee_id = mh.employee_id;

--- 
CREATE VIEW vw_Mental_Health_By_Industry AS
SELECT 
    jd.industry AS Industry,
    COUNT(*) AS Total_Employees,
    AVG(CAST(mh.work_life_balance_rating AS FLOAT)) AS Avg_Work_Life_Balance,
    AVG(CAST(mh.social_isolation_rating AS FLOAT)) AS Avg_Social_Isolation,
    SUM(CASE WHEN mh.stress_level = 'Low' THEN 1 ELSE 0 END) AS Low_Stress_Employees,
    SUM(CASE WHEN mh.stress_level = 'Medium' THEN 1 ELSE 0 END) AS Medium_Stress_Employees,
    SUM(CASE WHEN mh.stress_level = 'High' THEN 1 ELSE 0 END) AS High_Stress_Employees,
    SUM(CASE WHEN mh.mental_health_condition != 'None' THEN 1 ELSE 0 END) AS Employees_With_Mental_Health_Issues,
    SUM(CASE WHEN mh.access_to_mental_health_resources = 'Yes' THEN 1 ELSE 0 END) AS Employees_With_Resource_Access
FROM Job_Details jd
INNER JOIN Mental_Health_and_Habits mh ON jd.employee_id = mh.employee_id
GROUP BY jd.industry;

---

CREATE VIEW vw_Productivity_By_Work_Location AS
SELECT 
    wc.work_location AS Work_Location,
    COUNT(*) AS Total_Employees,
    AVG(CAST(wc.hours_worked_per_week AS FLOAT)) AS Avg_Hours_Worked,
    AVG(CAST(wc.number_of_virtual_meetings AS FLOAT)) AS Avg_Virtual_Meetings,
    SUM(CASE WHEN mh.productivity_change = 'Increase' THEN 1 ELSE 0 END) AS Employees_With_Increased_Productivity,
    SUM(CASE WHEN mh.productivity_change = 'Decrease' THEN 1 ELSE 0 END) AS Employees_With_Decreased_Productivity,
    SUM(CASE WHEN mh.satisfaction_with_remote_work = 'Satisfied' THEN 1 ELSE 0 END) AS Satisfied_Employees,
    SUM(CASE WHEN mh.satisfaction_with_remote_work = 'Unsatisfied' THEN 1 ELSE 0 END) AS Unsatisfied_Employees
FROM Work_Conditions wc
INNER JOIN Mental_Health_and_Habits mh ON wc.employee_id = mh.employee_id
GROUP BY wc.work_location;

---

CREATE VIEW vw_Health_Habits_Impact AS
SELECT 
    mh.physical_activity AS Physical_Activity,
    mh.sleep_quality AS Sleep_Quality,
    COUNT(*) AS Total_Employees,
    AVG(CAST(mh.work_life_balance_rating AS FLOAT)) AS Avg_Work_Life_Balance,
    AVG(CAST(mh.social_isolation_rating AS FLOAT)) AS Avg_Social_Isolation,
    SUM(CASE WHEN mh.stress_level = 'High' THEN 1 ELSE 0 END) AS High_Stress_Employees,
    SUM(CASE WHEN mh.mental_health_condition != 'None' THEN 1 ELSE 0 END) AS Employees_With_Mental_Health_Issues
FROM Mental_Health_and_Habits mh
GROUP BY mh.physical_activity, mh.sleep_quality;

---

CREATE VIEW vw_Employee_Demographics_Analysis AS
SELECT 
    e.gender AS Gender,
    e.region AS Region,
    CASE 
        WHEN DATEDIFF(YEAR, e.date_of_birth, '2025-04-13') < 30 THEN '<30'
        WHEN DATEDIFF(YEAR, e.date_of_birth, '2025-04-13') BETWEEN 30 AND 45 THEN '30-45'
        ELSE '>45'
    END AS Age_Group,
    COUNT(*) AS Total_Employees,
    AVG(CAST(mh.work_life_balance_rating AS FLOAT)) AS Avg_Work_Life_Balance,
    SUM(CASE WHEN mh.stress_level = 'High' THEN 1 ELSE 0 END) AS High_Stress_Employees,
    SUM(CASE WHEN mh.productivity_change = 'Increase' THEN 1 ELSE 0 END) AS Increased_Productivity,
    SUM(CASE WHEN mh.satisfaction_with_remote_work = 'Satisfied' THEN 1 ELSE 0 END) AS Satisfied_Employees
FROM Employees e
INNER JOIN Mental_Health_and_Habits mh ON e.employee_id = mh.employee_id
GROUP BY e.gender, e.region, 
    CASE 
        WHEN DATEDIFF(YEAR, e.date_of_birth, '2025-04-13') < 30 THEN '<30'
        WHEN DATEDIFF(YEAR, e.date_of_birth, '2025-04-13') BETWEEN 30 AND 45 THEN '30-45'
        ELSE '>45'
    END;

---

CREATE OR ALTER VIEW vw_Employee_Emotional_Impact_Analysis AS
SELECT 
    e.region AS Region,
    jd.industry AS Industry,
    jd.job_role AS Job_Role,
    e.gender AS Gender,
    wc.work_location AS Current_Work_Location,
    CASE 
        WHEN DATEDIFF(YEAR, e.date_of_birth, '2025-04-16') < 30 THEN '<30'
        WHEN DATEDIFF(YEAR, e.date_of_birth, '2025-04-16') BETWEEN 30 AND 39 THEN '30-40'
        WHEN DATEDIFF(YEAR, e.date_of_birth, '2025-04-16') BETWEEN 40 AND 49 THEN '40-50'
        ELSE '>=50'
    END AS Age_Group,
    COUNT(*) AS Total_Employees,
    AVG(CAST(mh.social_isolation_rating AS FLOAT)) AS Avg_Social_Isolation_Rating,
    AVG(CAST(mh.work_life_balance_rating AS FLOAT)) AS Avg_Work_Life_Balance_Rating,
    AVG(CAST(wc.company_support_for_remote_work AS FLOAT)) AS Avg_Company_Support,
    AVG(CAST(wc.hours_worked_per_week AS FLOAT)) AS Avg_Hours_Worked_Per_Week,
    100.0 * SUM(CASE WHEN mh.stress_level = 'High' THEN 1 ELSE 0 END) / COUNT(*) AS High_Stress_Percentage,
    100.0 * SUM(CASE WHEN mh.productivity_change = 'Increase' THEN 1 ELSE 0 END) / COUNT(*) AS Productivity_Increase_Percentage,
    100.0 * SUM(CASE WHEN mh.productivity_change = 'Decrease' THEN 1 ELSE 0 END) / COUNT(*) AS Productivity_Decrease_Percentage,
    100.0 * SUM(CASE WHEN mh.satisfaction_with_remote_work = 'Satisfied' THEN 1 ELSE 0 END) / COUNT(*) AS Satisfaction_Percentage,
    100.0 * SUM(CASE WHEN mh.satisfaction_with_remote_work = 'Unsatisfied' THEN 1 ELSE 0 END) / COUNT(*) AS Unsatisfaction_Percentage
FROM Employees e
INNER JOIN Mental_Health_and_Habits mh ON e.employee_id = mh.employee_id
INNER JOIN Work_Conditions wc ON e.employee_id = wc.employee_id
INNER JOIN Job_Details jd ON e.employee_id = jd.employee_id
WHERE 
    e.gender IN ('Male', 'Female')
    AND e.date_of_birth IS NOT NULL
    AND e.region IS NOT NULL
    AND jd.industry IS NOT NULL
    AND jd.job_role IS NOT NULL
    AND wc.work_location IS NOT NULL
    AND mh.social_isolation_rating IS NOT NULL
    AND mh.work_life_balance_rating IS NOT NULL
    AND wc.company_support_for_remote_work IS NOT NULL
    AND wc.hours_worked_per_week IS NOT NULL
    AND mh.stress_level IS NOT NULL
    AND mh.productivity_change IS NOT NULL
    AND mh.satisfaction_with_remote_work IS NOT NULL
GROUP BY 
    e.region,
    jd.industry,
    jd.job_role,
    e.gender,
    wc.work_location,
    CASE 
        WHEN DATEDIFF(YEAR, e.date_of_birth, '2025-04-16') < 30 THEN '<30'
        WHEN DATEDIFF(YEAR, e.date_of_birth, '2025-04-16') BETWEEN 30 AND 39 THEN '30-40'
        WHEN DATEDIFF(YEAR, e.date_of_birth, '2025-04-16') BETWEEN 40 AND 49 THEN '40-50'
        ELSE '>=50'
    END;


SELECT * FROM vw_Remote_Work_Impact
SELECT * FROM vw_Mental_Health_By_Industry;
SELECT * FROM vw_Productivity_By_Work_Location;
SELECT * FROM vw_Health_Habits_Impact;
SELECT * FROM vw_Employee_Demographics_Analysis;
SELECT * FROM vw_Employee_Emotional_Impact_Analysis;
SELECT * FROM Employees


CREATE INDEX idx_industry ON Job_Details(industry);
CREATE INDEX idx_job_role ON Job_Details(job_role);
CREATE INDEX idx_gender ON Employees(gender);
CREATE INDEX idx_work_location ON Work_Conditions(work_location);

SELECT * FROM vw_Employee_Emotional_Impact_Analysis
WHERE Region = 'Africa' and Gender = 'Male' and Current_Work_Location = 'Remote' and Industry = 'Education' and Job_Role = 'Designer'