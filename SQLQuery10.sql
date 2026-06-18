USE StudentManagement_DB;
GO

-- Add Departments first
INSERT INTO Departments (DeptName, DeptCode, EstablishedYear)
VALUES 
('Computer Science', 'CS', 2000),
('Electrical Engineering', 'EE', 1995),
('Mechanical Engineering', 'ME', 1998);
GO

-- Add Programs
INSERT INTO Programs (ProgramName, ProgramCode, DepartmentID, TotalSemesters)
VALUES 
('BS Computer Science', 'BSCS', 1, 8),
('BS Electrical Engineering', 'BSEE', 2, 8),
('BS Mechanical Engineering', 'BSME', 3, 8);
GO

-- Add Students
INSERT INTO Students (FirstName, LastName, Email, CNIC, Phone, DepartmentID, ProgramID, Semester)
VALUES 
('Ali', 'Ahmed', 'ali@hitec.edu.pk', '3520112345671', '03001234567', 1, 1, 3),
('Sara', 'Khan', 'sara@hitec.edu.pk', '3520112345672', '03001234568', 1, 1, 2),
('Usman', 'Ali', 'usman@hitec.edu.pk', '3520112345673', '03001234569', 2, 2, 4),
('Fatima', 'Malik', 'fatima@hitec.edu.pk', '3520112345674', '03001234560', 1, 1, 1);
GO