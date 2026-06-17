USE StudentManagement_DB;
GO
-- =============================================
-- TABLES
-- =============================================

CREATE TABLE Departments (
    DepartmentID    INT PRIMARY KEY IDENTITY(1,1),
    DeptName        NVARCHAR(100) NOT NULL UNIQUE,
    DeptCode        NVARCHAR(10)  NOT NULL UNIQUE,
    EstablishedYear INT CHECK (EstablishedYear >= 1990),
    CreatedAt       DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Programs (
    ProgramID      INT PRIMARY KEY IDENTITY(1,1),
    ProgramName    NVARCHAR(100) NOT NULL UNIQUE,
    ProgramCode    NVARCHAR(10)  NOT NULL UNIQUE,
    DepartmentID   INT NOT NULL,
    TotalSemesters INT DEFAULT 8,
    CreatedAt      DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

CREATE TABLE Students (
    StudentID    INT PRIMARY KEY IDENTITY(1,1),
    FirstName    NVARCHAR(50)  NOT NULL,
    LastName     NVARCHAR(50)  NOT NULL,
    Email        NVARCHAR(100) NOT NULL UNIQUE,
    CNIC         NVARCHAR(15)  NOT NULL UNIQUE,
    Phone        NVARCHAR(15),
    DepartmentID INT NOT NULL,
    ProgramID    INT NOT NULL,
    Semester     INT DEFAULT 1 CHECK (Semester BETWEEN 1 AND 8),
    CGPA         DECIMAL(3,2)  DEFAULT 0.00,
    Status       NVARCHAR(20)  DEFAULT 'Active',
    CreatedAt    DATETIME      DEFAULT GETDATE(),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    FOREIGN KEY (ProgramID)    REFERENCES Programs(ProgramID)
);
GO

CREATE TABLE Faculty (
    FacultyID    INT PRIMARY KEY IDENTITY(1,1),
    FirstName    NVARCHAR(50)  NOT NULL,
    LastName     NVARCHAR(50)  NOT NULL,
    Email        NVARCHAR(100) NOT NULL UNIQUE,
    CNIC         NVARCHAR(15)  NOT NULL UNIQUE,
    Phone        NVARCHAR(15),
    DepartmentID INT NOT NULL,
    Designation  NVARCHAR(50),
    JoiningDate  DATE          DEFAULT GETDATE(),
    Status       NVARCHAR(20)  DEFAULT 'Active',
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
GO

CREATE TABLE Staff (
    StaffID      INT PRIMARY KEY IDENTITY(1,1),
    FirstName    NVARCHAR(50)  NOT NULL,
    LastName     NVARCHAR(50)  NOT NULL,
    Email        NVARCHAR(100) NOT NULL UNIQUE,
    Phone        NVARCHAR(15),
    DepartmentID INT NOT NULL,
    Role         NVARCHAR(50),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
GO

CREATE TABLE Courses (
    CourseID       INT PRIMARY KEY IDENTITY(1,1),
    CourseName     NVARCHAR(100) NOT NULL,
    CourseCode     NVARCHAR(10)  NOT NULL UNIQUE,
    CreditHours    INT           NOT NULL CHECK (CreditHours BETWEEN 1 AND 4),
    DepartmentID   INT           NOT NULL,
    PrerequisiteID INT           NULL,
    FOREIGN KEY (DepartmentID)   REFERENCES Departments(DepartmentID),
    FOREIGN KEY (PrerequisiteID) REFERENCES Courses(CourseID)
);
GO

CREATE TABLE Sections (
    SectionID    INT PRIMARY KEY IDENTITY(1,1),
    SectionName  NVARCHAR(10)  NOT NULL,
    CourseID     INT           NOT NULL,
    FacultyID    INT           NOT NULL,
    Semester     INT           NOT NULL,
    AcademicYear NVARCHAR(10)  NOT NULL,
    TotalSeats   INT           DEFAULT 30,
    FilledSeats  INT           DEFAULT 0,
    FOREIGN KEY (CourseID)  REFERENCES Courses(CourseID),
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID)
);
GO

CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID    INT           NOT NULL,
    SectionID    INT           NOT NULL,
    EnrollDate   DATETIME      DEFAULT GETDATE(),
    Status       NVARCHAR(20)  DEFAULT 'Active',
    UNIQUE (StudentID, SectionID),
    FOREIGN KEY (StudentID)  REFERENCES Students(StudentID),
    FOREIGN KEY (SectionID)  REFERENCES Sections(SectionID)
);
GO

CREATE TABLE Grades (
    GradeID      INT PRIMARY KEY IDENTITY(1,1),
    EnrollmentID INT           NOT NULL,
    Marks        DECIMAL(5,2)  CHECK (Marks BETWEEN 0 AND 100),
    LetterGrade  NVARCHAR(5),
    GradePoints  DECIMAL(3,2),
    ExamType     NVARCHAR(20)  DEFAULT 'Final',
    CreatedAt    DATETIME      DEFAULT GETDATE(),
    FOREIGN KEY (EnrollmentID) REFERENCES Enrollments(EnrollmentID)
);
GO

CREATE TABLE AttendanceRecords (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    StudentID    INT           NOT NULL,
    SectionID    INT           NOT NULL,
    Date         DATE          NOT NULL,
    Status       NVARCHAR(10)  NOT NULL CHECK (Status IN ('Present','Absent','Leave')),
    FOREIGN KEY (StudentID)  REFERENCES Students(StudentID),
    FOREIGN KEY (SectionID)  REFERENCES Sections(SectionID)
);
GO

CREATE TABLE FeeStructure (
    FeeStructureID INT PRIMARY KEY IDENTITY(1,1),
    ProgramID      INT           NOT NULL,
    Semester       INT           NOT NULL,
    TuitionFee     DECIMAL(10,2) NOT NULL,
    LabFee         DECIMAL(10,2) DEFAULT 0,
    LibraryFee     DECIMAL(10,2) DEFAULT 0,
    OtherFee       DECIMAL(10,2) DEFAULT 0,
    TotalFee       AS (TuitionFee + LabFee + LibraryFee + OtherFee),
    AcademicYear   NVARCHAR(10)  NOT NULL,
    FOREIGN KEY (ProgramID) REFERENCES Programs(ProgramID)
);
GO

CREATE TABLE FeePayments (
    PaymentID     INT PRIMARY KEY IDENTITY(1,1),
    StudentID     INT           NOT NULL,
    Amount        DECIMAL(10,2) NOT NULL,
    PaymentDate   DATETIME      DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(20)  DEFAULT 'Cash',
    Status        NVARCHAR(20)  DEFAULT 'Paid',
    BankAccount   NVARCHAR(50),
    Remarks       NVARCHAR(200),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);
GO

CREATE TABLE LibraryItems (
    ItemID          INT PRIMARY KEY IDENTITY(1,1),
    Title           NVARCHAR(200) NOT NULL,
    Author          NVARCHAR(100) NOT NULL,
    ISBN            NVARCHAR(20)  UNIQUE,
    Category        NVARCHAR(50),
    TotalCopies     INT           DEFAULT 1,
    AvailableCopies INT           DEFAULT 1,
    AddedDate       DATETIME      DEFAULT GETDATE()
);
GO

CREATE TABLE LibraryIssues (
    IssueID    INT PRIMARY KEY IDENTITY(1,1),
    ItemID     INT           NOT NULL,
    StudentID  INT           NOT NULL,
    IssueDate  DATETIME      DEFAULT GETDATE(),
    DueDate    DATETIME      NOT NULL,
    ReturnDate DATETIME      NULL,
    Fine       DECIMAL(8,2)  DEFAULT 0,
    Status     NVARCHAR(20)  DEFAULT 'Issued',
    FOREIGN KEY (ItemID)    REFERENCES LibraryItems(ItemID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);
GO

CREATE TABLE Hostels (
    HostelID       INT PRIMARY KEY IDENTITY(1,1),
    HostelName     NVARCHAR(100) NOT NULL UNIQUE,
    HostelType     NVARCHAR(10)  NOT NULL CHECK (HostelType IN ('Boys','Girls')),
    TotalRooms     INT           NOT NULL,
    AvailableRooms INT           NOT NULL
);
GO

CREATE TABLE HostelAllotments (
    AllotmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID   INT           NOT NULL UNIQUE,
    HostelID    INT           NOT NULL,
    RoomNumber  NVARCHAR(10)  NOT NULL,
    AllotDate   DATETIME      DEFAULT GETDATE(),
    Status      NVARCHAR(20)  DEFAULT 'Active',
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (HostelID)  REFERENCES Hostels(HostelID)
);
GO

CREATE TABLE ExamSchedule (
    ExamID    INT PRIMARY KEY IDENTITY(1,1),
    SectionID INT           NOT NULL,
    ExamDate  DATETIME      NOT NULL,
    ExamType  NVARCHAR(20)  DEFAULT 'Final',
    Venue     NVARCHAR(100),
    Duration  INT           DEFAULT 180,
    FOREIGN KEY (SectionID) REFERENCES Sections(SectionID)
);
GO

CREATE TABLE Results (
    ResultID      INT PRIMARY KEY IDENTITY(1,1),
    StudentID     INT           NOT NULL,
    SectionID     INT           NOT NULL,
    TotalMarks    DECIMAL(5,2),
    ObtainedMarks DECIMAL(5,2),
    GPA           DECIMAL(3,2),
    Status        NVARCHAR(20)  DEFAULT 'Pass',
    CreatedAt     DATETIME      DEFAULT GETDATE(),
    FOREIGN KEY (StudentID)  REFERENCES Students(StudentID),
    FOREIGN KEY (SectionID)  REFERENCES Sections(SectionID)
);
GO

CREATE TABLE UserAccounts (
    UserID       INT PRIMARY KEY IDENTITY(1,1),
    Username     NVARCHAR(50)  NOT NULL UNIQUE,
    PasswordHash NVARCHAR(256) NOT NULL,
    Role         NVARCHAR(20)  NOT NULL CHECK (Role IN ('Admin','Student','Faculty','Finance')),
    ReferenceID  INT,
    IsActive     BIT           DEFAULT 1,
    CreatedAt    DATETIME      DEFAULT GETDATE()
);
GO

CREATE TABLE AuditLog (
    LogID     INT PRIMARY KEY IDENTITY(1,1),
    TableName NVARCHAR(50)  NOT NULL,
    Action    NVARCHAR(10)  NOT NULL,
    OldValue  NVARCHAR(MAX),
    NewValue  NVARCHAR(MAX),
    DBUser    NVARCHAR(100) DEFAULT SYSTEM_USER,
    LogTime   DATETIME      DEFAULT GETDATE()
);
GO

-- =============================================
-- STORED PROCEDURES
-- =============================================

CREATE OR ALTER PROCEDURE RegisterStudent
    @FirstName    NVARCHAR(50),
    @LastName     NVARCHAR(50),
    @Email        NVARCHAR(100),
    @CNIC         NVARCHAR(15),
    @Phone        NVARCHAR(15),
    @DeptID       INT,
    @ProgramID    INT,
    @NewStudentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            IF EXISTS (SELECT 1 FROM Students WHERE Email = @Email)
                THROW 50001, 'Email already exists.', 1;
            IF EXISTS (SELECT 1 FROM Students WHERE CNIC = @CNIC)
                THROW 50002, 'CNIC already exists.', 1;
            INSERT INTO Students (FirstName, LastName, Email, CNIC, Phone, DepartmentID, ProgramID)
            VALUES (@FirstName, @LastName, @Email, @CNIC, @Phone, @DeptID, @ProgramID);
            SET @NewStudentID = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE EnrollInCourse
    @StudentID    INT,
    @SectionID    INT,
    @EnrollmentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            IF EXISTS (SELECT 1 FROM Enrollments WHERE StudentID = @StudentID AND SectionID = @SectionID)
                THROW 50003, 'Student already enrolled in this section.', 1;
            IF (SELECT FilledSeats FROM Sections WHERE SectionID = @SectionID) >=
               (SELECT TotalSeats  FROM Sections WHERE SectionID = @SectionID)
                THROW 50004, 'No seats available in this section.', 1;
            INSERT INTO Enrollments (StudentID, SectionID)
            VALUES (@StudentID, @SectionID);
            SET @EnrollmentID = SCOPE_IDENTITY();
            UPDATE Sections SET FilledSeats = FilledSeats + 1
            WHERE SectionID = @SectionID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ProcessFeePayment
    @StudentID     INT,
    @Amount        DECIMAL(10,2),
    @PaymentMethod NVARCHAR(20),
    @PaymentID     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
                THROW 50005, 'Student not found.', 1;
            IF @Amount <= 0
                THROW 50006, 'Amount must be greater than zero.', 1;
            INSERT INTO FeePayments (StudentID, Amount, PaymentMethod)
            VALUES (@StudentID, @Amount, @PaymentMethod);
            SET @PaymentID = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE MarkAttendance
    @StudentID INT,
    @SectionID INT,
    @Date      DATE,
    @Status    NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Enrollments WHERE StudentID = @StudentID AND SectionID = @SectionID)
            THROW 50007, 'Student not enrolled in this section.', 1;
        IF EXISTS (SELECT 1 FROM AttendanceRecords WHERE StudentID = @StudentID AND SectionID = @SectionID AND Date = @Date)
            UPDATE AttendanceRecords SET Status = @Status
            WHERE StudentID = @StudentID AND SectionID = @SectionID AND Date = @Date;
        ELSE
            INSERT INTO AttendanceRecords (StudentID, SectionID, Date, Status)
            VALUES (@StudentID, @SectionID, @Date, @Status);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AddExamResult
    @StudentID     INT,
    @SectionID     INT,
    @ObtainedMarks DECIMAL(5,2),
    @TotalMarks    DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            IF @ObtainedMarks > @TotalMarks
                THROW 50008, 'Obtained marks cannot exceed total marks.', 1;
            INSERT INTO Results (StudentID, SectionID, TotalMarks, ObtainedMarks)
            VALUES (@StudentID, @SectionID, @TotalMarks, @ObtainedMarks);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE AllocateHostelRoom
    @StudentID   INT,
    @HostelID    INT,
    @RoomNumber  NVARCHAR(10),
    @AllotmentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            IF EXISTS (SELECT 1 FROM HostelAllotments WHERE StudentID = @StudentID)
                THROW 50009, 'Student already has a hostel room.', 1;
            IF (SELECT AvailableRooms FROM Hostels WHERE HostelID = @HostelID) <= 0
                THROW 50010, 'No rooms available in this hostel.', 1;
            INSERT INTO HostelAllotments (StudentID, HostelID, RoomNumber)
            VALUES (@StudentID, @HostelID, @RoomNumber);
            SET @AllotmentID = SCOPE_IDENTITY();
            UPDATE Hostels SET AvailableRooms = AvailableRooms - 1
            WHERE HostelID = @HostelID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE IssueLibraryBook
    @StudentID INT,
    @ItemID    INT,
    @DueDate   DATETIME,
    @IssueID   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            IF (SELECT AvailableCopies FROM LibraryItems WHERE ItemID = @ItemID) <= 0
                THROW 50011, 'No copies available.', 1;
            INSERT INTO LibraryIssues (ItemID, StudentID, DueDate)
            VALUES (@ItemID, @StudentID, @DueDate);
            SET @IssueID = SCOPE_IDENTITY();
            UPDATE LibraryItems SET AvailableCopies = AvailableCopies - 1
            WHERE ItemID = @ItemID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ReturnLibraryBook
    @IssueID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            IF NOT EXISTS (SELECT 1 FROM LibraryIssues WHERE IssueID = @IssueID)
                THROW 50012, 'Issue record not found.', 1;
            DECLARE @ItemID INT, @DueDate DATETIME, @Fine DECIMAL(8,2);
            SELECT @ItemID = ItemID, @DueDate = DueDate FROM LibraryIssues WHERE IssueID = @IssueID;
            SET @Fine = CASE WHEN GETDATE() > @DueDate
                        THEN DATEDIFF(DAY, @DueDate, GETDATE()) * 10
                        ELSE 0 END;
            UPDATE LibraryIssues
            SET ReturnDate = GETDATE(), Fine = @Fine, Status = 'Returned'
            WHERE IssueID = @IssueID;
            UPDATE LibraryItems SET AvailableCopies = AvailableCopies + 1
            WHERE ItemID = @ItemID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE CalculateSemesterGPA
    @StudentID INT,
    @Semester  INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        S.StudentID,
        S.FirstName + ' ' + S.LastName AS StudentName,
        AVG(G.GradePoints) AS SemesterGPA
    FROM Students S
    JOIN Enrollments E ON S.StudentID    = E.StudentID
    JOIN Sections SC   ON E.SectionID    = SC.SectionID
    JOIN Grades G      ON E.EnrollmentID = G.EnrollmentID
    WHERE S.StudentID = @StudentID AND SC.Semester = @Semester
    GROUP BY S.StudentID, S.FirstName, S.LastName;
END;
GO

CREATE OR ALTER PROCEDURE GetStudentReport
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        S.StudentID, S.FirstName, S.LastName, S.Email,
        D.DeptName, P.ProgramName, S.Semester, S.CGPA,
        COUNT(E.EnrollmentID) AS TotalCourses
    FROM Students S
    JOIN Departments D     ON S.DepartmentID = D.DepartmentID
    JOIN Programs P        ON S.ProgramID    = P.ProgramID
    LEFT JOIN Enrollments E ON S.StudentID   = E.StudentID
    WHERE S.StudentID = @StudentID
    GROUP BY S.StudentID, S.FirstName, S.LastName, S.Email,
             D.DeptName, P.ProgramName, S.Semester, S.CGPA;
END;
GO

CREATE OR ALTER PROCEDURE GetFacultyWorkload
    @FacultyID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        F.FacultyID,
        F.FirstName + ' ' + F.LastName AS FacultyName,
        COUNT(SC.SectionID) AS TotalSections,
        SUM(C.CreditHours)  AS TotalCreditHours
    FROM Faculty F
    JOIN Sections SC ON F.FacultyID = SC.FacultyID
    JOIN Courses C   ON SC.CourseID  = C.CourseID
    WHERE F.FacultyID = @FacultyID
    GROUP BY F.FacultyID, F.FirstName, F.LastName;
END;
GO

CREATE OR ALTER PROCEDURE GetDepartmentEnrollment
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        D.DeptName,
        COUNT(DISTINCT S.StudentID)    AS TotalStudents,
        COUNT(DISTINCT E.EnrollmentID) AS TotalEnrollments
    FROM Departments D
    JOIN Students S    ON D.DepartmentID = S.DepartmentID
    JOIN Enrollments E ON S.StudentID    = E.StudentID
    WHERE D.DepartmentID = @DepartmentID
    GROUP BY D.DeptName;
END;
GO

CREATE OR ALTER PROCEDURE GenerateFeeSlip
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        S.StudentID,
        S.FirstName + ' ' + S.LastName AS StudentName,
        P.ProgramName, S.Semester,
        FS.TuitionFee, FS.LabFee, FS.LibraryFee, FS.OtherFee, FS.TotalFee,
        ISNULL(SUM(FP.Amount), 0)              AS PaidAmount,
        FS.TotalFee - ISNULL(SUM(FP.Amount),0) AS OutstandingAmount
    FROM Students S
    JOIN Programs P      ON S.ProgramID = P.ProgramID
    JOIN FeeStructure FS ON S.ProgramID = FS.ProgramID AND S.Semester = FS.Semester
    LEFT JOIN FeePayments FP ON S.StudentID = FP.StudentID
    WHERE S.StudentID = @StudentID
    GROUP BY S.StudentID, S.FirstName, S.LastName, P.ProgramName,
             S.Semester, FS.TuitionFee, FS.LabFee, FS.LibraryFee,
             FS.OtherFee, FS.TotalFee;
END;
GO

CREATE OR ALTER PROCEDURE SearchCourses
    @SearchTerm NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT C.CourseID, C.CourseName, C.CourseCode, C.CreditHours, D.DeptName
    FROM Courses C
    JOIN Departments D ON C.DepartmentID = D.DepartmentID
    WHERE C.CourseName LIKE '%' + @SearchTerm + '%'
       OR C.CourseCode LIKE '%' + @SearchTerm + '%';
END;
GO

CREATE OR ALTER PROCEDURE GenerateTranscript
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        S.FirstName + ' ' + S.LastName AS StudentName,
        C.CourseName, C.CourseCode, C.CreditHours,
        SC.Semester, G.Marks, G.LetterGrade, G.GradePoints
    FROM Students S
    JOIN Enrollments E ON S.StudentID    = E.StudentID
    JOIN Sections SC   ON E.SectionID    = SC.SectionID
    JOIN Courses C     ON SC.CourseID    = C.CourseID
    JOIN Grades G      ON E.EnrollmentID = G.EnrollmentID
    WHERE S.StudentID = @StudentID
    ORDER BY SC.Semester, C.CourseName;
END;
GO

-- =============================================
-- FUNCTIONS
-- =============================================

CREATE OR ALTER FUNCTION fn_CalculateCGPA(@StudentID INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @CGPA DECIMAL(3,2);
    SELECT @CGPA = AVG(G.GradePoints)
    FROM Enrollments E
    JOIN Grades G ON E.EnrollmentID = G.EnrollmentID
    WHERE E.StudentID = @StudentID;
    RETURN ISNULL(@CGPA, 0.00);
END;
GO

CREATE OR ALTER FUNCTION fn_GetLetterGrade(@Marks DECIMAL(5,2))
RETURNS NVARCHAR(5)
AS
BEGIN
    RETURN CASE
        WHEN @Marks >= 90 THEN 'A+'
        WHEN @Marks >= 85 THEN 'A'
        WHEN @Marks >= 80 THEN 'A-'
        WHEN @Marks >= 75 THEN 'B+'
        WHEN @Marks >= 70 THEN 'B'
        WHEN @Marks >= 65 THEN 'B-'
        WHEN @Marks >= 60 THEN 'C+'
        WHEN @Marks >= 55 THEN 'C'
        WHEN @Marks >= 50 THEN 'D'
        ELSE 'F'
    END;
END;
GO

CREATE OR ALTER FUNCTION fn_IsLibraryItemAvailable(@ItemID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Available INT;
    SELECT @Available = AvailableCopies
    FROM LibraryItems WHERE ItemID = @ItemID;
    RETURN CASE WHEN ISNULL(@Available, 0) > 0 THEN 1 ELSE 0 END;
END;
GO

CREATE OR ALTER FUNCTION fn_GetOutstandingFee(@StudentID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalFee DECIMAL(10,2), @PaidFee DECIMAL(10,2);
    SELECT @TotalFee = FS.TotalFee
    FROM Students S
    JOIN FeeStructure FS ON S.ProgramID = FS.ProgramID
                        AND S.Semester  = FS.Semester
    WHERE S.StudentID = @StudentID;
    SELECT @PaidFee = ISNULL(SUM(Amount), 0)
    FROM FeePayments WHERE StudentID = @StudentID;
    RETURN ISNULL(@TotalFee, 0) - ISNULL(@PaidFee, 0);
END;
GO

CREATE OR ALTER FUNCTION fn_GetAttendancePercentage
    (@StudentID INT, @SectionID INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Total INT, @Present INT;
    SELECT @Total = COUNT(*)
    FROM AttendanceRecords
    WHERE StudentID = @StudentID AND SectionID = @SectionID;
    SELECT @Present = COUNT(*)
    FROM AttendanceRecords
    WHERE StudentID = @StudentID
      AND SectionID = @SectionID
      AND Status = 'Present';
    RETURN CASE WHEN @Total = 0 THEN 0
                ELSE CAST(@Present * 100.0 / @Total AS DECIMAL(5,2))
           END;
END;
GO

-- =============================================
-- TRIGGERS
-- =============================================

CREATE OR ALTER TRIGGER trg_AfterEnrollment
ON Enrollments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Sections
    SET FilledSeats = FilledSeats + 1
    WHERE SectionID IN (SELECT SectionID FROM inserted);
    INSERT INTO AuditLog (TableName, Action, NewValue)
    SELECT 'Enrollments', 'INSERT',
           'StudentID: ' + CAST(StudentID AS NVARCHAR) +
           ' SectionID: ' + CAST(SectionID AS NVARCHAR)
    FROM inserted;
END;
GO

CREATE OR ALTER TRIGGER trg_AfterGradeInsert
ON Grades
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE G
    SET G.LetterGrade = dbo.fn_GetLetterGrade(i.Marks),
        G.GradePoints = CASE
            WHEN i.Marks >= 90 THEN 4.00
            WHEN i.Marks >= 85 THEN 3.75
            WHEN i.Marks >= 80 THEN 3.50
            WHEN i.Marks >= 75 THEN 3.25
            WHEN i.Marks >= 70 THEN 3.00
            WHEN i.Marks >= 65 THEN 2.75
            WHEN i.Marks >= 60 THEN 2.50
            WHEN i.Marks >= 55 THEN 2.25
            WHEN i.Marks >= 50 THEN 2.00
            ELSE 0.00 END
    FROM Grades G
    JOIN inserted i ON G.GradeID = i.GradeID;
    UPDATE Students
    SET CGPA = dbo.fn_CalculateCGPA(E.StudentID)
    FROM Students
    JOIN Enrollments E ON Students.StudentID = E.StudentID
    JOIN inserted i    ON E.EnrollmentID     = i.EnrollmentID;
END;
GO

CREATE OR ALTER TRIGGER trg_AfterFeePayment
ON FeePayments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Action, NewValue)
    SELECT 'FeePayments', 'INSERT',
           'StudentID: ' + CAST(StudentID AS NVARCHAR) +
           ' Amount: '   + CAST(Amount AS NVARCHAR)
    FROM inserted;
END;
GO

CREATE OR ALTER TRIGGER trg_AuditStudentUpdate
ON Students
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Action, OldValue, NewValue)
    SELECT
        'Students', 'UPDATE',
        'OldName: ' + d.FirstName + ' ' + d.LastName +
        ' OldEmail: ' + d.Email,
        'NewName: ' + i.FirstName + ' ' + i.LastName +
        ' NewEmail: ' + i.Email
    FROM inserted i
    JOIN deleted d ON i.StudentID = d.StudentID;
END;
GO

CREATE OR ALTER TRIGGER trg_PreventDuplicateEnrollment
ON Enrollments
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM Enrollments E
        JOIN inserted i ON E.StudentID = i.StudentID
                       AND E.SectionID = i.SectionID
    )
    BEGIN
        RAISERROR('Student is already enrolled in this section.', 16, 1);
        RETURN;
    END
    INSERT INTO Enrollments (StudentID, SectionID, EnrollDate, Status)
    SELECT StudentID, SectionID, EnrollDate, Status FROM inserted;
END;
GO

CREATE OR ALTER TRIGGER trg_AfterLibraryReturn
ON LibraryIssues
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(Status)
    BEGIN
        UPDATE LibraryItems
        SET AvailableCopies = AvailableCopies + 1
        WHERE ItemID IN (
            SELECT i.ItemID FROM inserted i
            JOIN deleted d ON i.IssueID = d.IssueID
            WHERE i.Status = 'Returned' AND d.Status = 'Issued'
        );
    END
END;
GO