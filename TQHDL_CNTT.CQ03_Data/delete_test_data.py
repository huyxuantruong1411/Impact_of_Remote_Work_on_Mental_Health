from sqlalchemy import create_engine, text
import urllib

# Chuỗi kết nối SQL Server
conn_str = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=DESKTOP-HKIPI1M;"
    "DATABASE=Remote_Work_Impact;"
    "Trusted_Connection=yes;"
    "Encrypt=no;"
)

try:
    # Chuẩn bị chuỗi kết nối cho SQLAlchemy
    params = urllib.parse.quote_plus(conn_str)
    engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

    # Kết nối với cơ sở dữ liệu
    with engine.connect() as conn:
        # Kiểm tra số bản ghi thử nghiệm trước khi xóa
        count_query = text("SELECT COUNT(*) FROM Employees WHERE employee_id LIKE 'TEST_%'")
        result = conn.execute(count_query)
        num_records = result.scalar()
        print(f"Số bản ghi thử nghiệm hiện có: {num_records}")

        if num_records == 0:
            print("Không có bản ghi thử nghiệm nào để xóa (employee_id bắt đầu bằng 'TEST_').")
        else:
            # Xóa dữ liệu thử nghiệm từ các bảng (theo thứ tự ngược để tránh lỗi khóa ngoại)
            # 1. Xóa từ Mental_Health_and_Habits
            delete_query = text("DELETE FROM Mental_Health_and_Habits WHERE employee_id LIKE 'TEST_%'")
            result = conn.execute(delete_query)
            print(f"Đã xóa {result.rowcount} bản ghi từ bảng Mental_Health_and_Habits")

            # 2. Xóa từ Work_Conditions
            delete_query = text("DELETE FROM Work_Conditions WHERE employee_id LIKE 'TEST_%'")
            result = conn.execute(delete_query)
            print(f"Đã xóa {result.rowcount} bản ghi từ bảng Work_Conditions")

            # 3. Xóa từ Job_Details
            delete_query = text("DELETE FROM Job_Details WHERE employee_id LIKE 'TEST_%'")
            result = conn.execute(delete_query)
            print(f"Đã xóa {result.rowcount} bản ghi từ bảng Job_Details")

            # 4. Xóa từ Employees
            delete_query = text("DELETE FROM Employees WHERE employee_id LIKE 'TEST_%'")
            result = conn.execute(delete_query)
            print(f"Đã xóa {result.rowcount} bản ghi từ bảng Employees")

            # Commit giao dịch
            conn.commit()

except Exception as e:
    print(f"Lỗi xảy ra: {str(e)}")

finally:
    print("Hoàn tất quá trình xóa dữ liệu thử nghiệm")