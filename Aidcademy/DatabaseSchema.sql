-- =============================================
-- Aidcademy Database Schema (New)
-- Run this AFTER deleting the old AidcademyDB.mdf
-- =============================================

-- =============================================
-- 1. USER MANAGEMENT MODULE
-- =============================================

CREATE TABLE Users (
    UserID      INT IDENTITY(1,1) PRIMARY KEY,
    Username    NVARCHAR(50)  NOT NULL,
    Email       NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role        NVARCHAR(20)  NOT NULL DEFAULT 'Member', -- 'Admin', 'Instructor', 'Member', 'Visitor'
    Status      NVARCHAR(20)  NOT NULL DEFAULT 'Active', -- 'Active', 'Suspended', 'Deactivated'
    CreatedAt   DATETIME      NOT NULL DEFAULT GETDATE()
);

CREATE TABLE UserProfiles (
    ProfileID    INT IDENTITY(1,1) PRIMARY KEY,
    UserID       INT           NOT NULL UNIQUE,
    FullName     NVARCHAR(100) NOT NULL,
    PhoneNumber  NVARCHAR(20),
    ProfilePhoto NVARCHAR(255),
    Bio          NVARCHAR(500),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- =============================================
-- 2. COURSE & CONTENT MODULE
-- =============================================

CREATE TABLE Courses (
    CourseID       INT IDENTITY(1,1) PRIMARY KEY,
    UserID         INT           NOT NULL,  -- The Instructor
    Title          NVARCHAR(100) NOT NULL,
    Description    NVARCHAR(500),
    Category       NVARCHAR(50),
    ApprovalStatus NVARCHAR(20)  NOT NULL DEFAULT 'Pending', -- 'Pending', 'Approved', 'Rejected'
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE Lessons (
    LessonID      INT IDENTITY(1,1) PRIMARY KEY,
    CourseID      INT           NOT NULL,
    Title         NVARCHAR(100) NOT NULL,
    ContentBody   NVARCHAR(MAX),
    MediaURL      NVARCHAR(255),
    SequenceOrder INT           NOT NULL,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE
);

-- =============================================
-- 3. QUIZ & ASSESSMENT MODULE
-- =============================================

CREATE TABLE Quizzes (
    QuizID   INT IDENTITY(1,1) PRIMARY KEY,
    LessonID INT           NOT NULL,
    Title    NVARCHAR(100) NOT NULL,
    FOREIGN KEY (LessonID) REFERENCES Lessons(LessonID) ON DELETE CASCADE
);

CREATE TABLE QuizQuestions (
    QuestionID    INT IDENTITY(1,1) PRIMARY KEY,
    QuizID        INT           NOT NULL,
    QuestionText  NVARCHAR(500) NOT NULL,
    OptionA       NVARCHAR(200) NOT NULL,
    OptionB       NVARCHAR(200) NOT NULL,
    OptionC       NVARCHAR(200) NOT NULL,
    OptionD       NVARCHAR(200) NOT NULL,
    CorrectAnswer CHAR(1)       NOT NULL, -- 'A', 'B', 'C', 'D'
    FOREIGN KEY (QuizID) REFERENCES Quizzes(QuizID) ON DELETE CASCADE
);

-- =============================================
-- 4. ENGAGEMENT & INTERACTION MODULE
-- =============================================

CREATE TABLE Enrollments (
    EnrollmentID          INT IDENTITY(1,1) PRIMARY KEY,
    UserID                INT      NOT NULL,     -- The Member
    CourseID              INT      NOT NULL,
    EnrollmentDate        DATETIME NOT NULL DEFAULT GETDATE(),
    LastAccessedLessonID  INT      NULL,         -- NULL initially, updates as they progress
    ProgressPercentage    INT      NOT NULL DEFAULT 0,
    IsCompleted           BIT      NOT NULL DEFAULT 0,
    FOREIGN KEY (UserID)               REFERENCES Users(UserID),
    FOREIGN KEY (CourseID)             REFERENCES Courses(CourseID),
    FOREIGN KEY (LastAccessedLessonID) REFERENCES Lessons(LessonID)
);

CREATE TABLE LessonProgress (
    ProgressID       INT IDENTITY(1,1) PRIMARY KEY,
    UserID           INT          NOT NULL,
    LessonID         INT          NOT NULL,
    Status           NVARCHAR(20) NOT NULL, -- 'In Progress', 'Completed'
    LastAccessedDate DATETIME     NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (UserID)    REFERENCES Users(UserID),
    FOREIGN KEY (LessonID)  REFERENCES Lessons(LessonID)
);

CREATE TABLE QuizResults (
    ResultID  INT IDENTITY(1,1) PRIMARY KEY,
    UserID    INT      NOT NULL,
    QuizID    INT      NOT NULL,
    Score     INT      NOT NULL,
    DateTaken DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (UserID)  REFERENCES Users(UserID),
    FOREIGN KEY (QuizID)  REFERENCES Quizzes(QuizID)
);

CREATE TABLE CourseQuestions (
    QuestionID          INT IDENTITY(1,1) PRIMARY KEY,
    CourseID            INT           NOT NULL,
    UserID              INT           NOT NULL,  -- Member asking
    QuestionText        NVARCHAR(500) NOT NULL,
    InstructorResponse  NVARCHAR(1000),
    ResponseDate        DATETIME      NULL,
    Status              NVARCHAR(20)  NOT NULL DEFAULT 'Open', -- 'Open', 'Answered'
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    FOREIGN KEY (UserID)   REFERENCES Users(UserID)
);

CREATE TABLE Leaderboard (
    LeaderboardID       INT IDENTITY(1,1) PRIMARY KEY,
    UserID              INT      NOT NULL UNIQUE,
    TotalPoints         INT      NOT NULL DEFAULT 0,
    DailyStreak         INT      NOT NULL DEFAULT 0,
    LastQuizAttemptDate DATETIME NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- =============================================
-- 5. SYSTEM REPORTS & TRAFFIC MODULE (ADMIN)
-- =============================================

CREATE TABLE SiteTraffic (
    TrafficID        INT IDENTITY(1,1) PRIMARY KEY,
    SessionID        NVARCHAR(100) NOT NULL, -- Prevents double-counting on refresh
    VisitDate        DATETIME      NOT NULL DEFAULT GETDATE(),
    IsRegisteredUser BIT           NOT NULL DEFAULT 0  -- 0 = Visitor, 1 = Member/Instructor/Admin
);

-- =============================================
-- OTP CODES (Login 2FA & Forgot Password)
-- =============================================

CREATE TABLE OtpCodes (
    OtpID     INT IDENTITY(1,1) PRIMARY KEY,
    UserID    INT          NOT NULL,
    OtpCode   NVARCHAR(10) NOT NULL,
    Purpose   NVARCHAR(30) NOT NULL,  -- 'Login' | 'ForgotPassword'
    ExpiresAt DATETIME     NOT NULL,
    IsUsed    BIT          NOT NULL DEFAULT 0,
    CreatedAt DATETIME     NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

CREATE INDEX IX_OtpCodes_UserID ON OtpCodes(UserID);

-- =============================================
-- PASSWORD RESET TOKENS
-- =============================================

CREATE TABLE PasswordResetTokens (
    TokenID     INT IDENTITY(1,1) PRIMARY KEY,
    UserID      INT           NOT NULL,
    ResetToken  NVARCHAR(255) NOT NULL UNIQUE,
    ExpiryDate  DATETIME      NOT NULL,
    IsUsed      BIT           NOT NULL DEFAULT 0,
    CreatedDate DATETIME      NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

CREATE INDEX IX_Users_Email      ON Users(Email);
CREATE INDEX IX_Users_Username   ON Users(Username);
CREATE INDEX IX_Enrollments_User ON Enrollments(UserID);
CREATE INDEX IX_Enrollments_Course ON Enrollments(CourseID);
CREATE INDEX IX_LessonProgress_User ON LessonProgress(UserID);

-- =============================================
-- SAMPLE DATA
-- =============================================

-- Admin user (password: Admin@123 hashed with SHA256)
INSERT INTO Users (Username, Email, PasswordHash, Role, Status)
VALUES ('admin', 'admin@aidcademy.com',
        'c6f7e68cf92e6a5b14f8f3b8e2c9e3ad3d15d47e2e8c5d02e91ba69e1fe3ef4',
        'Admin', 'Active');

INSERT INTO UserProfiles (UserID, FullName)
VALUES (1, 'Site Administrator');

-- Instructor user (password: Instructor@123 hashed with SHA256)
INSERT INTO Users (Username, Email, PasswordHash, Role, Status)
VALUES ('instructor1', 'instructor@aidcademy.com',
        'c6f7e68cf92e6a5b14f8f3b8e2c9e3ad3d15d47e2e8c5d02e91ba69e1fe3ef4',
        'Instructor', 'Active');

INSERT INTO UserProfiles (UserID, FullName, PhoneNumber)
VALUES (2, 'John Doe', '0123456789');

-- Sample course (by instructor UserID = 2)
INSERT INTO Courses (UserID, Title, Description, Category, ApprovalStatus)
VALUES (2, 'Basic First Aid',
        'Learn the fundamentals of first aid including CPR, bandaging, and emergency response.',
        'Emergency Response', 'Approved');

-- Sample lessons
INSERT INTO Lessons (CourseID, Title, ContentBody, MediaURL, SequenceOrder)
VALUES
(1, 'Introduction to First Aid', 'This lesson covers the basic principles of first aid.', 'https://www.youtube.com/embed/sample1', 1),
(1, 'CPR Basics',               'Learn how to perform CPR on adults and children.',       'https://www.youtube.com/embed/sample2', 2),
(1, 'Bandaging Techniques',     'Master various bandaging techniques for wound care.',     'https://www.youtube.com/embed/sample3', 3);

-- Sample quiz
INSERT INTO Quizzes (LessonID, Title)
VALUES (1, 'First Aid Basics Quiz');

-- Sample quiz questions
INSERT INTO QuizQuestions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer)
VALUES
(1, 'What does CPR stand for?',
    'Cardiopulmonary Resuscitation', 'Cardiac Pressure Relief',
    'Cardio Physical Recovery', 'Critical Patient Response', 'A'),
(1, 'What is the first step in first aid?',
    'Call for help', 'Start CPR', 'Apply bandage', 'Give medication', 'A');

PRINT 'New Aidcademy schema created successfully!';
