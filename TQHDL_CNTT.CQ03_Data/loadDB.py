import pandas as pd
from sqlalchemy import create_engine
import urllib
from faker import Faker
import random

# Khởi tạo Faker để tạo tên ngẫu nhiên
fake = Faker()

# Đường dẫn file CSV
csv_file = r"C:\Users\Huy\Desktop\code\visualization\Lab4\Data_BaoCao\Impact_of_Remote_Work_on_Mental_Health.csv"

# Chuỗi kết nối SQL Server
conn_str = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=DESKTOP-HKIPI1M;"
    "DATABASE=Remote_Work_Impact;"
    "Trusted_Connection=yes;"
    "Encrypt=no;"
)

# Hàm tạo date_of_birth từ tuổi
def generate_dob(age):
    current_year = 2025  # Năm hiện tại
    birth_year = current_year - age
    # Tạo ngày và tháng ngẫu nhiên
    month = random.randint(1, 12)
    day = random.randint(1, 28)  # Giới hạn ngày để tránh lỗi
    return f"{birth_year}-{month:02d}-{day:02d}"

try:
    # Đọc file CSV
    df = pd.read_csv(csv_file)

    # Thêm cột name và date_of_birth
    df['name'] = [fake.name() for _ in range(len(df))]  # Tạo tên ngẫu nhiên
    df['date_of_birth'] = df['Age'].apply(generate_dob)  # Tạo ngày sinh từ tuổi

    # Chuẩn bị chuỗi kết nối cho SQLAlchemy
    params = urllib.parse.quote_plus(conn_str)
    engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

    # 1. Tải dữ liệu vào bảng Employees
    employees_df = df[['Employee_ID', 'name', 'date_of_birth', 'Gender', 'Region']].rename(columns={
        'Employee_ID': 'employee_id',
        'name': 'name',
        'date_of_birth': 'date_of_birth',
        'Gender': 'gender',
        'Region': 'region'
    })
    employees_df.to_sql('Employees', engine, if_exists='append', index=False)
    print("Đã nhập dữ liệu vào bảng Employees")

    # 2. Tải dữ liệu vào bảng Job_Details
    job_details_df = df[['Employee_ID', 'Job_Role', 'Industry', 'Years_of_Experience']].rename(columns={
        'Employee_ID': 'employee_id',
        'Job_Role': 'job_role',
        'Industry': 'industry',
        'Years_of_Experience': 'years_of_experience'
    })
    job_details_df.to_sql('Job_Details', engine, if_exists='append', index=False)
    print("Đã nhập dữ liệu vào bảng Job_Details")

    # 3. Tải dữ liệu vào bảng Work_Conditions
    work_conditions_df = df[['Employee_ID', 'Work_Location', 'Hours_Worked_Per_Week', 
                            'Number_of_Virtual_Meetings', 'Company_Support_for_Remote_Work']].rename(columns={
        'Employee_ID': 'employee_id',
        'Work_Location': 'work_location',
        'Hours_Worked_Per_Week': 'hours_worked_per_week',
        'Number_of_Virtual_Meetings': 'number_of_virtual_meetings',
        'Company_Support_for_Remote_Work': 'company_support_for_remote_work'
    })
    work_conditions_df.to_sql('Work_Conditions', engine, if_exists='append', index=False)
    print("Đã nhập dữ liệu vào bảng Work_Conditions")

    # 4. Tải dữ liệu vào bảng Mental_Health_and_Habits
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
    print("Đã nhập dữ liệu vào bảng Mental_Health_and_Habits")

except Exception as e:
    print(f"Lỗi xảy ra: {str(e)}")

finally:
    print("Hoàn tất quá trình nhập dữ liệu")