import pandas as pd
from sqlalchemy import create_engine
import urllib
from faker import Faker
import random

# Khởi tạo Faker để tạo dữ liệu giả
fake = Faker()

# Chuỗi kết nối SQL Server
conn_str = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=DESKTOP-HKIPI1M;"
    "DATABASE=Remote_Work_Impact;"
    "Trusted_Connection=yes;"
    "Encrypt=no;"
)

# Tạo dữ liệu mẫu
num_records = 1000  # Số bản ghi thử nghiệm
data = {
    'Employee_ID': [f'TEST_{i:04d}' for i in range(1, num_records + 1)],  # TEST_0001, TEST_0002, ...
    'name': [fake.name() for _ in range(num_records)],
    'Age': [random.randint(20, 60) for _ in range(num_records)],
    'Gender': [random.choice(['Male', 'Female', 'Non-binary']) for _ in range(num_records)],
    'Region': [random.choice(['Asia', 'Europe', 'North America', 'South America', 'Africa', 'Australia']) for _ in range(num_records)],
    'Job_Role': [random.choice(['Sales', 'Project Manager', 'Software Engineer', 'Designer', 'HR', 'Data Scientist', 'Marketing']) for _ in range(num_records)],
    'Industry': [random.choice(['Healthcare', 'IT', 'Finance', 'Education', 'Retail', 'Manufacturing', 'Entertainment']) for _ in range(num_records)],
    'Years_of_Experience': [random.randint(1, 30) for _ in range(num_records)],
    'Work_Location': [random.choice(['Remote', 'Hybrid', 'Onsite']) for _ in range(num_records)],
    'Hours_Worked_Per_Week': [random.randint(20, 60) for _ in range(num_records)],
    'Number_of_Virtual_Meetings': [random.randint(0, 20) for _ in range(num_records)],
    'Company_Support_for_Remote_Work': [random.randint(1, 5) for _ in range(num_records)],
    'Work_Life_Balance_Rating': [random.randint(1, 5) for _ in range(num_records)],
    'Stress_Level': [random.choice(['Low', 'Medium', 'High']) for _ in range(num_records)],
    'Mental_Health_Condition': [random.choice(['None', 'Anxiety', 'Depression', 'Burnout']) for _ in range(num_records)],
    'Access_to_Mental_Health_Resources': [random.choice(['Yes', 'No']) for _ in range(num_records)],
    'Productivity_Change': [random.choice(['Increase', 'Decrease', 'No Change']) for _ in range(num_records)],
    'Social_Isolation_Rating': [random.randint(1, 5) for _ in range(num_records)],
    'Satisfaction_with_Remote_Work': [random.choice(['Satisfied', 'Unsatisfied', 'Neutral']) for _ in range(num_records)],
    'Physical_Activity': [random.choice(['None', 'Weekly', 'Daily']) for _ in range(num_records)],
    'Sleep_Quality': [random.choice(['Poor', 'Average', 'Good']) for _ in range(num_records)]
}

# Tạo DataFrame
df = pd.DataFrame(data)

# Hàm tạo date_of_birth từ tuổi
def generate_dob(age):
    current_year = 2025
    birth_year = current_year - age
    month = random.randint(1, 12)
    day = random.randint(1, 28)
    return f"{birth_year}-{month:02d}-{day:02d}"

# Thêm cột date_of_birth
df['date_of_birth'] = df['Age'].apply(generate_dob)

try:
    # Chuẩn bị chuỗi kết nối cho SQLAlchemy
    params = urllib.parse.quote_plus(conn_str)
    engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

    # 1. Chèn vào bảng Employees
    employees_df = df[['Employee_ID', 'name', 'date_of_birth', 'Gender', 'Region']].rename(columns={
        'Employee_ID': 'employee_id',
        'name': 'name',
        'date_of_birth': 'date_of_birth',
        'Gender': 'gender',
        'Region': 'region'
    })
    employees_df.to_sql('Employees', engine, if_exists='append', index=False)
    print(f"Đã chèn {num_records} bản ghi vào bảng Employees")

    # 2. Chèn vào bảng Job_Details
    job_details_df = df[['Employee_ID', 'Job_Role', 'Industry', 'Years_of_Experience']].rename(columns={
        'Employee_ID': 'employee_id',
        'Job_Role': 'job_role',
        'Industry': 'industry',
        'Years_of_Experience': 'years_of_experience'
    })
    job_details_df.to_sql('Job_Details', engine, if_exists='append', index=False)
    print(f"Đã chèn {num_records} bản ghi vào bảng Job_Details")

    # 3. Chèn vào bảng Work_Conditions
    work_conditions_df = df[['Employee_ID', 'Work_Location', 'Hours_Worked_Per_Week', 
                            'Number_of_Virtual_Meetings', 'Company_Support_for_Remote_Work']].rename(columns={
        'Employee_ID': 'employee_id',
        'Work_Location': 'work_location',
        'Hours_Worked_Per_Week': 'hours_worked_per_week',
        'Number_of_Virtual_Meetings': 'number_of_virtual_meetings',
        'Company_Support_for_Remote_Work': 'company_support_for_remote_work'
    })
    work_conditions_df.to_sql('Work_Conditions', engine, if_exists='append', index=False)
    print(f"Đã chèn {num_records} bản ghi vào bảng Work_Conditions")

    # 4. Chèn vào bảng Mental_Health_and_Habits
    mental_health_df = df[['Employee_ID', 'Work_Life_Balance_Rating', 'Stress_Level', 
                           'Mental_Health_Condition', 'Access_to_Mental_Health_Resources', 
                           'Productivity_Change', 'Social_Isolation_Rating', 
                           'Satisfaction_with_Remote_Work', 'Physical_Activity', 
                           'Sleep_Quality']].rename(columns={
        'Employee_ID': 'employee_id',
        'Work_Life_Balance_Rating': 'work_life_balance_rating',
        'Stress_Level': 'stress_level',
        'Mental_Health_Condition': 'mental_health_condition',
        'Access_to_Mental_Health_Resources': 'access_to_mental_health_resources',
        'Productivity_Change': 'productivity_change',
        'Social_Isolation_Rating': 'social_isolation_rating',
        'Satisfaction_with_Remote_Work': 'satisfaction_with_remote_work',
        'Physical_Activity': 'physical_activity',
        'Sleep_Quality': 'sleep_quality'
    })
    mental_health_df.to_sql('Mental_Health_and_Habits', engine, if_exists='append', index=False)
    print(f"Đã chèn {num_records} bản ghi vào bảng Mental_Health_and_Habits")

except Exception as e:
    print(f"Lỗi xảy ra: {str(e)}")

finally:
    print("Hoàn tất quá trình chèn dữ liệu thử nghiệm")