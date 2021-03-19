USE [master]
GO
/****** Object:  Database [prod-4iq]    Script Date: 3/14/2021 4:50:08 PM ******/
CREATE DATABASE [prod-4iq]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'beta-4iq_Data', FILENAME = N'\home\asad\dbdata\prod-4iq.mdf' , SIZE = 7077184KB , MAXSIZE = UNLIMITED, FILEGROWTH = 51200KB ), 
 FILEGROUP [FourIQFileStreamGroup] CONTAINS FILESTREAM  DEFAULT
( NAME = N'FourIQResourceAssets', FILENAME = N'\home\asad\dbdata\prod-4iq_ResourceAssets' , MAXSIZE = UNLIMITED)
 LOG ON 
( NAME = N'beta-4iq_Log', FILENAME = N'\home\asad\dbdata\prod-4iq.ldf' , SIZE = 218432KB , MAXSIZE = 2048GB , FILEGROWTH = 51200KB )
GO
ALTER DATABASE [prod-4iq] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [prod-4iq].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO
ALTER DATABASE [prod-4iq] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [prod-4iq] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [prod-4iq] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [prod-4iq] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [prod-4iq] SET ARITHABORT OFF 
GO
ALTER DATABASE [prod-4iq] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [prod-4iq] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [prod-4iq] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [prod-4iq] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [prod-4iq] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [prod-4iq] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [prod-4iq] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [prod-4iq] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [prod-4iq] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [prod-4iq] SET  DISABLE_BROKER 
GO
ALTER DATABASE [prod-4iq] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [prod-4iq] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [prod-4iq] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [prod-4iq] SET ALLOW_SNAPSHOT_ISOLATION ON 
GO
ALTER DATABASE [prod-4iq] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [prod-4iq] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [prod-4iq] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [prod-4iq] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [prod-4iq] SET  MULTI_USER 
GO
ALTER DATABASE [prod-4iq] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [prod-4iq] SET DB_CHAINING OFF 
GO
ALTER DATABASE [prod-4iq] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [prod-4iq] SET TARGET_RECOVERY_TIME = 120 SECONDS 
GO
ALTER DATABASE [prod-4iq] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [prod-4iq] SET QUERY_STORE = OFF
GO
USE [prod-4iq]
GO
ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [prod-4iq]
GO
/****** Object:  User [CORSETTRA-DB\fouriqservice]    Script Date: 3/14/2021 4:50:08 PM ******/
CREATE USER [CORSETTRA-DB\fouriqservice] FOR LOGIN [CORSETTRA-DB\fouriqservice] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [CORSETTRA-DB\fouriqservice]
GO
/****** Object:  Schema [Configuration]    Script Date: 3/14/2021 4:50:08 PM ******/
CREATE SCHEMA [Configuration]
GO
/****** Object:  Schema [Reference]    Script Date: 3/14/2021 4:50:08 PM ******/
CREATE SCHEMA [Reference]
GO
/****** Object:  Schema [Registration]    Script Date: 3/14/2021 4:50:08 PM ******/
CREATE SCHEMA [Registration]
GO
/****** Object:  Schema [SUNY]    Script Date: 3/14/2021 4:50:08 PM ******/
CREATE SCHEMA [SUNY]
GO
/****** Object:  UserDefinedTableType [dbo].[CourseAssessmentPointsTableType]    Script Date: 3/14/2021 4:50:08 PM ******/
CREATE TYPE [dbo].[CourseAssessmentPointsTableType] AS TABLE(
	[AssessmentID] [uniqueidentifier] NULL,
	[Points] [decimal](19, 9) NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[fn_AddDurationToDate]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_AddDurationToDate] (@date datetime, @period int, @amount int)
returns datetime
AS
BEGIN
    --	Adds a duration (specified by @period and @amount) to the @date and returns the results.
    --	The values of @period correspond to DurationPeriodEnum

    declare @newDate datetime

    if (@period = 0)
    begin
        select @newDate = dateadd(day, @amount, @date)
    end else if (@period = 1)
    begin 
        select @newDate = dateadd(week, @amount, @date)
    end else if (@period = 2)
    begin 
        select @newDate = dateadd(month, @amount, @date)
    end else if (@period = 3)
    begin 
        select @newDate = dateadd(year, @amount, @date)
    end else
    begin
        select @newDate = cast('Unhandled duration period value of '+convert(varchar, @period) as int) -- hack to throw error
        return null;
    end

    return @newDate
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Assessment_NameInfo]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_Assessment_NameInfo] (@assessmentID uniqueidentifier)
RETURNS 
@info TABLE (Name nvarchar(200), Description nvarchar(max), Instructions nvarchar(max))
AS
BEGIN
    --  Returns Name, Description, and Instructions for an Assessment.

    declare @assessmentEntityType int
    select @assessmentEntityType = ParentEntityType from Assessments where ID = @assessmentID

    --  Find the basic info we need about the Assessment itself - to display to a user on the landing page, etc.
    --  This varies by the type of Assessment so add whatever is needed here so that we don't need to go
    --  get more stuff about it later
    if (@assessmentEntityType = 2600)           --   EntityTypeEnum.Evaluation
        insert into @info select Name, Description, Instructions from Evaluations where ID = @assessmentID
    else if (@assessmentEntityType = 3150)      --   EntityTypeEnum.Examination
        insert into @info select Name, Description, Instructions from Examinations where ID = @assessmentID
    else if (@assessmentEntityType = 2350)      --   EntityTypeEnum.DirectObservation
        insert into @info select Name, Description, Instructions from Examinations where ID = @assessmentID
    else if (@assessmentEntityType = 4350)      --   EntityTypeEnum.LogRequirement
        insert into @info select Name, Description, Instructions from Examinations where ID = @assessmentID
    else begin
        select @assessmentEntityType = cast('Unhandled Assessment type' as int) -- hack to throw error
        return;
    end

    return
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_AssessmentScheduledEvent_Assessors]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_AssessmentScheduledEvent_Assessors] (@assessmentScheduledEventID uniqueidentifier, @assessorRoleType int)
returns 
@assessors table (EntityID uniqueidentifier, DisplayID nvarchar(20), Name nvarchar(200), 
                 ProfileImageResourceAssetID uniqueidentifier, LastScheduledAssessmentID uniqueidentifier, [Status] int default 3)
AS
BEGIN
    --  Returns a table that contains each Assessor described by an Assessment_ScheduledEvent record (and the 
    --  AssessmentScheduleParams record it is linked to).

    declare @scheduledEventID uniqueidentifier

    select @scheduledEventID = a_se.ScheduledEventID
        from Assessment_ScheduledEvent a_se
        where a_se.ID = @assessmentScheduledEventID

    insert into @assessors (EntityID, DisplayID, Name, ProfileImageResourceAssetID)
        select distinct p.ID, p.DisplayID, p.LastName+', '+p.FirstName, p.ProfileImageResourceAssetID
            from dbo.fn_ScheduledEvent_PeopleOfRole(@scheduledEventID, @assessorRoleType) se_p
                join People p on p.ID = se_p.PersonID

    --  Find the current Status for any completed or in-progress assessments
    --  The default of the Status column we output is 3 (Not Started))
    update @assessors set Status=a.Status, LastScheduledAssessmentID=a.ID
        from @assessors s
            join (
                select ID, AssessorID, Status, RowNum=row_number() over
                (
                    --  http://stackoverflow.com/questions/6201253/how-to-get-the-last-record-per-group-in-sql
                    partition by BaseScheduledAssessmentID
                    order by StartDate desc
                )
                from ScheduledAssessments
                where AssessmentScheduledEventID = @assessmentScheduledEventID
            ) a on a.AssessorID = s.EntityID
        where a.RowNum=1

    return
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_AssessmentScheduledEvent_CalcEndDate]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_AssessmentScheduledEvent_CalcEndDate](@assessmentScheduledEventID uniqueidentifier)
returns datetime
AS
BEGIN
    declare @endDate datetime

    --  Course Type = 0 is Calendar scheduled course so use the ScheduledDate in the Scheduled Event
    --  Course Type = 1 is Independent Study so end time is calculated from time when assessment is started (which is now)
    select @endDate =
        case p.EndActionTime
            when 0 then dateadd(minute, p.EndMinutes, case when c.Type = 0 then se.ScheduledDate else getdate() end)
            when 1 then dateadd(minute, -p.EndMinutes, case when c.Type = 0 then se.ScheduledDate else getdate() end)
            when 2 then dateadd(minute, p.EndMinutes, dateadd(minute, se.DurationMinutes, case when c.Type = 0 then se.ScheduledDate else getdate() end))
            when 3 then null
            else cast('Invalid value for AssessmentScheduleParam.EndActionTime' as int) -- hack to throw error
        end
        from Assessment_ScheduledEvent a_se
            join AssessmentScheduleParams p on p.ID = a_se.AssessmentScheduleParamsID
            join Scheduled_Events se on se.ID = a_se.ScheduledEventID
            join Courses c on c.ID = se.CourseID
        where a_se.ID = @assessmentScheduledEventID

    return @endDate
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_AssessmentScheduledEvent_CalcStartDate]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_AssessmentScheduledEvent_CalcStartDate](@assessmentScheduledEventID uniqueidentifier)
returns datetime
AS
BEGIN
    declare @startDate datetime

    --  Course Type = 0 is Calendar scheduled course so use the ScheduledDate in the Scheduled Event and apply the configured offsets
    --  Course Type = 1 is Independent Study so the start time is always when the course starts
    select @startDate =
        case when c.Type = 1 
            then c.StartDate
            else case p.StartActionTime	--	defined in AssessmentScheduleActionTimeEnum
                when 0 then dateadd(minute, p.StartMinutes, se.ScheduledDate)
                when 1 then dateadd(minute, -p.StartMinutes, se.ScheduledDate)
                when 2 then dateadd(minute, p.StartMinutes, dateadd(minute, se.DurationMinutes, se.ScheduledDate))
                when 3 then null
                else cast('Invalid value for AssessmentScheduleParam.StartActionTime' as int) -- hack to throw error
            end
        end
        from Assessment_ScheduledEvent a_se
            join AssessmentScheduleParams p on p.ID = a_se.AssessmentScheduleParamsID
            join Scheduled_Events se on se.ID = a_se.ScheduledEventID
            join Courses c on c.ID = se.CourseID
        where a_se.ID = @assessmentScheduledEventID

    return @startDate
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_AssessmentScheduledEvent_Subjects]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_AssessmentScheduledEvent_Subjects] (@assessmentScheduledEventID uniqueidentifier, @personID uniqueidentifier, @coursePersonID uniqueidentifier, 
                                                        @isAssessor bit, @includeDetails bit,
                                                        @specificSubjectEntityType int, @specificSubjectEntityID uniqueidentifier)
returns 
@subjects table (EntityType int, EntityID uniqueidentifier, DisplayID nvarchar(20), EvaluationSubjectType int, Name nvarchar(200), Description nvarchar(max),
                 ProfileImageResourceAssetID uniqueidentifier, LastScheduledAssessmentID uniqueidentifier, [Status] int default 3)
AS
BEGIN
    --  Returns a table that contains each Subject described by an Assessment_ScheduledEvent record (and the 
    --  AssessmentScheduleParams record it is linked to).

    --  EntityTypeEnum constants
    declare @entityTypeCourse int
    declare @entityTypeExamination int
    declare @entityTypePerson int
    select @entityTypeCourse = 2000, @entityTypeExamination = 3150, @entityTypePerson = 5700

    declare @subjectEntityType int
    declare @subjectID uniqueidentifier
    declare @subjectRoleType int
    declare @evaluationSubjectType int      --  Values defined in EvaluationSubjectTypeEnum
    declare @scheduledEventID uniqueidentifier
    declare @courseID uniqueidentifier
    declare @assessmentEntityType int

    select @subjectRoleType = p.SubjectRoleType, @subjectEntityType = p.SubjectEntityType, 
            @subjectID = p.SubjectID, @evaluationSubjectType = p.EvaluationSubjectType,
            @courseID = se.CourseID, @scheduledEventID = a_se.ScheduledEventID,
            @assessmentEntityType = a.ParentEntityType
        from Assessment_ScheduledEvent a_se
            join AssessmentScheduleParams p on a_se.AssessmentScheduleParamsID = p.ID
            join Scheduled_Events se on se.ID = a_se.ScheduledEventID
            join Assessments a on a.ID = a_se.AssessmentID
        where a_se.ID = @assessmentScheduledEventID

    --  Force Exams to use current course
    if (@assessmentEntityType = @entityTypeExamination)
        select @subjectID = @courseID, @evaluationSubjectType = 5 /* EvaluationSubjectTypeEnum.ParentCourse */

    if ((@specificSubjectEntityType is not null) and (@specificSubjectEntityID is not null))
    begin
        --  We're fetching the subject information for a specific Subject.  This is used when we're building the
        --  details of an individual ScheduledAssessment so we don't want or need all of the other subjects.
        insert into @subjects (EntityType, EntityID, EvaluationSubjectType) values (@specificSubjectEntityType, @specificSubjectEntityID, @evaluationSubjectType)
        select @subjectEntityType = @specificSubjectEntityType
    end else
    begin
        if (@subjectID is not null)
        begin
            --  Assessment is for 1 specific entity.
            --  This also handles EvaluationSubjectTypeEnum.ParentCourse and SingleEntity
            insert into @subjects(EntityType, EntityID, EvaluationSubjectType) values (@subjectEntityType, @subjectID, @evaluationSubjectType)
        end else
        begin
            --  Need to look up the Entities that are the Subjects of this Assessment depending on 
            --  the EvaluationSubjectType, SubjectRoleType, and SubjectEntityType
            if (@evaluationSubjectType = 3)                 --  EvaluationSubjectTypeEnum.PeopleOfRoleTypeInCourse
            begin
                insert into @subjects (EntityType, EntityID, EvaluationSubjectType)
                    select @subjectEntityType, cp.PersonID, @evaluationSubjectType
                        from Course_People cp join People p on p.ID = cp.PersonID
                        where cp.CourseID = @courseID and cp.RoleType = @subjectRoleType and p.IsDeleted = 0
                                and cp.Retaken = 0       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)
								and cp.PersonID <> @personID	--Need to prevent returning the current person if they are one of theses roles or it would be a self evaluation

            end else if (@evaluationSubjectType = 4)        --  EvaluationSubjectTypeEnum.PeopleOfRoleTypeInEvent
            begin
                insert into @subjects (EntityType, EntityID, EvaluationSubjectType)
                    select @subjectEntityType, p.PersonID, @evaluationSubjectType
                        from dbo.fn_ScheduledEvent_PeopleOfRole(@scheduledEventID, @subjectRoleType) p
						where p.PersonID <> @personID	--Need to prevent returning the current person if they are one of theses roles or it would be a self evaluation

            end else if (@evaluationSubjectType = 8)        --  EvaluationSubjectTypeEnum.SelfEvaluation
            begin
                --  For self evaluation, we use @personID if @isAssessor (caller must validate that is true!) or
                --  we need to find all of the People for the RoleType in the Course.
                if (@isAssessor = 1)
                    insert into @subjects (EntityType, EntityID, EvaluationSubjectType) values (@subjectEntityType, @personID, @evaluationSubjectType)
                else begin
                    insert into @subjects (EntityType, EntityID, EvaluationSubjectType)
                        select @subjectEntityType, cp.PersonID, @evaluationSubjectType
                            from Course_People cp join People p on p.ID = cp.PersonID
                            where cp.CourseID = @courseID and cp.RoleType = @subjectRoleType and p.IsDeleted = 0
                                and cp.Retaken = 0       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)
                end
            end else
            begin
                select @entityTypeExamination = cast('Unhandled EvaluationSubjectType value of '+convert(varchar, @evaluationSubjectType) as int) -- hack to throw error
                return
            end
        end
    end

    if (@includeDetails = 1)
    begin
        --  Fill in the names of the Entities
        if (@subjectEntityType = @entityTypeCourse)
        begin
            update @subjects set DisplayID = c.DisplayID, Name = c.Name, Description = c.Description from @subjects s join Courses c on c.ID = s.EntityID
        end else if (@subjectEntityType = @entityTypePerson)
        begin
            update @subjects set DisplayID = p.DisplayID, Name = p.LastName+', '+p.FirstName, Description = p.Title,
                                 ProfileImageResourceAssetID = p.ProfileImageResourceAssetID
                from @subjects s join People p on p.ID = s.EntityID
        end

        if (@isAssessor = 1)
        begin
            --  Find the current Status for any completed or in-progress assessments
            --  The default of the Status column we output is 3 (Not Started))
            update @subjects set Status=a.Status, LastScheduledAssessmentID=a.ID
                from @subjects s
                    join (
                        select ID, Subject_EntityID, Status, RowNum=row_number() over
                        (
                            --  http://stackoverflow.com/questions/6201253/how-to-get-the-last-record-per-group-in-sql
                            partition by BaseScheduledAssessmentID
                            order by StartDate desc
                        )
                        from ScheduledAssessments
                        where AssessmentScheduledEventID = @assessmentScheduledEventID
                            and CoursePersonID = @coursePersonID        --  Must filter on CoursePersonID to restrict to the correct course instance for this person
                    ) a on a.Subject_EntityID = s.EntityID
                where a.RowNum=1
        end
        --  TODO: else find some stats to show the non-assessor - number of assessors for each subject,
        --  set status = null, 0, 1 depending on # of subjects completed vs. total expected.
    end

    return
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Calendar_CountPeopleOfRole]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_Calendar_CountPeopleOfRole] (@courseID uniqueidentifier, @calendarID uniqueidentifier, @roleType int, @useAllPeopleFromCourse bit)
returns int
AS
BEGIN
    --  Returns a count of the number of Current people in the scheduled event.  Will not double count if a student
    --  is retaking.
    --  TODO: This will count people who have "completed" the course which should be fine for a Calendar course
    --  but may not be appropriate for an Independent Study course.

    --	@roleType must be: 2 (Student) or 3 (Instructor)
    declare @peopleCount int

    if (@useAllPeopleFromCourse = 0)
    begin
        --	Use Students/Instructors on the Calendar
        select @peopleCount = count(1)
            from Calendar_People cal_p 
                join Course_People cp on cp.ID = cal_p.CoursePersonID
                join People p on p.ID = cp.PersonID
            where cal_p.CalendarID = @calendarID and cp.RoleType = @roleType and p.IsDeleted = 0
                and cp.Retaken = 0       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)
    end else
    begin
        --	Use Students/Instructors on the Course
        select @peopleCount = count(1)
            from Course_People cp 
                join People p on p.ID = cp.PersonID 
            where cp.CourseID = @courseID and cp.RoleType = @roleType and p.IsDeleted = 0
                and cp.Retaken = 0       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)
    end

    return @peopleCount
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Calendar_CoursePersonIsRoleType]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_Calendar_CoursePersonIsRoleType] (@calendarID uniqueidentifier, @roleType int, @coursePersonID uniqueidentifier)
returns bit
AS
BEGIN
    --  This checks a specific instance of a Course_People record.

    declare @personIsRoleType bit
    select @personIsRoleType = 0

    --	@roleType must be: 2 (Student) or 3 (Instructor)

    declare @useAllPeopleFromCourse bit
    declare @courseID uniqueidentifier
    select @useAllPeopleFromCourse = case when @roleType=2 then UseAllStudentsFromCourse else UseAllInstructorsFromCourse end, 
            @courseID = CourseID
        from Calendars c where ID = @calendarID

    if (@useAllPeopleFromCourse = 0)
    begin
        --	Use Students/Instructors on the Calendar
        if exists (select top 1 1
                    from Calendar_People cal_p 
                        join Course_People cp on cp.ID = cal_p.CoursePersonID
                        join People p on p.ID = cp.PersonID 
                    where cal_p.CalendarID = @calendarID and cp.ID = @coursePersonID and cp.RoleType = @roleType and p.IsDeleted = 0)
            select @personIsRoleType = 1
    end else
    begin
        --	Use Students/Instructors on the Course
        if exists (select top 1 1
                    from Course_People cp 
                        join People p on p.ID = cp.PersonID 
                    where cp.CourseID = @courseID and cp.ID = @coursePersonID and cp.RoleType = @roleType and p.IsDeleted = 0)
            select @personIsRoleType = 1
    end

    return @personIsRoleType
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Calendar_PeopleOfRole]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_Calendar_PeopleOfRole] (@calendarID uniqueidentifier, @roleType int)
returns 
@people table (PersonID uniqueidentifier)
AS
BEGIN
    --  Returns a count of the number of Current people in the scheduled event.  Will not double count if a student
    --  is retaking.
    --  TODO: This will return people who have "completed" the course which should be fine for a Calendar course
    --  but may not be appropriate for an Independent Study course.

    --	@roleType must be: 2 (Student) or 3 (Instructor)

    declare @useAllPeopleFromCourse bit
    declare @courseID uniqueidentifier
    select @useAllPeopleFromCourse = case when @roleType=2 then UseAllStudentsFromCourse else UseAllInstructorsFromCourse end, 
            @courseID = CourseID
        from Calendars c where ID = @calendarID

    if (@useAllPeopleFromCourse = 0)
    begin
        --	Use Students/Instructors on the Calendar
        insert into @people
            select cp.PersonID 
                from Calendar_People cal_p 
                    join Course_People cp on cp.ID = cal_p.CoursePersonID
                    join People p on p.ID = cp.PersonID 
                where cal_p.CalendarID = @calendarID and cp.RoleType = @roleType and p.IsDeleted = 0
                    and cp.Retaken = 0       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)
    end else
    begin
        --	Use Students/Instructors on the Course
        insert into @people
            select cp.PersonID 
                from Course_People cp 
                    join People p on p.ID = cp.PersonID 
                where cp.CourseID = @courseID and cp.RoleType = @roleType and p.IsDeleted = 0
                    and cp.Retaken = 0       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)
    end

    return
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Calendar_PersonIsRoleType]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_Calendar_PersonIsRoleType] (@calendarID uniqueidentifier, @roleType int, @personID uniqueidentifier)
returns bit
AS
BEGIN
    --  ****  Do not use this function - it is being replaced by fn_Calendar_CoursePersonIsRoleType which
    --  takes a CoursePersonID instead of a PersonID.

    --  ** This checks the current instance of the Course_People record.  If we need to check for past instances
    --  (i.e. a Course_People record from a previous instance of the course), we will either need a new method
    --  or should change this to take the Course_People.ID instead of @personID.  Same for fn_ScheduledEvent_PersonIsRoleType.

    declare @personIsRoleType bit
    select @personIsRoleType = 0

    --	@roleType must be: 2 (Student) or 3 (Instructor)

    declare @useAllPeopleFromCourse bit
    declare @courseID uniqueidentifier
    select @useAllPeopleFromCourse = case when @roleType=2 then UseAllStudentsFromCourse else UseAllInstructorsFromCourse end, 
            @courseID = CourseID
        from Calendars c where ID = @calendarID

    if (@useAllPeopleFromCourse = 0)
    begin
        --	Use Students/Instructors on the Calendar
        if exists (select top 1 1
                    from Calendar_People cal_p 
                        join Course_People cp on cp.ID = cal_p.CoursePersonID
                        join People p on p.ID = cp.PersonID 
                    where cal_p.CalendarID = @calendarID and cp.PersonID = @personID and cp.RoleType = @roleType and p.IsDeleted = 0
                        and cp.Retaken = 0)       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)
            select @personIsRoleType = 1
    end else
    begin
        --	Use Students/Instructors on the Course
        if exists (select top 1 1
                    from Course_People cp 
                        join People p on p.ID = cp.PersonID 
                    where cp.CourseID = @courseID and cp.PersonID = @personID and cp.RoleType = @roleType and p.IsDeleted = 0
                        and cp.Retaken = 0)       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)
            select @personIsRoleType = 1
    end

    return @personIsRoleType
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Course_GradebookAssessmentPoints]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_Course_GradebookAssessmentPoints] (@courseID uniqueidentifier)
returns @assessmentPoints table(
	AssessmentID uniqueidentifier,
	Points decimal(19,9)
)
as
begin

declare @categories table(
		ID uniqueidentifier,
		Weight decimal,
		UsePercent bit
	)
insert @categories
	select gc.ID
		  , gc.Weight
		  , gc.UsePercent
	from GradeBookCategories gc
	join GradeBooks gb on gc.GradeBookID = gb.ID
	join Courses c on gb.ID = c.GradeBookID and c.ID = @courseID

declare @categoryPoints table(
		ID uniqueidentifier,
		Points decimal
	)
insert @categoryPoints
	select c.ID, cat3.Points
	from @categories c
	join (
		select cat2.ID,
		   CASE WHEN cat2.PercentWeight > 0
		   THEN 
				CASE WHEN cat2.PointWeight > 0
				THEN 100 * cast(cat2.PointWeight as decimal) / (100 - cast(cat2.PercentWeight as decimal))
				ELSE cast(cat2.PercentWeight as decimal)
		   END
		   ELSE cast(cat2.PointWeight as decimal)
		   END as Points
	from (
		select cat1.ID
			, sum(CASE WHEN cat1.UsePercent = 0 THEN cat1.Weight ELSE 0 END) as PointWeight
			, sum(CASE WHEN cat1.UsePercent = 1 THEN cat1.Weight ELSE 0 END) as PercentWeight
		from @categories cat1
		group by cat1.ID ) cat2
		) as cat3 on c.ID = cat3.ID


declare @gradableItems table(
		ID uniqueidentifier,
		Weight decimal,
		UsePercent bit,
		CategoryID uniqueidentifier,
		ParentEntityID uniqueidentifier
	)
insert @gradableItems
	select gi.ID, gi.Weight, gi.UsePercent, gi.CategoryID, coalesce(ex.RootID, ev.RootID)
	from GradableItems gi
	left outer join Examinations ex on gi.ParentEntityID = ex.ID
	left outer join Evaluations ev on gi.ParentEntityID = ev.ID
	join @categories gc on gi.CategoryID = gc.ID

insert @assessmentPoints
	select	gis.ParentEntityID as AssessmentID
			, cast(gis.Weight as decimal) / cast(catPoints.Points as decimal) * cast(c.Points as decimal) as Points
	from @gradableItems gis
	join @categoryPoints c on gis.CategoryID = c.ID
	join (
	select cats.CategoryID,
		   CASE WHEN cats.PercentWeight > 0
		   THEN 
				CASE WHEN cats.PointWeight > 0
				THEN 100 * cast(cats.PointWeight as decimal) / (100 - cast(cats.PercentWeight as decimal))
				ELSE cats.PercentWeight
		   END
		   ELSE cats.PointWeight
		   END as Points
	from (
	select gi.CategoryID
		, sum(CASE WHEN gi.UsePercent = 0 THEN gi.Weight ELSE 0 END) as PointWeight
		, sum(CASE WHEN gi.UsePercent = 1 THEN gi.Weight ELSE 0 END) as PercentWeight
	from @gradableItems gi
	group by gi.CategoryID ) cats
	) as catPoints on gis.CategoryID = catPoints.CategoryID

	return
end
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Course_StudentCompletionStatus]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_Course_StudentCompletionStatus] (@courseID uniqueidentifier, @coursePersonID uniqueidentifier, @includeNotStarted bit)
returns int
AS
BEGIN
    --  This figures out if the Course_Person has Completed the course.  If so, it returns 2.
    --  If something in the course is not completed yet, it returns -1.
    declare @completionStatus int

    --  Only calculate this if the status is currently InProgress (1) or Complete(2) or NotStarted(0) if the @includeNotStarted flag says to.
    --  The student must start the course before the status can be affected by scheduled events.  And if it's
    --  expired or dropped, we don't want to change it!
    declare @currentCompletionStatus int
    select @currentCompletionStatus = CompletionStatus from Course_People where ID = @coursePersonID

	--If we want to allow/include not started people (i.e. the only requirement is attendance and they are marked as attended
	--	or they start the course and there are no requirements) then treat not started like in progress
	if(@includeNotStarted = 1 and @currentCompletionStatus = 0)
		set @currentCompletionStatus = 1

    if ((@currentCompletionStatus <> 1) and (@currentCompletionStatus <> 2))
        select @completionStatus = -1        -- Unchanged
    else
    begin
        --  Check to see if the Student has completed all required items.  If so, they have completed the course.
        --  ** Note that if none of the items are required (or the student is not registered in any scheduled events), this
        --  will consider them Complete.  May want to do the other check below (to look to see if they have completed anything at all)
        --  first - then  the student would at least have to do something in the course before we say it's completed.
		
		
		-- GHW - I think the commented query is a better way to do this, however I did not have time to test it properly
		-- so I am including it here for when I can circle back around and test this properly
		--
		--if exists(
		--	select top 1 1
		--	from Scheduled_Events se
		--	left outer join Attendance ea on se.ID = ea.ParentEntityID and ea.CoursePersonID = @coursePersonID
		--	join Courses c on se.CourseID = c.ID
		--	left outer join Attendance ca on c.ID = ca.ParentEntityID and ca.CoursePersonID = @coursePersonID
		--	left outer join Resource_ScheduledEvents rse on se.ID = rse.ScheduledEventID
		--											and rse.[Required] = 1
		--	left outer join ScheduledEventCompletedItems rseci on rse.ResourceID = rseci.ParentEntityID
		--													and se.ID = rseci.ScheduledEventID
		--													and rseci.CoursePersonID = @coursePersonID
		--	left outer join Assessment_ScheduledEvent ase on se.ID = ase.ScheduledEventID
		--												and ase.[Required] = 1
		--	left outer join Examinations exam on ase.AssessmentID = exam.ID
		--	left outer join Evaluations eval on ase.AssessmentID = eval.ID
		--	left outer join ScheduledEventCompletedItems aseci on se.ID = aseci.ScheduledEventID 
		--													and aseci.CoursePersonID = @coursePersonID
		--													and 
		--													(
		--													exam.RootID = aseci.ParentEntityID 
		--													or eval.RootID = aseci.ParentEntityID
		--													)
		--	where se.CourseID = @courseID
		--		and dbo.fn_ScheduledEvent_CoursePersonIsRoleType(se.ID, 2, @coursePersonID) = 1
		--		and (	(rse.ID is not null and rseci.CoursePersonID is null) 
		--			or	(ase.ID is not null and aseci.CoursePersonID is null)
		--			or	(se.AttendanceParams_Required = 1 and ea.ID is null)
		--			or	(c.AttendanceParams_Required = 1 and ca.ID is null)
		--		)
		--) 
		--begin select @completionStatus = -1 end
		--else begin select @completionStatus = 2 end 

        if not exists
		(
			select top 1 1
            from Scheduled_Events se
            where se.CourseID = @courseID 
              and dbo.fn_ScheduledEvent_CoursePersonIsRoleType(se.ID, 2, @coursePersonID) = 1     --  Not every student is registered in every SE!
              and 
			  (
				exists
				(
					select top 1 1
                    from Resource_ScheduledEvents rse 
                    left outer join ScheduledEventCompletedItems seci on rse.ResourceID = seci.ParentEntityID 
																	 and se.ID = seci.ScheduledEventID 
																	 and seci.CoursePersonID = @coursePersonID
                    where rse.ScheduledEventID = se.ID 
					  and rse.Required = 1 
					  and seci.ScheduledEventID is null
				) 
				or exists
				(
					select top 1 1
                    from Assessment_ScheduledEvent ase
					left outer join Examinations exam on ase.AssessmentID = exam.ID
					left outer join Evaluations eval on ase.AssessmentID = eval.ID
                    left outer join ScheduledEventCompletedItems seci on se.ID = seci.ScheduledEventID 
																	 and seci.CoursePersonID = @coursePersonID
																	 and 
																	 (
																		exam.RootID = seci.ParentEntityID 
																		or eval.RootID = seci.ParentEntityID
																	 )
                    where se.ID = ase.ScheduledEventID 
					  and ase.Required = 1 
					  and seci.ScheduledEventID is null
				)
                or
				(
					se.AttendanceParams_Required = 1 --Can't be complete if attendance is required on an event and they aren't marked as present
					and not exists
					(
						select top 1 1
                        from Attendance 
						where ParentEntityID = se.ID 
						  and CoursePersonID = @coursePersonID
                    )
				)
			)
		)
        and--Can't be complete if attendance is required on the course and they aren't marked as present
        (
			(
				select AttendanceParams_Required 
				from Courses 
				where ID = @courseID
			) = 0
            or exists
			(
				select top 1 1
                from Attendance 
				where ParentEntityID = @courseID 
				  and CoursePersonID = @coursePersonID
			)
		)
        begin
            select @completionStatus = 2        -- CompletionStatusEnum.Completed
        end else
        begin
            select @completionStatus = -1        -- Unchanged
        end
    end

    return @completionStatus
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CoursePerson_CalculatePercentComplete]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_CoursePerson_CalculatePercentComplete] (@coursePersonID uniqueidentifier)
returns decimal
AS
BEGIN
	declare @requiredEvents table(
		ID uniqueidentifier,
		TotalRequiredResources int,
		TotalRequiredAssessment int
	)

	insert @requiredEvents
		select se.ID, count(rse.ID) as TotalRequiredResourses, count(ase.ID) as TotalRequiredAssessments
		from Scheduled_Events se
		join Course_People cp on se.CourseID = cp.CourseID and cp.ID = @coursePersonID
		left outer join Resource_ScheduledEvents rse on se.ID = rse.ScheduledEventID and rse.Required = 1
		left outer join Assessment_ScheduledEvent ase on se.ID = ase.ScheduledEventID and ase.Required = 1
		where [dbo].[fn_ScheduledEvent_CoursePersonIsRoleType](se.ID, 2, @coursePersonID) = 1
			and (rse.ID is not null or ase.ID is not null)
		group by se.ID

	declare @totalRequired int
	select @totalRequired = count(*)
	from @requiredEvents

	declare @totalCompleted int
	select @totalCompleted = count(x.ScheduledEventID)
	from (select distinct seci.ScheduledEventID
		  from ScheduledEventCompletedItems seci
		  where seci.CoursePersonID = @coursePersonID 
			and seci.ScheduledEventID in (select ID from @requiredEvents)) x

    return cast(@totalCompleted as decimal) / cast(@totalRequired as decimal) * 100
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CoursePerson_CurrentCourseScore]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_CoursePerson_CurrentCourseScore] (@coursePersonID uniqueidentifier, @courseAssessmentPoints CourseAssessmentPointsTableType READONLY)
returns decimal(19,9)
as
begin

declare @currentScore as decimal(19,9)

select @currentScore = z.CurrentScore / z.CurrentMaxScore * 100
from
(
	select y.CourseID, sum(y.Score / y.MaxScore * y.CoursePoints) as CurrentScore, sum(y.CoursePoints) as CurrentMaxScore
	from 
	(
		select @coursePersonID as CourseID, x.AssessmentID, max(x.Score) as Score, max(x.MaximumScore) as MaxScore, max(ap.Points) as CoursePoints
		from (
			select coalesce(ex.RootID, ev.RootID) as AssessmentID, ps.Score, ps.MaximumScore
			from ScheduledAssessments sa
			join PersonScores ps on sa.ID = ps.ScheduledAssessmentID
			left outer join Examinations ex on sa.AssessmentID = ex.ID
			left outer join Evaluations ev on sa.AssessmentID = ev.ID
			where sa.CoursePersonID = @coursePersonID 
		) x
		join @courseAssessmentPoints ap on x.AssessmentID = ap.AssessmentID
		group by x.AssessmentID
	) y
	group by y.CourseID
) z

return @currentScore
end
GO
/****** Object:  UserDefinedFunction [dbo].[fn_DegreePerson_CalculateCompletionStatus]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_DegreePerson_CalculateCompletionStatus] (@degreePersonID uniqueidentifier, @forContinuingEd bit, @coursePeriodStartDate datetime, @coursePeriodEndDate datetime)
returns int
AS
BEGIN
    --  Calculates the Degree Completion Status based on the current courses that have been completed (and passed!).
    --  @forContinuingEd: If 1, calculates for Continuing Ed.  Otherwise, for normal degree requirements
    --  @coursePeriodStartDate and @coursePeriodEndDate: If not null, only checks courses with a StatusModifiedDate between this period.
    --      Probably only applies to Continuing Ed - so that we can find courses completed during the renewal period (and because
    --      the same course could be used for multiple renewals)

    --  Can grab everything we need to do all the grouping (to handle all of the and/or/group conditions) in 1 query.
    declare @courseUsageAccruals table
    (
        DegreeTrackCourseUsageID uniqueidentifier,
        DegreeTrackCourseUsageMinimumCredits int,
        DegreeTrackGroupID uniqueidentifier,
        DegreeTrackID uniqueidentifier,
        DegreeGroupID uniqueidentifier,
        AccruedCredits int,
        InProgressCredits int
    )

    --  Find the number of in progress & earned credits for each Degree Track Course Usage
    --  "left outer" joins used to make sure that we return SOMETHING if the CU Tag is not configured or if
    --  the student is not even in the course.  This guarantees we will have a row for every possible
    --  DegreeTrackCourseUsage record which saves us from having to re-query this entire degree/track/CU/group hierarchy
    --  in the roll-up queries that will follow.
    --  ** row_number() is used here because we want the most recent CoursePerson (and only that 1 record) within the date period.
    --  We CANNOT use cp.Retaken=0 to so this because Continuing Ed courses are retaken.
    --  This embeded select with the "row_number() over partition" stuff adds a row number field (named "rn" in this case)
    --  that is grouped/partitioned by all of the uniqueidentifier values that make each of these rows unique to us (and
    --  it counts by CoursePerson.StatusModifiedDate desc so rn=1 is the most recent record in that period).
    --  Then we can just pick off the rn=1 records and we won't have any duplicates - only the results of the most recent will be considered.
    --  https://stackoverflow.com/questions/7118170/sql-server-select-only-the-rows-with-maxdate/7118233#7118233
    insert @courseUsageAccruals 
    select DegreeTrackCourseUsageID, DegreeTrackCourseUsageMinimumCredits, DegreeTrackGroupID, DegreeTrackID,
            DegreeGroupID, AccruedCredits, InProgressCredits
        from (
            select DegreeTrackCourseUsageID=dtcu.ID, DegreeTrackCourseUsageMinimumCredits=dtcu.MinimumCredits, DegreeTrackGroupID=dtg.ID,
                    dtg.DegreeTrackID, dgdt.DegreeGroupID,
                    AccruedCredits = case when cp.CompletionStatus = 2 and (cp.HistoricalStatus = 2 or cp.HistoricalStatus = 6 or ps.ID is null) then co.Credits else 0 end,        --  Completed and Passed or no gradebook (ps = null)
                    InProgressCredits = case when cp.CompletionStatus = 1 then co.Credits else 0 end,
                    row_number() over (partition by dtcu.ID, dtg.ID, dtg.DegreeTrackID, dgdt.DegreeGroupID, cp.CourseID 
                                        order by cp.StatusModifiedDate desc) as rn
                from Degree_People dp
                    join Degrees d on d.ID = dp.DegreeID
                    join DegreeGroups dg on ((@forContinuingEd = 0) and (dg.DegreeID = dp.DegreeID) and (dg.ContinuingEducationRequirementsID is null))
                                         or ((@forContinuingEd = 1) and (dg.DegreeID is null) and (dg.ContinuingEducationRequirementsID = d.ContinuingEducationRequirementsID))
                    join DegreeGroupDegreeTracks dgdt on dgdt.DegreeGroupID = dg.ID
                    join DegreeTrackGroups dtg on dtg.DegreeTrackID = dgdt.DegreeTrackID
                    join DegreeTrackCourseUsages dtcu on dtcu.DegreeTrackGroupID = dtg.ID
                    join DegreeTrackCourseUsage_Tag dtcu_t on dtcu_t.DegreeTrackCourseUsageID = dtcu.ID
                    left outer join CourseOverview_Tag co_t on co_t.TagID = dtcu_t.TagID
                    left outer join CourseOverviews co on co.ID = co_t.CourseOverviewID
                    left outer join Courses c on c.CourseOverviewID = co_t.CourseOverviewID
                    left outer join Course_People cp on cp.CourseID = c.ID and cp.PersonID = dp.PersonID and cp.RoleType = 2 -- Student; do *NOT* use cp.Retaken here - see notes above about row_number()
                                                        and ((@coursePeriodStartDate is null) or (cast(cp.StatusModifiedDate as date) >= cast(@coursePeriodStartDate as date)))
                                                        and ((@coursePeriodEndDate is null) or (cast(cp.StatusModifiedDate as date) <= cast(@coursePeriodEndDate as date)))
                    left outer join PersonScores ps on ps.CoursePersonID = cp.ID and ps.GradeBookID = c.GradeBookID	--	null if no gradebook
                where dp.ID = @degreePersonID
            ) a
        where a.rn = 1

    --A Degree Track contains a collection of groups (DegreeTrackGroups).
    --In each group, there is a collection of Course Usages that are used 
    --to determine if certain course requirements have been met. 
    --The requirements of a group are met if ANY of the course usage requirements 
    --within the group are met.
    --The requirements of a degree track are met if ALL of the degree track group
    --requirements are met. 
    --Ex.
    --Degree Track 1 - NOT MET (Because at least 1 group is not met)
    --	Degree Track Group 1 - MET (Because at least 1 course usage is met)
    --		Course Usage 1 - MET
    --		Course Usage 1a - NOT MET
    --		Course Usage 1b - NOT MET
    --	Degree Track Group 2 - NOT MET
    --		Course Usage 2 - NOT MET
    --		Course Usage 2a - NOT MET

    declare @groupByDegreeTrack table
    (
        DegreeTrackID uniqueidentifier,
        DegreeGroupID uniqueidentifier,
        InProgressOrAccruedCredits int,
        TotalUnmetGroups int
    )

    --  Groups by DegreeTrack and finds the number of Groups inside it that have not been satisfied (do not have at least 1 completed Course Usage)
    insert into @groupByDegreeTrack
    select a.DegreeTrackID, a.DegreeGroupID,
            sum(a.InProgressOrAccruedCredits),
            sum(case when a.TotalPassedCourseUsages = 0 then 1 else 0 end)
        from (
            --  Groups by the DegreeTrackGroup and finds the number of Completed/Passed CourseUsages in the group.
            --  These are OR conditions so just need one completed CourseUsage in the Group to make it satisfied.
            select cua.DegreeTrackGroupID, cua.DegreeTrackID, cua.DegreeGroupID,
                    sum(cua.InProgressCredits) + sum(cua.AccruedCredits) as InProgressOrAccruedCredits,
                    sum(case when cua.AccruedCredits >= cua.DegreeTrackCourseUsageMinimumCredits then 1 else 0 end) as TotalPassedCourseUsages
                from @courseUsageAccruals cua
                group by cua.DegreeTrackGroupID, cua.DegreeTrackID, cua.DegreeGroupID
        ) a
        group by a.DegreeTrackID, a.DegreeGroupID

    --  At this point, the records only apply to the degree (or continuing ed requirements) so just sum them.  This finds the number of
    --  Groups inside it that have not been satisfied (do not have at least 1 completed Degree Track)
    declare @inProgressOrAccruedCredits int
    declare @totalUnmetDegreeGroups int
    select @inProgressOrAccruedCredits = sum(a.InProgressOrAccruedCredits),
            @totalUnmetDegreeGroups = sum(case when a.TotalCompletedDegreeTracks = 0 then 1 else 0 end)
        from (
            --  Groups by the DegreeGroup and finds the number of Completed/Passed DegreeTracks in the group.
            --  These are OR conditions so just need one completed DegreeTrack in the Group to make it satisfied.
            select gbdt.DegreeGroupID,
                    sum(gbdt.InProgressOrAccruedCredits) as InProgressOrAccruedCredits,
                    sum(case when gbdt.TotalUnmetGroups = 0 then 1 else 0 end) as TotalCompletedDegreeTracks
                from @groupByDegreeTrack gbdt
                group by gbdt.DegreeGroupID
        ) a

    declare @newDegreeStatus int
    select @newDegreeStatus = case when @totalUnmetDegreeGroups > 0
                                then case when @inProgressOrAccruedCredits > 0
                                            then 1 -- In Progress
                                            else 0 -- Not Started
                                        end
                                else 2 -- Complete
                                end
    
    return @newDegreeStatus
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Get_Question_Efficacy_Statistics]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_Get_Question_Efficacy_Statistics] (@questionID uniqueidentifier)
returns 
@statistics table (DiscriminationIndex float, DifficultyIndex float, OptimalDifficulty float, LowerBoundDifficulty float, TotalRespondents int, TotalCorrectRespondents int)
AS
BEGIN
declare @totalRespondents int
		, @totalCorrectRespondents int
		, @discriminationIndex float
		, @diffultyIndex float
		, @optimalDifficulty float
		, @lowerBoundDifficulty float
		, @totalResponseCombinations int
declare @questionInfo table(AssessmentID UniqueIdentifier, IsCorrect bit, RowNumber int)


select @totalResponseCombinations = 
		CASE 
			WHEN q.QuestionResponseTypeID in (1, 4, 5) THEN COUNT(*)
			WHEN q.QuestionResponseTypeID in (6, 10) THEN CAST(POWER(COUNT(*),2.0) as int)
			ELSE 0
		END
from Questions q
join PossibleResponses pr on q.ID = pr.QuestionID
where q.ID = @questionID
group by q.QuestionResponseTypeID

insert @questionInfo
select sa.AssessmentID, saq.IsCorrect, ROW_NUMBER() OVER (ORDER BY ps.Score DESC) as RowNumber
		from questions q
		join ScheduledAssessmentQuestions saq on q.ID = saq.QuestionID
		join ScheduledAssessments sa on saq.ScheduledAssessmentID = sa.ID
		join PersonScores ps on ps.PersonID = sa.AssessorID and ps.ScheduledAssessmentID = sa.ID
		where q.ID = @questionID

		--The discrimination index is a statistical value used to determine the efficacy of a 
		--question by comparing the performance of traditionally stronger students with 
		--traditionally weaker ones. The idea is that, if stronger students are getting the 
		--question right consistently and weaker students are getting it wrong consistently
		--then the question may be difficult, but it is an effective question in terms of testing.
		--The formula is D = (Uc - Lc)/U where:
		--	D is the discrimination index
		--	Uc is the population of stronger students that got it correct (using the top 27%
		--		of performers on the assessment containing the question)
		--	Lc is the poulation of weaker students that got is correct (using the bottom 27%
		--		of performers on the assessment containing the question)
		--	U is the population of stronger students in total.
		--
		--The discrimination index will fall in a range of -1.00 to 1.00 with any value greater
		--then 0.3 indicating an effective question.
select  @discriminationIndex = CASE WHEN SUM(CAST(y.TotalTopRespondents AS float)) is null OR SUM(CAST(y.TotalTopRespondents AS float)) = 0 THEN null
							   ELSE (SUM(CAST(y.TotalTopRespondentsThatGotItCorrect AS float)) - SUM(CAST(y.TotalBottomRespondentsThatGotItCorrect AS float))) / SUM(CAST(y.TotalTopRespondents AS float))
							   END
		--The difficulty index or p-value determines the relative difficulty of a question in terms of
		--how many respondents get it right and wrong. 
		--The formula is p = A/N where:
		--	p is the difficulty index
		--	A is the number the question was answered correctly
		--	N is the total number of correct and incorrect answers
		--The difficulty index will fall in the range of 0 (difficult) to 1.00 (easy).
		, @diffultyIndex = CASE WHEN SUM(CAST(y.NumberOfRespondents AS float)) is null or SUM(CAST(y.NumberOfRespondents AS float)) = 0 THEN null
						   ELSE SUM(CAST(y.TotalCorrect AS float)) / SUM(CAST(y.NumberOfRespondents AS float))
						   END
		--Other important values are the optimal difficulty and the lower bound difficulty
		--which allows for the determination of a scale (easy - optimal - hard). Both of these
		--values are a function of the number of answer combinations.
		--The formula for optimal difficulty is Do = (1.0 + (1 / Tr))) / 2 where:
		--	Do is the optimal difficulty
		--	Tr is the total number of response combinations
		, @optimalDifficulty = CASE WHEN @totalResponseCombinations is null OR @totalResponseCombinations = 0 THEN null
							   ELSE (1.0 + ( 1 / CAST(@totalResponseCombinations AS float))) / 2
							   END
		--The formula for lower bound difficulty is Dlb = (1 + 1.645*Math.Sqrt((Tr - 1)/ N))/Tr where:
		--	Dlb is the lower bound of the difficulty
		--	Tr is the total number of response combinations
		--	N is the total number of correct and incorrect answers
		, @lowerBoundDifficulty = CASE WHEN SUM(CAST(y.NumberOfRespondents AS float)) is null OR SUM(CAST(y.NumberOfRespondents AS float)) = 0 OR @totalResponseCombinations is null OR @totalResponseCombinations = 0 THEN null
								  ELSE (1 + 1.645 * SQRT((CAST(@totalResponseCombinations as float) - 1) / SUM(CAST(y.NumberOfRespondents AS float)))) / @totalResponseCombinations
								  END
		, @totalRespondents = SUM(y.NumberOfRespondents)
		, @totalCorrectRespondents = SUM(y.TotalCorrect)
from (
	select	qi.AssessmentID,
			x.NumberOfRespondents,
			x.TotalTopRespondents,
			SUM(CASE WHEN qi.IsCorrect = 1 THEN 1 ELSE 0 END) as TotalCorrect,
			SUM(CASE WHEN qi.IsCorrect = 1 AND qi.RowNumber <= x.TotalTopRespondents THEN 1 ELSE 0 END) as TotalTopRespondentsThatGotItCorrect,
			SUM(CASE WHEN qi.IsCorrect = 1 AND qi.RowNumber >= (x.NumberOfRespondents - x.TotalTopRespondents + 1) THEN 1 ELSE 0 END) as TotalBottomRespondentsThatGotItCorrect
	from (
		select stats.AssessmentID,
				COUNT(stats.AssessmentID) as NumberOfRespondents, 
				ROUND(0.27 * COUNT(*), 0) as TotalTopRespondents
				--, SUM(CASE WHEN (stats.IsCorrect = 1 AND stats.RowNumber <= ROUND(0.27 * COUNT(*), 0)) THEN 1 ELSE 0 END) as TotalTopRespondentsThatGotItCorrect
		from @questionInfo as stats
		group by stats.AssessmentID
		) as x
	join @questionInfo qi on x.AssessmentID = qi.AssessmentID
	group by qi.AssessmentID, x.TotalTopRespondents, x.NumberOfRespondents
	) as y

insert @statistics
	select @discriminationIndex, @diffultyIndex, @optimalDifficulty, @lowerBoundDifficulty, @totalRespondents, @totalCorrectRespondents

return
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ScheduledAssessment_MostCompleteStatus]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_ScheduledAssessment_MostCompleteStatus] (@scheduledEventID uniqueidentifier, @assessmentID uniqueidentifier, @personID uniqueidentifier)
returns int
AS
BEGIN
    declare @status int
    select top 1 @status = Status
        from ScheduledAssessments sa
            join Assessment_ScheduledEvent ase on ase.ID = sa.AssessmentScheduledEventID
        where ase.ScheduledEventID = @scheduledEventID and sa.AssessmentID = @assessmentID and (sa.AssessorID = @personID or sa.Subject_EntityID = @personID)
        order by sa.LastModifyDateTime desc

    return @status

    /* It seems like this is attempting to find the status of the last ScheduledAssessment.  But...
       1) It doesn't take into account the order of the records in any way
       2) It doesn't properly check the status of the PersonScore record (so will not detect partially graded, for example)
       3) The Status values have change since it was written so that we not have a proper NotGraded status.

       So it seems like the correct way to do this is just to pick out the last modified record.  Left this here in case that's not right.
       
    declare @status int,
            @currentStatus int,
            @graded bit;

    set @status = 3 --Not Started
    declare status_cursor CURSOR FOR
    select sa.Status, CASE WHEN seps.ID is null THEN 0 ELSE 1 END
    from ScheduledAssessments sa
    join Assessment_ScheduledEvent ase on sa.AssessmentScheduledEventID = ase.ID
    left outer join PersonScores seps on sa.ID = seps.ScheduledAssessmentID
    where ase.ScheduledEventID = @scheduledEventID and sa.AssessmentID = @assessmentID and (sa.AssessorID = @personID or sa.Subject_EntityID = @personID)

    OPEN status_cursor

    FETCH NEXT FROM status_cursor
    INTO @currentStatus, @graded

    WHILE @@FETCH_STATUS = 0  
    BEGIN
        -- status values
        -- 3 - Not Started
        -- 0 - Incomplete or In progress
        -- 1 - Submitted or Completed
        -- 2 - Reviewed
        -- 4 - Ungraded
        if (@status = 3 
            or (@status = 0 and @currentStatus in (1,2))
            or (@status = 1 and @currentStatus in (2))) 
            set @status = @currentStatus;
        if (@status in (1,2) and @graded = 0)
            set @status = 4

        FETCH NEXT FROM status_cursor
        INTO @currentStatus, @graded
    END
    CLOSE status_cursor
    DEALLOCATE status_cursor
    return @status
    */
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ScheduledEvent_CountPeopleOfRole]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_ScheduledEvent_CountPeopleOfRole] (@courseID uniqueidentifier, @calendarID uniqueidentifier, @scheduledEventID uniqueidentifier, @roleType int, @useAllPeopleFromCalendar bit, @useAllPeopleFromCourse bit)
RETURNS int
AS
BEGIN
    --  Returns a count of the number of Current people in the scheduled event.  Will not double count if a student
    --  is retaking.
    --  TODO: This will return people who have "completed" the course which should be fine for a Calendar course
    --  but may not be appropriate for an Independent Study course.

    --	@roleType must be: 2 (Student) or 3 (Instructor)
    declare @peopleCount int

    if (@useAllPeopleFromCalendar = 0)
    begin
        --	Use Students/Instructors on the ScheduledEvent
        select @peopleCount = count(1)
            from ScheduledEvent_People sep 
                join Course_People cp on cp.ID = sep.CoursePersonID
                join People p on p.ID = cp.PersonID 
            where sep.ScheduledEventID = @scheduledEventID and cp.RoleType = @roleType and p.IsDeleted = 0
                and cp.Retaken = 0       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)
    end else
    begin
        --	Use Students/Instructors on the Calendar
        if (@courseID is null)
            select @courseID = CourseID, @useAllPeopleFromCourse = UseAllStudentsFromCourse from Calendars where ID = @calendarID

        select @peopleCount = dbo.fn_Calendar_CountPeopleOfRole(@courseID, @calendarID, @roleType, @useAllPeopleFromCourse)
    end

    return @peopleCount
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ScheduledEvent_CoursePersonIsRoleType]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_ScheduledEvent_CoursePersonIsRoleType] (@scheduledEventID uniqueidentifier, @roleType int, @coursePersonID uniqueidentifier)
returns bit
AS
BEGIN
    --  This checks a specific instance of a Course_People record.

    declare @personIsRoleType bit
    select @personIsRoleType = 0

    --	@roleType must be: 2 (Student) or 3 (Instructor)

    declare @useAllPeopleFromCalendar bit
    declare @calendarID uniqueidentifier
    select @useAllPeopleFromCalendar = case when @roleType=2 then se.UseAllStudentsFromCalendar else se.UseAllInstructorsFromCalendar end, 
            @calendarID = se.CalendarID
        from Scheduled_Events se
        where se.ID = @scheduledEventID

    if (@useAllPeopleFromCalendar = 0)
    begin
        --	Use Students/Instructors on the ScheduledEvent
        if exists (select top 1 1
                    from ScheduledEvent_People sep 
                        join Course_People cp on cp.ID = sep.CoursePersonID
                        join People p on p.ID = cp.PersonID 
                    where sep.ScheduledEventID = @scheduledEventID and cp.ID = @coursePersonID and cp.RoleType = @roleType and p.IsDeleted = 0)
            select @personIsRoleType = 1
    end else
    begin
        --	Use Students/Instructors on the Calendar
        select @personIsRoleType = dbo.fn_Calendar_CoursePersonIsRoleType(@calendarID, @roleType, @coursePersonID)
    end

    return @personIsRoleType
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ScheduledEvent_IsAvailableForPerson]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_ScheduledEvent_IsAvailableForPerson] (@scheduledEventID uniqueidentifier, @roleType int, @coursePersonID uniqueidentifier)
returns bit
AS
BEGIN
    declare @previousScheduledEventID uniqueidentifier
    declare @courseID  uniqueidentifier
    declare @personID  uniqueidentifier
    declare @courseType int
    declare @scheduledDate datetime
    declare @returnValue bit
	declare @previousEventAttendanceRequired bit
	declare @completionStatus int

    --3 is instructor, all events are available to instructors
    if (@roleType = 3)
        return 1

	select top 1 @personID = cp.PersonID, @courseID = cp.CourseID, @courseType = c.[Type], @completionStatus = cp.CompletionStatus
	from Course_People cp
    join Courses c on c.ID = cp.CourseID
	where cp.ID = @coursePersonID

    select top 1 @scheduledDate = se.ScheduledDate
	from Scheduled_Events se
    where se.ID = @scheduledEventID

	--If they have completed the course then the event is available to them even if something is required (the item may have been made required after they completed)
	if (@completionStatus = 2)
		return 1

    --  If the person isn't of the role passed in then then this event isn't available to them.
    if (dbo.fn_ScheduledEvent_CoursePersonIsRoleType(@scheduledEventID, @roleType, @coursePersonID) <> 1)
        return 0

	--Find the previous event that has a required item for the person on it
	select top 1 @previousScheduledEventID = se.ID,  @previousEventAttendanceRequired = se.AttendanceParams_Required
		from Scheduled_Events se
			left join Assessment_ScheduledEvent ase on se.ID = ase.ScheduledEventID and ase.Required = 1 
			left join AssessmentScheduleParams sp on ase.AssessmentScheduleParamsID = sp.ID and sp.AssessorRoleType = @roleType
			left join Resource_ScheduledEvents rse on se.ID = rse.ScheduledEventID and rse.Required = 1
		where se.CourseID = @courseID 
			and se.ScheduledDate < @scheduledDate 
			and dbo.fn_ScheduledEvent_CoursePersonIsRoleType(se.ID, @roleType, @coursePersonID) = 1
			and (rse.ID is not null or (ase.ID is not null and sp.ID is not null) or se.AttendanceParams_Required = 1)
		order by se.ScheduledDate desc, se.DurationMinutes, se.Name

	--short circuit and return not allowed if they haven't been marked as present
	if (@previousEventAttendanceRequired = 1 and not exists (select * from Attendance where ParentEntityID = @previousScheduledEventID and CoursePersonID = @coursePersonID))
	begin
		return 0
	end

    if (@courseType = 0)--0 = calendar course
    begin
        if ((select TimeReleaseEvents from Courses where ID = @courseID) = 1)
        begin
            if (@scheduledDate <= GETUTCDATE())
                set @returnValue = 1
            else
                set @returnValue = 0
        end else
            set @returnValue = 1
    end 
	else
    begin

        --If nothing is required then it's available
        if (@previousScheduledEventID is null)
            set @returnValue = 1
        else
            select @returnValue = 
				case 
					when count(ResourceComplete) > 0 or Count(AssessmentComplete) > 0 
					then 0 
					else 1 
				end -- we only select the ones that have an incomplete resource or assessment, so a count here for one of them works
            from
                (select --Find out if they have completed all the required items from the the previous event with a required item
                case	when rse.ID is null then 1 --If no resource is required, then it's not locked for them
                        when rse.ResourceID = rci.ParentEntityID then 1 else 0 end as ResourceComplete, 
                case	when ase.ID is null then 1 --If no assessment is required, then it's not locked for them
                        when sp.AssessorRoleType <> @roleType then 1 
                        when exam.RootID = aci.ParentEntityID or eval.RootID = aci.ParentEntityID then 1 else 0 end as AssessmentComplete
                from Scheduled_Events se
                    left join Resource_ScheduledEvents rse on se.ID = rse.ScheduledEventID and rse.Required = 1
                    left join ScheduledEventCompletedItems rci on se.ID = rci.ScheduledEventID and rci.CoursePersonID = @coursePersonID and rci.ParentEntityID = rse.ResourceID
                    left join Assessment_ScheduledEvent ase on se.ID = ase.ScheduledEventID and ase.Required = 1
                    left join AssessmentScheduleParams sp on ase.AssessmentScheduleParamsID = sp.ID
					left outer join Examinations exam on ase.AssessmentID = exam.ID 
					left outer join Evaluations eval on ase.AssessmentID = eval.ID 
                    left join ScheduledEventCompletedItems aci on se.ID = aci.ScheduledEventID and aci.CoursePersonID = @coursePersonID and (aci.ParentEntityID = exam.RootID or aci.ParentEntityID = eval.RootID)
                where se.ID = @previousScheduledEventID) as Completed
            where ResourceComplete = 0 or AssessmentComplete = 0
    end

    return @returnValue
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ScheduledEvent_PeopleOfRole]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_ScheduledEvent_PeopleOfRole] (@scheduledEventID uniqueidentifier, @roleType int)
RETURNS 
@people TABLE (PersonID uniqueidentifier)
AS
BEGIN
    --  Returns the Current people in the scheduled event.  Will not double count if a student is retaking.
    --  TODO: This will count people who have "completed" the course which should be fine for a Calendar course
    --  but may not be appropriate for an Independent Study course.

    --	@roleType must be: 2 (Student) or 3 (Instructor)

    declare @useAllPeopleFromCalendar bit
    declare @calendarID uniqueidentifier
    select @useAllPeopleFromCalendar = case when @roleType=2 then se.UseAllStudentsFromCalendar else se.UseAllInstructorsFromCalendar end, 
            @calendarID = se.CalendarID
        from Scheduled_Events se
        where se.ID = @scheduledEventID

    if (@useAllPeopleFromCalendar = 0)
    begin
        --	Use Students/Instructors on the ScheduledEvent
        insert into @people
            select cp.PersonID 
                from ScheduledEvent_People sep 
                    join Course_People cp on cp.ID = sep.CoursePersonID
                    join People p on p.ID = cp.PersonID 
                where sep.ScheduledEventID = @scheduledEventID and cp.RoleType = @roleType and p.IsDeleted = 0
                    and cp.Retaken = 0       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)
    end else
    begin
        --	Use Students/Instructors on the Calendar
        insert into @people
            select PersonID from dbo.fn_Calendar_PeopleOfRole(@calendarID, @roleType)
    end

    return
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ScheduledEvent_PersonIsRoleType]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_ScheduledEvent_PersonIsRoleType] (@scheduledEventID uniqueidentifier, @roleType int, @personID uniqueidentifier)
returns bit
AS
BEGIN
    --  ****  Do not use this function - it is being replaced by fn_ScheduledEvent_CoursePersonIsRoleType which
    --  takes a CoursePersonID instead of a PersonID.

    --  ** This checks the current instance of the Coure_People record.  If we need to check for past instances
    --  (i.e. a Course_People record from a previous instance of the course), we will either need a new method
    --  or should change this to take the Course_People.ID instead of @personID.  Same for fn_Calendar_PersonIsRoleType.

    declare @personIsRoleType bit
    select @personIsRoleType = 0

    --	@roleType must be: 2 (Student) or 3 (Instructor)

    declare @useAllPeopleFromCalendar bit
    declare @calendarID uniqueidentifier
    select @useAllPeopleFromCalendar = case when @roleType=2 then se.UseAllStudentsFromCalendar else se.UseAllInstructorsFromCalendar end, 
            @calendarID = se.CalendarID
        from Scheduled_Events se
        where se.ID = @scheduledEventID

    if (@useAllPeopleFromCalendar = 0)
    begin
        --	Use Students/Instructors on the ScheduledEvent
        if exists (select top 1 1
                    from ScheduledEvent_People sep 
                        join Course_People cp on cp.ID = sep.CoursePersonID
                        join People p on p.ID = cp.PersonID 
                    where sep.ScheduledEventID = @scheduledEventID and cp.PersonID = @personID and cp.RoleType = @roleType and p.IsDeleted = 0
                        and cp.Retaken = 0)       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)
            select @personIsRoleType = 1
    end else
    begin
        --	Use Students/Instructors on the Calendar
        select @personIsRoleType = dbo.fn_Calendar_PersonIsRoleType(@calendarID, @roleType, @personID)
    end

    return @personIsRoleType
END
GO
/****** Object:  Table [Configuration].[AllowedRoleType]    Script Date: 3/14/2021 4:50:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[AllowedRoleType](
	[ID] [uniqueidentifier] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[RoleType] [int] NOT NULL,
	[IsCourseType] [bit] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Configuration.AllowedRoleType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Configuration].[ClientSettings]    Script Date: 3/14/2021 4:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[ClientSettings](
	[ID] [uniqueidentifier] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[SettingType] [int] NOT NULL,
	[SettingValue] [nvarchar](max) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Configuration.ClientSettings] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Configuration].[DirectObservationTypes]    Script Date: 3/14/2021 4:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[DirectObservationTypes](
	[ID] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[AAMCID] [nvarchar](max) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Configuration.DirectObservationTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Configuration].[EntityTypeSettings]    Script Date: 3/14/2021 4:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[EntityTypeSettings](
	[ID] [uniqueidentifier] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[EntityTypeID] [int] NOT NULL,
	[Hidden] [bit] NULL,
	[TrackEntityState] [bit] NULL,
	[Versionable] [bit] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Configuration.EntityTypeSettings] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Configuration].[EvaluationTypes]    Script Date: 3/14/2021 4:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[EvaluationTypes](
	[ID] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[AAMCID] [nvarchar](max) NULL,
 CONSTRAINT [PK_Reference.EvaluationTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Configuration].[EventTypes]    Script Date: 3/14/2021 4:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[EventTypes](
	[ID] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[AAMCID] [nvarchar](max) NULL,
 CONSTRAINT [PK_Configuration.EventTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Configuration].[ExaminationTypes]    Script Date: 3/14/2021 4:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[ExaminationTypes](
	[ID] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[AAMCID] [nvarchar](max) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Configuration.ExaminationTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Configuration].[LevelsOfLearning]    Script Date: 3/14/2021 4:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[LevelsOfLearning](
	[ID] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](200) NULL,
	[DisplayOrder] [int] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[OwnerClientID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Reference.LevelsOfLearning] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Configuration].[LocationTypes]    Script Date: 3/14/2021 4:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[LocationTypes](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Configuration.LocationTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Configuration].[LogRequirementTypes]    Script Date: 3/14/2021 4:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[LogRequirementTypes](
	[ID] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[AAMCID] [nvarchar](max) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Configuration.LogRequirementTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Configuration].[OrganizationTypes]    Script Date: 3/14/2021 4:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[OrganizationTypes](
	[ID] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Configuration.OrganizationTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Configuration].[RenewalFrequencyTypes]    Script Date: 3/14/2021 4:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[RenewalFrequencyTypes](
	[ID] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[RenewalFrequency_Period] [int] NOT NULL,
	[RenewalFrequency_Amount] [int] NOT NULL,
 CONSTRAINT [PK_Configuration.RenewalFrequencyTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Configuration].[ResourceTypes]    Script Date: 3/14/2021 4:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[ResourceTypes](
	[ID] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[OwnerClientID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Reference.ResourceTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Configuration].[SeminarTypes]    Script Date: 3/14/2021 4:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Configuration].[SeminarTypes](
	[ID] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Configuration.SeminarTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[__MigrationHistory]    Script Date: 3/14/2021 4:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__MigrationHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ContextKey] [nvarchar](300) NOT NULL,
	[Model] [varbinary](max) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK_dbo.__MigrationHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC,
	[ContextKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Activities]    Script Date: 3/14/2021 4:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Activities](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Description] [nvarchar](max) NULL,
	[ActivityType] [int] NOT NULL,
	[AvailableStartDate] [datetime] NOT NULL,
	[AvailableEndDate] [datetime] NULL,
	[Instructions] [nvarchar](max) NULL,
	[AssessmentID] [uniqueidentifier] NULL,
	[OwnerClientID] [uniqueidentifier] NOT NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
	[Priorities] [nvarchar](max) NULL,
	[Label] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.Activities] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Activity_Person]    Script Date: 3/14/2021 4:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Activity_Person](
	[ActivityID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Activity_Person] PRIMARY KEY CLUSTERED 
(
	[ActivityID] ASC,
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Addresses]    Script Date: 3/14/2021 4:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Addresses](
	[ID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NULL,
	[ClientID] [uniqueidentifier] NULL,
	[Address1] [nvarchar](max) NULL,
	[Address2] [nvarchar](200) NULL,
	[City] [nvarchar](max) NULL,
	[StateID] [nvarchar](max) NULL,
	[ZipCode] [nvarchar](max) NULL,
	[AddressType] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[Latitude] [decimal](18, 15) NOT NULL,
	[Longitude] [decimal](18, 15) NOT NULL,
	[Country] [nvarchar](max) NULL,
	[IsPrimary] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.Addresses] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Assessment_EventTemplate]    Script Date: 3/14/2021 4:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Assessment_EventTemplate](
	[AssessmentID] [uniqueidentifier] NOT NULL,
	[EventTemplateID] [uniqueidentifier] NOT NULL,
	[AssessmentScheduleParamsID] [uniqueidentifier] NOT NULL,
	[Purpose] [int] NOT NULL,
	[Required] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.Assessment_EventTemplate] PRIMARY KEY CLUSTERED 
(
	[AssessmentID] ASC,
	[EventTemplateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Assessment_Resource]    Script Date: 3/14/2021 4:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Assessment_Resource](
	[AssessmentID] [uniqueidentifier] NOT NULL,
	[ResourceID] [uniqueidentifier] NOT NULL,
	[ViewableByStudents] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.Assessment_Resource] PRIMARY KEY CLUSTERED 
(
	[AssessmentID] ASC,
	[ResourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Assessment_ScheduledEvent]    Script Date: 3/14/2021 4:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Assessment_ScheduledEvent](
	[ID] [uniqueidentifier] NOT NULL,
	[AssessmentID] [uniqueidentifier] NOT NULL,
	[ScheduledEventID] [uniqueidentifier] NOT NULL,
	[AssessmentScheduleParamsID] [uniqueidentifier] NOT NULL,
	[AssessmentScheduleQueueID] [uniqueidentifier] NULL,
	[GradableItemID] [uniqueidentifier] NULL,
	[Purpose] [int] NOT NULL,
	[Required] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.Assessment_ScheduledEvent] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AssessmentFormRow_Question]    Script Date: 3/14/2021 4:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssessmentFormRow_Question](
	[AssessmentFormRowID] [uniqueidentifier] NOT NULL,
	[QuestionID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.AssessmentFormRow_Question] PRIMARY KEY CLUSTERED 
(
	[AssessmentFormRowID] ASC,
	[QuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AssessmentFormRows]    Script Date: 3/14/2021 4:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssessmentFormRows](
	[ID] [uniqueidentifier] NOT NULL,
	[AssessmentFormSectionID] [uniqueidentifier] NOT NULL,
	[RowType] [int] NOT NULL,
	[TextHtml] [nvarchar](max) NULL,
	[Required] [bit] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Percent] [decimal](18, 2) NOT NULL,
	[UsePercent] [bit] NOT NULL,
	[Weight] [decimal](18, 2) NOT NULL,
	[QuestionsToDeliver] [int] NOT NULL,
	[IsGraded] [bit] NOT NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.AssessmentFormRows] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AssessmentForms]    Script Date: 3/14/2021 4:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssessmentForms](
	[ID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.AssessmentForms] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AssessmentFormSections]    Script Date: 3/14/2021 4:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssessmentFormSections](
	[ID] [uniqueidentifier] NOT NULL,
	[AssessmentFormID] [uniqueidentifier] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[MakeAllAssessmentRowScoresEqual] [bit] NOT NULL,
	[Percent] [decimal](18, 2) NOT NULL,
	[UsePercent] [bit] NOT NULL,
	[Weight] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_dbo.AssessmentFormSections] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Assessments]    Script Date: 3/14/2021 4:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Assessments](
	[ID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[ParentEntityType] [int] NOT NULL,
	[InteractiveContentID] [uniqueidentifier] NULL,
	[AdministrationType] [int] NOT NULL,
	[IsGraded] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.Assessments] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AssessmentScheduleParams]    Script Date: 3/14/2021 4:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssessmentScheduleParams](
	[ID] [uniqueidentifier] NOT NULL,
	[SubjectEntityType] [int] NOT NULL,
	[SubjectID] [uniqueidentifier] NULL,
	[StartActionTime] [int] NOT NULL,
	[StartMinutes] [int] NOT NULL,
	[EndActionTime] [int] NOT NULL,
	[EndMinutes] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[AssessorRoleType] [int] NULL,
	[SubjectRoleType] [int] NULL,
	[AllowResubmission] [bit] NOT NULL,
	[MaxNumberOfResubmissions] [int] NULL,
	[EvaluationSubjectType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.AssessmentScheduleParams] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AssessmentScheduleQueue]    Script Date: 3/14/2021 4:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssessmentScheduleQueue](
	[ID] [uniqueidentifier] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[LockID] [uniqueidentifier] NULL,
	[LockDate] [datetime] NULL,
 CONSTRAINT [PK_dbo.AssessmentScheduleQueue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AssignmentTemplate_EventTemplate]    Script Date: 3/14/2021 4:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssignmentTemplate_EventTemplate](
	[EventTemplateID] [uniqueidentifier] NOT NULL,
	[AssignmentTemplateID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.AssignmentTemplate_EventTemplate] PRIMARY KEY CLUSTERED 
(
	[EventTemplateID] ASC,
	[AssignmentTemplateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AssignmentTemplate_LearningObjective]    Script Date: 3/14/2021 4:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssignmentTemplate_LearningObjective](
	[AssignmentTemplateID] [uniqueidentifier] NOT NULL,
	[LearningObjectiveID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.AssignmentTemplate_LearningObjective] PRIMARY KEY CLUSTERED 
(
	[AssignmentTemplateID] ASC,
	[LearningObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AssignmentTemplates]    Script Date: 3/14/2021 4:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssignmentTemplates](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[Instructions] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[AllowStudentResponses] [bit] NOT NULL,
	[EntityState] [int] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[InUse] [bit] NOT NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.AssignmentTemplates] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AssignmentUploads]    Script Date: 3/14/2021 4:50:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssignmentUploads](
	[ID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NULL,
	[ResourceAssetID] [uniqueidentifier] NULL,
	[ScheduledAssignmentID] [uniqueidentifier] NULL,
	[ExpectedUploadID] [uniqueidentifier] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.AssignmentUploads] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Attendance]    Script Date: 3/14/2021 4:50:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Attendance](
	[ID] [uniqueidentifier] NOT NULL,
	[ParentEntityType] [int] NOT NULL,
	[ParentEntityID] [uniqueidentifier] NOT NULL,
	[CoursePersonID] [uniqueidentifier] NULL,
	[SeminarPersonID] [uniqueidentifier] NULL,
	[RecordedByPersonID] [uniqueidentifier] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[Method] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.Attendance] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuditReferences]    Script Date: 3/14/2021 4:50:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditReferences](
	[ID] [uniqueidentifier] NOT NULL,
	[AuditID] [uniqueidentifier] NOT NULL,
	[EntityID] [uniqueidentifier] NOT NULL,
	[EntityTypeID] [int] NOT NULL,
 CONSTRAINT [PK_dbo.AuditReferences] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Audits]    Script Date: 3/14/2021 4:50:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Audits](
	[ID] [uniqueidentifier] NOT NULL,
	[AuditDateTime] [datetime] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[Action] [nvarchar](1) NULL,
	[EntityTypeID] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Audits] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuditValues]    Script Date: 3/14/2021 4:50:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditValues](
	[ID] [uniqueidentifier] NOT NULL,
	[AuditID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[EntityTypeID] [int] NULL,
	[OldValue] [nvarchar](max) NULL,
	[NewValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.AuditValues] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BackgroundTasks]    Script Date: 3/14/2021 4:50:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BackgroundTasks](
	[ID] [uniqueidentifier] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[TaskType] [int] NOT NULL,
	[Frequency] [int] NOT NULL,
	[NextRunDate] [datetime] NOT NULL,
	[IntervalSeconds] [int] NULL,
	[Parameters] [nvarchar](max) NULL,
	[LockID] [uniqueidentifier] NULL,
	[LockDate] [datetime] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Enabled] [bit] NOT NULL,
	[ExecuteIfPastDue] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.BackgroundTasks] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Calendar_People]    Script Date: 3/14/2021 4:50:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Calendar_People](
	[CalendarID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NULL,
	[CoursePersonID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Calendar_People] PRIMARY KEY CLUSTERED 
(
	[CalendarID] ASC,
	[CoursePersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Calendars]    Script Date: 3/14/2021 4:50:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Calendars](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Color] [nvarchar](20) NULL,
	[CourseID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UseAllInstructorsFromCourse] [bit] NOT NULL,
	[UseAllStudentsFromCourse] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.Calendars] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Client_Organization]    Script Date: 3/14/2021 4:50:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Client_Organization](
	[ClientID] [uniqueidentifier] NOT NULL,
	[OrganizationID] [uniqueidentifier] NOT NULL,
	[OrganizationType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Client_Organization] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC,
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ClientNotificationPersons]    Script Date: 3/14/2021 4:50:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientNotificationPersons](
	[ID] [uniqueidentifier] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[NotificationType] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.ClientNotificationPersons] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Clients]    Script Date: 3/14/2021 4:50:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Clients](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[Domain] [nvarchar](200) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[Language] [nvarchar](max) NULL,
	[ExportReport] [nvarchar](max) NULL,
	[ParentClientID] [uniqueidentifier] NULL,
	[ClientCode] [nvarchar](10) NOT NULL,
	[NotificationUrl] [nvarchar](max) NULL,
	[TimeZone] [nvarchar](max) NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
	[Currency] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Clients] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContinuingEducationHistory]    Script Date: 3/14/2021 4:50:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContinuingEducationHistory](
	[ID] [uniqueidentifier] NOT NULL,
	[DateCompleted] [datetime] NULL,
	[DegreePersonID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[RenewalDueDate] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.ContinuingEducationHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContinuingEducationRequirements]    Script Date: 3/14/2021 4:50:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContinuingEducationRequirements](
	[ID] [uniqueidentifier] NOT NULL,
	[RenewalFrequencyID] [uniqueidentifier] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[FirstRenewalDelay] [int] NOT NULL,
 CONSTRAINT [PK_dbo.ContinuingEducationRequirements] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CoreCompetencies]    Script Date: 3/14/2021 4:50:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoreCompetencies](
	[ID] [uniqueidentifier] NOT NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[OwnerClientID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CoreCompetencies] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CoreCompetency_Degree]    Script Date: 3/14/2021 4:50:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoreCompetency_Degree](
	[CoreCompetencyID] [uniqueidentifier] NOT NULL,
	[DegreeID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CoreCompetency_Degree] PRIMARY KEY CLUSTERED 
(
	[CoreCompetencyID] ASC,
	[DegreeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CoreCompetency_ProgramObjective]    Script Date: 3/14/2021 4:50:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoreCompetency_ProgramObjective](
	[ProgramObjectiveID] [uniqueidentifier] NOT NULL,
	[CoreCompetencyID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CoreCompetency_ProgramObjective] PRIMARY KEY CLUSTERED 
(
	[ProgramObjectiveID] ASC,
	[CoreCompetencyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Course_DirectObservation]    Script Date: 3/14/2021 4:50:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Course_DirectObservation](
	[CourseID] [uniqueidentifier] NOT NULL,
	[DirectObservationID] [uniqueidentifier] NOT NULL,
	[NumRequired] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Course_DirectObservation] PRIMARY KEY CLUSTERED 
(
	[CourseID] ASC,
	[DirectObservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Course_LogRequirement]    Script Date: 3/14/2021 4:50:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Course_LogRequirement](
	[CourseID] [uniqueidentifier] NOT NULL,
	[LogRequirementID] [uniqueidentifier] NOT NULL,
	[NumRequired] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Course_LogRequirement] PRIMARY KEY CLUSTERED 
(
	[CourseID] ASC,
	[LogRequirementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Course_People]    Script Date: 3/14/2021 4:50:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Course_People](
	[CourseID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[RoleType] [int] NOT NULL,
	[SchedulingRoundID] [uniqueidentifier] NULL,
	[CompletionStatus] [int] NOT NULL,
	[StartDate] [datetime] NULL,
	[ID] [uniqueidentifier] NOT NULL,
	[EndDate] [datetime] NULL,
	[Retaken] [bit] NOT NULL,
	[PreviousCoursePersonID] [uniqueidentifier] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[StatusModifiedDate] [datetime] NOT NULL,
	[AddedBy] [int] NOT NULL,
	[HistoricalStatus] [int] NOT NULL,
	[AddedByID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.Course_People] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Course_Seminar]    Script Date: 3/14/2021 4:50:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Course_Seminar](
	[CourseID] [uniqueidentifier] NOT NULL,
	[SeminarID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Course_Seminar] PRIMARY KEY CLUSTERED 
(
	[CourseID] ASC,
	[SeminarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Course_Tag]    Script Date: 3/14/2021 4:50:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Course_Tag](
	[TagID] [uniqueidentifier] NOT NULL,
	[CourseID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Course_Tag] PRIMARY KEY CLUSTERED 
(
	[TagID] ASC,
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Course_WaitListPerson]    Script Date: 3/14/2021 4:50:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Course_WaitListPerson](
	[CourseID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[CourseDisplayOrder] [int] NOT NULL,
	[PersonDisplayOrder] [int] NOT NULL,
	[ID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.Course_WaitListPerson] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseCatalog_CourseOverview]    Script Date: 3/14/2021 4:50:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseCatalog_CourseOverview](
	[CourseCatalogID] [uniqueidentifier] NOT NULL,
	[CourseOverviewID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CourseCatalog_CourseOverview] PRIMARY KEY CLUSTERED 
(
	[CourseCatalogID] ASC,
	[CourseOverviewID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseCatalog_Person]    Script Date: 3/14/2021 4:50:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseCatalog_Person](
	[CourseCatalogID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CourseCatalog_Person] PRIMARY KEY CLUSTERED 
(
	[CourseCatalogID] ASC,
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseCatalog_SchedulingSession]    Script Date: 3/14/2021 4:50:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseCatalog_SchedulingSession](
	[SchedulingSessionID] [uniqueidentifier] NOT NULL,
	[CourseCatalogID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CourseCatalog_SchedulingSession] PRIMARY KEY CLUSTERED 
(
	[SchedulingSessionID] ASC,
	[CourseCatalogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseCatalogs]    Script Date: 3/14/2021 4:50:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseCatalogs](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.CourseCatalogs] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseObjective_CourseOverview]    Script Date: 3/14/2021 4:50:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseObjective_CourseOverview](
	[CourseObjectiveID] [uniqueidentifier] NOT NULL,
	[CourseOverviewID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CourseObjective_CourseOverview] PRIMARY KEY CLUSTERED 
(
	[CourseObjectiveID] ASC,
	[CourseOverviewID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseObjective_LearningObjective]    Script Date: 3/14/2021 4:50:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseObjective_LearningObjective](
	[LearningObjectiveID] [uniqueidentifier] NOT NULL,
	[CourseObjectiveID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CourseObjective_LearningObjective] PRIMARY KEY CLUSTERED 
(
	[LearningObjectiveID] ASC,
	[CourseObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseObjective_LevelOfLearning]    Script Date: 3/14/2021 4:50:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseObjective_LevelOfLearning](
	[LevelOfLearningID] [uniqueidentifier] NOT NULL,
	[CourseObjectiveID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CourseObjective_LevelOfLearning] PRIMARY KEY CLUSTERED 
(
	[LevelOfLearningID] ASC,
	[CourseObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseObjective_ProgramObjective]    Script Date: 3/14/2021 4:50:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseObjective_ProgramObjective](
	[ProgramObjectiveID] [uniqueidentifier] NOT NULL,
	[CourseObjectiveID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CourseObjective_ProgramObjective] PRIMARY KEY CLUSTERED 
(
	[ProgramObjectiveID] ASC,
	[CourseObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseObjective_Tag]    Script Date: 3/14/2021 4:50:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseObjective_Tag](
	[TagID] [uniqueidentifier] NOT NULL,
	[CourseObjectiveID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CourseObjective_Tag] PRIMARY KEY CLUSTERED 
(
	[TagID] ASC,
	[CourseObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseObjectives]    Script Date: 3/14/2021 4:50:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseObjectives](
	[ID] [uniqueidentifier] NOT NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[IsDeleted] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[OwnerClientID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CourseObjectives] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseOverview_LevelOfLearning]    Script Date: 3/14/2021 4:50:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseOverview_LevelOfLearning](
	[CourseOverviewID] [uniqueidentifier] NOT NULL,
	[LevelOfLearningID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CourseOverview_LevelOfLearning] PRIMARY KEY CLUSTERED 
(
	[CourseOverviewID] ASC,
	[LevelOfLearningID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseOverview_Tag]    Script Date: 3/14/2021 4:50:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseOverview_Tag](
	[TagID] [uniqueidentifier] NOT NULL,
	[CourseOverviewID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CourseOverview_Tag] PRIMARY KEY CLUSTERED 
(
	[TagID] ASC,
	[CourseOverviewID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseOverviews]    Script Date: 3/14/2021 4:50:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseOverviews](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[Credits] [int] NOT NULL,
	[EntityState] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Duration] [int] NOT NULL,
	[AllowConcurrentScheduling] [bit] NOT NULL,
	[InUse] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.CourseOverviews] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CoursePerson_Tag]    Script Date: 3/14/2021 4:50:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoursePerson_Tag](
	[CoursePersonID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.CoursePerson_Tag] PRIMARY KEY CLUSTERED 
(
	[CoursePersonID] ASC,
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Courses]    Script Date: 3/14/2021 4:50:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Courses](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[Syllabus] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[StartDate] [datetime] NULL,
	[IncludeWeekends] [bit] NOT NULL,
	[AvailableHoursStartTime] [datetime] NULL,
	[AvailableHoursEndTime] [datetime] NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[GradeBookID] [uniqueidentifier] NULL,
	[StudentsMax] [int] NOT NULL,
	[WaitListedPeopleMax] [int] NOT NULL,
	[CourseOverviewID] [uniqueidentifier] NOT NULL,
	[EndDate] [datetime] NULL,
	[Median] [decimal](18, 2) NOT NULL,
	[Average] [decimal](18, 2) NOT NULL,
	[Type] [int] NOT NULL,
	[TimeReleaseEvents] [bit] NOT NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
	[UseTimeLimit] [bit] NOT NULL,
	[TimeLimitDays] [int] NOT NULL,
	[AttendanceParams_Track] [bit] NOT NULL,
	[AttendanceParams_AllowedMethods] [int] NOT NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
	[IncludeInSelfRegistration] [bit] NOT NULL,
	[AttendanceParams_Required] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.Courses] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Degree_People]    Script Date: 3/14/2021 4:50:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Degree_People](
	[DegreeID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[CompletionStatus] [int] NOT NULL,
	[StatusModifiedDate] [datetime] NULL,
	[ID] [uniqueidentifier] NOT NULL,
	[PaidDate] [datetime] NULL,
	[PersonPaymentID] [uniqueidentifier] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[LastCertificateCardPrintedDate] [datetime] NULL,
	[ExpirationDate] [datetime] NULL,
	[NextRequiredContinuingEducationRenewalID] [uniqueidentifier] NULL,
	[CompletedDate] [datetime] NULL,
	[StartDate] [datetime] NULL,
 CONSTRAINT [PK_dbo.Degree_People] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Degree_Seminar]    Script Date: 3/14/2021 4:50:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Degree_Seminar](
	[DegreeID] [uniqueidentifier] NOT NULL,
	[SeminarID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Degree_Seminar] PRIMARY KEY CLUSTERED 
(
	[DegreeID] ASC,
	[SeminarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DegreeGroupDegreeTracks]    Script Date: 3/14/2021 4:50:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DegreeGroupDegreeTracks](
	[ID] [uniqueidentifier] NOT NULL,
	[DegreeGroupID] [uniqueidentifier] NOT NULL,
	[DegreeTrackID] [uniqueidentifier] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[OrderMethod] [int] NOT NULL,
 CONSTRAINT [PK_dbo.DegreeGroupDegreeTracks] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DegreeGroups]    Script Date: 3/14/2021 4:50:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DegreeGroups](
	[ID] [uniqueidentifier] NOT NULL,
	[DegreeID] [uniqueidentifier] NULL,
	[DisplayOrder] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[ContinuingEducationRequirementsID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.DegreeGroups] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Degrees]    Script Date: 3/14/2021 4:50:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Degrees](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Type] [int] NOT NULL,
	[AllowOnlineRegistration] [bit] NOT NULL,
	[ContinuingEducationRequirementsID] [uniqueidentifier] NULL,
	[RootID] [uniqueidentifier] NOT NULL,
	[Version] [int] NOT NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
	[Locked] [bit] NOT NULL,
	[MostRecentVersion] [bit] NOT NULL,
	[MostRecentApprovedVersion] [bit] NOT NULL,
	[Price] [float] NOT NULL,
	[ImageResourceAssetID] [uniqueidentifier] NULL,
	[CertificateText] [nvarchar](max) NULL,
	[VerificationSearchEnabled] [bit] NOT NULL,
	[ExpirationDuration_Period] [int] NOT NULL,
	[ExpirationDuration_Amount] [int] NOT NULL,
	[CertificateTemplate] [int] NOT NULL,
	[PrimarySignatoryID] [uniqueidentifier] NULL,
	[SecondarySignatoryID] [uniqueidentifier] NULL,
	[PersonID] [uniqueidentifier] NULL,
	[ExpirationBuffer] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Degrees] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DegreeTrack_LevelOfLearning]    Script Date: 3/14/2021 4:50:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DegreeTrack_LevelOfLearning](
	[DegreeTrackID] [uniqueidentifier] NOT NULL,
	[LevelOfLearningID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.DegreeTrack_LevelOfLearning] PRIMARY KEY CLUSTERED 
(
	[DegreeTrackID] ASC,
	[LevelOfLearningID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DegreeTrackCourseUsage_Tag]    Script Date: 3/14/2021 4:50:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DegreeTrackCourseUsage_Tag](
	[DegreeTrackCourseUsageID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.DegreeTrackCourseUsage_Tag] PRIMARY KEY CLUSTERED 
(
	[DegreeTrackCourseUsageID] ASC,
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DegreeTrackCourseUsages]    Script Date: 3/14/2021 4:50:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DegreeTrackCourseUsages](
	[ID] [uniqueidentifier] NOT NULL,
	[DegreeTrackGroupID] [uniqueidentifier] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[MinimumCredits] [int] NOT NULL,
	[MaximumCredits] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[OrderMethod] [int] NOT NULL,
 CONSTRAINT [PK_dbo.DegreeTrackCourseUsages] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DegreeTrackGroups]    Script Date: 3/14/2021 4:50:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DegreeTrackGroups](
	[ID] [uniqueidentifier] NOT NULL,
	[DegreeID] [uniqueidentifier] NULL,
	[DegreeTrackID] [uniqueidentifier] NULL,
	[DegreeTrackGroupType] [int] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[ContinuingEducationRequirementsID] [uniqueidentifier] NULL,
	[IsSequential] [bit] NOT NULL,
	[TagID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.DegreeTrackGroups] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DegreeTracks]    Script Date: 3/14/2021 4:50:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DegreeTracks](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[Duration_Period] [int] NOT NULL,
	[Duration_Amount] [int] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[RootID] [uniqueidentifier] NOT NULL,
	[Version] [int] NOT NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
	[Locked] [bit] NOT NULL,
	[MostRecentVersion] [bit] NOT NULL,
	[MostRecentApprovedVersion] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.DegreeTracks] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DirectObservation_Tag]    Script Date: 3/14/2021 4:50:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DirectObservation_Tag](
	[DirectObservationID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.DirectObservation_Tag] PRIMARY KEY CLUSTERED 
(
	[DirectObservationID] ASC,
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DirectObservations]    Script Date: 3/14/2021 4:50:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DirectObservations](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[RootID] [uniqueidentifier] NOT NULL,
	[Version] [int] NOT NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
	[MostRecentVersion] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Instructions] [nvarchar](max) NULL,
	[DurationMinutes] [int] NOT NULL,
	[DirectObservationTypeID] [uniqueidentifier] NULL,
	[Locked] [bit] NOT NULL,
	[MostRecentApprovedVersion] [bit] NOT NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.DirectObservations] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ELMAH_Error]    Script Date: 3/14/2021 4:50:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ELMAH_Error](
	[ErrorId] [uniqueidentifier] NOT NULL,
	[Application] [nvarchar](60) NOT NULL,
	[Host] [nvarchar](50) NOT NULL,
	[Type] [nvarchar](100) NOT NULL,
	[Source] [nvarchar](60) NOT NULL,
	[Message] [nvarchar](500) NOT NULL,
	[User] [nvarchar](50) NOT NULL,
	[StatusCode] [int] NOT NULL,
	[TimeUtc] [datetime] NOT NULL,
	[Sequence] [int] IDENTITY(1,1) NOT NULL,
	[AllXml] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_dbo.ELMAH_Error] PRIMARY KEY CLUSTERED 
(
	[ErrorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Emails]    Script Date: 3/14/2021 4:50:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Emails](
	[ID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NULL,
	[Address] [nvarchar](200) NULL,
	[EmailTypeID] [int] NOT NULL,
	[SendNotifications] [bit] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[HasBeenVerified] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.Emails] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnrollCourses]    Script Date: 3/14/2021 4:50:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnrollCourses](
	[ID] [uniqueidentifier] NOT NULL,
	[CourseID] [uniqueidentifier] NOT NULL,
	[EnrollDegreeID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.EnrollCourses] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnrollCourseUsages]    Script Date: 3/14/2021 4:50:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnrollCourseUsages](
	[ID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
	[EnrollCourseID] [uniqueidentifier] NULL,
	[PersonPaymentID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.EnrollCourseUsages] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnrollDegrees]    Script Date: 3/14/2021 4:50:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnrollDegrees](
	[ID] [uniqueidentifier] NOT NULL,
	[DegreeID] [uniqueidentifier] NOT NULL,
	[PersonPaymentID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.EnrollDegrees] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EntityType_Report]    Script Date: 3/14/2021 4:50:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EntityType_Report](
	[EntityTypeID] [int] NOT NULL,
	[ReportID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.EntityType_Report] PRIMARY KEY CLUSTERED 
(
	[EntityTypeID] ASC,
	[ReportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EntityType_TagCategory]    Script Date: 3/14/2021 4:50:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EntityType_TagCategory](
	[EntityTypeID] [int] NOT NULL,
	[TagCategoryID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.EntityType_TagCategory] PRIMARY KEY CLUSTERED 
(
	[EntityTypeID] ASC,
	[TagCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Evaluation_Resource]    Script Date: 3/14/2021 4:50:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Evaluation_Resource](
	[EvaluationID] [uniqueidentifier] NOT NULL,
	[ResourceID] [uniqueidentifier] NOT NULL,
	[ID] [uniqueidentifier] NOT NULL,
	[AssessmentScheduleParamsID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Evaluation_Resource] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Evaluation_Tag]    Script Date: 3/14/2021 4:50:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Evaluation_Tag](
	[EvaluationID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Evaluation_Tag] PRIMARY KEY CLUSTERED 
(
	[EvaluationID] ASC,
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Evaluations]    Script Date: 3/14/2021 4:50:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Evaluations](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[DurationMinutes] [int] NOT NULL,
	[CreateDurationMinutes] [int] NOT NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[EvaluationTypeID] [uniqueidentifier] NULL,
	[RootID] [uniqueidentifier] NOT NULL,
	[Version] [int] NOT NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
	[MostRecentVersion] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Locked] [bit] NOT NULL,
	[MostRecentApprovedVersion] [bit] NOT NULL,
	[Instructions] [nvarchar](max) NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.Evaluations] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EventTemplate_LearningObjective]    Script Date: 3/14/2021 4:50:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventTemplate_LearningObjective](
	[EventTemplateID] [uniqueidentifier] NOT NULL,
	[LearningObjectiveID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.EventTemplate_LearningObjective] PRIMARY KEY CLUSTERED 
(
	[EventTemplateID] ASC,
	[LearningObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EventTemplate_Resources]    Script Date: 3/14/2021 4:50:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventTemplate_Resources](
	[ID] [uniqueidentifier] NOT NULL,
	[ResourceID] [uniqueidentifier] NOT NULL,
	[EventTemplateID] [uniqueidentifier] NOT NULL,
	[Required] [bit] NOT NULL,
	[EventTemplateDisplayOrder] [int] NOT NULL,
	[ResourceDisplayOrder] [int] NOT NULL,
 CONSTRAINT [PK_dbo.EventTemplate_Resources] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EventTemplate_Tag]    Script Date: 3/14/2021 4:50:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventTemplate_Tag](
	[EventTemplateID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.EventTemplate_Tag] PRIMARY KEY CLUSTERED 
(
	[EventTemplateID] ASC,
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EventTemplateResource_RoleType]    Script Date: 3/14/2021 4:50:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventTemplateResource_RoleType](
	[EventTemplateResourceID] [uniqueidentifier] NOT NULL,
	[RoleType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.EventTemplateResource_RoleType] PRIMARY KEY CLUSTERED 
(
	[EventTemplateResourceID] ASC,
	[RoleType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EventTemplates]    Script Date: 3/14/2021 4:50:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventTemplates](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[EventTypeID] [uniqueidentifier] NULL,
	[Interprofessional] [bit] NOT NULL,
	[EntityState] [int] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Duration] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[InUse] [bit] NOT NULL,
	[Instructions] [nvarchar](max) NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.EventTemplates] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Examination_Tag]    Script Date: 3/14/2021 4:50:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Examination_Tag](
	[ExaminationID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Examination_Tag] PRIMARY KEY CLUSTERED 
(
	[ExaminationID] ASC,
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Examinations]    Script Date: 3/14/2021 4:50:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Examinations](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[RootID] [uniqueidentifier] NOT NULL,
	[Version] [int] NOT NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
	[MostRecentVersion] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[DurationMinutes] [int] NOT NULL,
	[ExaminationTypeID] [uniqueidentifier] NULL,
	[Locked] [bit] NOT NULL,
	[MostRecentApprovedVersion] [bit] NOT NULL,
	[Instructions] [nvarchar](max) NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.Examinations] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExpectedUploads]    Script Date: 3/14/2021 4:50:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExpectedUploads](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[ScheduledAssignmentID] [uniqueidentifier] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[AssignmentTemplateID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.ExpectedUploads] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GradableItems]    Script Date: 3/14/2021 4:50:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GradableItems](
	[ID] [uniqueidentifier] NOT NULL,
	[ParentEntityID] [uniqueidentifier] NOT NULL,
	[ParentEntityType] [int] NOT NULL,
	[Weight] [decimal](18, 2) NOT NULL,
	[RequiredToPass] [bit] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[CategoryID] [uniqueidentifier] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[UsePercent] [bit] NOT NULL,
	[Color] [nvarchar](max) NULL,
	[Median] [decimal](18, 2) NOT NULL,
	[Average] [decimal](18, 2) NOT NULL,
	[Percent] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_dbo.GradableItems] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GradeBookCategories]    Script Date: 3/14/2021 4:50:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GradeBookCategories](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Weight] [decimal](18, 2) NOT NULL,
	[RequiredToPass] [bit] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[GradeBookID] [uniqueidentifier] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[UsePercent] [bit] NOT NULL,
	[Color] [nvarchar](max) NULL,
	[Median] [decimal](18, 2) NOT NULL,
	[Average] [decimal](18, 2) NOT NULL,
	[Percent] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_dbo.GradeBookCategories] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GradeBooks]    Script Date: 3/14/2021 4:50:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GradeBooks](
	[ID] [uniqueidentifier] NOT NULL,
	[ShowClassStatisticsToStudents] [bit] NOT NULL,
	[HideScoresUntilPublished] [bit] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[GradingCriterionID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.GradeBooks] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GradingCriterionRanges]    Script Date: 3/14/2021 4:50:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GradingCriterionRanges](
	[ID] [uniqueidentifier] NOT NULL,
	[Grade] [nvarchar](max) NULL,
	[ConstitutesFailing] [bit] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[GradingCriterionID] [uniqueidentifier] NOT NULL,
	[Threshold] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_dbo.GradingCriterionRanges] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GradingCriterions]    Script Date: 3/14/2021 4:50:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GradingCriterions](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[DisplayID] [nvarchar](20) NULL,
	[IsDefault] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.GradingCriterions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Helps]    Script Date: 3/14/2021 4:50:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Helps](
	[ID] [uniqueidentifier] NOT NULL,
	[Information] [nvarchar](max) NULL,
	[ParentEntityType] [int] NULL,
	[HelpKey] [int] NULL,
	[Type] [int] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.Helps] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HtmlMediaContents]    Script Date: 3/14/2021 4:50:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HtmlMediaContents](
	[ID] [uniqueidentifier] NOT NULL,
	[ParentEntityID] [uniqueidentifier] NOT NULL,
	[ParentType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.HtmlMediaContents] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InteractiveContents]    Script Date: 3/14/2021 4:50:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InteractiveContents](
	[ID] [uniqueidentifier] NOT NULL,
	[ContentType] [int] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[SourceID] [nvarchar](max) NULL,
	[ThumbnailImageFilename] [nvarchar](max) NULL,
	[PublishedDate] [datetime] NULL,
	[AuthorName] [nvarchar](max) NULL,
	[DurationText] [nvarchar](max) NULL,
	[AuthoringApplicationName] [nvarchar](max) NULL,
	[AuthoringApplicationVersion] [nvarchar](max) NULL,
	[LaunchFilename] [nvarchar](max) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.InteractiveContents] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LearningObjective_LevelOfLearning]    Script Date: 3/14/2021 4:50:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LearningObjective_LevelOfLearning](
	[LevelOfLearningID] [uniqueidentifier] NOT NULL,
	[LearningObjectiveID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.LearningObjective_LevelOfLearning] PRIMARY KEY CLUSTERED 
(
	[LevelOfLearningID] ASC,
	[LearningObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LearningObjective_Question]    Script Date: 3/14/2021 4:50:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LearningObjective_Question](
	[LearningObjectiveID] [uniqueidentifier] NOT NULL,
	[QuestionID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.LearningObjective_Question] PRIMARY KEY CLUSTERED 
(
	[LearningObjectiveID] ASC,
	[QuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LearningObjective_Resource]    Script Date: 3/14/2021 4:50:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LearningObjective_Resource](
	[ResourceID] [uniqueidentifier] NOT NULL,
	[LearningObjectiveID] [uniqueidentifier] NOT NULL,
	[LearningObjectiveDisplayOrder] [int] NOT NULL,
	[ResourceDisplayOrder] [int] NOT NULL,
 CONSTRAINT [PK_dbo.LearningObjective_Resource] PRIMARY KEY CLUSTERED 
(
	[ResourceID] ASC,
	[LearningObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LearningObjective_ScheduledAssignment]    Script Date: 3/14/2021 4:50:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LearningObjective_ScheduledAssignment](
	[ScheduledAssignmentID] [uniqueidentifier] NOT NULL,
	[LearningObjectiveID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.LearningObjective_ScheduledAssignment] PRIMARY KEY CLUSTERED 
(
	[ScheduledAssignmentID] ASC,
	[LearningObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LearningObjective_ScheduledEvent]    Script Date: 3/14/2021 4:50:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LearningObjective_ScheduledEvent](
	[LearningObjectiveID] [uniqueidentifier] NOT NULL,
	[ScheduledEventID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.LearningObjective_ScheduledEvent] PRIMARY KEY CLUSTERED 
(
	[LearningObjectiveID] ASC,
	[ScheduledEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LearningObjective_Tag]    Script Date: 3/14/2021 4:50:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LearningObjective_Tag](
	[TagID] [uniqueidentifier] NOT NULL,
	[LearningObjectiveID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.LearningObjective_Tag] PRIMARY KEY CLUSTERED 
(
	[TagID] ASC,
	[LearningObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LearningObjectives]    Script Date: 3/14/2021 4:50:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LearningObjectives](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[RootID] [uniqueidentifier] NOT NULL,
	[Version] [int] NOT NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
	[MostRecentVersion] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Locked] [bit] NOT NULL,
	[MostRecentApprovedVersion] [bit] NOT NULL,
	[OwnerClientID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.LearningObjectives] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Locations]    Script Date: 3/14/2021 4:50:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Locations](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[LocationTypeID] [uniqueidentifier] NULL,
	[IsDeleted] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[AddressID] [uniqueidentifier] NULL,
	[ImageResourceAssetID] [uniqueidentifier] NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.Locations] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Logins]    Script Date: 3/14/2021 4:50:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Logins](
	[ID] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](max) NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[LastLoginDateTime] [datetime] NULL,
	[AuthenticationProvider] [int] NOT NULL,
	[ProviderID] [uniqueidentifier] NULL,
	[PreferredUsername] [nvarchar](max) NULL,
	[Email] [nvarchar](max) NULL,
	[EmailVerified] [bit] NOT NULL,
	[IsExternalProvider] [bit] NOT NULL,
	[IsExternalProviderName] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.Logins] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LogRequirement_Tag]    Script Date: 3/14/2021 4:50:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LogRequirement_Tag](
	[LogRequirementID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.LogRequirement_Tag] PRIMARY KEY CLUSTERED 
(
	[LogRequirementID] ASC,
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LogRequirements]    Script Date: 3/14/2021 4:50:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LogRequirements](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[RootID] [uniqueidentifier] NOT NULL,
	[Version] [int] NOT NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
	[MostRecentVersion] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Instructions] [nvarchar](max) NULL,
	[DurationMinutes] [int] NOT NULL,
	[LogRequirementTypeID] [uniqueidentifier] NULL,
	[Locked] [bit] NOT NULL,
	[MostRecentApprovedVersion] [bit] NOT NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.LogRequirements] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MarketingEfforts]    Script Date: 3/14/2021 4:50:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MarketingEfforts](
	[ID] [uniqueidentifier] NOT NULL,
	[SeminarID] [uniqueidentifier] NOT NULL,
	[RegistrationUrl] [nvarchar](max) NULL,
	[ShortCode] [nvarchar](max) NULL,
	[Type] [int] NOT NULL,
	[Budget] [decimal](18, 2) NOT NULL,
	[Spend] [decimal](18, 2) NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.MarketingEfforts] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MobileDevices]    Script Date: 3/14/2021 4:50:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MobileDevices](
	[ID] [uniqueidentifier] NOT NULL,
	[DeviceRegistrationID] [nvarchar](200) NOT NULL,
	[MobilePlatform] [nvarchar](50) NOT NULL,
	[OSVersion] [nvarchar](20) NOT NULL,
	[DeviceManufacturer] [nvarchar](100) NOT NULL,
	[AppVersion] [nvarchar](20) NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.MobileDevices] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notes]    Script Date: 3/14/2021 4:50:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notes](
	[ID] [uniqueidentifier] NOT NULL,
	[ParentEntityType] [int] NOT NULL,
	[ParentEntityID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[Shared] [bit] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[NoteTitle] [nvarchar](200) NULL,
	[NotePreview] [nvarchar](200) NULL,
	[NoteHtml] [nvarchar](max) NULL,
	[EvernoteNoteID] [nvarchar](50) NULL,
	[EvernoteSharedNoteKey] [nvarchar](500) NULL,
 CONSTRAINT [PK_dbo.Notes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NotificationHistory]    Script Date: 3/14/2021 4:50:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationHistory](
	[ID] [uniqueidentifier] NOT NULL,
	[DeliveredDate] [datetime] NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[NotificationPersonID] [uniqueidentifier] NOT NULL,
	[NotificationType] [int] NOT NULL,
	[Address] [nvarchar](200) NULL,
	[Status] [int] NOT NULL,
	[NumAttempts] [int] NOT NULL,
	[LastErrorMessage] [nvarchar](1000) NULL,
 CONSTRAINT [PK_dbo.NotificationHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NotificationMessageTypeTemplateNotificationTypes]    Script Date: 3/14/2021 4:50:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationMessageTypeTemplateNotificationTypes](
	[ID] [uniqueidentifier] NOT NULL,
	[NotificationMessageTypeTemplateID] [uniqueidentifier] NOT NULL,
	[NotificationType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.NotificationMessageTypeTemplateNotificationTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NotificationMessageTypeTemplates]    Script Date: 3/14/2021 4:50:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationMessageTypeTemplates](
	[ID] [uniqueidentifier] NOT NULL,
	[CourseID] [uniqueidentifier] NULL,
	[NotificationMessageType] [int] NOT NULL,
	[TemplateHTML] [nvarchar](max) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.NotificationMessageTypeTemplates] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NotificationPeople]    Script Date: 3/14/2021 4:50:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationPeople](
	[ID] [uniqueidentifier] NOT NULL,
	[NotificationID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NULL,
	[ViewedDate] [datetime] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Saved] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[EmailAddress] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.NotificationPeople] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NotificationQueue]    Script Date: 3/14/2021 4:50:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationQueue](
	[ID] [uniqueidentifier] NOT NULL,
	[NextAttemptDate] [datetime] NOT NULL,
	[LastAttemptDate] [datetime] NULL,
	[LockDate] [datetime] NULL,
	[LockID] [uniqueidentifier] NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[NotificationPersonID] [uniqueidentifier] NOT NULL,
	[NotificationType] [int] NOT NULL,
	[Address] [nvarchar](200) NULL,
	[Status] [int] NOT NULL,
	[NumAttempts] [int] NOT NULL,
	[LastErrorMessage] [nvarchar](1000) NULL,
 CONSTRAINT [PK_dbo.NotificationQueue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notifications]    Script Date: 3/14/2021 4:50:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notifications](
	[ID] [uniqueidentifier] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[Subject] [nvarchar](200) NULL,
	[EmailContent] [nvarchar](max) NULL,
	[PushNotificationContent] [nvarchar](1000) NULL,
	[EntityTypeID] [int] NULL,
	[EntityID] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ActiveDate] [datetime] NOT NULL,
	[InactiveDate] [datetime] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[NotificationMessageType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Notifications] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OAuthKeys]    Script Date: 3/14/2021 4:50:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OAuthKeys](
	[ID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[AuthToken] [nvarchar](500) NULL,
	[ExpirationDate] [datetime] NULL,
	[ProviderSpecificPropertiesJson] [nvarchar](max) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[AuthenticationProvider] [int] NOT NULL,
 CONSTRAINT [PK_dbo.OAuthKeys] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Organization_Tag]    Script Date: 3/14/2021 4:50:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Organization_Tag](
	[OrganizationID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Organization_Tag] PRIMARY KEY CLUSTERED 
(
	[OrganizationID] ASC,
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Organizations]    Script Date: 3/14/2021 4:50:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Organizations](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[OrganizationTypeID] [uniqueidentifier] NULL,
	[WebsiteUrl] [nvarchar](max) NULL,
	[CanRegisterInto] [int] NOT NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.Organizations] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PasswordResets]    Script Date: 3/14/2021 4:50:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PasswordResets](
	[ID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[Username] [nvarchar](max) NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[RequestIP] [nvarchar](max) NULL,
	[RequestUserAgent] [nvarchar](max) NULL,
	[ViewedDateTime] [datetime] NULL,
	[PasswordUpdatedDateTime] [datetime] NULL,
 CONSTRAINT [PK_dbo.PasswordResets] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[People]    Script Date: 3/14/2021 4:50:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[People](
	[ID] [uniqueidentifier] NOT NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[Pronunciation] [nvarchar](350) NULL,
	[Title] [nvarchar](200) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[ProfileImageResourceAssetID] [uniqueidentifier] NULL,
	[Language] [nvarchar](max) NULL,
	[OriginatingSystemKey] [nvarchar](max) NULL,
	[DisableTutorials] [bit] NOT NULL,
	[SystemType] [int] NOT NULL,
	[LastClientID] [uniqueidentifier] NULL,
	[EnablePortal] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.People] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[People_Payments]    Script Date: 3/14/2021 4:50:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[People_Payments](
	[ID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NULL,
	[PaymentID] [nvarchar](max) NULL,
	[SaleID] [nvarchar](max) NULL,
	[Receipt] [nvarchar](max) NULL,
	[Status] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[FetchID] [uniqueidentifier] NOT NULL,
	[SubmittedUserRegistrationID] [uniqueidentifier] NULL,
	[SeminarID] [uniqueidentifier] NULL,
	[SeminarPromoCode] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.People_Payments] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[People_Roles]    Script Date: 3/14/2021 4:50:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[People_Roles](
	[ID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[RoleID] [uniqueidentifier] NOT NULL,
	[OrganizationID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.People_Roles] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Person_PersonPayment]    Script Date: 3/14/2021 4:50:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Person_PersonPayment](
	[PersonID] [uniqueidentifier] NOT NULL,
	[PersonPaymentID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Person_PersonPayment] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[PersonPaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Person_SchedulingSession]    Script Date: 3/14/2021 4:50:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Person_SchedulingSession](
	[SchedulingSessionID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Person_SchedulingSession] PRIMARY KEY CLUSTERED 
(
	[SchedulingSessionID] ASC,
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Person_Tag]    Script Date: 3/14/2021 4:50:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Person_Tag](
	[TagID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Person_Tag] PRIMARY KEY CLUSTERED 
(
	[TagID] ASC,
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PersonClients]    Script Date: 3/14/2021 4:50:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonClients](
	[ID] [uniqueidentifier] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.PersonClients] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PersonScores]    Script Date: 3/14/2021 4:50:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonScores](
	[ID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NULL,
	[Score] [decimal](18, 2) NOT NULL,
	[MaximumScore] [decimal](18, 2) NOT NULL,
	[GradableItemID] [uniqueidentifier] NULL,
	[GradeBookCategoryID] [uniqueidentifier] NULL,
	[GradeBookID] [uniqueidentifier] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[OverriddenScore] [decimal](18, 2) NULL,
	[Comment] [nvarchar](max) NULL,
	[OverridePersonID] [uniqueidentifier] NULL,
	[Status] [int] NOT NULL,
	[ScheduledAssessmentID] [uniqueidentifier] NULL,
	[Passed] [bit] NOT NULL,
	[Grade] [nvarchar](max) NULL,
	[CourseID] [uniqueidentifier] NULL,
	[CoursePersonID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.PersonScores] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PersonSearches]    Script Date: 3/14/2021 4:50:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonSearches](
	[ID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[JsonSearch] [nvarchar](max) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.PersonSearches] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PhoneNumbers]    Script Date: 3/14/2021 4:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PhoneNumbers](
	[ID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NULL,
	[Number] [nvarchar](12) NULL,
	[Extension] [nvarchar](6) NULL,
	[PhoneType] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[OrganizationID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.PhoneNumbers] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PossibleResponses]    Script Date: 3/14/2021 4:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PossibleResponses](
	[ID] [uniqueidentifier] NOT NULL,
	[QuestionID] [uniqueidentifier] NOT NULL,
	[Response] [nvarchar](500) NULL,
	[PercentageWeight] [decimal](18, 2) NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[SourceID] [nvarchar](200) NULL,
	[FeedbackComment] [nvarchar](max) NULL,
	[PromptText] [nvarchar](500) NULL,
	[AllowInput] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.PossibleResponses] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProgramObjective_Tag]    Script Date: 3/14/2021 4:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgramObjective_Tag](
	[TagID] [uniqueidentifier] NOT NULL,
	[ProgramObjectiveID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.ProgramObjective_Tag] PRIMARY KEY CLUSTERED 
(
	[TagID] ASC,
	[ProgramObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProgramObjectives]    Script Date: 3/14/2021 4:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgramObjectives](
	[ID] [uniqueidentifier] NOT NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[OwnerClientID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.ProgramObjectives] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[QualityAssuranceHistory]    Script Date: 3/14/2021 4:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QualityAssuranceHistory](
	[ID] [uniqueidentifier] NOT NULL,
	[ProprietaryID] [nvarchar](max) NULL,
	[CompletionDateTime] [datetime] NOT NULL,
	[ScheduledAssessmentID] [uniqueidentifier] NOT NULL,
	[Review] [bit] NOT NULL,
	[Score] [decimal](18, 2) NOT NULL,
	[Retrieved] [bit] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[DisplayID] [nvarchar](max) NULL,
	[SubjectID] [nvarchar](max) NULL,
	[AssessorLogin] [nvarchar](max) NULL,
	[Remarks] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NULL,
	[Priority] [int] NULL,
 CONSTRAINT [PK_dbo.QualityAssuranceHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[QualityAssuranceQueue]    Script Date: 3/14/2021 4:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QualityAssuranceQueue](
	[ID] [uniqueidentifier] NOT NULL,
	[Label] [nvarchar](max) NULL,
	[ProprietaryID] [nvarchar](max) NULL,
	[QueuedDateTime] [datetime] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[Priority] [int] NOT NULL,
	[Url] [nvarchar](max) NULL,
	[LockDateTime] [datetime] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[SubjectID] [nvarchar](max) NULL,
	[DisplayID] [nvarchar](max) NULL,
	[LockedByPersonID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.QualityAssuranceQueue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Question_Tag]    Script Date: 3/14/2021 4:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Question_Tag](
	[TagID] [uniqueidentifier] NOT NULL,
	[QuestionID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Question_Tag] PRIMARY KEY CLUSTERED 
(
	[TagID] ASC,
	[QuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[QuestionCells]    Script Date: 3/14/2021 4:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionCells](
	[ID] [uniqueidentifier] NOT NULL,
	[QuestionRowID] [uniqueidentifier] NOT NULL,
	[PossibleResponseID] [uniqueidentifier] NOT NULL,
	[Text] [nvarchar](500) NULL,
	[Disabled] [bit] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.QuestionCells] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[QuestionRows]    Script Date: 3/14/2021 4:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionRows](
	[ID] [uniqueidentifier] NOT NULL,
	[QuestionID] [uniqueidentifier] NOT NULL,
	[Text] [nvarchar](500) NULL,
	[SourceID] [nvarchar](200) NULL,
	[DisplayOrder] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.QuestionRows] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Questions]    Script Date: 3/14/2021 4:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Questions](
	[ID] [uniqueidentifier] NOT NULL,
	[QuestionText] [nvarchar](max) NULL,
	[QuestionResponseTypeID] [int] NOT NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[RootID] [uniqueidentifier] NOT NULL,
	[Version] [int] NOT NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
	[MostRecentVersion] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[SourceID] [nvarchar](200) NULL,
	[Locked] [bit] NOT NULL,
	[MostRecentApprovedVersion] [bit] NOT NULL,
	[OneResponsePerRow] [bit] NOT NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
	[EnableComment] [bit] NOT NULL,
	[CommentLabel] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.Questions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ratings]    Script Date: 3/14/2021 4:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ratings](
	[ID] [uniqueidentifier] NOT NULL,
	[ResourceID] [uniqueidentifier] NULL,
	[RatingValue] [tinyint] NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[TotalViewsCount] [int] NOT NULL,
	[LastViewedDate] [datetime] NULL,
 CONSTRAINT [PK_dbo.Ratings] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Report_RoleType]    Script Date: 3/14/2021 4:50:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Report_RoleType](
	[ReportID] [uniqueidentifier] NOT NULL,
	[RoleType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Report_RoleType] PRIMARY KEY CLUSTERED 
(
	[ReportID] ASC,
	[RoleType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReportDefinitions]    Script Date: 3/14/2021 4:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportDefinitions](
	[ID] [uniqueidentifier] NOT NULL,
	[AuthorPersonID] [uniqueidentifier] NOT NULL,
	[IsPublic] [bit] NOT NULL,
	[DataSourceName] [nvarchar](max) NULL,
	[IsWarehouseReport] [bit] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[SettingsJson] [nvarchar](max) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.ReportDefinitions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reports]    Script Date: 3/14/2021 4:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reports](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[DisplayName] [nvarchar](max) NULL,
	[ThumbnailImageName] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.Reports] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Resource_ScheduledEvents]    Script Date: 3/14/2021 4:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Resource_ScheduledEvents](
	[ID] [uniqueidentifier] NOT NULL,
	[ResourceID] [uniqueidentifier] NOT NULL,
	[ScheduledEventID] [uniqueidentifier] NOT NULL,
	[Required] [bit] NOT NULL,
	[ScheduledEventDisplayOrder] [int] NOT NULL,
	[ResourceDisplayOrder] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Resource_ScheduledEvents] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Resource_Tag]    Script Date: 3/14/2021 4:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Resource_Tag](
	[ResourceID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Resource_Tag] PRIMARY KEY CLUSTERED 
(
	[ResourceID] ASC,
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResourceAssets]    Script Date: 3/14/2021 4:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResourceAssets](
	[ID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Filename] [nvarchar](200) NULL,
	[ContentType] [nvarchar](100) NULL,
	[Content] [varbinary](max) NULL,
	[UploadDate] [datetime] NOT NULL,
	[DownloadCount] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[ResourceID] [uniqueidentifier] NULL,
	[Description] [nvarchar](max) NULL,
	[InteractiveContentID] [uniqueidentifier] NULL,
	[ContentStorageType] [int] NOT NULL,
	[TempUploadID] [uniqueidentifier] NULL,
	[TempUploadChunkNum] [int] NULL,
	[Type] [int] NOT NULL,
	[HtmlMediaContentID] [uniqueidentifier] NULL,
	[SeminarID] [uniqueidentifier] NULL,
	[ClientID] [uniqueidentifier] NULL,
	[FileStreamContent] [varbinary](max) FILESTREAM  NULL,
	[CourseID] [uniqueidentifier] NULL,
	[ProviderTempFilename] [nvarchar](max) NULL,
	[BlobContainerName] [nvarchar](max) NULL,
	[DegreeID] [uniqueidentifier] NULL,
	[PersonID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.ResourceAssets] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY] FILESTREAM_ON [FourIQFileStreamGroup]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY] FILESTREAM_ON [FourIQFileStreamGroup]
GO
/****** Object:  Table [dbo].[Resources]    Script Date: 3/14/2021 4:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Resources](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[DurationMinutes] [int] NOT NULL,
	[CreateDurationMinutes] [int] NOT NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[ResourceTypeID] [uniqueidentifier] NULL,
	[RootID] [uniqueidentifier] NOT NULL,
	[Version] [int] NOT NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
	[MostRecentVersion] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[InteractiveContentID] [uniqueidentifier] NULL,
	[Locked] [bit] NOT NULL,
	[MostRecentApprovedVersion] [bit] NOT NULL,
	[ContentUrl] [nvarchar](max) NULL,
	[OwnerClientID] [uniqueidentifier] NOT NULL,
	[IsPublic] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.Resources] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResourceScheduledEvent_RoleType]    Script Date: 3/14/2021 4:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResourceScheduledEvent_RoleType](
	[ResourceScheduledEventID] [uniqueidentifier] NOT NULL,
	[RoleType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.ResourceScheduledEvent_RoleType] PRIMARY KEY CLUSTERED 
(
	[ResourceScheduledEventID] ASC,
	[RoleType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RolePermissions]    Script Date: 3/14/2021 4:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RolePermissions](
	[ID] [uniqueidentifier] NOT NULL,
	[RoleID] [uniqueidentifier] NOT NULL,
	[UserPermissionID] [int] NOT NULL,
	[View] [bit] NOT NULL,
	[Create] [bit] NOT NULL,
	[Edit] [bit] NOT NULL,
	[Delete] [bit] NOT NULL,
	[ModifySection] [bit] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Approve] [bit] NOT NULL,
	[Close] [bit] NOT NULL,
	[EditInUse] [bit] NOT NULL,
	[Share] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.RolePermissions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 3/14/2021 4:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[RoleType] [int] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[GrantAllPermissions] [bit] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[SystemType] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Roles] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Scheduled_Events]    Script Date: 3/14/2021 4:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Scheduled_Events](
	[ID] [uniqueidentifier] NOT NULL,
	[CalendarID] [uniqueidentifier] NOT NULL,
	[EventTemplateID] [uniqueidentifier] NULL,
	[ScheduledDate] [datetime] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[DurationMinutes] [int] NOT NULL,
	[EventTypeID] [uniqueidentifier] NULL,
	[Interprofessional] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[UseAllStudentsFromCalendar] [bit] NOT NULL,
	[UseAllInstructorsFromCalendar] [bit] NOT NULL,
	[DueDate] [datetime] NULL,
	[IsTaskItem] [bit] NOT NULL,
	[SubLocationID] [uniqueidentifier] NULL,
	[CourseID] [uniqueidentifier] NOT NULL,
	[Instructions] [nvarchar](max) NULL,
	[AttendanceParams_Track] [bit] NOT NULL,
	[AttendanceParams_AllowedMethods] [int] NOT NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
	[AttendanceParams_Required] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.Scheduled_Events] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ScheduledAssessmentAnswers]    Script Date: 3/14/2021 4:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScheduledAssessmentAnswers](
	[ID] [uniqueidentifier] NOT NULL,
	[ResponseAnswerID] [uniqueidentifier] NULL,
	[TextAnswer] [nvarchar](max) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[ScheduledAssessmentQuestionID] [uniqueidentifier] NOT NULL,
	[QuestionRowID] [uniqueidentifier] NULL,
	[SelectedOrder] [int] NULL,
 CONSTRAINT [PK_dbo.ScheduledAssessmentAnswers] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ScheduledAssessmentProperties]    Script Date: 3/14/2021 4:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScheduledAssessmentProperties](
	[ID] [uniqueidentifier] NOT NULL,
	[ScheduledAssessmentID] [uniqueidentifier] NOT NULL,
	[Key] [nvarchar](max) NULL,
	[Value] [nvarchar](max) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.ScheduledAssessmentProperties] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ScheduledAssessmentQuestions]    Script Date: 3/14/2021 4:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScheduledAssessmentQuestions](
	[ID] [uniqueidentifier] NOT NULL,
	[ScheduledAssessmentID] [uniqueidentifier] NOT NULL,
	[AssessmentFormRowID] [uniqueidentifier] NOT NULL,
	[IsCorrect] [bit] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[FlaggedForReview] [bit] NOT NULL,
	[Score] [decimal](18, 2) NULL,
	[MaximumScore] [decimal](18, 2) NULL,
	[Feedback] [nvarchar](max) NULL,
	[GraderID] [uniqueidentifier] NULL,
	[QuestionID] [uniqueidentifier] NOT NULL,
	[QuestionPoolDisplayOrder] [int] NOT NULL,
	[Comment] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.ScheduledAssessmentQuestions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ScheduledAssessments]    Script Date: 3/14/2021 4:50:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScheduledAssessments](
	[ID] [uniqueidentifier] NOT NULL,
	[AssessmentID] [uniqueidentifier] NOT NULL,
	[AssessorID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[AssessmentScheduledEventID] [uniqueidentifier] NULL,
	[Status] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[SubmittedDate] [datetime] NULL,
	[CourseID] [uniqueidentifier] NULL,
	[BaseScheduledAssessmentID] [uniqueidentifier] NULL,
	[Subject_EntityType] [int] NULL,
	[Subject_EntityID] [uniqueidentifier] NULL,
	[CoursePersonID] [uniqueidentifier] NULL,
	[ActivityID] [uniqueidentifier] NULL,
	[Review] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.ScheduledAssessments] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ScheduledAssignments]    Script Date: 3/14/2021 4:50:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScheduledAssignments](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[Instructions] [nvarchar](max) NULL,
	[IsDeleted] [bit] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[AllowStudentResponses] [bit] NOT NULL,
	[ScheduledEventID] [uniqueidentifier] NOT NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.ScheduledAssignments] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ScheduledEvent_People]    Script Date: 3/14/2021 4:50:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScheduledEvent_People](
	[ScheduledEventID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NULL,
	[CoursePersonID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.ScheduledEvent_People] PRIMARY KEY CLUSTERED 
(
	[ScheduledEventID] ASC,
	[CoursePersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ScheduledEventCompletedItems]    Script Date: 3/14/2021 4:50:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScheduledEventCompletedItems](
	[ScheduledEventID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[ParentEntityID] [uniqueidentifier] NOT NULL,
	[ParentEntityType] [int] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[IsUserDetermined] [bit] NOT NULL,
	[CoursePersonID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.ScheduledEventCompletedItems] PRIMARY KEY CLUSTERED 
(
	[ScheduledEventID] ASC,
	[CoursePersonID] ASC,
	[ParentEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SchedulingDistributionCriteria]    Script Date: 3/14/2021 4:50:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SchedulingDistributionCriteria](
	[ID] [uniqueidentifier] NOT NULL,
	[SchedulingRoundID] [uniqueidentifier] NOT NULL,
	[CriterionType] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Weight] [int] NOT NULL,
 CONSTRAINT [PK_dbo.SchedulingDistributionCriteria] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SchedulingResults]    Script Date: 3/14/2021 4:50:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SchedulingResults](
	[ID] [uniqueidentifier] NOT NULL,
	[SchedulingRoundID] [uniqueidentifier] NOT NULL,
	[RunDate] [datetime] NOT NULL,
	[PctComplete] [real] NOT NULL,
	[PublishedDate] [datetime] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[Successful] [bit] NOT NULL,
	[UnassignedCredits] [int] NOT NULL,
	[PctFirstPreference] [real] NOT NULL,
	[NumFirstPreference] [int] NOT NULL,
	[PctSecondPreference] [real] NOT NULL,
	[NumSecondPreference] [int] NOT NULL,
	[PctThirdPreference] [real] NOT NULL,
	[NumThirdPreference] [int] NOT NULL,
	[ResultsJson] [varbinary](max) NULL,
 CONSTRAINT [PK_dbo.SchedulingResults] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SchedulingRound_SchedulingTimeBlock]    Script Date: 3/14/2021 4:50:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SchedulingRound_SchedulingTimeBlock](
	[SchedulingTimeBlockID] [uniqueidentifier] NOT NULL,
	[SchedulingRoundID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.SchedulingRound_SchedulingTimeBlock] PRIMARY KEY CLUSTERED 
(
	[SchedulingTimeBlockID] ASC,
	[SchedulingRoundID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SchedulingRoundCourseUsageGroups]    Script Date: 3/14/2021 4:50:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SchedulingRoundCourseUsageGroups](
	[ID] [uniqueidentifier] NOT NULL,
	[SchedulingRoundID] [uniqueidentifier] NOT NULL,
	[IsSequential] [bit] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.SchedulingRoundCourseUsageGroups] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SchedulingRoundCourseUsages]    Script Date: 3/14/2021 4:50:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SchedulingRoundCourseUsages](
	[ID] [uniqueidentifier] NOT NULL,
	[CourseUsageGroupID] [uniqueidentifier] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[CourseUsageID] [uniqueidentifier] NOT NULL,
	[MinimumCredits] [int] NOT NULL,
	[MaximumCredits] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.SchedulingRoundCourseUsages] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SchedulingRounds]    Script Date: 3/14/2021 4:50:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SchedulingRounds](
	[ID] [uniqueidentifier] NOT NULL,
	[SchedulingSessionID] [uniqueidentifier] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[AutoPublishResults] [bit] NOT NULL,
	[MaxCoursesScheduled] [int] NOT NULL,
	[MaxPreferencesPermitted] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[PublishedSchedulingResultID] [uniqueidentifier] NULL,
	[RunDate] [datetime] NULL,
 CONSTRAINT [PK_dbo.SchedulingRounds] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SchedulingSessions]    Script Date: 3/14/2021 4:50:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SchedulingSessions](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[SchedulingType] [int] NOT NULL,
	[SchedulingTrackID] [uniqueidentifier] NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.SchedulingSessions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SchedulingTimeBlocks]    Script Date: 3/14/2021 4:50:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SchedulingTimeBlocks](
	[ID] [uniqueidentifier] NOT NULL,
	[SchedulingTrackID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[StartDate] [datetime] NOT NULL,
	[DurationWeeks] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
 CONSTRAINT [PK_dbo.SchedulingTimeBlocks] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SchedulingTracks]    Script Date: 3/14/2021 4:50:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SchedulingTracks](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.SchedulingTracks] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SeatReservations]    Script Date: 3/14/2021 4:50:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SeatReservations](
	[ID] [uniqueidentifier] NOT NULL,
	[ParentEntityID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[ExpirationDateTime] [datetime] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.SeatReservations] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Seminar_People]    Script Date: 3/14/2021 4:50:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Seminar_People](
	[ID] [uniqueidentifier] NOT NULL,
	[SeminarID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[StatusModifiedDate] [datetime] NOT NULL,
	[RegistrationPromoCode] [nvarchar](max) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[RoleType] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[AddedBy] [int] NOT NULL,
	[RegisteredDate] [datetime] NULL,
	[PersonPaymentID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_dbo.Seminar_People] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Seminar_Tag]    Script Date: 3/14/2021 4:50:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Seminar_Tag](
	[SeminarID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Seminar_Tag] PRIMARY KEY CLUSTERED 
(
	[SeminarID] ASC,
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Seminars]    Script Date: 3/14/2021 4:50:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Seminars](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[RegistrationUrl] [nvarchar](200) NULL,
	[Cost] [decimal](18, 2) NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Instructions] [nvarchar](max) NULL,
	[EntityState] [int] NOT NULL,
	[InUse] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[AttendanceParams_Track] [bit] NOT NULL,
	[AttendanceParams_AllowedMethods] [int] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[HtmlMediaID] [uniqueidentifier] NULL,
	[SeminarTypeID] [uniqueidentifier] NULL,
	[AvailableOnExternalSearch] [bit] NOT NULL,
	[AttendanceParams_Required] [bit] NOT NULL,
	[StudentsMax] [int] NOT NULL,
	[TimeZoneOffset] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.Seminars] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Standard_StandardObjective]    Script Date: 3/14/2021 4:50:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Standard_StandardObjective](
	[StandardID] [uniqueidentifier] NOT NULL,
	[StandardObjectiveID] [uniqueidentifier] NOT NULL,
	[StandardObjectiveDisplayOrder] [int] NOT NULL,
	[StandardDisplayOrder] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Standard_StandardObjective] PRIMARY KEY CLUSTERED 
(
	[StandardID] ASC,
	[StandardObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StandardObjective_Tag]    Script Date: 3/14/2021 4:50:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StandardObjective_Tag](
	[StandardObjectiveID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.StandardObjective_Tag] PRIMARY KEY CLUSTERED 
(
	[StandardObjectiveID] ASC,
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StandardObjectives]    Script Date: 3/14/2021 4:50:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StandardObjectives](
	[ID] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[DomainKey] [nvarchar](200) NULL,
	[TagFilterID] [uniqueidentifier] NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[OwnerClientID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.StandardObjectives] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StandardPackages]    Script Date: 3/14/2021 4:50:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StandardPackages](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[Version] [nvarchar](max) NULL,
	[Package] [nvarchar](max) NULL,
	[ClientType] [int] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.StandardPackages] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Standards]    Script Date: 3/14/2021 4:50:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Standards](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[Domain] [nvarchar](200) NULL,
	[OwnerClientID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Standards] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StudentSchedulingPreferences]    Script Date: 3/14/2021 4:50:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudentSchedulingPreferences](
	[ID] [uniqueidentifier] NOT NULL,
	[StudentSchedulingRoundID] [uniqueidentifier] NOT NULL,
	[SchedulingTimeBlockID] [uniqueidentifier] NOT NULL,
	[CourseUsageID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[PreferenceOrder] [int] NOT NULL,
 CONSTRAINT [PK_dbo.StudentSchedulingPreferences] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StudentSchedulingRounds]    Script Date: 3/14/2021 4:50:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudentSchedulingRounds](
	[ID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[SchedulingRoundID] [uniqueidentifier] NOT NULL,
	[CompletedDate] [datetime] NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.StudentSchedulingRounds] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubLocations]    Script Date: 3/14/2021 4:50:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubLocations](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[LocationID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.SubLocations] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tag_TagGroup]    Script Date: 3/14/2021 4:50:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tag_TagGroup](
	[TagGroupID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.Tag_TagGroup] PRIMARY KEY CLUSTERED 
(
	[TagGroupID] ASC,
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TagCategories]    Script Date: 3/14/2021 4:50:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TagCategories](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[AutoAssignTags] [bit] NOT NULL,
	[SourceID] [nvarchar](200) NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[DisplayID] [nvarchar](20) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[TagType] [int] NOT NULL,
	[OwnerClientID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dbo.TagCategories] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TagFilters]    Script Date: 3/14/2021 4:50:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TagFilters](
	[ID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.TagFilters] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TagGroups]    Script Date: 3/14/2021 4:50:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TagGroups](
	[ID] [uniqueidentifier] NOT NULL,
	[TagFilterID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.TagGroups] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tags]    Script Date: 3/14/2021 4:50:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tags](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](250) NULL,
	[TagCategoryID] [uniqueidentifier] NOT NULL,
	[SourceID] [nvarchar](200) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.Tags] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TagSearchTerms]    Script Date: 3/14/2021 4:50:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TagSearchTerms](
	[ID] [uniqueidentifier] NOT NULL,
	[TagID] [uniqueidentifier] NOT NULL,
	[SearchTerm] [nvarchar](100) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.TagSearchTerms] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ThesaurusSynonyms]    Script Date: 3/14/2021 4:50:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ThesaurusSynonyms](
	[ID] [uniqueidentifier] NOT NULL,
	[ThesaurusTermID] [uniqueidentifier] NOT NULL,
	[Synonym] [nvarchar](100) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.ThesaurusSynonyms] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ThesaurusTerms]    Script Date: 3/14/2021 4:50:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ThesaurusTerms](
	[ID] [uniqueidentifier] NOT NULL,
	[Source] [int] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[Term] [nvarchar](100) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.ThesaurusTerms] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UnderstandFlags]    Script Date: 3/14/2021 4:50:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UnderstandFlags](
	[ID] [uniqueidentifier] NOT NULL,
	[UnderstandFlagType] [int] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[LearningObjectiveID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.UnderstandFlags] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 3/14/2021 4:50:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[ID] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](100) NULL,
	[Hash] [nvarchar](100) NULL,
	[Salt] [nvarchar](50) NULL,
	[ExpirationDate] [datetime] NULL,
	[Enabled] [bit] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.Users] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserSettings]    Script Date: 3/14/2021 4:50:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSettings](
	[ID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[SettingType] [int] NOT NULL,
	[SettingValue] [nvarchar](1000) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.UserSettings] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[xAPIUserState]    Script Date: 3/14/2021 4:50:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xAPIUserState](
	[ID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NULL,
	[CoursePersonID] [uniqueidentifier] NULL,
	[Key] [nvarchar](max) NULL,
	[StateID] [nvarchar](max) NULL,
	[StateData] [nvarchar](max) NULL,
	[ContentType] [nvarchar](200) NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
 CONSTRAINT [PK_dbo.xAPIUserState] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Reference].[EntityTypes]    Script Date: 3/14/2021 4:50:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reference].[EntityTypes](
	[ID] [int] NOT NULL,
	[TypeName] [nvarchar](200) NULL,
	[SingularName] [nvarchar](200) NULL,
	[PluralName] [nvarchar](200) NULL,
	[DisplayIDPrefix] [nvarchar](20) NULL,
	[IsTaggable] [bit] NOT NULL,
	[IsSearchable] [bit] NOT NULL,
	[LastID] [int] NOT NULL,
	[IsNoteParent] [bit] NOT NULL,
	[IsEntityState] [bit] NOT NULL,
	[IsVersionable] [bit] NOT NULL,
 CONSTRAINT [PK_Reference.EntityTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Reference].[RoleTypes]    Script Date: 3/14/2021 4:50:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reference].[RoleTypes](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](200) NULL,
 CONSTRAINT [PK_Reference.RoleTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Reference].[Taxonomies]    Script Date: 3/14/2021 4:50:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reference].[Taxonomies](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Reference.Taxonomies] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Reference].[TaxonomyActionVerbs]    Script Date: 3/14/2021 4:50:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reference].[TaxonomyActionVerbs](
	[ID] [uniqueidentifier] NOT NULL,
	[TaxonomyLevelID] [uniqueidentifier] NOT NULL,
	[Verb] [nvarchar](50) NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Reference.TaxonomyActionVerbs] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Reference].[TaxonomyDomains]    Script Date: 3/14/2021 4:50:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reference].[TaxonomyDomains](
	[ID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[TaxonomyID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Reference.TaxonomyDomains] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Reference].[TaxonomyLevels]    Script Date: 3/14/2021 4:50:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reference].[TaxonomyLevels](
	[ID] [uniqueidentifier] NOT NULL,
	[Level] [int] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[TaxonomyDomainID] [uniqueidentifier] NOT NULL,
	[ModifyTimestamp] [timestamp] NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Reference.TaxonomyLevels] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Reference].[UserPermissions]    Script Date: 3/14/2021 4:50:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reference].[UserPermissions](
	[ID] [int] NOT NULL,
	[GroupName] [nvarchar](200) NULL,
	[Name] [nvarchar](200) NULL,
	[AvailableToRoleType] [int] NOT NULL,
	[ParentUserPermission] [int] NULL,
	[Visible] [bit] NOT NULL,
	[ShowView] [bit] NOT NULL,
	[ShowCreate] [bit] NOT NULL,
	[ShowEdit] [bit] NOT NULL,
	[ShowDelete] [bit] NOT NULL,
	[ShowModifySection] [bit] NOT NULL,
	[ShowApprove] [bit] NOT NULL,
	[ShowClose] [bit] NOT NULL,
	[ShowEditInUse] [bit] NOT NULL,
	[ShowShared] [bit] NOT NULL,
 CONSTRAINT [PK_Reference.UserPermissions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Registration].[SubmittedUserRegistration]    Script Date: 3/14/2021 4:50:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Registration].[SubmittedUserRegistration](
	[ID] [uniqueidentifier] NOT NULL,
	[FirstName] [nvarchar](max) NULL,
	[LastName] [nvarchar](max) NULL,
	[Username] [nvarchar](100) NULL,
	[Email] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneType] [int] NOT NULL,
	[ClientID] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[AuthenticationProvider] [int] NOT NULL,
	[Hash] [nvarchar](100) NULL,
	[Salt] [nvarchar](50) NULL,
	[Address1] [nvarchar](max) NULL,
	[Address2] [nvarchar](max) NULL,
	[City] [nvarchar](max) NULL,
	[ZipCode] [nvarchar](max) NULL,
	[StateID] [nvarchar](max) NULL,
	[AddressType] [int] NOT NULL,
	[SeminarID] [uniqueidentifier] NULL,
	[SeminarPromoCode] [nvarchar](max) NULL,
	[OrganizationID] [uniqueidentifier] NULL,
	[RoleID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Registration.SubmittedUserRegistration] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [SUNY].[FacultyList]    Script Date: 3/14/2021 4:50:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SUNY].[FacultyList](
	[Name] [varchar](100) NULL,
	[SUNYID] [varchar](50) NULL,
	[Title] [varchar](100) NULL,
	[College] [varchar](100) NULL,
	[Department] [varchar](100) NULL,
	[Home] [int] NULL,
	[UniqueID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_FacultyList] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SUNY].[SessionLOs]    Script Date: 3/14/2021 4:50:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SUNY].[SessionLOs](
	[Unit] [varchar](100) NULL,
	[SessionID] [smallint] NULL,
	[Session] [varchar](1000) NULL,
	[LOText] [varchar](1000) NULL,
	[CG] [varchar](1000) NULL,
	[Competency] [varchar](1000) NULL,
	[UniqueID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_SessionLOs] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SUNY].[SessionOfferings]    Script Date: 3/14/2021 4:50:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SUNY].[SessionOfferings](
	[Course] [varchar](100) NULL,
	[SessionID] [smallint] NULL,
	[Session] [varchar](100) NULL,
	[SessionType] [varchar](50) NULL,
	[DateOfOffering] [datetime] NULL,
	[StartTime] [varchar](50) NULL,
	[EndTime] [varchar](50) NULL,
	[Room] [varchar](100) NULL,
	[Group1Title] [varchar](50) NULL,
	[UniqueID] [int] IDENTITY(1,1) NOT NULL,
	[InstructorID] [varchar](50) NULL,
 CONSTRAINT [PK_SessionOfferings] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SUNY].[SessionTagging]    Script Date: 3/14/2021 4:50:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SUNY].[SessionTagging](
	[DisciplineID] [smallint] NULL,
	[Discipline] [varchar](200) NULL,
	[CourseYear] [smallint] NULL,
	[Course] [varchar](100) NULL,
	[SessionID] [smallint] NULL,
	[Session] [varchar](100) NULL,
	[SessionType] [varchar](100) NULL,
	[UniqueID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_SessionTagging] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [SUNY].[Users]    Script Date: 3/14/2021 4:50:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SUNY].[Users](
	[UserID] [varchar](50) NULL,
	[LastName] [varchar](100) NULL,
	[FirstName] [varchar](100) NULL,
	[MiddleName] [varchar](50) NULL,
	[Phone] [varchar](50) NULL,
	[Email] [varchar](100) NULL,
	[Enabled] [varchar](50) NULL,
	[UniqueID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID_RoleType]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ClientID_RoleType] ON [Configuration].[AllowedRoleType]
(
	[ClientID] ASC,
	[RoleType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID_SettingType]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ClientID_SettingType] ON [Configuration].[ClientSettings]
(
	[ClientID] ASC,
	[SettingType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [Configuration].[DirectObservationTypes]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID_EntityType]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ClientID_EntityType] ON [Configuration].[EntityTypeSettings]
(
	[ClientID] ASC,
	[EntityTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [Configuration].[EvaluationTypes]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [Configuration].[EventTypes]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [Configuration].[ExaminationTypes]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [Configuration].[LevelsOfLearning]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OwnerClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OwnerClientID] ON [Configuration].[LevelsOfLearning]
(
	[OwnerClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [Configuration].[LocationTypes]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [Configuration].[LogRequirementTypes]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [Configuration].[OrganizationTypes]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [Configuration].[RenewalFrequencyTypes]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [Configuration].[ResourceTypes]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OwnerClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OwnerClientID] ON [Configuration].[ResourceTypes]
(
	[OwnerClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [Configuration].[SeminarTypes]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssessmentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentID] ON [dbo].[Activities]
(
	[AssessmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Activities]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[Activities]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OwnerClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OwnerClientID] ON [dbo].[Activities]
(
	[OwnerClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ActivityID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ActivityID] ON [dbo].[Activity_Person]
(
	[ActivityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[Activity_Person]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Addresses]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[Addresses]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[Addresses]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssessmentScheduleParamsID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentScheduleParamsID] ON [dbo].[Assessment_EventTemplate]
(
	[AssessmentScheduleParamsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssessmentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentID] ON [dbo].[Assessment_Resource]
(
	[AssessmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ResourceID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ResourceID] ON [dbo].[Assessment_Resource]
(
	[ResourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssessmentID_ScheduledEventID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_AssessmentID_ScheduledEventID] ON [dbo].[Assessment_ScheduledEvent]
(
	[AssessmentID] ASC,
	[ScheduledEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssessmentScheduleParamsID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentScheduleParamsID] ON [dbo].[Assessment_ScheduledEvent]
(
	[AssessmentScheduleParamsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssessmentScheduleQueueID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentScheduleQueueID] ON [dbo].[Assessment_ScheduledEvent]
(
	[AssessmentScheduleQueueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_GradableItemID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_GradableItemID] ON [dbo].[Assessment_ScheduledEvent]
(
	[GradableItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssessmentFormRowID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentFormRowID] ON [dbo].[AssessmentFormRow_Question]
(
	[AssessmentFormRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_QuestionID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_QuestionID] ON [dbo].[AssessmentFormRow_Question]
(
	[QuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssessmentFormSectionID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentFormSectionID] ON [dbo].[AssessmentFormRows]
(
	[AssessmentFormSectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[AssessmentFormRows]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ID] ON [dbo].[AssessmentForms]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssessmentFormID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentFormID] ON [dbo].[AssessmentFormSections]
(
	[AssessmentFormID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_InteractiveContentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_InteractiveContentID] ON [dbo].[Assessments]
(
	[InteractiveContentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[AssignmentTemplates]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[AssignmentTemplates]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[AssignmentTemplates]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ExpectedUploadID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ExpectedUploadID] ON [dbo].[AssignmentUploads]
(
	[ExpectedUploadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[AssignmentUploads]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ResourceAssetID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ResourceAssetID] ON [dbo].[AssignmentUploads]
(
	[ResourceAssetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledAssignmentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ScheduledAssignmentID] ON [dbo].[AssignmentUploads]
(
	[ScheduledAssignmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CoursePersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CoursePersonID] ON [dbo].[Attendance]
(
	[CoursePersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ParentEntityID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ParentEntityID] ON [dbo].[Attendance]
(
	[ParentEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RecordedByPersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_RecordedByPersonID] ON [dbo].[Attendance]
(
	[RecordedByPersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SeminarPersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SeminarPersonID] ON [dbo].[Attendance]
(
	[SeminarPersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AuditID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AuditID] ON [dbo].[AuditReferences]
(
	[AuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_AuditID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AuditID] ON [dbo].[AuditValues]
(
	[AuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[BackgroundTasks]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[BackgroundTasks]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CalendarID] ON [dbo].[Calendar_People]
(
	[CalendarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CoursePersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CoursePersonID] ON [dbo].[Calendar_People]
(
	[CoursePersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[Calendar_People]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseID] ON [dbo].[Calendars]
(
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Client_Organization]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[Client_Organization]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Notification_ClientID_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_Notification_ClientID_PersonID] ON [dbo].[ClientNotificationPersons]
(
	[ClientID] ASC,
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ClientCode]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ClientCode] ON [dbo].[Clients]
(
	[ClientCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[Clients]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ParentClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ParentClientID] ON [dbo].[Clients]
(
	[ParentClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DegreePersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DegreePersonID] ON [dbo].[ContinuingEducationHistory]
(
	[DegreePersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RenewalFrequencyID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_RenewalFrequencyID] ON [dbo].[ContinuingEducationRequirements]
(
	[RenewalFrequencyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[CoreCompetencies]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[CoreCompetencies]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OwnerClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OwnerClientID] ON [dbo].[CoreCompetencies]
(
	[OwnerClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CoreCompetencyID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CoreCompetencyID] ON [dbo].[CoreCompetency_Degree]
(
	[CoreCompetencyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_DegreeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DegreeID] ON [dbo].[CoreCompetency_Degree]
(
	[DegreeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CoreCompetencyID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CoreCompetencyID] ON [dbo].[CoreCompetency_ProgramObjective]
(
	[CoreCompetencyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ProgramObjectiveID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ProgramObjectiveID] ON [dbo].[CoreCompetency_ProgramObjective]
(
	[ProgramObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseID] ON [dbo].[Course_DirectObservation]
(
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_DirectObservationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DirectObservationID] ON [dbo].[Course_DirectObservation]
(
	[DirectObservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseID] ON [dbo].[Course_LogRequirement]
(
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_LogRequirementID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_LogRequirementID] ON [dbo].[Course_LogRequirement]
(
	[LogRequirementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseID_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseID_PersonID] ON [dbo].[Course_People]
(
	[CourseID] ASC,
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SchedulingRoundID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SchedulingRoundID] ON [dbo].[Course_People]
(
	[SchedulingRoundID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseID] ON [dbo].[Course_Seminar]
(
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SeminarID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SeminarID] ON [dbo].[Course_Seminar]
(
	[SeminarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseID_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CourseID_PersonID] ON [dbo].[Course_WaitListPerson]
(
	[CourseID] ASC,
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseCatalogID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseCatalogID] ON [dbo].[CourseCatalog_CourseOverview]
(
	[CourseCatalogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[CourseCatalogs]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[CourseCatalogs]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseObjectiveID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseObjectiveID] ON [dbo].[CourseObjective_CourseOverview]
(
	[CourseObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_LevelOfLearningID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_LevelOfLearningID] ON [dbo].[CourseObjective_LevelOfLearning]
(
	[LevelOfLearningID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[CourseObjectives]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[CourseObjectives]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OwnerClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OwnerClientID] ON [dbo].[CourseObjectives]
(
	[OwnerClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseOverviewID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseOverviewID] ON [dbo].[CourseOverview_LevelOfLearning]
(
	[CourseOverviewID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_LevelOfLearningID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_LevelOfLearningID] ON [dbo].[CourseOverview_LevelOfLearning]
(
	[LevelOfLearningID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[CourseOverviews]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[CourseOverviews]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CoursePersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CoursePersonID] ON [dbo].[CoursePerson_Tag]
(
	[CoursePersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagID] ON [dbo].[CoursePerson_Tag]
(
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Courses]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseOverviewID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseOverviewID] ON [dbo].[Courses]
(
	[CourseOverviewID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_GradeBookID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_GradeBookID] ON [dbo].[Courses]
(
	[GradeBookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[Courses]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[Courses]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_DegreeID_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DegreeID_PersonID] ON [dbo].[Degree_People]
(
	[DegreeID] ASC,
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_NextRequiredContinuingEducationRenewalID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_NextRequiredContinuingEducationRenewalID] ON [dbo].[Degree_People]
(
	[NextRequiredContinuingEducationRenewalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonPaymentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonPaymentID] ON [dbo].[Degree_People]
(
	[PersonPaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DegreeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DegreeID] ON [dbo].[Degree_Seminar]
(
	[DegreeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SeminarID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SeminarID] ON [dbo].[Degree_Seminar]
(
	[SeminarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DegreeGroupID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DegreeGroupID] ON [dbo].[DegreeGroupDegreeTracks]
(
	[DegreeGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DegreeTrackID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DegreeTrackID] ON [dbo].[DegreeGroupDegreeTracks]
(
	[DegreeTrackID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContinuingEducationRequirementsID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContinuingEducationRequirementsID] ON [dbo].[DegreeGroups]
(
	[ContinuingEducationRequirementsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DegreeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DegreeID] ON [dbo].[DegreeGroups]
(
	[DegreeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Degrees]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContinuingEducationRequirementsID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContinuingEducationRequirementsID] ON [dbo].[Degrees]
(
	[ContinuingEducationRequirementsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ImageResourceAssetID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ImageResourceAssetID] ON [dbo].[Degrees]
(
	[ImageResourceAssetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[Degrees]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[Degrees]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PrimarySignatoryID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PrimarySignatoryID] ON [dbo].[Degrees]
(
	[PrimarySignatoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SecondarySignatoryID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SecondarySignatoryID] ON [dbo].[Degrees]
(
	[SecondarySignatoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DegreeTrackID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DegreeTrackID] ON [dbo].[DegreeTrack_LevelOfLearning]
(
	[DegreeTrackID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_LevelOfLearningID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_LevelOfLearningID] ON [dbo].[DegreeTrack_LevelOfLearning]
(
	[LevelOfLearningID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_DegreeTrackCourseUsageID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DegreeTrackCourseUsageID] ON [dbo].[DegreeTrackCourseUsage_Tag]
(
	[DegreeTrackCourseUsageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagID] ON [dbo].[DegreeTrackCourseUsage_Tag]
(
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DegreeTrackGroupID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DegreeTrackGroupID] ON [dbo].[DegreeTrackCourseUsages]
(
	[DegreeTrackGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContinuingEducationRequirementsID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ContinuingEducationRequirementsID] ON [dbo].[DegreeTrackGroups]
(
	[ContinuingEducationRequirementsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DegreeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DegreeID] ON [dbo].[DegreeTrackGroups]
(
	[DegreeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_DegreeTrackID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DegreeTrackID] ON [dbo].[DegreeTrackGroups]
(
	[DegreeTrackID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagID] ON [dbo].[DegreeTrackGroups]
(
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[DegreeTracks]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[DegreeTracks]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_DirectObservationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DirectObservationID] ON [dbo].[DirectObservation_Tag]
(
	[DirectObservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagID] ON [dbo].[DirectObservation_Tag]
(
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[DirectObservations]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_DirectObservationTypeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DirectObservationTypeID] ON [dbo].[DirectObservations]
(
	[DirectObservationTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[DirectObservations]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ID] ON [dbo].[DirectObservations]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[DirectObservations]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[Emails]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[Emails]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_EnrollDegreeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_EnrollDegreeID] ON [dbo].[EnrollCourses]
(
	[EnrollDegreeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_EnrollCourseID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_EnrollCourseID] ON [dbo].[EnrollCourseUsages]
(
	[EnrollCourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonPaymentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonPaymentID] ON [dbo].[EnrollCourseUsages]
(
	[PersonPaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonPaymentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonPaymentID] ON [dbo].[EnrollDegrees]
(
	[PersonPaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_EntityTypeClassID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_EntityTypeClassID] ON [dbo].[EntityType_Report]
(
	[EntityTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssessmentScheduleParamsID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentScheduleParamsID] ON [dbo].[Evaluation_Resource]
(
	[AssessmentScheduleParamsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_EvaluationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_EvaluationID] ON [dbo].[Evaluation_Resource]
(
	[EvaluationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ResourceID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ResourceID] ON [dbo].[Evaluation_Resource]
(
	[ResourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Evaluations]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_EvaluationTypeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_EvaluationTypeID] ON [dbo].[Evaluations]
(
	[EvaluationTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[Evaluations]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ID] ON [dbo].[Evaluations]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[Evaluations]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ResourceID_EventTemplateID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ResourceID_EventTemplateID] ON [dbo].[EventTemplate_Resources]
(
	[ResourceID] ASC,
	[EventTemplateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_EventTemplateID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_EventTemplateID] ON [dbo].[EventTemplate_Tag]
(
	[EventTemplateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagID] ON [dbo].[EventTemplate_Tag]
(
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_EventTemplateResourceID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_EventTemplateResourceID] ON [dbo].[EventTemplateResource_RoleType]
(
	[EventTemplateResourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[EventTemplates]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_EventTypeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_EventTypeID] ON [dbo].[EventTemplates]
(
	[EventTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[EventTemplates]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[EventTemplates]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ExaminationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ExaminationID] ON [dbo].[Examination_Tag]
(
	[ExaminationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagID] ON [dbo].[Examination_Tag]
(
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Examinations]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ExaminationTypeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ExaminationTypeID] ON [dbo].[Examinations]
(
	[ExaminationTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[Examinations]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ID] ON [dbo].[Examinations]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[Examinations]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssignmentTemplateID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssignmentTemplateID] ON [dbo].[ExpectedUploads]
(
	[AssignmentTemplateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledAssignmentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ScheduledAssignmentID] ON [dbo].[ExpectedUploads]
(
	[ScheduledAssignmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CategoryID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CategoryID] ON [dbo].[GradableItems]
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ParentEntityID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ParentEntityID] ON [dbo].[GradableItems]
(
	[ParentEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_GradeBookID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_GradeBookID] ON [dbo].[GradeBookCategories]
(
	[GradeBookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_GradingCriterionID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_GradingCriterionID] ON [dbo].[GradeBooks]
(
	[GradingCriterionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_GradingCriterionID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_GradingCriterionID] ON [dbo].[GradingCriterionRanges]
(
	[GradingCriterionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[GradingCriterions]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Helps]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMedia_ParentEntityID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMedia_ParentEntityID] ON [dbo].[HtmlMediaContents]
(
	[ParentEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[LearningObjectives]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[LearningObjectives]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OwnerClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OwnerClientID] ON [dbo].[LearningObjectives]
(
	[OwnerClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AddressID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AddressID] ON [dbo].[Locations]
(
	[AddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Locations]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[Locations]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ImageResourceAssetID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ImageResourceAssetID] ON [dbo].[Locations]
(
	[ImageResourceAssetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_LocationTypeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_LocationTypeID] ON [dbo].[Locations]
(
	[LocationTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[Logins]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_LogRequirementID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_LogRequirementID] ON [dbo].[LogRequirement_Tag]
(
	[LogRequirementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagID] ON [dbo].[LogRequirement_Tag]
(
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[LogRequirements]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[LogRequirements]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ID] ON [dbo].[LogRequirements]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_LogRequirementTypeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_LogRequirementTypeID] ON [dbo].[LogRequirements]
(
	[LogRequirementTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[LogRequirements]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_SeminarID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SeminarID] ON [dbo].[MarketingEfforts]
(
	[SeminarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[MobileDevices]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ParentEntityID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ParentEntityID] ON [dbo].[Notes]
(
	[ParentEntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[Notes]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_NotificationPersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_NotificationPersonID] ON [dbo].[NotificationHistory]
(
	[NotificationPersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_NotificationMessageTypeTemplateID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_NotificationMessageTypeTemplateID] ON [dbo].[NotificationMessageTypeTemplateNotificationTypes]
(
	[NotificationMessageTypeTemplateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseID] ON [dbo].[NotificationMessageTypeTemplates]
(
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[NotificationMessageTypeTemplates]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_NotificationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_NotificationID] ON [dbo].[NotificationPeople]
(
	[NotificationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[NotificationPeople]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_NotificationPersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_NotificationPersonID] ON [dbo].[NotificationQueue]
(
	[NotificationPersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ActiveInactiveDates]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ActiveInactiveDates] ON [dbo].[Notifications]
(
	[ActiveDate] ASC,
	[InactiveDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Notifications]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_EntityID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_EntityID] ON [dbo].[Notifications]
(
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[OAuthKeys]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[Organization_Tag]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagID] ON [dbo].[Organization_Tag]
(
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Organizations]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationTypeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationTypeID] ON [dbo].[Organizations]
(
	[OrganizationTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[PasswordResets]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[People]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ProfileImageResourceAssetID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ProfileImageResourceAssetID] ON [dbo].[People]
(
	[ProfileImageResourceAssetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[People_Payments]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SeminarID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SeminarID] ON [dbo].[People_Payments]
(
	[SeminarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SubmittedUserRegistrationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SubmittedUserRegistrationID] ON [dbo].[People_Payments]
(
	[SubmittedUserRegistrationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[People_Roles]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[People_Roles]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_RoleID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_RoleID] ON [dbo].[People_Roles]
(
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[Person_PersonPayment]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonPaymentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonPaymentID] ON [dbo].[Person_PersonPayment]
(
	[PersonPaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID_Person]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ClientID_Person] ON [dbo].[PersonClients]
(
	[ClientID] ASC,
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseID] ON [dbo].[PersonScores]
(
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CoursePersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CoursePersonID] ON [dbo].[PersonScores]
(
	[CoursePersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_GradableItemID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_GradableItemID] ON [dbo].[PersonScores]
(
	[GradableItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_GradeBookCategoryID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_GradeBookCategoryID] ON [dbo].[PersonScores]
(
	[GradeBookCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_GradeBookID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_GradeBookID] ON [dbo].[PersonScores]
(
	[GradeBookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OverridePersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OverridePersonID] ON [dbo].[PersonScores]
(
	[OverridePersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[PersonScores]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledAssessmentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ScheduledAssessmentID] ON [dbo].[PersonScores]
(
	[ScheduledAssessmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[PersonSearches]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[PhoneNumbers]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[PhoneNumbers]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_QuestionID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_QuestionID] ON [dbo].[PossibleResponses]
(
	[QuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[ProgramObjectives]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[ProgramObjectives]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OwnerClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OwnerClientID] ON [dbo].[ProgramObjectives]
(
	[OwnerClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[QualityAssuranceHistory]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[QualityAssuranceQueue]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_QuestionRowID_PossibleResponseID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_QuestionRowID_PossibleResponseID] ON [dbo].[QuestionCells]
(
	[QuestionRowID] ASC,
	[PossibleResponseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_QuestionID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_QuestionID] ON [dbo].[QuestionRows]
(
	[QuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Questions]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[Questions]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[Questions]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[Ratings]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ResourceID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ResourceID] ON [dbo].[Ratings]
(
	[ResourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ReportID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ReportID] ON [dbo].[Report_RoleType]
(
	[ReportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_AuthorPersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AuthorPersonID] ON [dbo].[ReportDefinitions]
(
	[AuthorPersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ResourceID_ScheduledEventID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ResourceID_ScheduledEventID] ON [dbo].[Resource_ScheduledEvents]
(
	[ResourceID] ASC,
	[ScheduledEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[ResourceAssets]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseID] ON [dbo].[ResourceAssets]
(
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DegreeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_DegreeID] ON [dbo].[ResourceAssets]
(
	[DegreeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaContentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaContentID] ON [dbo].[ResourceAssets]
(
	[HtmlMediaContentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_InteractiveContentID_Filename]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_InteractiveContentID_Filename] ON [dbo].[ResourceAssets]
(
	[InteractiveContentID] ASC,
	[Filename] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[ResourceAssets]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ResourceID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ResourceID] ON [dbo].[ResourceAssets]
(
	[ResourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_SeminarID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SeminarID] ON [dbo].[ResourceAssets]
(
	[SeminarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TempUploadID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TempUploadID] ON [dbo].[ResourceAssets]
(
	[TempUploadID] ASC,
	[TempUploadChunkNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Resources]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_InteractiveContentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_InteractiveContentID] ON [dbo].[Resources]
(
	[InteractiveContentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[Resources]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OwnerClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OwnerClientID] ON [dbo].[Resources]
(
	[OwnerClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ResourceTypeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ResourceTypeID] ON [dbo].[Resources]
(
	[ResourceTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ResourceScheduledEventID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ResourceScheduledEventID] ON [dbo].[ResourceScheduledEvent_RoleType]
(
	[ResourceScheduledEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_RoleID_UserPermissionID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_RoleID_UserPermissionID] ON [dbo].[RolePermissions]
(
	[RoleID] ASC,
	[UserPermissionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Roles]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CalendarID] ON [dbo].[Scheduled_Events]
(
	[CalendarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Scheduled_Events]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseID] ON [dbo].[Scheduled_Events]
(
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_EventID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_EventID] ON [dbo].[Scheduled_Events]
(
	[EventTemplateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_EventTemplateID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_EventTemplateID] ON [dbo].[Scheduled_Events]
(
	[EventTemplateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_EventTypeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_EventTypeID] ON [dbo].[Scheduled_Events]
(
	[EventTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[Scheduled_Events]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SubLocationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SubLocationID] ON [dbo].[Scheduled_Events]
(
	[SubLocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_QuestionRowID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_QuestionRowID] ON [dbo].[ScheduledAssessmentAnswers]
(
	[QuestionRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ResponseAnswerID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ResponseAnswerID] ON [dbo].[ScheduledAssessmentAnswers]
(
	[ResponseAnswerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledAssessmentQuestionID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ScheduledAssessmentQuestionID] ON [dbo].[ScheduledAssessmentAnswers]
(
	[ScheduledAssessmentQuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledAssessmentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ScheduledAssessmentID] ON [dbo].[ScheduledAssessmentProperties]
(
	[ScheduledAssessmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_GraderID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_GraderID] ON [dbo].[ScheduledAssessmentQuestions]
(
	[GraderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledAssessmentID_AssessmentFormRowID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ScheduledAssessmentID_AssessmentFormRowID] ON [dbo].[ScheduledAssessmentQuestions]
(
	[ScheduledAssessmentID] ASC,
	[AssessmentFormRowID] ASC,
	[QuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ActivityID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ActivityID] ON [dbo].[ScheduledAssessments]
(
	[ActivityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssessmentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentID] ON [dbo].[ScheduledAssessments]
(
	[AssessmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssessmentScheduledEventID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentScheduledEventID] ON [dbo].[ScheduledAssessments]
(
	[AssessmentScheduledEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AssessorID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssessorID] ON [dbo].[ScheduledAssessments]
(
	[AssessorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_BaseScheduledAssessmentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_BaseScheduledAssessmentID] ON [dbo].[ScheduledAssessments]
(
	[BaseScheduledAssessmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseID] ON [dbo].[ScheduledAssessments]
(
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CoursePersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CoursePersonID] ON [dbo].[ScheduledAssessments]
(
	[CoursePersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[ScheduledAssignments]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[ScheduledAssignments]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledEventID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ScheduledEventID] ON [dbo].[ScheduledAssignments]
(
	[ScheduledEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CoursePersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CoursePersonID] ON [dbo].[ScheduledEvent_People]
(
	[CoursePersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[ScheduledEvent_People]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledEventID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ScheduledEventID] ON [dbo].[ScheduledEvent_People]
(
	[ScheduledEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CoursePersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CoursePersonID] ON [dbo].[ScheduledEventCompletedItems]
(
	[CoursePersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[ScheduledEventCompletedItems]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ScheduledEventID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ScheduledEventID] ON [dbo].[ScheduledEventCompletedItems]
(
	[ScheduledEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_SchedulingRoundID_CriterionType]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SchedulingRoundID_CriterionType] ON [dbo].[SchedulingDistributionCriteria]
(
	[SchedulingRoundID] ASC,
	[CriterionType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_SchedulingRoundID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SchedulingRoundID] ON [dbo].[SchedulingResults]
(
	[SchedulingRoundID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_SchedulingRoundID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SchedulingRoundID] ON [dbo].[SchedulingRoundCourseUsageGroups]
(
	[SchedulingRoundID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseUsageGroupID_CourseUsageID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CourseUsageGroupID_CourseUsageID] ON [dbo].[SchedulingRoundCourseUsages]
(
	[CourseUsageGroupID] ASC,
	[CourseUsageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_SchedulingSessionID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SchedulingSessionID] ON [dbo].[SchedulingRounds]
(
	[SchedulingSessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[SchedulingSessions]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[SchedulingSessions]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_SchedulingTrackID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SchedulingTrackID] ON [dbo].[SchedulingSessions]
(
	[SchedulingTrackID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_SchedulingTrackID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SchedulingTrackID] ON [dbo].[SchedulingTimeBlocks]
(
	[SchedulingTrackID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[SchedulingTracks]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[SeatReservations]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonPaymentID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonPaymentID] ON [dbo].[Seminar_People]
(
	[PersonPaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SeminarID_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SeminarID_PersonID] ON [dbo].[Seminar_People]
(
	[SeminarID] ASC,
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SeminarID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SeminarID] ON [dbo].[Seminar_Tag]
(
	[SeminarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagID] ON [dbo].[Seminar_Tag]
(
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Seminars]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_HtmlMediaID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_HtmlMediaID] ON [dbo].[Seminars]
(
	[HtmlMediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationID] ON [dbo].[Seminars]
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SeminarTypeID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SeminarTypeID] ON [dbo].[Seminars]
(
	[SeminarTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_StandardID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_StandardID] ON [dbo].[Standard_StandardObjective]
(
	[StandardID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_StandardObjectiveID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_StandardObjectiveID] ON [dbo].[Standard_StandardObjective]
(
	[StandardObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_StandardObjectiveID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_StandardObjectiveID] ON [dbo].[StandardObjective_Tag]
(
	[StandardObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagID] ON [dbo].[StandardObjective_Tag]
(
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[StandardObjectives]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OwnerClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OwnerClientID] ON [dbo].[StandardObjectives]
(
	[OwnerClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagFilterID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagFilterID] ON [dbo].[StandardObjectives]
(
	[TagFilterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[Standards]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OwnerClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OwnerClientID] ON [dbo].[Standards]
(
	[OwnerClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseUsageID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_CourseUsageID] ON [dbo].[StudentSchedulingPreferences]
(
	[CourseUsageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_SchedulingTimeBlockID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SchedulingTimeBlockID] ON [dbo].[StudentSchedulingPreferences]
(
	[SchedulingTimeBlockID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_StudentSchedulingRoundID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_StudentSchedulingRoundID] ON [dbo].[StudentSchedulingPreferences]
(
	[StudentSchedulingRoundID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[StudentSchedulingRounds]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_SchedulingRoundID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_SchedulingRoundID] ON [dbo].[StudentSchedulingRounds]
(
	[SchedulingRoundID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_LocationID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_LocationID] ON [dbo].[SubLocations]
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagGroupID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagGroupID] ON [dbo].[Tag_TagGroup]
(
	[TagGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[TagCategories]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_OwnerClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_OwnerClientID] ON [dbo].[TagCategories]
(
	[OwnerClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagFilterID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagFilterID] ON [dbo].[TagGroups]
(
	[TagFilterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagCategoryID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagCategoryID] ON [dbo].[Tags]
(
	[TagCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_TagID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TagID] ON [dbo].[TagSearchTerms]
(
	[TagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ThesaurusTermID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ThesaurusTermID] ON [dbo].[ThesaurusSynonyms]
(
	[ThesaurusTermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_ClientID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClientID] ON [dbo].[ThesaurusTerms]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_LearningObjectiveID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_LearningObjectiveID] ON [dbo].[UnderstandFlags]
(
	[LearningObjectiveID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[UnderstandFlags]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_UserName]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserName] ON [dbo].[Users]
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PersonID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_PersonID] ON [dbo].[UserSettings]
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_TaxonomyLevelID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TaxonomyLevelID] ON [Reference].[TaxonomyActionVerbs]
(
	[TaxonomyLevelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_TaxonomyID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TaxonomyID] ON [Reference].[TaxonomyDomains]
(
	[TaxonomyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [IX_TaxonomyDomainID]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_TaxonomyDomainID] ON [Reference].[TaxonomyLevels]
(
	[TaxonomyDomainID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Username]    Script Date: 3/14/2021 4:50:28 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Username] ON [Registration].[SubmittedUserRegistration]
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Configuration].[AllowedRoleType] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [Configuration].[ClientSettings] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Configuration].[DirectObservationTypes] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Configuration].[EntityTypeSettings] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [Configuration].[EvaluationTypes] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Configuration].[EventTypes] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Configuration].[ExaminationTypes] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Configuration].[LevelsOfLearning] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Configuration].[LocationTypes] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Configuration].[LogRequirementTypes] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Configuration].[OrganizationTypes] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Configuration].[RenewalFrequencyTypes] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [Configuration].[RenewalFrequencyTypes] ADD  DEFAULT ((0)) FOR [RenewalFrequency_Period]
GO
ALTER TABLE [Configuration].[RenewalFrequencyTypes] ADD  DEFAULT ((0)) FOR [RenewalFrequency_Amount]
GO
ALTER TABLE [Configuration].[ResourceTypes] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Configuration].[SeminarTypes] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Activities] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Addresses] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Addresses] ADD  DEFAULT ((0)) FOR [Latitude]
GO
ALTER TABLE [dbo].[Addresses] ADD  DEFAULT ((0)) FOR [Longitude]
GO
ALTER TABLE [dbo].[Addresses] ADD  DEFAULT ((0)) FOR [IsPrimary]
GO
ALTER TABLE [dbo].[Assessment_EventTemplate] ADD  DEFAULT ((0)) FOR [Purpose]
GO
ALTER TABLE [dbo].[Assessment_EventTemplate] ADD  DEFAULT ((0)) FOR [Required]
GO
ALTER TABLE [dbo].[Assessment_ScheduledEvent] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Assessment_ScheduledEvent] ADD  DEFAULT ((0)) FOR [Purpose]
GO
ALTER TABLE [dbo].[Assessment_ScheduledEvent] ADD  DEFAULT ((0)) FOR [Required]
GO
ALTER TABLE [dbo].[AssessmentFormRows] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[AssessmentFormRows] ADD  DEFAULT ((0)) FOR [Percent]
GO
ALTER TABLE [dbo].[AssessmentFormRows] ADD  DEFAULT ((0)) FOR [UsePercent]
GO
ALTER TABLE [dbo].[AssessmentFormRows] ADD  DEFAULT ((0)) FOR [Weight]
GO
ALTER TABLE [dbo].[AssessmentFormRows] ADD  DEFAULT ((0)) FOR [QuestionsToDeliver]
GO
ALTER TABLE [dbo].[AssessmentFormRows] ADD  DEFAULT ((0)) FOR [IsGraded]
GO
ALTER TABLE [dbo].[AssessmentFormSections] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[AssessmentFormSections] ADD  DEFAULT ((0)) FOR [MakeAllAssessmentRowScoresEqual]
GO
ALTER TABLE [dbo].[AssessmentFormSections] ADD  DEFAULT ((0)) FOR [Percent]
GO
ALTER TABLE [dbo].[AssessmentFormSections] ADD  DEFAULT ((0)) FOR [UsePercent]
GO
ALTER TABLE [dbo].[AssessmentFormSections] ADD  DEFAULT ((0)) FOR [Weight]
GO
ALTER TABLE [dbo].[Assessments] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Assessments] ADD  DEFAULT ((0)) FOR [ParentEntityType]
GO
ALTER TABLE [dbo].[Assessments] ADD  DEFAULT ((0)) FOR [AdministrationType]
GO
ALTER TABLE [dbo].[Assessments] ADD  DEFAULT ((0)) FOR [IsGraded]
GO
ALTER TABLE [dbo].[AssessmentScheduleParams] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[AssessmentScheduleParams] ADD  DEFAULT ((0)) FOR [AllowResubmission]
GO
ALTER TABLE [dbo].[AssessmentScheduleParams] ADD  DEFAULT ((0)) FOR [EvaluationSubjectType]
GO
ALTER TABLE [dbo].[AssessmentScheduleQueue] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[AssignmentTemplates] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[AssignmentTemplates] ADD  DEFAULT ((0)) FOR [InUse]
GO
ALTER TABLE [dbo].[AssignmentUploads] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Attendance] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[AuditReferences] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Audits] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[AuditValues] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[BackgroundTasks] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[BackgroundTasks] ADD  DEFAULT ((0)) FOR [Enabled]
GO
ALTER TABLE [dbo].[BackgroundTasks] ADD  DEFAULT ((0)) FOR [ExecuteIfPastDue]
GO
ALTER TABLE [dbo].[Calendar_People] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [CoursePersonID]
GO
ALTER TABLE [dbo].[Calendars] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Calendars] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Calendars] ADD  DEFAULT ((0)) FOR [UseAllInstructorsFromCourse]
GO
ALTER TABLE [dbo].[Calendars] ADD  DEFAULT ((0)) FOR [UseAllStudentsFromCourse]
GO
ALTER TABLE [dbo].[ClientNotificationPersons] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Clients] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Clients] ADD  DEFAULT ('') FOR [ClientCode]
GO
ALTER TABLE [dbo].[Clients] ADD  DEFAULT ((0)) FOR [Currency]
GO
ALTER TABLE [dbo].[ContinuingEducationHistory] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[ContinuingEducationHistory] ADD  DEFAULT ('1900-01-01T00:00:00.000') FOR [RenewalDueDate]
GO
ALTER TABLE [dbo].[ContinuingEducationRequirements] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[ContinuingEducationRequirements] ADD  DEFAULT ((0)) FOR [FirstRenewalDelay]
GO
ALTER TABLE [dbo].[CoreCompetencies] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Course_People] ADD  DEFAULT ((0)) FOR [CompletionStatus]
GO
ALTER TABLE [dbo].[Course_People] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Course_People] ADD  DEFAULT ((0)) FOR [Retaken]
GO
ALTER TABLE [dbo].[Course_People] ADD  DEFAULT ('1900-01-01T00:00:00.000') FOR [LastModifyDateTime]
GO
ALTER TABLE [dbo].[Course_People] ADD  DEFAULT ('1900-01-01T00:00:00.000') FOR [StatusModifiedDate]
GO
ALTER TABLE [dbo].[Course_People] ADD  DEFAULT ((0)) FOR [AddedBy]
GO
ALTER TABLE [dbo].[Course_People] ADD  DEFAULT ((0)) FOR [HistoricalStatus]
GO
ALTER TABLE [dbo].[Course_WaitListPerson] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Course_WaitListPerson] ADD  DEFAULT ('1900-01-01T00:00:00.000') FOR [LastModifyDateTime]
GO
ALTER TABLE [dbo].[CourseCatalogs] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[CourseObjectives] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[CourseOverviews] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[CourseOverviews] ADD  DEFAULT ((0)) FOR [Duration]
GO
ALTER TABLE [dbo].[CourseOverviews] ADD  DEFAULT ((0)) FOR [AllowConcurrentScheduling]
GO
ALTER TABLE [dbo].[CourseOverviews] ADD  DEFAULT ((0)) FOR [InUse]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [StudentsMax]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [WaitListedPeopleMax]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [CourseOverviewID]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [Median]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [Average]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [Type]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [TimeReleaseEvents]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [EntityState]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [InUse]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [UseTimeLimit]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [TimeLimitDays]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [AttendanceParams_Track]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [AttendanceParams_AllowedMethods]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [IncludeInSelfRegistration]
GO
ALTER TABLE [dbo].[Courses] ADD  DEFAULT ((0)) FOR [AttendanceParams_Required]
GO
ALTER TABLE [dbo].[Degree_People] ADD  DEFAULT ((0)) FOR [CompletionStatus]
GO
ALTER TABLE [dbo].[Degree_People] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Degree_People] ADD  DEFAULT ('1900-01-01T00:00:00.000') FOR [LastModifyDateTime]
GO
ALTER TABLE [dbo].[DegreeGroupDegreeTracks] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[DegreeGroupDegreeTracks] ADD  DEFAULT ((0)) FOR [OrderMethod]
GO
ALTER TABLE [dbo].[DegreeGroups] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [Type]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [AllowOnlineRegistration]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [RootID]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [Version]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [EntityState]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [InUse]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [Locked]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [MostRecentVersion]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [MostRecentApprovedVersion]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [Price]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [VerificationSearchEnabled]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [ExpirationDuration_Period]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [ExpirationDuration_Amount]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [CertificateTemplate]
GO
ALTER TABLE [dbo].[Degrees] ADD  DEFAULT ((0)) FOR [ExpirationBuffer]
GO
ALTER TABLE [dbo].[DegreeTrackCourseUsages] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[DegreeTrackCourseUsages] ADD  DEFAULT ((0)) FOR [OrderMethod]
GO
ALTER TABLE [dbo].[DegreeTrackGroups] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[DegreeTrackGroups] ADD  DEFAULT ((0)) FOR [IsSequential]
GO
ALTER TABLE [dbo].[DegreeTracks] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[DegreeTracks] ADD  DEFAULT ((0)) FOR [Duration_Period]
GO
ALTER TABLE [dbo].[DegreeTracks] ADD  DEFAULT ((0)) FOR [Duration_Amount]
GO
ALTER TABLE [dbo].[DegreeTracks] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [ClientID]
GO
ALTER TABLE [dbo].[DegreeTracks] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [RootID]
GO
ALTER TABLE [dbo].[DegreeTracks] ADD  DEFAULT ((0)) FOR [Version]
GO
ALTER TABLE [dbo].[DegreeTracks] ADD  DEFAULT ((0)) FOR [EntityState]
GO
ALTER TABLE [dbo].[DegreeTracks] ADD  DEFAULT ((0)) FOR [InUse]
GO
ALTER TABLE [dbo].[DegreeTracks] ADD  DEFAULT ((0)) FOR [Locked]
GO
ALTER TABLE [dbo].[DegreeTracks] ADD  DEFAULT ((0)) FOR [MostRecentVersion]
GO
ALTER TABLE [dbo].[DegreeTracks] ADD  DEFAULT ((0)) FOR [MostRecentApprovedVersion]
GO
ALTER TABLE [dbo].[DirectObservations] ADD  DEFAULT ((0)) FOR [DurationMinutes]
GO
ALTER TABLE [dbo].[DirectObservations] ADD  DEFAULT ((0)) FOR [Locked]
GO
ALTER TABLE [dbo].[DirectObservations] ADD  DEFAULT ((0)) FOR [MostRecentApprovedVersion]
GO
ALTER TABLE [dbo].[ELMAH_Error] ADD  DEFAULT (newid()) FOR [ErrorId]
GO
ALTER TABLE [dbo].[Emails] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Emails] ADD  DEFAULT ((0)) FOR [HasBeenVerified]
GO
ALTER TABLE [dbo].[EnrollCourses] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[EnrollCourseUsages] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[EnrollDegrees] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Evaluation_Resource] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Evaluation_Resource] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [AssessmentScheduleParamsID]
GO
ALTER TABLE [dbo].[Evaluations] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Evaluations] ADD  DEFAULT ((0)) FOR [Locked]
GO
ALTER TABLE [dbo].[Evaluations] ADD  DEFAULT ((0)) FOR [MostRecentApprovedVersion]
GO
ALTER TABLE [dbo].[EventTemplate_Resources] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[EventTemplate_Resources] ADD  DEFAULT ((0)) FOR [Required]
GO
ALTER TABLE [dbo].[EventTemplate_Resources] ADD  DEFAULT ((0)) FOR [EventTemplateDisplayOrder]
GO
ALTER TABLE [dbo].[EventTemplate_Resources] ADD  DEFAULT ((0)) FOR [ResourceDisplayOrder]
GO
ALTER TABLE [dbo].[EventTemplates] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[EventTemplates] ADD  DEFAULT ((0)) FOR [Duration]
GO
ALTER TABLE [dbo].[EventTemplates] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[EventTemplates] ADD  DEFAULT ((0)) FOR [InUse]
GO
ALTER TABLE [dbo].[Examinations] ADD  DEFAULT ((0)) FOR [DurationMinutes]
GO
ALTER TABLE [dbo].[Examinations] ADD  DEFAULT ((0)) FOR [Locked]
GO
ALTER TABLE [dbo].[Examinations] ADD  DEFAULT ((0)) FOR [MostRecentApprovedVersion]
GO
ALTER TABLE [dbo].[ExpectedUploads] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[GradableItems] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[GradableItems] ADD  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[GradableItems] ADD  DEFAULT ((0)) FOR [UsePercent]
GO
ALTER TABLE [dbo].[GradableItems] ADD  DEFAULT ((0)) FOR [Median]
GO
ALTER TABLE [dbo].[GradableItems] ADD  DEFAULT ((0)) FOR [Average]
GO
ALTER TABLE [dbo].[GradableItems] ADD  DEFAULT ((0)) FOR [Percent]
GO
ALTER TABLE [dbo].[GradeBookCategories] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[GradeBookCategories] ADD  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[GradeBookCategories] ADD  DEFAULT ((0)) FOR [UsePercent]
GO
ALTER TABLE [dbo].[GradeBookCategories] ADD  DEFAULT ((0)) FOR [Median]
GO
ALTER TABLE [dbo].[GradeBookCategories] ADD  DEFAULT ((0)) FOR [Average]
GO
ALTER TABLE [dbo].[GradeBookCategories] ADD  DEFAULT ((0)) FOR [Percent]
GO
ALTER TABLE [dbo].[GradeBooks] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[GradingCriterionRanges] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[GradingCriterionRanges] ADD  DEFAULT ((0)) FOR [Threshold]
GO
ALTER TABLE [dbo].[GradingCriterions] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[GradingCriterions] ADD  DEFAULT ('') FOR [DisplayID]
GO
ALTER TABLE [dbo].[GradingCriterions] ADD  DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [dbo].[Helps] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[InteractiveContents] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[LearningObjective_Resource] ADD  DEFAULT ((0)) FOR [LearningObjectiveDisplayOrder]
GO
ALTER TABLE [dbo].[LearningObjective_Resource] ADD  DEFAULT ((0)) FOR [ResourceDisplayOrder]
GO
ALTER TABLE [dbo].[LearningObjectives] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[LearningObjectives] ADD  DEFAULT ((0)) FOR [Locked]
GO
ALTER TABLE [dbo].[LearningObjectives] ADD  DEFAULT ((0)) FOR [MostRecentApprovedVersion]
GO
ALTER TABLE [dbo].[Locations] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Logins] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Logins] ADD  DEFAULT ((0)) FOR [AuthenticationProvider]
GO
ALTER TABLE [dbo].[Logins] ADD  DEFAULT ((0)) FOR [EmailVerified]
GO
ALTER TABLE [dbo].[Logins] ADD  DEFAULT ((0)) FOR [IsExternalProvider]
GO
ALTER TABLE [dbo].[LogRequirements] ADD  DEFAULT ((0)) FOR [DurationMinutes]
GO
ALTER TABLE [dbo].[LogRequirements] ADD  DEFAULT ((0)) FOR [Locked]
GO
ALTER TABLE [dbo].[LogRequirements] ADD  DEFAULT ((0)) FOR [MostRecentApprovedVersion]
GO
ALTER TABLE [dbo].[MarketingEfforts] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[MobileDevices] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Notes] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[NotificationHistory] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[NotificationMessageTypeTemplateNotificationTypes] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[NotificationMessageTypeTemplates] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[NotificationPeople] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[NotificationPeople] ADD  DEFAULT ((0)) FOR [Saved]
GO
ALTER TABLE [dbo].[NotificationPeople] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[NotificationQueue] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Notifications] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Notifications] ADD  DEFAULT ((0)) FOR [NotificationMessageType]
GO
ALTER TABLE [dbo].[OAuthKeys] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[OAuthKeys] ADD  DEFAULT ((0)) FOR [AuthenticationProvider]
GO
ALTER TABLE [dbo].[Organizations] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Organizations] ADD  DEFAULT ((0)) FOR [CanRegisterInto]
GO
ALTER TABLE [dbo].[Organizations] ADD  DEFAULT ((0)) FOR [EntityState]
GO
ALTER TABLE [dbo].[Organizations] ADD  DEFAULT ((0)) FOR [InUse]
GO
ALTER TABLE [dbo].[PasswordResets] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[People] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[People] ADD  DEFAULT ((0)) FOR [DisableTutorials]
GO
ALTER TABLE [dbo].[People] ADD  DEFAULT ((0)) FOR [SystemType]
GO
ALTER TABLE [dbo].[People] ADD  DEFAULT ((0)) FOR [EnablePortal]
GO
ALTER TABLE [dbo].[People_Payments] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[People_Payments] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [FetchID]
GO
ALTER TABLE [dbo].[People_Roles] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[PersonClients] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[PersonScores] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[PersonScores] ADD  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[PersonScores] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [ScheduledAssessmentID]
GO
ALTER TABLE [dbo].[PersonScores] ADD  DEFAULT ((0)) FOR [Passed]
GO
ALTER TABLE [dbo].[PersonScores] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [CourseID]
GO
ALTER TABLE [dbo].[PersonScores] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [CoursePersonID]
GO
ALTER TABLE [dbo].[PersonSearches] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[PhoneNumbers] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[PossibleResponses] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[PossibleResponses] ADD  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[PossibleResponses] ADD  DEFAULT ((0)) FOR [AllowInput]
GO
ALTER TABLE [dbo].[ProgramObjectives] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[QualityAssuranceHistory] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[QualityAssuranceQueue] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[QuestionCells] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[QuestionRows] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Questions] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Questions] ADD  DEFAULT ((0)) FOR [Locked]
GO
ALTER TABLE [dbo].[Questions] ADD  DEFAULT ((0)) FOR [MostRecentApprovedVersion]
GO
ALTER TABLE [dbo].[Questions] ADD  DEFAULT ((0)) FOR [OneResponsePerRow]
GO
ALTER TABLE [dbo].[Questions] ADD  DEFAULT ((0)) FOR [EnableComment]
GO
ALTER TABLE [dbo].[Ratings] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Ratings] ADD  DEFAULT ((0)) FOR [TotalViewsCount]
GO
ALTER TABLE [dbo].[ReportDefinitions] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Reports] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Resource_ScheduledEvents] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Resource_ScheduledEvents] ADD  DEFAULT ((0)) FOR [Required]
GO
ALTER TABLE [dbo].[Resource_ScheduledEvents] ADD  DEFAULT ((0)) FOR [ScheduledEventDisplayOrder]
GO
ALTER TABLE [dbo].[Resource_ScheduledEvents] ADD  DEFAULT ((0)) FOR [ResourceDisplayOrder]
GO
ALTER TABLE [dbo].[ResourceAssets] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[ResourceAssets] ADD  DEFAULT ((0)) FOR [ContentStorageType]
GO
ALTER TABLE [dbo].[ResourceAssets] ADD  DEFAULT ((0)) FOR [Type]
GO
ALTER TABLE [dbo].[Resources] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Resources] ADD  DEFAULT ((0)) FOR [Locked]
GO
ALTER TABLE [dbo].[Resources] ADD  DEFAULT ((0)) FOR [MostRecentApprovedVersion]
GO
ALTER TABLE [dbo].[Resources] ADD  DEFAULT ((0)) FOR [IsPublic]
GO
ALTER TABLE [dbo].[RolePermissions] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[RolePermissions] ADD  DEFAULT ((0)) FOR [Approve]
GO
ALTER TABLE [dbo].[RolePermissions] ADD  DEFAULT ((0)) FOR [Close]
GO
ALTER TABLE [dbo].[RolePermissions] ADD  DEFAULT ((0)) FOR [EditInUse]
GO
ALTER TABLE [dbo].[RolePermissions] ADD  DEFAULT ((0)) FOR [Share]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT ((0)) FOR [GrantAllPermissions]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT ((0)) FOR [SystemType]
GO
ALTER TABLE [dbo].[Scheduled_Events] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Scheduled_Events] ADD  DEFAULT ((0)) FOR [DurationMinutes]
GO
ALTER TABLE [dbo].[Scheduled_Events] ADD  DEFAULT ((0)) FOR [Interprofessional]
GO
ALTER TABLE [dbo].[Scheduled_Events] ADD  DEFAULT ('') FOR [DisplayID]
GO
ALTER TABLE [dbo].[Scheduled_Events] ADD  DEFAULT ((0)) FOR [UseAllStudentsFromCalendar]
GO
ALTER TABLE [dbo].[Scheduled_Events] ADD  DEFAULT ((0)) FOR [UseAllInstructorsFromCalendar]
GO
ALTER TABLE [dbo].[Scheduled_Events] ADD  DEFAULT ((0)) FOR [IsTaskItem]
GO
ALTER TABLE [dbo].[Scheduled_Events] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [CourseID]
GO
ALTER TABLE [dbo].[Scheduled_Events] ADD  DEFAULT ((0)) FOR [AttendanceParams_Track]
GO
ALTER TABLE [dbo].[Scheduled_Events] ADD  DEFAULT ((0)) FOR [AttendanceParams_AllowedMethods]
GO
ALTER TABLE [dbo].[Scheduled_Events] ADD  DEFAULT ((0)) FOR [AttendanceParams_Required]
GO
ALTER TABLE [dbo].[ScheduledAssessmentAnswers] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[ScheduledAssessmentAnswers] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [ScheduledAssessmentQuestionID]
GO
ALTER TABLE [dbo].[ScheduledAssessmentProperties] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[ScheduledAssessmentQuestions] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[ScheduledAssessmentQuestions] ADD  DEFAULT ((0)) FOR [FlaggedForReview]
GO
ALTER TABLE [dbo].[ScheduledAssessmentQuestions] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [QuestionID]
GO
ALTER TABLE [dbo].[ScheduledAssessmentQuestions] ADD  DEFAULT ((0)) FOR [QuestionPoolDisplayOrder]
GO
ALTER TABLE [dbo].[ScheduledAssessments] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[ScheduledAssessments] ADD  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[ScheduledAssessments] ADD  DEFAULT ('1900-01-01T00:00:00.000') FOR [StartDate]
GO
ALTER TABLE [dbo].[ScheduledAssessments] ADD  DEFAULT ('1900-01-01T00:00:00.000') FOR [EndDate]
GO
ALTER TABLE [dbo].[ScheduledAssessments] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [CourseID]
GO
ALTER TABLE [dbo].[ScheduledAssessments] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [CoursePersonID]
GO
ALTER TABLE [dbo].[ScheduledAssessments] ADD  DEFAULT ((0)) FOR [Review]
GO
ALTER TABLE [dbo].[ScheduledAssignments] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[ScheduledAssignments] ADD  DEFAULT ((0)) FOR [AllowStudentResponses]
GO
ALTER TABLE [dbo].[ScheduledAssignments] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [ScheduledEventID]
GO
ALTER TABLE [dbo].[ScheduledEvent_People] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [CoursePersonID]
GO
ALTER TABLE [dbo].[ScheduledEventCompletedItems] ADD  DEFAULT ((0)) FOR [IsUserDetermined]
GO
ALTER TABLE [dbo].[ScheduledEventCompletedItems] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [CoursePersonID]
GO
ALTER TABLE [dbo].[SchedulingDistributionCriteria] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[SchedulingDistributionCriteria] ADD  DEFAULT ((0)) FOR [Weight]
GO
ALTER TABLE [dbo].[SchedulingResults] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[SchedulingResults] ADD  DEFAULT ('1900-01-01T00:00:00.000') FOR [EndDate]
GO
ALTER TABLE [dbo].[SchedulingResults] ADD  DEFAULT ((0)) FOR [Successful]
GO
ALTER TABLE [dbo].[SchedulingResults] ADD  DEFAULT ((0)) FOR [UnassignedCredits]
GO
ALTER TABLE [dbo].[SchedulingResults] ADD  DEFAULT ((0)) FOR [PctFirstPreference]
GO
ALTER TABLE [dbo].[SchedulingResults] ADD  DEFAULT ((0)) FOR [NumFirstPreference]
GO
ALTER TABLE [dbo].[SchedulingResults] ADD  DEFAULT ((0)) FOR [PctSecondPreference]
GO
ALTER TABLE [dbo].[SchedulingResults] ADD  DEFAULT ((0)) FOR [NumSecondPreference]
GO
ALTER TABLE [dbo].[SchedulingResults] ADD  DEFAULT ((0)) FOR [PctThirdPreference]
GO
ALTER TABLE [dbo].[SchedulingResults] ADD  DEFAULT ((0)) FOR [NumThirdPreference]
GO
ALTER TABLE [dbo].[SchedulingRoundCourseUsageGroups] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[SchedulingRoundCourseUsages] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[SchedulingRounds] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[SchedulingRounds] ADD  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[SchedulingSessions] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[SchedulingSessions] ADD  DEFAULT ((0)) FOR [EntityState]
GO
ALTER TABLE [dbo].[SchedulingSessions] ADD  DEFAULT ((0)) FOR [InUse]
GO
ALTER TABLE [dbo].[SchedulingTimeBlocks] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[SchedulingTimeBlocks] ADD  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[SchedulingTracks] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[SeatReservations] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Seminar_People] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Seminar_People] ADD  DEFAULT ((0)) FOR [AddedBy]
GO
ALTER TABLE [dbo].[Seminars] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Seminars] ADD  DEFAULT ((0)) FOR [AvailableOnExternalSearch]
GO
ALTER TABLE [dbo].[Seminars] ADD  DEFAULT ((0)) FOR [AttendanceParams_Required]
GO
ALTER TABLE [dbo].[Seminars] ADD  DEFAULT ((0)) FOR [StudentsMax]
GO
ALTER TABLE [dbo].[StandardObjectives] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[StandardPackages] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [dbo].[Standards] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[StudentSchedulingPreferences] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[StudentSchedulingPreferences] ADD  DEFAULT ((0)) FOR [PreferenceOrder]
GO
ALTER TABLE [dbo].[StudentSchedulingRounds] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[SubLocations] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[TagCategories] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[TagCategories] ADD  DEFAULT ((0)) FOR [TagType]
GO
ALTER TABLE [dbo].[TagFilters] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[TagGroups] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Tags] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[TagSearchTerms] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[ThesaurusSynonyms] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[ThesaurusTerms] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[UnderstandFlags] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[UserSettings] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[xAPIUserState] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [Reference].[EntityTypes] ADD  DEFAULT ((0)) FOR [IsNoteParent]
GO
ALTER TABLE [Reference].[EntityTypes] ADD  DEFAULT ((0)) FOR [IsEntityState]
GO
ALTER TABLE [Reference].[EntityTypes] ADD  DEFAULT ((0)) FOR [IsVersionable]
GO
ALTER TABLE [Reference].[Taxonomies] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Reference].[TaxonomyActionVerbs] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Reference].[TaxonomyDomains] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Reference].[TaxonomyLevels] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [Reference].[UserPermissions] ADD  DEFAULT ((0)) FOR [ShowApprove]
GO
ALTER TABLE [Reference].[UserPermissions] ADD  DEFAULT ((0)) FOR [ShowClose]
GO
ALTER TABLE [Reference].[UserPermissions] ADD  DEFAULT ((0)) FOR [ShowEditInUse]
GO
ALTER TABLE [Reference].[UserPermissions] ADD  DEFAULT ((0)) FOR [ShowShared]
GO
ALTER TABLE [Registration].[SubmittedUserRegistration] ADD  DEFAULT (newsequentialid()) FOR [ID]
GO
ALTER TABLE [Registration].[SubmittedUserRegistration] ADD  DEFAULT ((0)) FOR [AddressType]
GO
ALTER TABLE [Registration].[SubmittedUserRegistration] ADD  DEFAULT ('00000000-0000-0000-0000-000000000000') FOR [RoleID]
GO
ALTER TABLE [Configuration].[AllowedRoleType]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.AllowedRoleType_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[AllowedRoleType] CHECK CONSTRAINT [FK_Configuration.AllowedRoleType_dbo.Clients_ClientID]
GO
ALTER TABLE [Configuration].[ClientSettings]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.ClientSettings_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[ClientSettings] CHECK CONSTRAINT [FK_Configuration.ClientSettings_dbo.Clients_ClientID]
GO
ALTER TABLE [Configuration].[DirectObservationTypes]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.DirectObservationTypes_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[DirectObservationTypes] CHECK CONSTRAINT [FK_Configuration.DirectObservationTypes_dbo.Clients_ClientID]
GO
ALTER TABLE [Configuration].[EntityTypeSettings]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.EntityTypeSettings_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[EntityTypeSettings] CHECK CONSTRAINT [FK_Configuration.EntityTypeSettings_dbo.Clients_ClientID]
GO
ALTER TABLE [Configuration].[EvaluationTypes]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.EvaluationTypes_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[EvaluationTypes] CHECK CONSTRAINT [FK_Configuration.EvaluationTypes_dbo.Clients_ClientID]
GO
ALTER TABLE [Configuration].[EventTypes]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.EventTypes_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[EventTypes] CHECK CONSTRAINT [FK_Configuration.EventTypes_dbo.Clients_ClientID]
GO
ALTER TABLE [Configuration].[ExaminationTypes]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.ExaminationTypes_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[ExaminationTypes] CHECK CONSTRAINT [FK_Configuration.ExaminationTypes_dbo.Clients_ClientID]
GO
ALTER TABLE [Configuration].[LevelsOfLearning]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.LevelsOfLearning_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[LevelsOfLearning] CHECK CONSTRAINT [FK_Configuration.LevelsOfLearning_dbo.Clients_ClientID]
GO
ALTER TABLE [Configuration].[LevelsOfLearning]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.LevelsOfLearning_dbo.Clients_OwnerClientID] FOREIGN KEY([OwnerClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[LevelsOfLearning] CHECK CONSTRAINT [FK_Configuration.LevelsOfLearning_dbo.Clients_OwnerClientID]
GO
ALTER TABLE [Configuration].[LocationTypes]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.LocationTypes_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[LocationTypes] CHECK CONSTRAINT [FK_Configuration.LocationTypes_dbo.Clients_ClientID]
GO
ALTER TABLE [Configuration].[LogRequirementTypes]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.LogRequirementTypes_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[LogRequirementTypes] CHECK CONSTRAINT [FK_Configuration.LogRequirementTypes_dbo.Clients_ClientID]
GO
ALTER TABLE [Configuration].[OrganizationTypes]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.OrganizationTypes_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[OrganizationTypes] CHECK CONSTRAINT [FK_Configuration.OrganizationTypes_dbo.Clients_ClientID]
GO
ALTER TABLE [Configuration].[RenewalFrequencyTypes]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.RenewalFrequencyTypes_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[RenewalFrequencyTypes] CHECK CONSTRAINT [FK_Configuration.RenewalFrequencyTypes_dbo.Clients_ClientID]
GO
ALTER TABLE [Configuration].[ResourceTypes]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.ResourceTypes_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[ResourceTypes] CHECK CONSTRAINT [FK_Configuration.ResourceTypes_dbo.Clients_ClientID]
GO
ALTER TABLE [Configuration].[ResourceTypes]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.ResourceTypes_dbo.Clients_OwnerClientID] FOREIGN KEY([OwnerClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[ResourceTypes] CHECK CONSTRAINT [FK_Configuration.ResourceTypes_dbo.Clients_OwnerClientID]
GO
ALTER TABLE [Configuration].[SeminarTypes]  WITH CHECK ADD  CONSTRAINT [FK_Configuration.SeminarTypes_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [Configuration].[SeminarTypes] CHECK CONSTRAINT [FK_Configuration.SeminarTypes_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Activities]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Activities_dbo.Assessments_AssessmentID] FOREIGN KEY([AssessmentID])
REFERENCES [dbo].[Assessments] ([ID])
GO
ALTER TABLE [dbo].[Activities] CHECK CONSTRAINT [FK_dbo.Activities_dbo.Assessments_AssessmentID]
GO
ALTER TABLE [dbo].[Activities]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Activities_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Activities] CHECK CONSTRAINT [FK_dbo.Activities_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Activities]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Activities_dbo.Clients_OwnerClientID] FOREIGN KEY([OwnerClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Activities] CHECK CONSTRAINT [FK_dbo.Activities_dbo.Clients_OwnerClientID]
GO
ALTER TABLE [dbo].[Activities]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Activities_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[Activities] CHECK CONSTRAINT [FK_dbo.Activities_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[Activity_Person]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Activity_Person_dbo.Activities_ActivityID] FOREIGN KEY([ActivityID])
REFERENCES [dbo].[Activities] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Activity_Person] CHECK CONSTRAINT [FK_dbo.Activity_Person_dbo.Activities_ActivityID]
GO
ALTER TABLE [dbo].[Activity_Person]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Activity_Person_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Activity_Person] CHECK CONSTRAINT [FK_dbo.Activity_Person_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Addresses]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Addresses_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Addresses] CHECK CONSTRAINT [FK_dbo.Addresses_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Addresses]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Addresses_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[Addresses] CHECK CONSTRAINT [FK_dbo.Addresses_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[Addresses]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Addresses_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[Addresses] CHECK CONSTRAINT [FK_dbo.Addresses_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Assessment_EventTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assessment_EventTemplate_dbo.Assessments_AssessmentID] FOREIGN KEY([AssessmentID])
REFERENCES [dbo].[Assessments] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Assessment_EventTemplate] CHECK CONSTRAINT [FK_dbo.Assessment_EventTemplate_dbo.Assessments_AssessmentID]
GO
ALTER TABLE [dbo].[Assessment_EventTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assessment_EventTemplate_dbo.AssessmentScheduleParams_AssessmentScheduleParamsID] FOREIGN KEY([AssessmentScheduleParamsID])
REFERENCES [dbo].[AssessmentScheduleParams] ([ID])
GO
ALTER TABLE [dbo].[Assessment_EventTemplate] CHECK CONSTRAINT [FK_dbo.Assessment_EventTemplate_dbo.AssessmentScheduleParams_AssessmentScheduleParamsID]
GO
ALTER TABLE [dbo].[Assessment_EventTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assessment_EventTemplate_dbo.EventTemplates_EventTemplateID] FOREIGN KEY([EventTemplateID])
REFERENCES [dbo].[EventTemplates] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Assessment_EventTemplate] CHECK CONSTRAINT [FK_dbo.Assessment_EventTemplate_dbo.EventTemplates_EventTemplateID]
GO
ALTER TABLE [dbo].[Assessment_Resource]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assessment_Resource_dbo.Assessments_AssessmentID] FOREIGN KEY([AssessmentID])
REFERENCES [dbo].[Assessments] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Assessment_Resource] CHECK CONSTRAINT [FK_dbo.Assessment_Resource_dbo.Assessments_AssessmentID]
GO
ALTER TABLE [dbo].[Assessment_Resource]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assessment_Resource_dbo.Resources_ResourceID] FOREIGN KEY([ResourceID])
REFERENCES [dbo].[Resources] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Assessment_Resource] CHECK CONSTRAINT [FK_dbo.Assessment_Resource_dbo.Resources_ResourceID]
GO
ALTER TABLE [dbo].[Assessment_ScheduledEvent]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assessment_ScheduledEvent_dbo.Assessments_AssessmentID] FOREIGN KEY([AssessmentID])
REFERENCES [dbo].[Assessments] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Assessment_ScheduledEvent] CHECK CONSTRAINT [FK_dbo.Assessment_ScheduledEvent_dbo.Assessments_AssessmentID]
GO
ALTER TABLE [dbo].[Assessment_ScheduledEvent]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assessment_ScheduledEvent_dbo.AssessmentScheduleParams_AssessmentScheduleParamsID] FOREIGN KEY([AssessmentScheduleParamsID])
REFERENCES [dbo].[AssessmentScheduleParams] ([ID])
GO
ALTER TABLE [dbo].[Assessment_ScheduledEvent] CHECK CONSTRAINT [FK_dbo.Assessment_ScheduledEvent_dbo.AssessmentScheduleParams_AssessmentScheduleParamsID]
GO
ALTER TABLE [dbo].[Assessment_ScheduledEvent]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assessment_ScheduledEvent_dbo.AssessmentScheduleQueue_AssessmentScheduleQueueID] FOREIGN KEY([AssessmentScheduleQueueID])
REFERENCES [dbo].[AssessmentScheduleQueue] ([ID])
GO
ALTER TABLE [dbo].[Assessment_ScheduledEvent] CHECK CONSTRAINT [FK_dbo.Assessment_ScheduledEvent_dbo.AssessmentScheduleQueue_AssessmentScheduleQueueID]
GO
ALTER TABLE [dbo].[Assessment_ScheduledEvent]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assessment_ScheduledEvent_dbo.GradableItems_GradableItemID] FOREIGN KEY([GradableItemID])
REFERENCES [dbo].[GradableItems] ([ID])
GO
ALTER TABLE [dbo].[Assessment_ScheduledEvent] CHECK CONSTRAINT [FK_dbo.Assessment_ScheduledEvent_dbo.GradableItems_GradableItemID]
GO
ALTER TABLE [dbo].[Assessment_ScheduledEvent]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assessment_ScheduledEvent_dbo.Scheduled_Events_ScheduledEventID] FOREIGN KEY([ScheduledEventID])
REFERENCES [dbo].[Scheduled_Events] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Assessment_ScheduledEvent] CHECK CONSTRAINT [FK_dbo.Assessment_ScheduledEvent_dbo.Scheduled_Events_ScheduledEventID]
GO
ALTER TABLE [dbo].[AssessmentFormRow_Question]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssessmentFormRow_Question_dbo.AssessmentFormRows_AssessmentFormRowID] FOREIGN KEY([AssessmentFormRowID])
REFERENCES [dbo].[AssessmentFormRows] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssessmentFormRow_Question] CHECK CONSTRAINT [FK_dbo.AssessmentFormRow_Question_dbo.AssessmentFormRows_AssessmentFormRowID]
GO
ALTER TABLE [dbo].[AssessmentFormRow_Question]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssessmentFormRow_Question_dbo.Questions_QuestionID] FOREIGN KEY([QuestionID])
REFERENCES [dbo].[Questions] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssessmentFormRow_Question] CHECK CONSTRAINT [FK_dbo.AssessmentFormRow_Question_dbo.Questions_QuestionID]
GO
ALTER TABLE [dbo].[AssessmentFormRows]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssessmentFormRows_dbo.AssessmentFormSections_AssessmentFormSectionID] FOREIGN KEY([AssessmentFormSectionID])
REFERENCES [dbo].[AssessmentFormSections] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssessmentFormRows] CHECK CONSTRAINT [FK_dbo.AssessmentFormRows_dbo.AssessmentFormSections_AssessmentFormSectionID]
GO
ALTER TABLE [dbo].[AssessmentFormRows]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssessmentFormRows_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[AssessmentFormRows] CHECK CONSTRAINT [FK_dbo.AssessmentFormRows_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[AssessmentForms]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssessmentForms_dbo.Assessments_ID] FOREIGN KEY([ID])
REFERENCES [dbo].[Assessments] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssessmentForms] CHECK CONSTRAINT [FK_dbo.AssessmentForms_dbo.Assessments_ID]
GO
ALTER TABLE [dbo].[AssessmentFormSections]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssessmentFormSections_dbo.AssessmentForms_AssessmentFormID] FOREIGN KEY([AssessmentFormID])
REFERENCES [dbo].[AssessmentForms] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssessmentFormSections] CHECK CONSTRAINT [FK_dbo.AssessmentFormSections_dbo.AssessmentForms_AssessmentFormID]
GO
ALTER TABLE [dbo].[Assessments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Assessments_dbo.InteractiveContents_InteractiveContentID] FOREIGN KEY([InteractiveContentID])
REFERENCES [dbo].[InteractiveContents] ([ID])
GO
ALTER TABLE [dbo].[Assessments] CHECK CONSTRAINT [FK_dbo.Assessments_dbo.InteractiveContents_InteractiveContentID]
GO
ALTER TABLE [dbo].[AssignmentTemplate_EventTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssignmentTemplate_EventTemplate_dbo.AssignmentTemplates_AssignmentTemplateID] FOREIGN KEY([AssignmentTemplateID])
REFERENCES [dbo].[AssignmentTemplates] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssignmentTemplate_EventTemplate] CHECK CONSTRAINT [FK_dbo.AssignmentTemplate_EventTemplate_dbo.AssignmentTemplates_AssignmentTemplateID]
GO
ALTER TABLE [dbo].[AssignmentTemplate_EventTemplate]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssignmentTemplate_EventTemplate_dbo.EventTemplates_EventTemplateID] FOREIGN KEY([EventTemplateID])
REFERENCES [dbo].[EventTemplates] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssignmentTemplate_EventTemplate] CHECK CONSTRAINT [FK_dbo.AssignmentTemplate_EventTemplate_dbo.EventTemplates_EventTemplateID]
GO
ALTER TABLE [dbo].[AssignmentTemplate_LearningObjective]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssignmentTemplate_LearningObjective_dbo.AssignmentTemplates_AssignmentTemplateID] FOREIGN KEY([AssignmentTemplateID])
REFERENCES [dbo].[AssignmentTemplates] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssignmentTemplate_LearningObjective] CHECK CONSTRAINT [FK_dbo.AssignmentTemplate_LearningObjective_dbo.AssignmentTemplates_AssignmentTemplateID]
GO
ALTER TABLE [dbo].[AssignmentTemplate_LearningObjective]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssignmentTemplate_LearningObjective_dbo.LearningObjectives_LearningObjectiveID] FOREIGN KEY([LearningObjectiveID])
REFERENCES [dbo].[LearningObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssignmentTemplate_LearningObjective] CHECK CONSTRAINT [FK_dbo.AssignmentTemplate_LearningObjective_dbo.LearningObjectives_LearningObjectiveID]
GO
ALTER TABLE [dbo].[AssignmentTemplates]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssignmentTemplates_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[AssignmentTemplates] CHECK CONSTRAINT [FK_dbo.AssignmentTemplates_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[AssignmentTemplates]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssignmentTemplates_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[AssignmentTemplates] CHECK CONSTRAINT [FK_dbo.AssignmentTemplates_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[AssignmentTemplates]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssignmentTemplates_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[AssignmentTemplates] CHECK CONSTRAINT [FK_dbo.AssignmentTemplates_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[AssignmentUploads]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssignmentUploads_dbo.ExpectedUploads_ExpectedUploadID] FOREIGN KEY([ExpectedUploadID])
REFERENCES [dbo].[ExpectedUploads] ([ID])
GO
ALTER TABLE [dbo].[AssignmentUploads] CHECK CONSTRAINT [FK_dbo.AssignmentUploads_dbo.ExpectedUploads_ExpectedUploadID]
GO
ALTER TABLE [dbo].[AssignmentUploads]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssignmentUploads_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[AssignmentUploads] CHECK CONSTRAINT [FK_dbo.AssignmentUploads_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[AssignmentUploads]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssignmentUploads_dbo.ResourceAssets_ResourceAssetID] FOREIGN KEY([ResourceAssetID])
REFERENCES [dbo].[ResourceAssets] ([ID])
GO
ALTER TABLE [dbo].[AssignmentUploads] CHECK CONSTRAINT [FK_dbo.AssignmentUploads_dbo.ResourceAssets_ResourceAssetID]
GO
ALTER TABLE [dbo].[AssignmentUploads]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AssignmentUploads_dbo.ScheduledAssignments_ScheduledAssignmentID] FOREIGN KEY([ScheduledAssignmentID])
REFERENCES [dbo].[ScheduledAssignments] ([ID])
GO
ALTER TABLE [dbo].[AssignmentUploads] CHECK CONSTRAINT [FK_dbo.AssignmentUploads_dbo.ScheduledAssignments_ScheduledAssignmentID]
GO
ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.Course_People_CoursePersonID] FOREIGN KEY([CoursePersonID])
REFERENCES [dbo].[Course_People] ([ID])
GO
ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.Course_People_CoursePersonID]
GO
ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.People_RecordedByPersonID] FOREIGN KEY([RecordedByPersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.People_RecordedByPersonID]
GO
ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.Seminar_People_SeminarPersonID] FOREIGN KEY([SeminarPersonID])
REFERENCES [dbo].[Seminar_People] ([ID])
GO
ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.Seminar_People_SeminarPersonID]
GO
ALTER TABLE [dbo].[AuditReferences]  WITH NOCHECK ADD  CONSTRAINT [FK_dbo.AuditReferences_dbo.Audits_AuditID] FOREIGN KEY([AuditID])
REFERENCES [dbo].[Audits] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AuditReferences] CHECK CONSTRAINT [FK_dbo.AuditReferences_dbo.Audits_AuditID]
GO
ALTER TABLE [dbo].[AuditValues]  WITH NOCHECK ADD  CONSTRAINT [FK_dbo.AuditValues_dbo.Audits_AuditID] FOREIGN KEY([AuditID])
REFERENCES [dbo].[Audits] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AuditValues] CHECK CONSTRAINT [FK_dbo.AuditValues_dbo.Audits_AuditID]
GO
ALTER TABLE [dbo].[BackgroundTasks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BackgroundTasks_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[BackgroundTasks] CHECK CONSTRAINT [FK_dbo.BackgroundTasks_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[BackgroundTasks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.BackgroundTasks_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BackgroundTasks] CHECK CONSTRAINT [FK_dbo.BackgroundTasks_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Calendar_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Calendar_People_dbo.Calendars_CalendarID] FOREIGN KEY([CalendarID])
REFERENCES [dbo].[Calendars] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Calendar_People] CHECK CONSTRAINT [FK_dbo.Calendar_People_dbo.Calendars_CalendarID]
GO
ALTER TABLE [dbo].[Calendar_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Calendar_People_dbo.Course_People_CoursePersonID] FOREIGN KEY([CoursePersonID])
REFERENCES [dbo].[Course_People] ([ID])
GO
ALTER TABLE [dbo].[Calendar_People] CHECK CONSTRAINT [FK_dbo.Calendar_People_dbo.Course_People_CoursePersonID]
GO
ALTER TABLE [dbo].[Calendar_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Calendar_People_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[Calendar_People] CHECK CONSTRAINT [FK_dbo.Calendar_People_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Calendars]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Calendars_dbo.Courses_CourseID] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Calendars] CHECK CONSTRAINT [FK_dbo.Calendars_dbo.Courses_CourseID]
GO
ALTER TABLE [dbo].[Client_Organization]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Client_Organization_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Client_Organization] CHECK CONSTRAINT [FK_dbo.Client_Organization_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Client_Organization]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Client_Organization_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Client_Organization] CHECK CONSTRAINT [FK_dbo.Client_Organization_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[ClientNotificationPersons]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ClientNotificationPersons_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[ClientNotificationPersons] CHECK CONSTRAINT [FK_dbo.ClientNotificationPersons_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[ClientNotificationPersons]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ClientNotificationPersons_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ClientNotificationPersons] CHECK CONSTRAINT [FK_dbo.ClientNotificationPersons_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Clients]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Clients_dbo.Clients_ParentClientID] FOREIGN KEY([ParentClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Clients] CHECK CONSTRAINT [FK_dbo.Clients_dbo.Clients_ParentClientID]
GO
ALTER TABLE [dbo].[Clients]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Clients_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[Clients] CHECK CONSTRAINT [FK_dbo.Clients_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[ContinuingEducationHistory]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ContinuingEducationHistory_dbo.Degree_People_DegreePersonID] FOREIGN KEY([DegreePersonID])
REFERENCES [dbo].[Degree_People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContinuingEducationHistory] CHECK CONSTRAINT [FK_dbo.ContinuingEducationHistory_dbo.Degree_People_DegreePersonID]
GO
ALTER TABLE [dbo].[ContinuingEducationRequirements]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ContinuingEducationRequirements_Configuration.RenewalFrequencyTypes_RenewalFrequencyID] FOREIGN KEY([RenewalFrequencyID])
REFERENCES [Configuration].[RenewalFrequencyTypes] ([ID])
GO
ALTER TABLE [dbo].[ContinuingEducationRequirements] CHECK CONSTRAINT [FK_dbo.ContinuingEducationRequirements_Configuration.RenewalFrequencyTypes_RenewalFrequencyID]
GO
ALTER TABLE [dbo].[CoreCompetencies]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CoreCompetencies_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[CoreCompetencies] CHECK CONSTRAINT [FK_dbo.CoreCompetencies_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[CoreCompetencies]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CoreCompetencies_dbo.Clients_OwnerClientID] FOREIGN KEY([OwnerClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[CoreCompetencies] CHECK CONSTRAINT [FK_dbo.CoreCompetencies_dbo.Clients_OwnerClientID]
GO
ALTER TABLE [dbo].[CoreCompetencies]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CoreCompetencies_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[CoreCompetencies] CHECK CONSTRAINT [FK_dbo.CoreCompetencies_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[CoreCompetency_Degree]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CoreCompetency_Degree_dbo.CoreCompetencies_CoreCompetencyID] FOREIGN KEY([CoreCompetencyID])
REFERENCES [dbo].[CoreCompetencies] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CoreCompetency_Degree] CHECK CONSTRAINT [FK_dbo.CoreCompetency_Degree_dbo.CoreCompetencies_CoreCompetencyID]
GO
ALTER TABLE [dbo].[CoreCompetency_Degree]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CoreCompetency_Degree_dbo.Degrees_DegreeID] FOREIGN KEY([DegreeID])
REFERENCES [dbo].[Degrees] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CoreCompetency_Degree] CHECK CONSTRAINT [FK_dbo.CoreCompetency_Degree_dbo.Degrees_DegreeID]
GO
ALTER TABLE [dbo].[CoreCompetency_ProgramObjective]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CoreCompetency_ProgramObjective_dbo.CoreCompetencies_CoreCompetencyID] FOREIGN KEY([CoreCompetencyID])
REFERENCES [dbo].[CoreCompetencies] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CoreCompetency_ProgramObjective] CHECK CONSTRAINT [FK_dbo.CoreCompetency_ProgramObjective_dbo.CoreCompetencies_CoreCompetencyID]
GO
ALTER TABLE [dbo].[CoreCompetency_ProgramObjective]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CoreCompetency_ProgramObjective_dbo.ProgramObjectives_ProgramObjectiveID] FOREIGN KEY([ProgramObjectiveID])
REFERENCES [dbo].[ProgramObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CoreCompetency_ProgramObjective] CHECK CONSTRAINT [FK_dbo.CoreCompetency_ProgramObjective_dbo.ProgramObjectives_ProgramObjectiveID]
GO
ALTER TABLE [dbo].[Course_DirectObservation]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Course_DirectObservation_dbo.Courses_CourseID] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Course_DirectObservation] CHECK CONSTRAINT [FK_dbo.Course_DirectObservation_dbo.Courses_CourseID]
GO
ALTER TABLE [dbo].[Course_DirectObservation]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Course_DirectObservation_dbo.DirectObservations_DirectObservationID] FOREIGN KEY([DirectObservationID])
REFERENCES [dbo].[DirectObservations] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Course_DirectObservation] CHECK CONSTRAINT [FK_dbo.Course_DirectObservation_dbo.DirectObservations_DirectObservationID]
GO
ALTER TABLE [dbo].[Course_LogRequirement]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Course_LogRequirement_dbo.Courses_CourseID] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Course_LogRequirement] CHECK CONSTRAINT [FK_dbo.Course_LogRequirement_dbo.Courses_CourseID]
GO
ALTER TABLE [dbo].[Course_LogRequirement]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Course_LogRequirement_dbo.LogRequirements_LogRequirementID] FOREIGN KEY([LogRequirementID])
REFERENCES [dbo].[LogRequirements] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Course_LogRequirement] CHECK CONSTRAINT [FK_dbo.Course_LogRequirement_dbo.LogRequirements_LogRequirementID]
GO
ALTER TABLE [dbo].[Course_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Course_People_dbo.Courses_CourseID] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Course_People] CHECK CONSTRAINT [FK_dbo.Course_People_dbo.Courses_CourseID]
GO
ALTER TABLE [dbo].[Course_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Course_People_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Course_People] CHECK CONSTRAINT [FK_dbo.Course_People_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Course_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Course_People_dbo.SchedulingRounds_SchedulingRoundID] FOREIGN KEY([SchedulingRoundID])
REFERENCES [dbo].[SchedulingRounds] ([ID])
GO
ALTER TABLE [dbo].[Course_People] CHECK CONSTRAINT [FK_dbo.Course_People_dbo.SchedulingRounds_SchedulingRoundID]
GO
ALTER TABLE [dbo].[Course_Seminar]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Course_Seminar_dbo.Courses_CourseID] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Course_Seminar] CHECK CONSTRAINT [FK_dbo.Course_Seminar_dbo.Courses_CourseID]
GO
ALTER TABLE [dbo].[Course_Seminar]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Course_Seminar_dbo.Seminars_SeminarID] FOREIGN KEY([SeminarID])
REFERENCES [dbo].[Seminars] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Course_Seminar] CHECK CONSTRAINT [FK_dbo.Course_Seminar_dbo.Seminars_SeminarID]
GO
ALTER TABLE [dbo].[Course_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Course_Tag_dbo.Courses_CourseID] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Course_Tag] CHECK CONSTRAINT [FK_dbo.Course_Tag_dbo.Courses_CourseID]
GO
ALTER TABLE [dbo].[Course_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Course_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Course_Tag] CHECK CONSTRAINT [FK_dbo.Course_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[Course_WaitListPerson]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Course_WaitListPerson_dbo.Courses_CourseID] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Course_WaitListPerson] CHECK CONSTRAINT [FK_dbo.Course_WaitListPerson_dbo.Courses_CourseID]
GO
ALTER TABLE [dbo].[Course_WaitListPerson]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Course_WaitListPerson_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Course_WaitListPerson] CHECK CONSTRAINT [FK_dbo.Course_WaitListPerson_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[CourseCatalog_CourseOverview]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseCatalog_CourseOverview_dbo.CourseCatalogs_CourseCatalogID] FOREIGN KEY([CourseCatalogID])
REFERENCES [dbo].[CourseCatalogs] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseCatalog_CourseOverview] CHECK CONSTRAINT [FK_dbo.CourseCatalog_CourseOverview_dbo.CourseCatalogs_CourseCatalogID]
GO
ALTER TABLE [dbo].[CourseCatalog_CourseOverview]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseCatalog_CourseOverview_dbo.CourseOverviews_CourseOverviewID] FOREIGN KEY([CourseOverviewID])
REFERENCES [dbo].[CourseOverviews] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseCatalog_CourseOverview] CHECK CONSTRAINT [FK_dbo.CourseCatalog_CourseOverview_dbo.CourseOverviews_CourseOverviewID]
GO
ALTER TABLE [dbo].[CourseCatalog_Person]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseCatalog_Person_dbo.CourseCatalogs_CourseCatalogID] FOREIGN KEY([CourseCatalogID])
REFERENCES [dbo].[CourseCatalogs] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseCatalog_Person] CHECK CONSTRAINT [FK_dbo.CourseCatalog_Person_dbo.CourseCatalogs_CourseCatalogID]
GO
ALTER TABLE [dbo].[CourseCatalog_Person]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseCatalog_Person_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseCatalog_Person] CHECK CONSTRAINT [FK_dbo.CourseCatalog_Person_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[CourseCatalog_SchedulingSession]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseCatalog_SchedulingSession_dbo.CourseCatalogs_CourseCatalogID] FOREIGN KEY([CourseCatalogID])
REFERENCES [dbo].[CourseCatalogs] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseCatalog_SchedulingSession] CHECK CONSTRAINT [FK_dbo.CourseCatalog_SchedulingSession_dbo.CourseCatalogs_CourseCatalogID]
GO
ALTER TABLE [dbo].[CourseCatalog_SchedulingSession]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseCatalog_SchedulingSession_dbo.SchedulingSessions_SchedulingSessionID] FOREIGN KEY([SchedulingSessionID])
REFERENCES [dbo].[SchedulingSessions] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseCatalog_SchedulingSession] CHECK CONSTRAINT [FK_dbo.CourseCatalog_SchedulingSession_dbo.SchedulingSessions_SchedulingSessionID]
GO
ALTER TABLE [dbo].[CourseCatalogs]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseCatalogs_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[CourseCatalogs] CHECK CONSTRAINT [FK_dbo.CourseCatalogs_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[CourseCatalogs]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseCatalogs_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[CourseCatalogs] CHECK CONSTRAINT [FK_dbo.CourseCatalogs_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[CourseObjective_CourseOverview]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseObjective_CourseOverview_dbo.CourseObjectives_CourseObjectiveID] FOREIGN KEY([CourseObjectiveID])
REFERENCES [dbo].[CourseObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseObjective_CourseOverview] CHECK CONSTRAINT [FK_dbo.CourseObjective_CourseOverview_dbo.CourseObjectives_CourseObjectiveID]
GO
ALTER TABLE [dbo].[CourseObjective_CourseOverview]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseObjective_CourseOverview_dbo.CourseOverviews_CourseOverviewID] FOREIGN KEY([CourseOverviewID])
REFERENCES [dbo].[CourseOverviews] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseObjective_CourseOverview] CHECK CONSTRAINT [FK_dbo.CourseObjective_CourseOverview_dbo.CourseOverviews_CourseOverviewID]
GO
ALTER TABLE [dbo].[CourseObjective_LearningObjective]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseObjective_LearningObjective_dbo.CourseObjectives_CourseObjectiveID] FOREIGN KEY([CourseObjectiveID])
REFERENCES [dbo].[CourseObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseObjective_LearningObjective] CHECK CONSTRAINT [FK_dbo.CourseObjective_LearningObjective_dbo.CourseObjectives_CourseObjectiveID]
GO
ALTER TABLE [dbo].[CourseObjective_LearningObjective]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseObjective_LearningObjective_dbo.LearningObjectives_LearningObjectiveID] FOREIGN KEY([LearningObjectiveID])
REFERENCES [dbo].[LearningObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseObjective_LearningObjective] CHECK CONSTRAINT [FK_dbo.CourseObjective_LearningObjective_dbo.LearningObjectives_LearningObjectiveID]
GO
ALTER TABLE [dbo].[CourseObjective_LevelOfLearning]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseObjective_LevelOfLearning_Configuration.LevelsOfLearning_LevelOfLearningID] FOREIGN KEY([LevelOfLearningID])
REFERENCES [Configuration].[LevelsOfLearning] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseObjective_LevelOfLearning] CHECK CONSTRAINT [FK_dbo.CourseObjective_LevelOfLearning_Configuration.LevelsOfLearning_LevelOfLearningID]
GO
ALTER TABLE [dbo].[CourseObjective_LevelOfLearning]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseObjective_LevelOfLearning_dbo.CourseObjectives_CourseObjectiveID] FOREIGN KEY([CourseObjectiveID])
REFERENCES [dbo].[CourseObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseObjective_LevelOfLearning] CHECK CONSTRAINT [FK_dbo.CourseObjective_LevelOfLearning_dbo.CourseObjectives_CourseObjectiveID]
GO
ALTER TABLE [dbo].[CourseObjective_ProgramObjective]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseObjective_ProgramObjective_dbo.CourseObjectives_CourseObjectiveID] FOREIGN KEY([CourseObjectiveID])
REFERENCES [dbo].[CourseObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseObjective_ProgramObjective] CHECK CONSTRAINT [FK_dbo.CourseObjective_ProgramObjective_dbo.CourseObjectives_CourseObjectiveID]
GO
ALTER TABLE [dbo].[CourseObjective_ProgramObjective]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseObjective_ProgramObjective_dbo.ProgramObjectives_ProgramObjectiveID] FOREIGN KEY([ProgramObjectiveID])
REFERENCES [dbo].[ProgramObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseObjective_ProgramObjective] CHECK CONSTRAINT [FK_dbo.CourseObjective_ProgramObjective_dbo.ProgramObjectives_ProgramObjectiveID]
GO
ALTER TABLE [dbo].[CourseObjective_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseObjective_Tag_dbo.CourseObjectives_CourseObjectiveID] FOREIGN KEY([CourseObjectiveID])
REFERENCES [dbo].[CourseObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseObjective_Tag] CHECK CONSTRAINT [FK_dbo.CourseObjective_Tag_dbo.CourseObjectives_CourseObjectiveID]
GO
ALTER TABLE [dbo].[CourseObjective_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseObjective_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseObjective_Tag] CHECK CONSTRAINT [FK_dbo.CourseObjective_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[CourseObjectives]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseObjectives_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[CourseObjectives] CHECK CONSTRAINT [FK_dbo.CourseObjectives_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[CourseObjectives]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseObjectives_dbo.Clients_OwnerClientID] FOREIGN KEY([OwnerClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[CourseObjectives] CHECK CONSTRAINT [FK_dbo.CourseObjectives_dbo.Clients_OwnerClientID]
GO
ALTER TABLE [dbo].[CourseObjectives]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseObjectives_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[CourseObjectives] CHECK CONSTRAINT [FK_dbo.CourseObjectives_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[CourseOverview_LevelOfLearning]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseOverview_LevelOfLearning_Configuration.LevelsOfLearning_LevelOfLearningID] FOREIGN KEY([LevelOfLearningID])
REFERENCES [Configuration].[LevelsOfLearning] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseOverview_LevelOfLearning] CHECK CONSTRAINT [FK_dbo.CourseOverview_LevelOfLearning_Configuration.LevelsOfLearning_LevelOfLearningID]
GO
ALTER TABLE [dbo].[CourseOverview_LevelOfLearning]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseOverview_LevelOfLearning_dbo.CourseOverviews_CourseOverviewID] FOREIGN KEY([CourseOverviewID])
REFERENCES [dbo].[CourseOverviews] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseOverview_LevelOfLearning] CHECK CONSTRAINT [FK_dbo.CourseOverview_LevelOfLearning_dbo.CourseOverviews_CourseOverviewID]
GO
ALTER TABLE [dbo].[CourseOverview_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseOverview_Tag_dbo.CourseOverviews_CourseOverviewID] FOREIGN KEY([CourseOverviewID])
REFERENCES [dbo].[CourseOverviews] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseOverview_Tag] CHECK CONSTRAINT [FK_dbo.CourseOverview_Tag_dbo.CourseOverviews_CourseOverviewID]
GO
ALTER TABLE [dbo].[CourseOverview_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseOverview_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseOverview_Tag] CHECK CONSTRAINT [FK_dbo.CourseOverview_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[CourseOverviews]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseOverviews_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[CourseOverviews] CHECK CONSTRAINT [FK_dbo.CourseOverviews_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[CourseOverviews]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CourseOverviews_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[CourseOverviews] CHECK CONSTRAINT [FK_dbo.CourseOverviews_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[CoursePerson_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CoursePerson_Tag_dbo.Course_People_CoursePersonID] FOREIGN KEY([CoursePersonID])
REFERENCES [dbo].[Course_People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CoursePerson_Tag] CHECK CONSTRAINT [FK_dbo.CoursePerson_Tag_dbo.Course_People_CoursePersonID]
GO
ALTER TABLE [dbo].[CoursePerson_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CoursePerson_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CoursePerson_Tag] CHECK CONSTRAINT [FK_dbo.CoursePerson_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Courses_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [FK_dbo.Courses_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Courses_dbo.CourseOverviews_CourseOverviewID] FOREIGN KEY([CourseOverviewID])
REFERENCES [dbo].[CourseOverviews] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [FK_dbo.Courses_dbo.CourseOverviews_CourseOverviewID]
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Courses_dbo.GradeBooks_GradeBookID] FOREIGN KEY([GradeBookID])
REFERENCES [dbo].[GradeBooks] ([ID])
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [FK_dbo.Courses_dbo.GradeBooks_GradeBookID]
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Courses_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [FK_dbo.Courses_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Courses_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [FK_dbo.Courses_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[Degree_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Degree_People_dbo.ContinuingEducationHistory_NextRequiredContinuingEducationRenewalID] FOREIGN KEY([NextRequiredContinuingEducationRenewalID])
REFERENCES [dbo].[ContinuingEducationHistory] ([ID])
GO
ALTER TABLE [dbo].[Degree_People] CHECK CONSTRAINT [FK_dbo.Degree_People_dbo.ContinuingEducationHistory_NextRequiredContinuingEducationRenewalID]
GO
ALTER TABLE [dbo].[Degree_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Degree_People_dbo.Degrees_DegreeID] FOREIGN KEY([DegreeID])
REFERENCES [dbo].[Degrees] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Degree_People] CHECK CONSTRAINT [FK_dbo.Degree_People_dbo.Degrees_DegreeID]
GO
ALTER TABLE [dbo].[Degree_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Degree_People_dbo.People_Payments_PersonPaymentID] FOREIGN KEY([PersonPaymentID])
REFERENCES [dbo].[People_Payments] ([ID])
GO
ALTER TABLE [dbo].[Degree_People] CHECK CONSTRAINT [FK_dbo.Degree_People_dbo.People_Payments_PersonPaymentID]
GO
ALTER TABLE [dbo].[Degree_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Degree_People_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Degree_People] CHECK CONSTRAINT [FK_dbo.Degree_People_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Degree_Seminar]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Degree_Seminar_dbo.Degrees_DegreeID] FOREIGN KEY([DegreeID])
REFERENCES [dbo].[Degrees] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Degree_Seminar] CHECK CONSTRAINT [FK_dbo.Degree_Seminar_dbo.Degrees_DegreeID]
GO
ALTER TABLE [dbo].[Degree_Seminar]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Degree_Seminar_dbo.Seminars_SeminarID] FOREIGN KEY([SeminarID])
REFERENCES [dbo].[Seminars] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Degree_Seminar] CHECK CONSTRAINT [FK_dbo.Degree_Seminar_dbo.Seminars_SeminarID]
GO
ALTER TABLE [dbo].[DegreeGroupDegreeTracks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeGroupDegreeTracks_dbo.DegreeGroups_DegreeGroupID] FOREIGN KEY([DegreeGroupID])
REFERENCES [dbo].[DegreeGroups] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DegreeGroupDegreeTracks] CHECK CONSTRAINT [FK_dbo.DegreeGroupDegreeTracks_dbo.DegreeGroups_DegreeGroupID]
GO
ALTER TABLE [dbo].[DegreeGroupDegreeTracks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeGroupDegreeTracks_dbo.DegreeTracks_DegreeTrackID] FOREIGN KEY([DegreeTrackID])
REFERENCES [dbo].[DegreeTracks] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DegreeGroupDegreeTracks] CHECK CONSTRAINT [FK_dbo.DegreeGroupDegreeTracks_dbo.DegreeTracks_DegreeTrackID]
GO
ALTER TABLE [dbo].[DegreeGroups]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeGroups_dbo.ContinuingEducationRequirements_ContinuingEducationRequirementsID] FOREIGN KEY([ContinuingEducationRequirementsID])
REFERENCES [dbo].[ContinuingEducationRequirements] ([ID])
GO
ALTER TABLE [dbo].[DegreeGroups] CHECK CONSTRAINT [FK_dbo.DegreeGroups_dbo.ContinuingEducationRequirements_ContinuingEducationRequirementsID]
GO
ALTER TABLE [dbo].[DegreeGroups]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeGroups_dbo.Degrees_DegreeID] FOREIGN KEY([DegreeID])
REFERENCES [dbo].[Degrees] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DegreeGroups] CHECK CONSTRAINT [FK_dbo.DegreeGroups_dbo.Degrees_DegreeID]
GO
ALTER TABLE [dbo].[Degrees]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Degrees_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Degrees] CHECK CONSTRAINT [FK_dbo.Degrees_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Degrees]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Degrees_dbo.ContinuingEducationRequirements_ContinuingEducationRequirementsID] FOREIGN KEY([ContinuingEducationRequirementsID])
REFERENCES [dbo].[ContinuingEducationRequirements] ([ID])
GO
ALTER TABLE [dbo].[Degrees] CHECK CONSTRAINT [FK_dbo.Degrees_dbo.ContinuingEducationRequirements_ContinuingEducationRequirementsID]
GO
ALTER TABLE [dbo].[Degrees]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Degrees_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[Degrees] CHECK CONSTRAINT [FK_dbo.Degrees_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[Degrees]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Degrees_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[Degrees] CHECK CONSTRAINT [FK_dbo.Degrees_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Degrees]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Degrees_dbo.People_PrimarySignatoryID] FOREIGN KEY([PrimarySignatoryID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[Degrees] CHECK CONSTRAINT [FK_dbo.Degrees_dbo.People_PrimarySignatoryID]
GO
ALTER TABLE [dbo].[Degrees]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Degrees_dbo.People_SecondarySignatoryID] FOREIGN KEY([SecondarySignatoryID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[Degrees] CHECK CONSTRAINT [FK_dbo.Degrees_dbo.People_SecondarySignatoryID]
GO
ALTER TABLE [dbo].[Degrees]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Degrees_dbo.ResourceAssets_ImageResourceAssetID] FOREIGN KEY([ImageResourceAssetID])
REFERENCES [dbo].[ResourceAssets] ([ID])
GO
ALTER TABLE [dbo].[Degrees] CHECK CONSTRAINT [FK_dbo.Degrees_dbo.ResourceAssets_ImageResourceAssetID]
GO
ALTER TABLE [dbo].[DegreeTrack_LevelOfLearning]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeTrack_LevelOfLearning_Configuration.LevelsOfLearning_LevelOfLearningID] FOREIGN KEY([LevelOfLearningID])
REFERENCES [Configuration].[LevelsOfLearning] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DegreeTrack_LevelOfLearning] CHECK CONSTRAINT [FK_dbo.DegreeTrack_LevelOfLearning_Configuration.LevelsOfLearning_LevelOfLearningID]
GO
ALTER TABLE [dbo].[DegreeTrack_LevelOfLearning]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeTrack_LevelOfLearning_dbo.DegreeTracks_DegreeTrackID] FOREIGN KEY([DegreeTrackID])
REFERENCES [dbo].[DegreeTracks] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DegreeTrack_LevelOfLearning] CHECK CONSTRAINT [FK_dbo.DegreeTrack_LevelOfLearning_dbo.DegreeTracks_DegreeTrackID]
GO
ALTER TABLE [dbo].[DegreeTrackCourseUsage_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeTrackCourseUsage_Tag_dbo.DegreeTrackCourseUsages_DegreeTrackCourseUsageID] FOREIGN KEY([DegreeTrackCourseUsageID])
REFERENCES [dbo].[DegreeTrackCourseUsages] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DegreeTrackCourseUsage_Tag] CHECK CONSTRAINT [FK_dbo.DegreeTrackCourseUsage_Tag_dbo.DegreeTrackCourseUsages_DegreeTrackCourseUsageID]
GO
ALTER TABLE [dbo].[DegreeTrackCourseUsage_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeTrackCourseUsage_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DegreeTrackCourseUsage_Tag] CHECK CONSTRAINT [FK_dbo.DegreeTrackCourseUsage_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[DegreeTrackCourseUsages]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeTrackCourseUsages_dbo.DegreeTrackGroups_DegreeTrackGroupID] FOREIGN KEY([DegreeTrackGroupID])
REFERENCES [dbo].[DegreeTrackGroups] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DegreeTrackCourseUsages] CHECK CONSTRAINT [FK_dbo.DegreeTrackCourseUsages_dbo.DegreeTrackGroups_DegreeTrackGroupID]
GO
ALTER TABLE [dbo].[DegreeTrackGroups]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeTrackGroups_dbo.ContinuingEducationRequirements_ContinuingEducationRequirementsID] FOREIGN KEY([ContinuingEducationRequirementsID])
REFERENCES [dbo].[ContinuingEducationRequirements] ([ID])
GO
ALTER TABLE [dbo].[DegreeTrackGroups] CHECK CONSTRAINT [FK_dbo.DegreeTrackGroups_dbo.ContinuingEducationRequirements_ContinuingEducationRequirementsID]
GO
ALTER TABLE [dbo].[DegreeTrackGroups]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeTrackGroups_dbo.Degrees_DegreeID] FOREIGN KEY([DegreeID])
REFERENCES [dbo].[Degrees] ([ID])
GO
ALTER TABLE [dbo].[DegreeTrackGroups] CHECK CONSTRAINT [FK_dbo.DegreeTrackGroups_dbo.Degrees_DegreeID]
GO
ALTER TABLE [dbo].[DegreeTrackGroups]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeTrackGroups_dbo.DegreeTracks_DegreeTrackID] FOREIGN KEY([DegreeTrackID])
REFERENCES [dbo].[DegreeTracks] ([ID])
GO
ALTER TABLE [dbo].[DegreeTrackGroups] CHECK CONSTRAINT [FK_dbo.DegreeTrackGroups_dbo.DegreeTracks_DegreeTrackID]
GO
ALTER TABLE [dbo].[DegreeTrackGroups]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeTrackGroups_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
GO
ALTER TABLE [dbo].[DegreeTrackGroups] CHECK CONSTRAINT [FK_dbo.DegreeTrackGroups_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[DegreeTracks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeTracks_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[DegreeTracks] CHECK CONSTRAINT [FK_dbo.DegreeTracks_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[DegreeTracks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DegreeTracks_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[DegreeTracks] CHECK CONSTRAINT [FK_dbo.DegreeTracks_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[DirectObservation_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DirectObservation_Tag_dbo.DirectObservations_DirectObservationID] FOREIGN KEY([DirectObservationID])
REFERENCES [dbo].[DirectObservations] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DirectObservation_Tag] CHECK CONSTRAINT [FK_dbo.DirectObservation_Tag_dbo.DirectObservations_DirectObservationID]
GO
ALTER TABLE [dbo].[DirectObservation_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DirectObservation_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DirectObservation_Tag] CHECK CONSTRAINT [FK_dbo.DirectObservation_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[DirectObservations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DirectObservations_Configuration.DirectObservationTypes_DirectObservationTypeID] FOREIGN KEY([DirectObservationTypeID])
REFERENCES [Configuration].[DirectObservationTypes] ([ID])
GO
ALTER TABLE [dbo].[DirectObservations] CHECK CONSTRAINT [FK_dbo.DirectObservations_Configuration.DirectObservationTypes_DirectObservationTypeID]
GO
ALTER TABLE [dbo].[DirectObservations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DirectObservations_dbo.Assessments_ID] FOREIGN KEY([ID])
REFERENCES [dbo].[Assessments] ([ID])
GO
ALTER TABLE [dbo].[DirectObservations] CHECK CONSTRAINT [FK_dbo.DirectObservations_dbo.Assessments_ID]
GO
ALTER TABLE [dbo].[DirectObservations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DirectObservations_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[DirectObservations] CHECK CONSTRAINT [FK_dbo.DirectObservations_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[DirectObservations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DirectObservations_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[DirectObservations] CHECK CONSTRAINT [FK_dbo.DirectObservations_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[DirectObservations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.DirectObservations_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[DirectObservations] CHECK CONSTRAINT [FK_dbo.DirectObservations_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[Emails]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Emails_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[Emails] CHECK CONSTRAINT [FK_dbo.Emails_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[Emails]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Emails_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[Emails] CHECK CONSTRAINT [FK_dbo.Emails_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[EnrollCourses]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EnrollCourses_dbo.EnrollDegrees_EnrollDegreeID] FOREIGN KEY([EnrollDegreeID])
REFERENCES [dbo].[EnrollDegrees] ([ID])
GO
ALTER TABLE [dbo].[EnrollCourses] CHECK CONSTRAINT [FK_dbo.EnrollCourses_dbo.EnrollDegrees_EnrollDegreeID]
GO
ALTER TABLE [dbo].[EnrollCourseUsages]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EnrollCourseUsages_dbo.EnrollCourses_EnrollCourseID] FOREIGN KEY([EnrollCourseID])
REFERENCES [dbo].[EnrollCourses] ([ID])
GO
ALTER TABLE [dbo].[EnrollCourseUsages] CHECK CONSTRAINT [FK_dbo.EnrollCourseUsages_dbo.EnrollCourses_EnrollCourseID]
GO
ALTER TABLE [dbo].[EnrollCourseUsages]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EnrollCourseUsages_dbo.People_Payments_PersonPaymentID] FOREIGN KEY([PersonPaymentID])
REFERENCES [dbo].[People_Payments] ([ID])
GO
ALTER TABLE [dbo].[EnrollCourseUsages] CHECK CONSTRAINT [FK_dbo.EnrollCourseUsages_dbo.People_Payments_PersonPaymentID]
GO
ALTER TABLE [dbo].[EnrollDegrees]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EnrollDegrees_dbo.People_Payments_PersonPaymentID] FOREIGN KEY([PersonPaymentID])
REFERENCES [dbo].[People_Payments] ([ID])
GO
ALTER TABLE [dbo].[EnrollDegrees] CHECK CONSTRAINT [FK_dbo.EnrollDegrees_dbo.People_Payments_PersonPaymentID]
GO
ALTER TABLE [dbo].[EntityType_Report]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EntityType_Report_dbo.Reports_ReportID] FOREIGN KEY([ReportID])
REFERENCES [dbo].[Reports] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EntityType_Report] CHECK CONSTRAINT [FK_dbo.EntityType_Report_dbo.Reports_ReportID]
GO
ALTER TABLE [dbo].[EntityType_Report]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EntityType_Report_Reference.EntityTypes_EntityTypeID] FOREIGN KEY([EntityTypeID])
REFERENCES [Reference].[EntityTypes] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EntityType_Report] CHECK CONSTRAINT [FK_dbo.EntityType_Report_Reference.EntityTypes_EntityTypeID]
GO
ALTER TABLE [dbo].[EntityType_TagCategory]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EntityType_TagCategory_dbo.TagCategories_TagCategoryID] FOREIGN KEY([TagCategoryID])
REFERENCES [dbo].[TagCategories] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EntityType_TagCategory] CHECK CONSTRAINT [FK_dbo.EntityType_TagCategory_dbo.TagCategories_TagCategoryID]
GO
ALTER TABLE [dbo].[EntityType_TagCategory]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EntityType_TagCategory_Reference.EntityTypes_EntityTypeID] FOREIGN KEY([EntityTypeID])
REFERENCES [Reference].[EntityTypes] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EntityType_TagCategory] CHECK CONSTRAINT [FK_dbo.EntityType_TagCategory_Reference.EntityTypes_EntityTypeID]
GO
ALTER TABLE [dbo].[Evaluation_Resource]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Evaluation_Resource_dbo.AssessmentScheduleParams_AssessmentScheduleParamsID] FOREIGN KEY([AssessmentScheduleParamsID])
REFERENCES [dbo].[AssessmentScheduleParams] ([ID])
GO
ALTER TABLE [dbo].[Evaluation_Resource] CHECK CONSTRAINT [FK_dbo.Evaluation_Resource_dbo.AssessmentScheduleParams_AssessmentScheduleParamsID]
GO
ALTER TABLE [dbo].[Evaluation_Resource]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Evaluation_Resource_dbo.Evaluations_EvaluationID] FOREIGN KEY([EvaluationID])
REFERENCES [dbo].[Evaluations] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Evaluation_Resource] CHECK CONSTRAINT [FK_dbo.Evaluation_Resource_dbo.Evaluations_EvaluationID]
GO
ALTER TABLE [dbo].[Evaluation_Resource]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Evaluation_Resource_dbo.Resources_ResourceID] FOREIGN KEY([ResourceID])
REFERENCES [dbo].[Resources] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Evaluation_Resource] CHECK CONSTRAINT [FK_dbo.Evaluation_Resource_dbo.Resources_ResourceID]
GO
ALTER TABLE [dbo].[Evaluation_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Evaluation_Tag_dbo.Evaluations_EvaluationID] FOREIGN KEY([EvaluationID])
REFERENCES [dbo].[Evaluations] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Evaluation_Tag] CHECK CONSTRAINT [FK_dbo.Evaluation_Tag_dbo.Evaluations_EvaluationID]
GO
ALTER TABLE [dbo].[Evaluation_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Evaluation_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Evaluation_Tag] CHECK CONSTRAINT [FK_dbo.Evaluation_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[Evaluations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Evaluations_Configuration.EvaluationTypes_EvaluationTypeID] FOREIGN KEY([EvaluationTypeID])
REFERENCES [Configuration].[EvaluationTypes] ([ID])
GO
ALTER TABLE [dbo].[Evaluations] CHECK CONSTRAINT [FK_dbo.Evaluations_Configuration.EvaluationTypes_EvaluationTypeID]
GO
ALTER TABLE [dbo].[Evaluations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Evaluations_dbo.Assessments_ID] FOREIGN KEY([ID])
REFERENCES [dbo].[Assessments] ([ID])
GO
ALTER TABLE [dbo].[Evaluations] CHECK CONSTRAINT [FK_dbo.Evaluations_dbo.Assessments_ID]
GO
ALTER TABLE [dbo].[Evaluations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Evaluations_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Evaluations] CHECK CONSTRAINT [FK_dbo.Evaluations_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Evaluations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Evaluations_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[Evaluations] CHECK CONSTRAINT [FK_dbo.Evaluations_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[Evaluations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Evaluations_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[Evaluations] CHECK CONSTRAINT [FK_dbo.Evaluations_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[EventTemplate_LearningObjective]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventTemplate_LearningObjective_dbo.EventTemplates_EventTemplateID] FOREIGN KEY([EventTemplateID])
REFERENCES [dbo].[EventTemplates] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EventTemplate_LearningObjective] CHECK CONSTRAINT [FK_dbo.EventTemplate_LearningObjective_dbo.EventTemplates_EventTemplateID]
GO
ALTER TABLE [dbo].[EventTemplate_LearningObjective]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventTemplate_LearningObjective_dbo.LearningObjectives_LearningObjectiveID] FOREIGN KEY([LearningObjectiveID])
REFERENCES [dbo].[LearningObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EventTemplate_LearningObjective] CHECK CONSTRAINT [FK_dbo.EventTemplate_LearningObjective_dbo.LearningObjectives_LearningObjectiveID]
GO
ALTER TABLE [dbo].[EventTemplate_Resources]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventTemplate_Resources_dbo.EventTemplates_EventTemplateID] FOREIGN KEY([EventTemplateID])
REFERENCES [dbo].[EventTemplates] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EventTemplate_Resources] CHECK CONSTRAINT [FK_dbo.EventTemplate_Resources_dbo.EventTemplates_EventTemplateID]
GO
ALTER TABLE [dbo].[EventTemplate_Resources]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventTemplate_Resources_dbo.Resources_ResourceID] FOREIGN KEY([ResourceID])
REFERENCES [dbo].[Resources] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EventTemplate_Resources] CHECK CONSTRAINT [FK_dbo.EventTemplate_Resources_dbo.Resources_ResourceID]
GO
ALTER TABLE [dbo].[EventTemplate_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventTemplate_Tag_dbo.EventTemplates_EventTemplateID] FOREIGN KEY([EventTemplateID])
REFERENCES [dbo].[EventTemplates] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EventTemplate_Tag] CHECK CONSTRAINT [FK_dbo.EventTemplate_Tag_dbo.EventTemplates_EventTemplateID]
GO
ALTER TABLE [dbo].[EventTemplate_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventTemplate_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EventTemplate_Tag] CHECK CONSTRAINT [FK_dbo.EventTemplate_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[EventTemplateResource_RoleType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventTemplateResource_RoleType_dbo.EventTemplate_Resources_EventTemplateResourceID] FOREIGN KEY([EventTemplateResourceID])
REFERENCES [dbo].[EventTemplate_Resources] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EventTemplateResource_RoleType] CHECK CONSTRAINT [FK_dbo.EventTemplateResource_RoleType_dbo.EventTemplate_Resources_EventTemplateResourceID]
GO
ALTER TABLE [dbo].[EventTemplates]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventTemplates_Configuration.EventTypes_EventTypeID] FOREIGN KEY([EventTypeID])
REFERENCES [Configuration].[EventTypes] ([ID])
GO
ALTER TABLE [dbo].[EventTemplates] CHECK CONSTRAINT [FK_dbo.EventTemplates_Configuration.EventTypes_EventTypeID]
GO
ALTER TABLE [dbo].[EventTemplates]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventTemplates_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[EventTemplates] CHECK CONSTRAINT [FK_dbo.EventTemplates_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[EventTemplates]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventTemplates_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[EventTemplates] CHECK CONSTRAINT [FK_dbo.EventTemplates_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[EventTemplates]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventTemplates_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[EventTemplates] CHECK CONSTRAINT [FK_dbo.EventTemplates_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[Examination_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Examination_Tag_dbo.Examinations_ExaminationID] FOREIGN KEY([ExaminationID])
REFERENCES [dbo].[Examinations] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Examination_Tag] CHECK CONSTRAINT [FK_dbo.Examination_Tag_dbo.Examinations_ExaminationID]
GO
ALTER TABLE [dbo].[Examination_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Examination_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Examination_Tag] CHECK CONSTRAINT [FK_dbo.Examination_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[Examinations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Examinations_Configuration.ExaminationTypes_ExaminationTypeID] FOREIGN KEY([ExaminationTypeID])
REFERENCES [Configuration].[ExaminationTypes] ([ID])
GO
ALTER TABLE [dbo].[Examinations] CHECK CONSTRAINT [FK_dbo.Examinations_Configuration.ExaminationTypes_ExaminationTypeID]
GO
ALTER TABLE [dbo].[Examinations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Examinations_dbo.Assessments_ID] FOREIGN KEY([ID])
REFERENCES [dbo].[Assessments] ([ID])
GO
ALTER TABLE [dbo].[Examinations] CHECK CONSTRAINT [FK_dbo.Examinations_dbo.Assessments_ID]
GO
ALTER TABLE [dbo].[Examinations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Examinations_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Examinations] CHECK CONSTRAINT [FK_dbo.Examinations_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Examinations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Examinations_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[Examinations] CHECK CONSTRAINT [FK_dbo.Examinations_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[Examinations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Examinations_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[Examinations] CHECK CONSTRAINT [FK_dbo.Examinations_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[ExpectedUploads]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ExpectedUploads_dbo.AssignmentTemplates_AssignmentTemplateID] FOREIGN KEY([AssignmentTemplateID])
REFERENCES [dbo].[AssignmentTemplates] ([ID])
GO
ALTER TABLE [dbo].[ExpectedUploads] CHECK CONSTRAINT [FK_dbo.ExpectedUploads_dbo.AssignmentTemplates_AssignmentTemplateID]
GO
ALTER TABLE [dbo].[ExpectedUploads]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ExpectedUploads_dbo.ScheduledAssignments_ScheduledAssignmentID] FOREIGN KEY([ScheduledAssignmentID])
REFERENCES [dbo].[ScheduledAssignments] ([ID])
GO
ALTER TABLE [dbo].[ExpectedUploads] CHECK CONSTRAINT [FK_dbo.ExpectedUploads_dbo.ScheduledAssignments_ScheduledAssignmentID]
GO
ALTER TABLE [dbo].[GradableItems]  WITH CHECK ADD  CONSTRAINT [FK_dbo.GradableItems_dbo.GradeBookCategories_CategoryID] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[GradeBookCategories] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[GradableItems] CHECK CONSTRAINT [FK_dbo.GradableItems_dbo.GradeBookCategories_CategoryID]
GO
ALTER TABLE [dbo].[GradeBookCategories]  WITH CHECK ADD  CONSTRAINT [FK_dbo.GradeBookCategories_dbo.GradeBooks_GradeBookID] FOREIGN KEY([GradeBookID])
REFERENCES [dbo].[GradeBooks] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[GradeBookCategories] CHECK CONSTRAINT [FK_dbo.GradeBookCategories_dbo.GradeBooks_GradeBookID]
GO
ALTER TABLE [dbo].[GradeBooks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.GradeBooks_dbo.GradingCriterions_GradingCriterionID] FOREIGN KEY([GradingCriterionID])
REFERENCES [dbo].[GradingCriterions] ([ID])
GO
ALTER TABLE [dbo].[GradeBooks] CHECK CONSTRAINT [FK_dbo.GradeBooks_dbo.GradingCriterions_GradingCriterionID]
GO
ALTER TABLE [dbo].[GradingCriterionRanges]  WITH CHECK ADD  CONSTRAINT [FK_dbo.GradingCriterionRanges_dbo.GradingCriterions_GradingCriterionID] FOREIGN KEY([GradingCriterionID])
REFERENCES [dbo].[GradingCriterions] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[GradingCriterionRanges] CHECK CONSTRAINT [FK_dbo.GradingCriterionRanges_dbo.GradingCriterions_GradingCriterionID]
GO
ALTER TABLE [dbo].[GradingCriterions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.GradingCriterions_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[GradingCriterions] CHECK CONSTRAINT [FK_dbo.GradingCriterions_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Helps]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Helps_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Helps] CHECK CONSTRAINT [FK_dbo.Helps_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[LearningObjective_LevelOfLearning]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjective_LevelOfLearning_Configuration.LevelsOfLearning_LevelOfLearningID] FOREIGN KEY([LevelOfLearningID])
REFERENCES [Configuration].[LevelsOfLearning] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearningObjective_LevelOfLearning] CHECK CONSTRAINT [FK_dbo.LearningObjective_LevelOfLearning_Configuration.LevelsOfLearning_LevelOfLearningID]
GO
ALTER TABLE [dbo].[LearningObjective_LevelOfLearning]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjective_LevelOfLearning_dbo.LearningObjectives_LearningObjectiveID] FOREIGN KEY([LearningObjectiveID])
REFERENCES [dbo].[LearningObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearningObjective_LevelOfLearning] CHECK CONSTRAINT [FK_dbo.LearningObjective_LevelOfLearning_dbo.LearningObjectives_LearningObjectiveID]
GO
ALTER TABLE [dbo].[LearningObjective_Question]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjective_Question_dbo.LearningObjectives_LearningObjectiveID] FOREIGN KEY([LearningObjectiveID])
REFERENCES [dbo].[LearningObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearningObjective_Question] CHECK CONSTRAINT [FK_dbo.LearningObjective_Question_dbo.LearningObjectives_LearningObjectiveID]
GO
ALTER TABLE [dbo].[LearningObjective_Question]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjective_Question_dbo.Questions_QuestionID] FOREIGN KEY([QuestionID])
REFERENCES [dbo].[Questions] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearningObjective_Question] CHECK CONSTRAINT [FK_dbo.LearningObjective_Question_dbo.Questions_QuestionID]
GO
ALTER TABLE [dbo].[LearningObjective_Resource]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjective_Resource_dbo.LearningObjectives_LearningObjectiveID] FOREIGN KEY([LearningObjectiveID])
REFERENCES [dbo].[LearningObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearningObjective_Resource] CHECK CONSTRAINT [FK_dbo.LearningObjective_Resource_dbo.LearningObjectives_LearningObjectiveID]
GO
ALTER TABLE [dbo].[LearningObjective_Resource]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjective_Resource_dbo.Resources_ResourceID] FOREIGN KEY([ResourceID])
REFERENCES [dbo].[Resources] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearningObjective_Resource] CHECK CONSTRAINT [FK_dbo.LearningObjective_Resource_dbo.Resources_ResourceID]
GO
ALTER TABLE [dbo].[LearningObjective_ScheduledAssignment]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjective_ScheduledAssignment_dbo.LearningObjectives_LearningObjectiveID] FOREIGN KEY([LearningObjectiveID])
REFERENCES [dbo].[LearningObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearningObjective_ScheduledAssignment] CHECK CONSTRAINT [FK_dbo.LearningObjective_ScheduledAssignment_dbo.LearningObjectives_LearningObjectiveID]
GO
ALTER TABLE [dbo].[LearningObjective_ScheduledAssignment]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjective_ScheduledAssignment_dbo.ScheduledAssignments_ScheduledAssignmentID] FOREIGN KEY([ScheduledAssignmentID])
REFERENCES [dbo].[ScheduledAssignments] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearningObjective_ScheduledAssignment] CHECK CONSTRAINT [FK_dbo.LearningObjective_ScheduledAssignment_dbo.ScheduledAssignments_ScheduledAssignmentID]
GO
ALTER TABLE [dbo].[LearningObjective_ScheduledEvent]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjective_ScheduledEvent_dbo.LearningObjectives_LearningObjectiveID] FOREIGN KEY([LearningObjectiveID])
REFERENCES [dbo].[LearningObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearningObjective_ScheduledEvent] CHECK CONSTRAINT [FK_dbo.LearningObjective_ScheduledEvent_dbo.LearningObjectives_LearningObjectiveID]
GO
ALTER TABLE [dbo].[LearningObjective_ScheduledEvent]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjective_ScheduledEvent_dbo.Scheduled_Events_ScheduledEventID] FOREIGN KEY([ScheduledEventID])
REFERENCES [dbo].[Scheduled_Events] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearningObjective_ScheduledEvent] CHECK CONSTRAINT [FK_dbo.LearningObjective_ScheduledEvent_dbo.Scheduled_Events_ScheduledEventID]
GO
ALTER TABLE [dbo].[LearningObjective_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjective_Tag_dbo.LearningObjectives_LearningObjectiveID] FOREIGN KEY([LearningObjectiveID])
REFERENCES [dbo].[LearningObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearningObjective_Tag] CHECK CONSTRAINT [FK_dbo.LearningObjective_Tag_dbo.LearningObjectives_LearningObjectiveID]
GO
ALTER TABLE [dbo].[LearningObjective_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjective_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearningObjective_Tag] CHECK CONSTRAINT [FK_dbo.LearningObjective_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[LearningObjectives]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjectives_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[LearningObjectives] CHECK CONSTRAINT [FK_dbo.LearningObjectives_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[LearningObjectives]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjectives_dbo.Clients_OwnerClientID] FOREIGN KEY([OwnerClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[LearningObjectives] CHECK CONSTRAINT [FK_dbo.LearningObjectives_dbo.Clients_OwnerClientID]
GO
ALTER TABLE [dbo].[LearningObjectives]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LearningObjectives_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[LearningObjectives] CHECK CONSTRAINT [FK_dbo.LearningObjectives_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[Locations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Locations_Configuration.LocationTypes_LocationTypeID] FOREIGN KEY([LocationTypeID])
REFERENCES [Configuration].[LocationTypes] ([ID])
GO
ALTER TABLE [dbo].[Locations] CHECK CONSTRAINT [FK_dbo.Locations_Configuration.LocationTypes_LocationTypeID]
GO
ALTER TABLE [dbo].[Locations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Locations_dbo.Addresses_AddressID] FOREIGN KEY([AddressID])
REFERENCES [dbo].[Addresses] ([ID])
GO
ALTER TABLE [dbo].[Locations] CHECK CONSTRAINT [FK_dbo.Locations_dbo.Addresses_AddressID]
GO
ALTER TABLE [dbo].[Locations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Locations_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Locations] CHECK CONSTRAINT [FK_dbo.Locations_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Locations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Locations_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[Locations] CHECK CONSTRAINT [FK_dbo.Locations_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[Locations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Locations_dbo.ResourceAssets_ImageResourceAssetID] FOREIGN KEY([ImageResourceAssetID])
REFERENCES [dbo].[ResourceAssets] ([ID])
GO
ALTER TABLE [dbo].[Locations] CHECK CONSTRAINT [FK_dbo.Locations_dbo.ResourceAssets_ImageResourceAssetID]
GO
ALTER TABLE [dbo].[Logins]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Logins_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Logins] CHECK CONSTRAINT [FK_dbo.Logins_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[LogRequirement_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LogRequirement_Tag_dbo.LogRequirements_LogRequirementID] FOREIGN KEY([LogRequirementID])
REFERENCES [dbo].[LogRequirements] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LogRequirement_Tag] CHECK CONSTRAINT [FK_dbo.LogRequirement_Tag_dbo.LogRequirements_LogRequirementID]
GO
ALTER TABLE [dbo].[LogRequirement_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LogRequirement_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LogRequirement_Tag] CHECK CONSTRAINT [FK_dbo.LogRequirement_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[LogRequirements]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LogRequirements_Configuration.LogRequirementTypes_LogRequirementTypeID] FOREIGN KEY([LogRequirementTypeID])
REFERENCES [Configuration].[LogRequirementTypes] ([ID])
GO
ALTER TABLE [dbo].[LogRequirements] CHECK CONSTRAINT [FK_dbo.LogRequirements_Configuration.LogRequirementTypes_LogRequirementTypeID]
GO
ALTER TABLE [dbo].[LogRequirements]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LogRequirements_dbo.Assessments_ID] FOREIGN KEY([ID])
REFERENCES [dbo].[Assessments] ([ID])
GO
ALTER TABLE [dbo].[LogRequirements] CHECK CONSTRAINT [FK_dbo.LogRequirements_dbo.Assessments_ID]
GO
ALTER TABLE [dbo].[LogRequirements]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LogRequirements_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[LogRequirements] CHECK CONSTRAINT [FK_dbo.LogRequirements_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[LogRequirements]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LogRequirements_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[LogRequirements] CHECK CONSTRAINT [FK_dbo.LogRequirements_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[LogRequirements]  WITH CHECK ADD  CONSTRAINT [FK_dbo.LogRequirements_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[LogRequirements] CHECK CONSTRAINT [FK_dbo.LogRequirements_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[MarketingEfforts]  WITH CHECK ADD  CONSTRAINT [FK_dbo.MarketingEfforts_dbo.Seminars_SeminarID] FOREIGN KEY([SeminarID])
REFERENCES [dbo].[Seminars] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MarketingEfforts] CHECK CONSTRAINT [FK_dbo.MarketingEfforts_dbo.Seminars_SeminarID]
GO
ALTER TABLE [dbo].[MobileDevices]  WITH CHECK ADD  CONSTRAINT [FK_dbo.MobileDevices_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MobileDevices] CHECK CONSTRAINT [FK_dbo.MobileDevices_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Notes]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Notes_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Notes] CHECK CONSTRAINT [FK_dbo.Notes_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[NotificationHistory]  WITH CHECK ADD  CONSTRAINT [FK_dbo.NotificationHistory_dbo.NotificationPeople_NotificationPersonID] FOREIGN KEY([NotificationPersonID])
REFERENCES [dbo].[NotificationPeople] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[NotificationHistory] CHECK CONSTRAINT [FK_dbo.NotificationHistory_dbo.NotificationPeople_NotificationPersonID]
GO
ALTER TABLE [dbo].[NotificationMessageTypeTemplateNotificationTypes]  WITH CHECK ADD  CONSTRAINT [FK_dbo.NotificationMessageTypeTemplateNotificationTypes_dbo.NotificationMessageTypeTemplates_NotificationMessageTypeTemplateID] FOREIGN KEY([NotificationMessageTypeTemplateID])
REFERENCES [dbo].[NotificationMessageTypeTemplates] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[NotificationMessageTypeTemplateNotificationTypes] CHECK CONSTRAINT [FK_dbo.NotificationMessageTypeTemplateNotificationTypes_dbo.NotificationMessageTypeTemplates_NotificationMessageTypeTemplateID]
GO
ALTER TABLE [dbo].[NotificationMessageTypeTemplates]  WITH CHECK ADD  CONSTRAINT [FK_dbo.NotificationMessageTypeTemplates_dbo.Courses_CourseID] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([ID])
GO
ALTER TABLE [dbo].[NotificationMessageTypeTemplates] CHECK CONSTRAINT [FK_dbo.NotificationMessageTypeTemplates_dbo.Courses_CourseID]
GO
ALTER TABLE [dbo].[NotificationMessageTypeTemplates]  WITH CHECK ADD  CONSTRAINT [FK_dbo.NotificationMessageTypeTemplates_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[NotificationMessageTypeTemplates] CHECK CONSTRAINT [FK_dbo.NotificationMessageTypeTemplates_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[NotificationPeople]  WITH CHECK ADD  CONSTRAINT [FK_dbo.NotificationPeople_dbo.Notifications_NotificationID] FOREIGN KEY([NotificationID])
REFERENCES [dbo].[Notifications] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[NotificationPeople] CHECK CONSTRAINT [FK_dbo.NotificationPeople_dbo.Notifications_NotificationID]
GO
ALTER TABLE [dbo].[NotificationPeople]  WITH CHECK ADD  CONSTRAINT [FK_dbo.NotificationPeople_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[NotificationPeople] CHECK CONSTRAINT [FK_dbo.NotificationPeople_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[NotificationQueue]  WITH CHECK ADD  CONSTRAINT [FK_dbo.NotificationQueue_dbo.NotificationPeople_NotificationPersonID] FOREIGN KEY([NotificationPersonID])
REFERENCES [dbo].[NotificationPeople] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[NotificationQueue] CHECK CONSTRAINT [FK_dbo.NotificationQueue_dbo.NotificationPeople_NotificationPersonID]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Notifications_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [FK_dbo.Notifications_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[OAuthKeys]  WITH CHECK ADD  CONSTRAINT [FK_dbo.OAuthKeys_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[OAuthKeys] CHECK CONSTRAINT [FK_dbo.OAuthKeys_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Organization_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Organization_Tag_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Organization_Tag] CHECK CONSTRAINT [FK_dbo.Organization_Tag_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[Organization_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Organization_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Organization_Tag] CHECK CONSTRAINT [FK_dbo.Organization_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[Organizations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Organizations_Configuration.OrganizationTypes_OrganizationTypeID] FOREIGN KEY([OrganizationTypeID])
REFERENCES [Configuration].[OrganizationTypes] ([ID])
GO
ALTER TABLE [dbo].[Organizations] CHECK CONSTRAINT [FK_dbo.Organizations_Configuration.OrganizationTypes_OrganizationTypeID]
GO
ALTER TABLE [dbo].[Organizations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Organizations_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Organizations] CHECK CONSTRAINT [FK_dbo.Organizations_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[PasswordResets]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PasswordResets_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PasswordResets] CHECK CONSTRAINT [FK_dbo.PasswordResets_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.People_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[People] CHECK CONSTRAINT [FK_dbo.People_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.People_dbo.ResourceAssets_ProfileImageResourceAssetID] FOREIGN KEY([ProfileImageResourceAssetID])
REFERENCES [dbo].[ResourceAssets] ([ID])
GO
ALTER TABLE [dbo].[People] CHECK CONSTRAINT [FK_dbo.People_dbo.ResourceAssets_ProfileImageResourceAssetID]
GO
ALTER TABLE [dbo].[People_Payments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.People_Payments_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[People_Payments] CHECK CONSTRAINT [FK_dbo.People_Payments_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[People_Payments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.People_Payments_dbo.Seminars_SeminarID] FOREIGN KEY([SeminarID])
REFERENCES [dbo].[Seminars] ([ID])
GO
ALTER TABLE [dbo].[People_Payments] CHECK CONSTRAINT [FK_dbo.People_Payments_dbo.Seminars_SeminarID]
GO
ALTER TABLE [dbo].[People_Payments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.People_Payments_Registration.SubmittedUserRegistration_SubmittedUserRegistrationID] FOREIGN KEY([SubmittedUserRegistrationID])
REFERENCES [Registration].[SubmittedUserRegistration] ([ID])
GO
ALTER TABLE [dbo].[People_Payments] CHECK CONSTRAINT [FK_dbo.People_Payments_Registration.SubmittedUserRegistration_SubmittedUserRegistrationID]
GO
ALTER TABLE [dbo].[People_Roles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.People_Roles_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[People_Roles] CHECK CONSTRAINT [FK_dbo.People_Roles_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[People_Roles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.People_Roles_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[People_Roles] CHECK CONSTRAINT [FK_dbo.People_Roles_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[People_Roles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.People_Roles_dbo.Roles_RoleID] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Roles] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[People_Roles] CHECK CONSTRAINT [FK_dbo.People_Roles_dbo.Roles_RoleID]
GO
ALTER TABLE [dbo].[Person_PersonPayment]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Person_PersonPayment_dbo.People_Payments_PersonPaymentID] FOREIGN KEY([PersonPaymentID])
REFERENCES [dbo].[People_Payments] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Person_PersonPayment] CHECK CONSTRAINT [FK_dbo.Person_PersonPayment_dbo.People_Payments_PersonPaymentID]
GO
ALTER TABLE [dbo].[Person_PersonPayment]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Person_PersonPayment_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Person_PersonPayment] CHECK CONSTRAINT [FK_dbo.Person_PersonPayment_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Person_SchedulingSession]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Person_SchedulingSession_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Person_SchedulingSession] CHECK CONSTRAINT [FK_dbo.Person_SchedulingSession_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Person_SchedulingSession]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Person_SchedulingSession_dbo.SchedulingSessions_SchedulingSessionID] FOREIGN KEY([SchedulingSessionID])
REFERENCES [dbo].[SchedulingSessions] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Person_SchedulingSession] CHECK CONSTRAINT [FK_dbo.Person_SchedulingSession_dbo.SchedulingSessions_SchedulingSessionID]
GO
ALTER TABLE [dbo].[Person_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Person_Tag_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Person_Tag] CHECK CONSTRAINT [FK_dbo.Person_Tag_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Person_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Person_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Person_Tag] CHECK CONSTRAINT [FK_dbo.Person_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[PersonClients]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PersonClients_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[PersonClients] CHECK CONSTRAINT [FK_dbo.PersonClients_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[PersonClients]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PersonClients_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PersonClients] CHECK CONSTRAINT [FK_dbo.PersonClients_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[PersonScores]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PersonScores_dbo.Course_People_CoursePersonID] FOREIGN KEY([CoursePersonID])
REFERENCES [dbo].[Course_People] ([ID])
GO
ALTER TABLE [dbo].[PersonScores] CHECK CONSTRAINT [FK_dbo.PersonScores_dbo.Course_People_CoursePersonID]
GO
ALTER TABLE [dbo].[PersonScores]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PersonScores_dbo.Courses_CourseID] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([ID])
GO
ALTER TABLE [dbo].[PersonScores] CHECK CONSTRAINT [FK_dbo.PersonScores_dbo.Courses_CourseID]
GO
ALTER TABLE [dbo].[PersonScores]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PersonScores_dbo.GradableItems_GradableItemID] FOREIGN KEY([GradableItemID])
REFERENCES [dbo].[GradableItems] ([ID])
GO
ALTER TABLE [dbo].[PersonScores] CHECK CONSTRAINT [FK_dbo.PersonScores_dbo.GradableItems_GradableItemID]
GO
ALTER TABLE [dbo].[PersonScores]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PersonScores_dbo.GradeBookCategories_GradeBookCategoryID] FOREIGN KEY([GradeBookCategoryID])
REFERENCES [dbo].[GradeBookCategories] ([ID])
GO
ALTER TABLE [dbo].[PersonScores] CHECK CONSTRAINT [FK_dbo.PersonScores_dbo.GradeBookCategories_GradeBookCategoryID]
GO
ALTER TABLE [dbo].[PersonScores]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PersonScores_dbo.GradeBooks_GradeBookID] FOREIGN KEY([GradeBookID])
REFERENCES [dbo].[GradeBooks] ([ID])
GO
ALTER TABLE [dbo].[PersonScores] CHECK CONSTRAINT [FK_dbo.PersonScores_dbo.GradeBooks_GradeBookID]
GO
ALTER TABLE [dbo].[PersonScores]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PersonScores_dbo.People_OverridePersonID] FOREIGN KEY([OverridePersonID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[PersonScores] CHECK CONSTRAINT [FK_dbo.PersonScores_dbo.People_OverridePersonID]
GO
ALTER TABLE [dbo].[PersonScores]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PersonScores_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[PersonScores] CHECK CONSTRAINT [FK_dbo.PersonScores_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[PersonScores]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PersonScores_dbo.ScheduledAssessments_ScheduledAssessmentID] FOREIGN KEY([ScheduledAssessmentID])
REFERENCES [dbo].[ScheduledAssessments] ([ID])
GO
ALTER TABLE [dbo].[PersonScores] CHECK CONSTRAINT [FK_dbo.PersonScores_dbo.ScheduledAssessments_ScheduledAssessmentID]
GO
ALTER TABLE [dbo].[PersonSearches]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PersonSearches_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PersonSearches] CHECK CONSTRAINT [FK_dbo.PersonSearches_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[PhoneNumbers]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PhoneNumbers_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[PhoneNumbers] CHECK CONSTRAINT [FK_dbo.PhoneNumbers_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[PhoneNumbers]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PhoneNumbers_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[PhoneNumbers] CHECK CONSTRAINT [FK_dbo.PhoneNumbers_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[PossibleResponses]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PossibleResponses_dbo.Questions_QuestionID] FOREIGN KEY([QuestionID])
REFERENCES [dbo].[Questions] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PossibleResponses] CHECK CONSTRAINT [FK_dbo.PossibleResponses_dbo.Questions_QuestionID]
GO
ALTER TABLE [dbo].[ProgramObjective_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ProgramObjective_Tag_dbo.ProgramObjectives_ProgramObjectiveID] FOREIGN KEY([ProgramObjectiveID])
REFERENCES [dbo].[ProgramObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ProgramObjective_Tag] CHECK CONSTRAINT [FK_dbo.ProgramObjective_Tag_dbo.ProgramObjectives_ProgramObjectiveID]
GO
ALTER TABLE [dbo].[ProgramObjective_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ProgramObjective_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ProgramObjective_Tag] CHECK CONSTRAINT [FK_dbo.ProgramObjective_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[ProgramObjectives]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ProgramObjectives_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[ProgramObjectives] CHECK CONSTRAINT [FK_dbo.ProgramObjectives_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[ProgramObjectives]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ProgramObjectives_dbo.Clients_OwnerClientID] FOREIGN KEY([OwnerClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[ProgramObjectives] CHECK CONSTRAINT [FK_dbo.ProgramObjectives_dbo.Clients_OwnerClientID]
GO
ALTER TABLE [dbo].[ProgramObjectives]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ProgramObjectives_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[ProgramObjectives] CHECK CONSTRAINT [FK_dbo.ProgramObjectives_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[QualityAssuranceHistory]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QualityAssuranceHistory_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[QualityAssuranceHistory] CHECK CONSTRAINT [FK_dbo.QualityAssuranceHistory_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[QualityAssuranceQueue]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QualityAssuranceQueue_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[QualityAssuranceQueue] CHECK CONSTRAINT [FK_dbo.QualityAssuranceQueue_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Question_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Question_Tag_dbo.Questions_QuestionID] FOREIGN KEY([QuestionID])
REFERENCES [dbo].[Questions] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Question_Tag] CHECK CONSTRAINT [FK_dbo.Question_Tag_dbo.Questions_QuestionID]
GO
ALTER TABLE [dbo].[Question_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Question_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Question_Tag] CHECK CONSTRAINT [FK_dbo.Question_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[QuestionCells]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionCells_dbo.PossibleResponses_PossibleResponseID] FOREIGN KEY([PossibleResponseID])
REFERENCES [dbo].[PossibleResponses] ([ID])
GO
ALTER TABLE [dbo].[QuestionCells] CHECK CONSTRAINT [FK_dbo.QuestionCells_dbo.PossibleResponses_PossibleResponseID]
GO
ALTER TABLE [dbo].[QuestionCells]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionCells_dbo.QuestionRows_QuestionRowID] FOREIGN KEY([QuestionRowID])
REFERENCES [dbo].[QuestionRows] ([ID])
GO
ALTER TABLE [dbo].[QuestionCells] CHECK CONSTRAINT [FK_dbo.QuestionCells_dbo.QuestionRows_QuestionRowID]
GO
ALTER TABLE [dbo].[QuestionRows]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QuestionRows_dbo.Questions_QuestionID] FOREIGN KEY([QuestionID])
REFERENCES [dbo].[Questions] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[QuestionRows] CHECK CONSTRAINT [FK_dbo.QuestionRows_dbo.Questions_QuestionID]
GO
ALTER TABLE [dbo].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Questions] CHECK CONSTRAINT [FK_dbo.Questions_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[Questions] CHECK CONSTRAINT [FK_dbo.Questions_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[Questions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Questions_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[Questions] CHECK CONSTRAINT [FK_dbo.Questions_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[Ratings]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Ratings_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Ratings] CHECK CONSTRAINT [FK_dbo.Ratings_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Ratings]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Ratings_dbo.Resources_ResourceID] FOREIGN KEY([ResourceID])
REFERENCES [dbo].[Resources] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Ratings] CHECK CONSTRAINT [FK_dbo.Ratings_dbo.Resources_ResourceID]
GO
ALTER TABLE [dbo].[Report_RoleType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Report_RoleType_dbo.Reports_ReportID] FOREIGN KEY([ReportID])
REFERENCES [dbo].[Reports] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Report_RoleType] CHECK CONSTRAINT [FK_dbo.Report_RoleType_dbo.Reports_ReportID]
GO
ALTER TABLE [dbo].[ReportDefinitions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ReportDefinitions_dbo.People_AuthorPersonID] FOREIGN KEY([AuthorPersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ReportDefinitions] CHECK CONSTRAINT [FK_dbo.ReportDefinitions_dbo.People_AuthorPersonID]
GO
ALTER TABLE [dbo].[Resource_ScheduledEvents]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Resource_ScheduledEvents_dbo.Resources_ResourceID] FOREIGN KEY([ResourceID])
REFERENCES [dbo].[Resources] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Resource_ScheduledEvents] CHECK CONSTRAINT [FK_dbo.Resource_ScheduledEvents_dbo.Resources_ResourceID]
GO
ALTER TABLE [dbo].[Resource_ScheduledEvents]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Resource_ScheduledEvents_dbo.Scheduled_Events_ScheduledEventID] FOREIGN KEY([ScheduledEventID])
REFERENCES [dbo].[Scheduled_Events] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Resource_ScheduledEvents] CHECK CONSTRAINT [FK_dbo.Resource_ScheduledEvents_dbo.Scheduled_Events_ScheduledEventID]
GO
ALTER TABLE [dbo].[Resource_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Resource_Tag_dbo.Resources_ResourceID] FOREIGN KEY([ResourceID])
REFERENCES [dbo].[Resources] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Resource_Tag] CHECK CONSTRAINT [FK_dbo.Resource_Tag_dbo.Resources_ResourceID]
GO
ALTER TABLE [dbo].[Resource_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Resource_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Resource_Tag] CHECK CONSTRAINT [FK_dbo.Resource_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[ResourceAssets]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ResourceAssets_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[ResourceAssets] CHECK CONSTRAINT [FK_dbo.ResourceAssets_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[ResourceAssets]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ResourceAssets_dbo.Courses_CourseID] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ResourceAssets] CHECK CONSTRAINT [FK_dbo.ResourceAssets_dbo.Courses_CourseID]
GO
ALTER TABLE [dbo].[ResourceAssets]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ResourceAssets_dbo.Degrees_DegreeID] FOREIGN KEY([DegreeID])
REFERENCES [dbo].[Degrees] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ResourceAssets] CHECK CONSTRAINT [FK_dbo.ResourceAssets_dbo.Degrees_DegreeID]
GO
ALTER TABLE [dbo].[ResourceAssets]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ResourceAssets_dbo.HtmlMediaContents_HtmlMediaContentID] FOREIGN KEY([HtmlMediaContentID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ResourceAssets] CHECK CONSTRAINT [FK_dbo.ResourceAssets_dbo.HtmlMediaContents_HtmlMediaContentID]
GO
ALTER TABLE [dbo].[ResourceAssets]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ResourceAssets_dbo.InteractiveContents_InteractiveContentID] FOREIGN KEY([InteractiveContentID])
REFERENCES [dbo].[InteractiveContents] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ResourceAssets] CHECK CONSTRAINT [FK_dbo.ResourceAssets_dbo.InteractiveContents_InteractiveContentID]
GO
ALTER TABLE [dbo].[ResourceAssets]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ResourceAssets_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ResourceAssets] CHECK CONSTRAINT [FK_dbo.ResourceAssets_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[ResourceAssets]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ResourceAssets_dbo.Resources_ResourceID] FOREIGN KEY([ResourceID])
REFERENCES [dbo].[Resources] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ResourceAssets] CHECK CONSTRAINT [FK_dbo.ResourceAssets_dbo.Resources_ResourceID]
GO
ALTER TABLE [dbo].[ResourceAssets]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ResourceAssets_dbo.Seminars_SeminarID] FOREIGN KEY([SeminarID])
REFERENCES [dbo].[Seminars] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ResourceAssets] CHECK CONSTRAINT [FK_dbo.ResourceAssets_dbo.Seminars_SeminarID]
GO
ALTER TABLE [dbo].[Resources]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Resources_Configuration.ResourceTypes_ResourceTypeID] FOREIGN KEY([ResourceTypeID])
REFERENCES [Configuration].[ResourceTypes] ([ID])
GO
ALTER TABLE [dbo].[Resources] CHECK CONSTRAINT [FK_dbo.Resources_Configuration.ResourceTypes_ResourceTypeID]
GO
ALTER TABLE [dbo].[Resources]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Resources_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Resources] CHECK CONSTRAINT [FK_dbo.Resources_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Resources]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Resources_dbo.Clients_OwnerClientID] FOREIGN KEY([OwnerClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Resources] CHECK CONSTRAINT [FK_dbo.Resources_dbo.Clients_OwnerClientID]
GO
ALTER TABLE [dbo].[Resources]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Resources_dbo.InteractiveContents_InteractiveContentID] FOREIGN KEY([InteractiveContentID])
REFERENCES [dbo].[InteractiveContents] ([ID])
GO
ALTER TABLE [dbo].[Resources] CHECK CONSTRAINT [FK_dbo.Resources_dbo.InteractiveContents_InteractiveContentID]
GO
ALTER TABLE [dbo].[Resources]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Resources_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[Resources] CHECK CONSTRAINT [FK_dbo.Resources_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[ResourceScheduledEvent_RoleType]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ResourceScheduledEvent_RoleType_dbo.Resource_ScheduledEvents_ResourceScheduledEventID] FOREIGN KEY([ResourceScheduledEventID])
REFERENCES [dbo].[Resource_ScheduledEvents] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ResourceScheduledEvent_RoleType] CHECK CONSTRAINT [FK_dbo.ResourceScheduledEvent_RoleType_dbo.Resource_ScheduledEvents_ResourceScheduledEventID]
GO
ALTER TABLE [dbo].[RolePermissions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RolePermissions_dbo.Roles_RoleID] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Roles] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RolePermissions] CHECK CONSTRAINT [FK_dbo.RolePermissions_dbo.Roles_RoleID]
GO
ALTER TABLE [dbo].[RolePermissions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.RolePermissions_Reference.UserPermissions_UserPermissionID] FOREIGN KEY([UserPermissionID])
REFERENCES [Reference].[UserPermissions] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RolePermissions] CHECK CONSTRAINT [FK_dbo.RolePermissions_Reference.UserPermissions_UserPermissionID]
GO
ALTER TABLE [dbo].[Roles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Roles_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Roles] CHECK CONSTRAINT [FK_dbo.Roles_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Scheduled_Events]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Scheduled_Events_Configuration.EventTypes_EventTypeID] FOREIGN KEY([EventTypeID])
REFERENCES [Configuration].[EventTypes] ([ID])
GO
ALTER TABLE [dbo].[Scheduled_Events] CHECK CONSTRAINT [FK_dbo.Scheduled_Events_Configuration.EventTypes_EventTypeID]
GO
ALTER TABLE [dbo].[Scheduled_Events]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Scheduled_Events_dbo.Calendars_CalendarID] FOREIGN KEY([CalendarID])
REFERENCES [dbo].[Calendars] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Scheduled_Events] CHECK CONSTRAINT [FK_dbo.Scheduled_Events_dbo.Calendars_CalendarID]
GO
ALTER TABLE [dbo].[Scheduled_Events]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Scheduled_Events_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Scheduled_Events] CHECK CONSTRAINT [FK_dbo.Scheduled_Events_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Scheduled_Events]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Scheduled_Events_dbo.Courses_CourseID] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([ID])
GO
ALTER TABLE [dbo].[Scheduled_Events] CHECK CONSTRAINT [FK_dbo.Scheduled_Events_dbo.Courses_CourseID]
GO
ALTER TABLE [dbo].[Scheduled_Events]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Scheduled_Events_dbo.EventTemplates_EventTemplateID] FOREIGN KEY([EventTemplateID])
REFERENCES [dbo].[EventTemplates] ([ID])
GO
ALTER TABLE [dbo].[Scheduled_Events] CHECK CONSTRAINT [FK_dbo.Scheduled_Events_dbo.EventTemplates_EventTemplateID]
GO
ALTER TABLE [dbo].[Scheduled_Events]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Scheduled_Events_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[Scheduled_Events] CHECK CONSTRAINT [FK_dbo.Scheduled_Events_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[Scheduled_Events]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Scheduled_Events_dbo.SubLocations_SubLocationID] FOREIGN KEY([SubLocationID])
REFERENCES [dbo].[SubLocations] ([ID])
GO
ALTER TABLE [dbo].[Scheduled_Events] CHECK CONSTRAINT [FK_dbo.Scheduled_Events_dbo.SubLocations_SubLocationID]
GO
ALTER TABLE [dbo].[ScheduledAssessmentAnswers]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessmentAnswers_dbo.PossibleResponses_ResponseAnswerID] FOREIGN KEY([ResponseAnswerID])
REFERENCES [dbo].[PossibleResponses] ([ID])
GO
ALTER TABLE [dbo].[ScheduledAssessmentAnswers] CHECK CONSTRAINT [FK_dbo.ScheduledAssessmentAnswers_dbo.PossibleResponses_ResponseAnswerID]
GO
ALTER TABLE [dbo].[ScheduledAssessmentAnswers]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessmentAnswers_dbo.QuestionRows_QuestionRowID] FOREIGN KEY([QuestionRowID])
REFERENCES [dbo].[QuestionRows] ([ID])
GO
ALTER TABLE [dbo].[ScheduledAssessmentAnswers] CHECK CONSTRAINT [FK_dbo.ScheduledAssessmentAnswers_dbo.QuestionRows_QuestionRowID]
GO
ALTER TABLE [dbo].[ScheduledAssessmentAnswers]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessmentAnswers_dbo.ScheduledAssessmentQuestions_ScheduledAssessmentQuestionID] FOREIGN KEY([ScheduledAssessmentQuestionID])
REFERENCES [dbo].[ScheduledAssessmentQuestions] ([ID])
GO
ALTER TABLE [dbo].[ScheduledAssessmentAnswers] CHECK CONSTRAINT [FK_dbo.ScheduledAssessmentAnswers_dbo.ScheduledAssessmentQuestions_ScheduledAssessmentQuestionID]
GO
ALTER TABLE [dbo].[ScheduledAssessmentProperties]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessmentProperties_dbo.ScheduledAssessments_ScheduledAssessmentID] FOREIGN KEY([ScheduledAssessmentID])
REFERENCES [dbo].[ScheduledAssessments] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ScheduledAssessmentProperties] CHECK CONSTRAINT [FK_dbo.ScheduledAssessmentProperties_dbo.ScheduledAssessments_ScheduledAssessmentID]
GO
ALTER TABLE [dbo].[ScheduledAssessmentQuestions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessmentQuestions_dbo.AssessmentFormRows_AssessmentFormRowID] FOREIGN KEY([AssessmentFormRowID])
REFERENCES [dbo].[AssessmentFormRows] ([ID])
GO
ALTER TABLE [dbo].[ScheduledAssessmentQuestions] CHECK CONSTRAINT [FK_dbo.ScheduledAssessmentQuestions_dbo.AssessmentFormRows_AssessmentFormRowID]
GO
ALTER TABLE [dbo].[ScheduledAssessmentQuestions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessmentQuestions_dbo.People_GraderID] FOREIGN KEY([GraderID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[ScheduledAssessmentQuestions] CHECK CONSTRAINT [FK_dbo.ScheduledAssessmentQuestions_dbo.People_GraderID]
GO
ALTER TABLE [dbo].[ScheduledAssessmentQuestions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessmentQuestions_dbo.Questions_QuestionID] FOREIGN KEY([QuestionID])
REFERENCES [dbo].[Questions] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ScheduledAssessmentQuestions] CHECK CONSTRAINT [FK_dbo.ScheduledAssessmentQuestions_dbo.Questions_QuestionID]
GO
ALTER TABLE [dbo].[ScheduledAssessmentQuestions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessmentQuestions_dbo.ScheduledAssessments_ScheduledAssessmentID] FOREIGN KEY([ScheduledAssessmentID])
REFERENCES [dbo].[ScheduledAssessments] ([ID])
GO
ALTER TABLE [dbo].[ScheduledAssessmentQuestions] CHECK CONSTRAINT [FK_dbo.ScheduledAssessmentQuestions_dbo.ScheduledAssessments_ScheduledAssessmentID]
GO
ALTER TABLE [dbo].[ScheduledAssessments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.Activities_ActivityID] FOREIGN KEY([ActivityID])
REFERENCES [dbo].[Activities] ([ID])
GO
ALTER TABLE [dbo].[ScheduledAssessments] CHECK CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.Activities_ActivityID]
GO
ALTER TABLE [dbo].[ScheduledAssessments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.Assessment_ScheduledEvent_AssessmentScheduledEventID] FOREIGN KEY([AssessmentScheduledEventID])
REFERENCES [dbo].[Assessment_ScheduledEvent] ([ID])
GO
ALTER TABLE [dbo].[ScheduledAssessments] CHECK CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.Assessment_ScheduledEvent_AssessmentScheduledEventID]
GO
ALTER TABLE [dbo].[ScheduledAssessments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.Assessments_AssessmentID] FOREIGN KEY([AssessmentID])
REFERENCES [dbo].[Assessments] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ScheduledAssessments] CHECK CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.Assessments_AssessmentID]
GO
ALTER TABLE [dbo].[ScheduledAssessments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.Course_People_CoursePersonID] FOREIGN KEY([CoursePersonID])
REFERENCES [dbo].[Course_People] ([ID])
GO
ALTER TABLE [dbo].[ScheduledAssessments] CHECK CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.Course_People_CoursePersonID]
GO
ALTER TABLE [dbo].[ScheduledAssessments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.Courses_CourseID] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([ID])
GO
ALTER TABLE [dbo].[ScheduledAssessments] CHECK CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.Courses_CourseID]
GO
ALTER TABLE [dbo].[ScheduledAssessments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.People_AssessorID] FOREIGN KEY([AssessorID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ScheduledAssessments] CHECK CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.People_AssessorID]
GO
ALTER TABLE [dbo].[ScheduledAssessments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.ScheduledAssessments_BaseScheduledAssessmentID] FOREIGN KEY([BaseScheduledAssessmentID])
REFERENCES [dbo].[ScheduledAssessments] ([ID])
GO
ALTER TABLE [dbo].[ScheduledAssessments] CHECK CONSTRAINT [FK_dbo.ScheduledAssessments_dbo.ScheduledAssessments_BaseScheduledAssessmentID]
GO
ALTER TABLE [dbo].[ScheduledAssignments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssignments_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[ScheduledAssignments] CHECK CONSTRAINT [FK_dbo.ScheduledAssignments_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[ScheduledAssignments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssignments_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[ScheduledAssignments] CHECK CONSTRAINT [FK_dbo.ScheduledAssignments_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[ScheduledAssignments]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledAssignments_dbo.Scheduled_Events_ScheduledEventID] FOREIGN KEY([ScheduledEventID])
REFERENCES [dbo].[Scheduled_Events] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ScheduledAssignments] CHECK CONSTRAINT [FK_dbo.ScheduledAssignments_dbo.Scheduled_Events_ScheduledEventID]
GO
ALTER TABLE [dbo].[ScheduledEvent_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledEvent_People_dbo.Course_People_CoursePersonID] FOREIGN KEY([CoursePersonID])
REFERENCES [dbo].[Course_People] ([ID])
GO
ALTER TABLE [dbo].[ScheduledEvent_People] CHECK CONSTRAINT [FK_dbo.ScheduledEvent_People_dbo.Course_People_CoursePersonID]
GO
ALTER TABLE [dbo].[ScheduledEvent_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledEvent_People_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
GO
ALTER TABLE [dbo].[ScheduledEvent_People] CHECK CONSTRAINT [FK_dbo.ScheduledEvent_People_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[ScheduledEvent_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledEvent_People_dbo.Scheduled_Events_ScheduledEventID] FOREIGN KEY([ScheduledEventID])
REFERENCES [dbo].[Scheduled_Events] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ScheduledEvent_People] CHECK CONSTRAINT [FK_dbo.ScheduledEvent_People_dbo.Scheduled_Events_ScheduledEventID]
GO
ALTER TABLE [dbo].[ScheduledEventCompletedItems]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledEventCompletedItems_dbo.Course_People_CoursePersonID] FOREIGN KEY([CoursePersonID])
REFERENCES [dbo].[Course_People] ([ID])
GO
ALTER TABLE [dbo].[ScheduledEventCompletedItems] CHECK CONSTRAINT [FK_dbo.ScheduledEventCompletedItems_dbo.Course_People_CoursePersonID]
GO
ALTER TABLE [dbo].[ScheduledEventCompletedItems]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledEventCompletedItems_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ScheduledEventCompletedItems] CHECK CONSTRAINT [FK_dbo.ScheduledEventCompletedItems_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[ScheduledEventCompletedItems]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ScheduledEventCompletedItems_dbo.Scheduled_Events_ScheduledEventID] FOREIGN KEY([ScheduledEventID])
REFERENCES [dbo].[Scheduled_Events] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ScheduledEventCompletedItems] CHECK CONSTRAINT [FK_dbo.ScheduledEventCompletedItems_dbo.Scheduled_Events_ScheduledEventID]
GO
ALTER TABLE [dbo].[SchedulingDistributionCriteria]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SchedulingDistributionCriteria_dbo.SchedulingRounds_SchedulingRoundID] FOREIGN KEY([SchedulingRoundID])
REFERENCES [dbo].[SchedulingRounds] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SchedulingDistributionCriteria] CHECK CONSTRAINT [FK_dbo.SchedulingDistributionCriteria_dbo.SchedulingRounds_SchedulingRoundID]
GO
ALTER TABLE [dbo].[SchedulingResults]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SchedulingResults_dbo.SchedulingRounds_SchedulingRoundID] FOREIGN KEY([SchedulingRoundID])
REFERENCES [dbo].[SchedulingRounds] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SchedulingResults] CHECK CONSTRAINT [FK_dbo.SchedulingResults_dbo.SchedulingRounds_SchedulingRoundID]
GO
ALTER TABLE [dbo].[SchedulingRound_SchedulingTimeBlock]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SchedulingRound_SchedulingTimeBlock_dbo.SchedulingRounds_SchedulingRoundID] FOREIGN KEY([SchedulingRoundID])
REFERENCES [dbo].[SchedulingRounds] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SchedulingRound_SchedulingTimeBlock] CHECK CONSTRAINT [FK_dbo.SchedulingRound_SchedulingTimeBlock_dbo.SchedulingRounds_SchedulingRoundID]
GO
ALTER TABLE [dbo].[SchedulingRound_SchedulingTimeBlock]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SchedulingRound_SchedulingTimeBlock_dbo.SchedulingTimeBlocks_SchedulingTimeBlockID] FOREIGN KEY([SchedulingTimeBlockID])
REFERENCES [dbo].[SchedulingTimeBlocks] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SchedulingRound_SchedulingTimeBlock] CHECK CONSTRAINT [FK_dbo.SchedulingRound_SchedulingTimeBlock_dbo.SchedulingTimeBlocks_SchedulingTimeBlockID]
GO
ALTER TABLE [dbo].[SchedulingRoundCourseUsageGroups]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SchedulingRoundCourseUsageGroups_dbo.SchedulingRounds_SchedulingRoundID] FOREIGN KEY([SchedulingRoundID])
REFERENCES [dbo].[SchedulingRounds] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SchedulingRoundCourseUsageGroups] CHECK CONSTRAINT [FK_dbo.SchedulingRoundCourseUsageGroups_dbo.SchedulingRounds_SchedulingRoundID]
GO
ALTER TABLE [dbo].[SchedulingRoundCourseUsages]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SchedulingRoundCourseUsages_dbo.SchedulingRoundCourseUsageGroups_CourseUsageGroupID] FOREIGN KEY([CourseUsageGroupID])
REFERENCES [dbo].[SchedulingRoundCourseUsageGroups] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SchedulingRoundCourseUsages] CHECK CONSTRAINT [FK_dbo.SchedulingRoundCourseUsages_dbo.SchedulingRoundCourseUsageGroups_CourseUsageGroupID]
GO
ALTER TABLE [dbo].[SchedulingRoundCourseUsages]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SchedulingRoundCourseUsages_dbo.Tags_CourseUsageID] FOREIGN KEY([CourseUsageID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SchedulingRoundCourseUsages] CHECK CONSTRAINT [FK_dbo.SchedulingRoundCourseUsages_dbo.Tags_CourseUsageID]
GO
ALTER TABLE [dbo].[SchedulingRounds]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SchedulingRounds_dbo.SchedulingSessions_SchedulingSessionID] FOREIGN KEY([SchedulingSessionID])
REFERENCES [dbo].[SchedulingSessions] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SchedulingRounds] CHECK CONSTRAINT [FK_dbo.SchedulingRounds_dbo.SchedulingSessions_SchedulingSessionID]
GO
ALTER TABLE [dbo].[SchedulingSessions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SchedulingSessions_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[SchedulingSessions] CHECK CONSTRAINT [FK_dbo.SchedulingSessions_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[SchedulingSessions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SchedulingSessions_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[SchedulingSessions] CHECK CONSTRAINT [FK_dbo.SchedulingSessions_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[SchedulingSessions]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SchedulingSessions_dbo.SchedulingTracks_SchedulingTrackID] FOREIGN KEY([SchedulingTrackID])
REFERENCES [dbo].[SchedulingTracks] ([ID])
GO
ALTER TABLE [dbo].[SchedulingSessions] CHECK CONSTRAINT [FK_dbo.SchedulingSessions_dbo.SchedulingTracks_SchedulingTrackID]
GO
ALTER TABLE [dbo].[SchedulingTimeBlocks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SchedulingTimeBlocks_dbo.SchedulingTracks_SchedulingTrackID] FOREIGN KEY([SchedulingTrackID])
REFERENCES [dbo].[SchedulingTracks] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SchedulingTimeBlocks] CHECK CONSTRAINT [FK_dbo.SchedulingTimeBlocks_dbo.SchedulingTracks_SchedulingTrackID]
GO
ALTER TABLE [dbo].[SchedulingTracks]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SchedulingTracks_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[SchedulingTracks] CHECK CONSTRAINT [FK_dbo.SchedulingTracks_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[SeatReservations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SeatReservations_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SeatReservations] CHECK CONSTRAINT [FK_dbo.SeatReservations_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Seminar_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Seminar_People_dbo.People_Payments_PersonPaymentID] FOREIGN KEY([PersonPaymentID])
REFERENCES [dbo].[People_Payments] ([ID])
GO
ALTER TABLE [dbo].[Seminar_People] CHECK CONSTRAINT [FK_dbo.Seminar_People_dbo.People_Payments_PersonPaymentID]
GO
ALTER TABLE [dbo].[Seminar_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Seminar_People_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Seminar_People] CHECK CONSTRAINT [FK_dbo.Seminar_People_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[Seminar_People]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Seminar_People_dbo.Seminars_SeminarID] FOREIGN KEY([SeminarID])
REFERENCES [dbo].[Seminars] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Seminar_People] CHECK CONSTRAINT [FK_dbo.Seminar_People_dbo.Seminars_SeminarID]
GO
ALTER TABLE [dbo].[Seminar_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Seminar_Tag_dbo.Seminars_SeminarID] FOREIGN KEY([SeminarID])
REFERENCES [dbo].[Seminars] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Seminar_Tag] CHECK CONSTRAINT [FK_dbo.Seminar_Tag_dbo.Seminars_SeminarID]
GO
ALTER TABLE [dbo].[Seminar_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Seminar_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Seminar_Tag] CHECK CONSTRAINT [FK_dbo.Seminar_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[Seminars]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Seminars_Configuration.SeminarTypes_SeminarTypeID] FOREIGN KEY([SeminarTypeID])
REFERENCES [Configuration].[SeminarTypes] ([ID])
GO
ALTER TABLE [dbo].[Seminars] CHECK CONSTRAINT [FK_dbo.Seminars_Configuration.SeminarTypes_SeminarTypeID]
GO
ALTER TABLE [dbo].[Seminars]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Seminars_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Seminars] CHECK CONSTRAINT [FK_dbo.Seminars_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Seminars]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Seminars_dbo.HtmlMediaContents_HtmlMediaID] FOREIGN KEY([HtmlMediaID])
REFERENCES [dbo].[HtmlMediaContents] ([ID])
GO
ALTER TABLE [dbo].[Seminars] CHECK CONSTRAINT [FK_dbo.Seminars_dbo.HtmlMediaContents_HtmlMediaID]
GO
ALTER TABLE [dbo].[Seminars]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Seminars_dbo.Organizations_OrganizationID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organizations] ([ID])
GO
ALTER TABLE [dbo].[Seminars] CHECK CONSTRAINT [FK_dbo.Seminars_dbo.Organizations_OrganizationID]
GO
ALTER TABLE [dbo].[Standard_StandardObjective]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Standard_StandardObjective_dbo.StandardObjectives_StandardObjectiveID] FOREIGN KEY([StandardObjectiveID])
REFERENCES [dbo].[StandardObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Standard_StandardObjective] CHECK CONSTRAINT [FK_dbo.Standard_StandardObjective_dbo.StandardObjectives_StandardObjectiveID]
GO
ALTER TABLE [dbo].[Standard_StandardObjective]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Standard_StandardObjective_dbo.Standards_StandardID] FOREIGN KEY([StandardID])
REFERENCES [dbo].[Standards] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Standard_StandardObjective] CHECK CONSTRAINT [FK_dbo.Standard_StandardObjective_dbo.Standards_StandardID]
GO
ALTER TABLE [dbo].[StandardObjective_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.StandardObjective_Tag_dbo.StandardObjectives_StandardObjectiveID] FOREIGN KEY([StandardObjectiveID])
REFERENCES [dbo].[StandardObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StandardObjective_Tag] CHECK CONSTRAINT [FK_dbo.StandardObjective_Tag_dbo.StandardObjectives_StandardObjectiveID]
GO
ALTER TABLE [dbo].[StandardObjective_Tag]  WITH CHECK ADD  CONSTRAINT [FK_dbo.StandardObjective_Tag_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StandardObjective_Tag] CHECK CONSTRAINT [FK_dbo.StandardObjective_Tag_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[StandardObjectives]  WITH CHECK ADD  CONSTRAINT [FK_dbo.StandardObjectives_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[StandardObjectives] CHECK CONSTRAINT [FK_dbo.StandardObjectives_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[StandardObjectives]  WITH CHECK ADD  CONSTRAINT [FK_dbo.StandardObjectives_dbo.Clients_OwnerClientID] FOREIGN KEY([OwnerClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[StandardObjectives] CHECK CONSTRAINT [FK_dbo.StandardObjectives_dbo.Clients_OwnerClientID]
GO
ALTER TABLE [dbo].[StandardObjectives]  WITH CHECK ADD  CONSTRAINT [FK_dbo.StandardObjectives_dbo.TagFilters_TagFilterID] FOREIGN KEY([TagFilterID])
REFERENCES [dbo].[TagFilters] ([ID])
GO
ALTER TABLE [dbo].[StandardObjectives] CHECK CONSTRAINT [FK_dbo.StandardObjectives_dbo.TagFilters_TagFilterID]
GO
ALTER TABLE [dbo].[Standards]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Standards_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Standards] CHECK CONSTRAINT [FK_dbo.Standards_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[Standards]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Standards_dbo.Clients_OwnerClientID] FOREIGN KEY([OwnerClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[Standards] CHECK CONSTRAINT [FK_dbo.Standards_dbo.Clients_OwnerClientID]
GO
ALTER TABLE [dbo].[StudentSchedulingPreferences]  WITH CHECK ADD  CONSTRAINT [FK_dbo.StudentSchedulingPreferences_dbo.SchedulingTimeBlocks_SchedulingTimeBlockID] FOREIGN KEY([SchedulingTimeBlockID])
REFERENCES [dbo].[SchedulingTimeBlocks] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StudentSchedulingPreferences] CHECK CONSTRAINT [FK_dbo.StudentSchedulingPreferences_dbo.SchedulingTimeBlocks_SchedulingTimeBlockID]
GO
ALTER TABLE [dbo].[StudentSchedulingPreferences]  WITH CHECK ADD  CONSTRAINT [FK_dbo.StudentSchedulingPreferences_dbo.StudentSchedulingRounds_StudentSchedulingRoundID] FOREIGN KEY([StudentSchedulingRoundID])
REFERENCES [dbo].[StudentSchedulingRounds] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StudentSchedulingPreferences] CHECK CONSTRAINT [FK_dbo.StudentSchedulingPreferences_dbo.StudentSchedulingRounds_StudentSchedulingRoundID]
GO
ALTER TABLE [dbo].[StudentSchedulingPreferences]  WITH CHECK ADD  CONSTRAINT [FK_dbo.StudentSchedulingPreferences_dbo.Tags_CourseUsageID] FOREIGN KEY([CourseUsageID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StudentSchedulingPreferences] CHECK CONSTRAINT [FK_dbo.StudentSchedulingPreferences_dbo.Tags_CourseUsageID]
GO
ALTER TABLE [dbo].[StudentSchedulingRounds]  WITH CHECK ADD  CONSTRAINT [FK_dbo.StudentSchedulingRounds_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StudentSchedulingRounds] CHECK CONSTRAINT [FK_dbo.StudentSchedulingRounds_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[StudentSchedulingRounds]  WITH CHECK ADD  CONSTRAINT [FK_dbo.StudentSchedulingRounds_dbo.SchedulingRounds_SchedulingRoundID] FOREIGN KEY([SchedulingRoundID])
REFERENCES [dbo].[SchedulingRounds] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StudentSchedulingRounds] CHECK CONSTRAINT [FK_dbo.StudentSchedulingRounds_dbo.SchedulingRounds_SchedulingRoundID]
GO
ALTER TABLE [dbo].[SubLocations]  WITH CHECK ADD  CONSTRAINT [FK_dbo.SubLocations_dbo.Locations_LocationID] FOREIGN KEY([LocationID])
REFERENCES [dbo].[Locations] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SubLocations] CHECK CONSTRAINT [FK_dbo.SubLocations_dbo.Locations_LocationID]
GO
ALTER TABLE [dbo].[Tag_TagGroup]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Tag_TagGroup_dbo.TagGroups_TagGroupID] FOREIGN KEY([TagGroupID])
REFERENCES [dbo].[TagGroups] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Tag_TagGroup] CHECK CONSTRAINT [FK_dbo.Tag_TagGroup_dbo.TagGroups_TagGroupID]
GO
ALTER TABLE [dbo].[Tag_TagGroup]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Tag_TagGroup_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Tag_TagGroup] CHECK CONSTRAINT [FK_dbo.Tag_TagGroup_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[TagCategories]  WITH CHECK ADD  CONSTRAINT [FK_dbo.TagCategories_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[TagCategories] CHECK CONSTRAINT [FK_dbo.TagCategories_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[TagCategories]  WITH CHECK ADD  CONSTRAINT [FK_dbo.TagCategories_dbo.Clients_OwnerClientID] FOREIGN KEY([OwnerClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[TagCategories] CHECK CONSTRAINT [FK_dbo.TagCategories_dbo.Clients_OwnerClientID]
GO
ALTER TABLE [dbo].[TagGroups]  WITH CHECK ADD  CONSTRAINT [FK_dbo.TagGroups_dbo.TagFilters_TagFilterID] FOREIGN KEY([TagFilterID])
REFERENCES [dbo].[TagFilters] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TagGroups] CHECK CONSTRAINT [FK_dbo.TagGroups_dbo.TagFilters_TagFilterID]
GO
ALTER TABLE [dbo].[Tags]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Tags_dbo.TagCategories_TagCategoryID] FOREIGN KEY([TagCategoryID])
REFERENCES [dbo].[TagCategories] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Tags] CHECK CONSTRAINT [FK_dbo.Tags_dbo.TagCategories_TagCategoryID]
GO
ALTER TABLE [dbo].[TagSearchTerms]  WITH CHECK ADD  CONSTRAINT [FK_dbo.TagSearchTerms_dbo.Tags_TagID] FOREIGN KEY([TagID])
REFERENCES [dbo].[Tags] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TagSearchTerms] CHECK CONSTRAINT [FK_dbo.TagSearchTerms_dbo.Tags_TagID]
GO
ALTER TABLE [dbo].[ThesaurusSynonyms]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ThesaurusSynonyms_dbo.ThesaurusTerms_ThesaurusTermID] FOREIGN KEY([ThesaurusTermID])
REFERENCES [dbo].[ThesaurusTerms] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ThesaurusSynonyms] CHECK CONSTRAINT [FK_dbo.ThesaurusSynonyms_dbo.ThesaurusTerms_ThesaurusTermID]
GO
ALTER TABLE [dbo].[ThesaurusTerms]  WITH CHECK ADD  CONSTRAINT [FK_dbo.ThesaurusTerms_dbo.Clients_ClientID] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ID])
GO
ALTER TABLE [dbo].[ThesaurusTerms] CHECK CONSTRAINT [FK_dbo.ThesaurusTerms_dbo.Clients_ClientID]
GO
ALTER TABLE [dbo].[UnderstandFlags]  WITH CHECK ADD  CONSTRAINT [FK_dbo.UnderstandFlags_dbo.LearningObjectives_LearningObjectiveID] FOREIGN KEY([LearningObjectiveID])
REFERENCES [dbo].[LearningObjectives] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UnderstandFlags] CHECK CONSTRAINT [FK_dbo.UnderstandFlags_dbo.LearningObjectives_LearningObjectiveID]
GO
ALTER TABLE [dbo].[UnderstandFlags]  WITH CHECK ADD  CONSTRAINT [FK_dbo.UnderstandFlags_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UnderstandFlags] CHECK CONSTRAINT [FK_dbo.UnderstandFlags_dbo.People_PersonID]
GO
ALTER TABLE [dbo].[UserSettings]  WITH CHECK ADD  CONSTRAINT [FK_dbo.UserSettings_dbo.People_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[People] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserSettings] CHECK CONSTRAINT [FK_dbo.UserSettings_dbo.People_PersonID]
GO
ALTER TABLE [Reference].[TaxonomyActionVerbs]  WITH CHECK ADD  CONSTRAINT [FK_Reference.TaxonomyActionVerbs_Reference.TaxonomyLevels_TaxonomyLevelID] FOREIGN KEY([TaxonomyLevelID])
REFERENCES [Reference].[TaxonomyLevels] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [Reference].[TaxonomyActionVerbs] CHECK CONSTRAINT [FK_Reference.TaxonomyActionVerbs_Reference.TaxonomyLevels_TaxonomyLevelID]
GO
ALTER TABLE [Reference].[TaxonomyDomains]  WITH CHECK ADD  CONSTRAINT [FK_Reference.TaxonomyDomains_Reference.Taxonomies_TaxonomyID] FOREIGN KEY([TaxonomyID])
REFERENCES [Reference].[Taxonomies] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [Reference].[TaxonomyDomains] CHECK CONSTRAINT [FK_Reference.TaxonomyDomains_Reference.Taxonomies_TaxonomyID]
GO
ALTER TABLE [Reference].[TaxonomyLevels]  WITH CHECK ADD  CONSTRAINT [FK_Reference.TaxonomyLevels_Reference.TaxonomyDomains_TaxonomyDomainID] FOREIGN KEY([TaxonomyDomainID])
REFERENCES [Reference].[TaxonomyDomains] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [Reference].[TaxonomyLevels] CHECK CONSTRAINT [FK_Reference.TaxonomyLevels_Reference.TaxonomyDomains_TaxonomyDomainID]
GO
/****** Object:  StoredProcedure [dbo].[Assessment_GetSubjects]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Assessment_GetSubjects] (@assessmentID uniqueidentifier, @byScheduledEvent bit, @nameSearch varchar(max))
as
begin

	declare @rootID uniqueidentifier

	select @rootID = coalesce(ev.RootID, ex.RootID)
		from assessments a
		left outer join Evaluations ev on a.ID = ev.ID
		left outer join Examinations ex on a.ID = ex.ID
		where a.id = @assessmentID

	if (@byScheduledEvent = 1)
		select ID, EntityType, DisplayID, ScheduledEventID, ScheduledEventName, ScheduledEventDisplayID, Name, COUNT(*) as Total
		from(
		select sa.Subject_EntityID as ID, 
				sa.Subject_EntityType as EntityType, 
				CASE
				WHEN c.ID is not null THEN c.DisplayID
				WHEN p.ID is not null THEN p.DisplayID
				ELSE null
				END as DisplayID,
				ase.ScheduledEventID as ScheduledEventID,
				se.Name as ScheduledEventName,
				se.DisplayID as ScheduledEventDisplayID,
				CASE  
				WHEN c.ID is not null THEN c.Name
				WHEN p.ID is not null THEN ISNULL(p.LastName, '') + ', ' + ISNULL(p.FirstName, '') + ' ' + ISNULL(p.MiddleName, '')
				ELSE null 
				END as Name
		from ScheduledAssessments sa
		join Assessment_ScheduledEvent ase on sa.AssessmentScheduledEventID = ase.ID
		join Scheduled_Events se on ase.ScheduledEventID = se.ID
		left outer join People p on sa.Subject_EntityID = p.ID
		left outer join Courses c on sa.Subject_EntityID = c.ID
		left outer join Evaluations ev on sa.AssessmentID = ev.ID
		left outer join Examinations ex on sa.AssessmentID = ex.ID
		where ev.RootID = @rootID or ex.RootID = @rootID
		) as subjects
		where @nameSearch is null or subjects.Name like ('%' + @nameSearch + '%')
		group by subjects.ID, subjects.EntityType, DisplayID, subjects.Name, subjects.ScheduledEventID, ScheduledEventName, ScheduledEventDisplayID
	else
		select ID, EntityType, DisplayID, Name, COUNT(*) as Total
		from(
		select sa.Subject_EntityID as ID, 
				sa.Subject_EntityType as EntityType, 
				CASE
				WHEN c.ID is not null THEN c.DisplayID
				WHEN p.ID is not null THEN p.DisplayID
				ELSE null
				END as DisplayID,
				CASE  
				WHEN c.ID is not null THEN c.Name
				WHEN p.ID is not null THEN ISNULL(p.LastName, '') + ', ' + ISNULL(p.FirstName, '') + ' ' + ISNULL(p.MiddleName, '')
				ELSE null 
				END as Name
		from ScheduledAssessments sa
		left outer join People p on sa.Subject_EntityID = p.ID
		left outer join Courses c on sa.Subject_EntityID = c.ID
		left outer join Evaluations ev on sa.AssessmentID = ev.ID
		left outer join Examinations ex on sa.AssessmentID = ex.ID
		where ev.RootID = @rootID or ex.RootID = @rootID
		) as subjects
		where @nameSearch is null or subjects.Name like ('%' + @nameSearch + '%')
		group by subjects.ID, subjects.EntityType, DisplayID, subjects.Name
end
GO
/****** Object:  StoredProcedure [dbo].[AssessmentScheduleQueue_NextItemsToProcess]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[AssessmentScheduleQueue_NextItemsToProcess] (@numItems int)
as
begin
	set nocount on

	declare @lockID uniqueidentifier
	declare @now datetime
	select @lockID = newid(), @now = getdate()

	--	Safety check - if anything has been locked for 5 minutes, something went horribly wrong.  Just unlock them so they will schedule.
	update AssessmentScheduleQueue set LockDate = null, LockID = null where LockDate < dateadd(minute, -5, @now)

	--	Find the next @numItems from the queue.  They are all locked with the same lockID
	--	which is then used to fetch the details.

	--	Common Table Expression makes this atomic (the leading ; is not a typo - no idea why, but that's required!)
	;with cte as
	(
		select top (@numItems) asq.*
			from Assessment_ScheduledEvent a_se join AssessmentScheduleQueue asq on asq.ID = a_se.AssessmentScheduleQueueID
			where asq.LockID is null and (dbo.fn_AssessmentScheduledEvent_CalcStartDate(a_se.ID) <= @now)
	)
	update cte set LockDate=@now, LockID=@lockID, LastModifyDateTime = @now

	--	Return null if nothing available
	if (@@ROWCOUNT = 0)
		select @lockID=null

	select ID from AssessmentScheduleQueue where LockID=@lockID
end
GO
/****** Object:  StoredProcedure [dbo].[AssessmentScheduleQueue_Process]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[AssessmentScheduleQueue_Process] (@assessmentScheduleQueueID uniqueidentifier)
as
begin
    set xact_abort on
    set nocount on

    --	Needed for raiserror...
    declare @assessmentScheduleQueueIDString varchar(100)
    select @assessmentScheduleQueueIDString = cast(@assessmentScheduleQueueID as varchar(100))

    --	Load info and params about the assessment we are going to schedule
    declare @assessmentScheduledEventID uniqueidentifier
    declare @assessmentID uniqueidentifier
    declare @courseID uniqueidentifier
    declare @assessmentEntityType int
    declare @courseType int

    select @assessmentScheduledEventID = a_se.ID, @assessmentID = a_se.AssessmentID, 
            @assessmentEntityType = a.ParentEntityType, @courseID = se.CourseID, @courseType = c.Type
        from Assessment_ScheduledEvent a_se
            join Assessments a on a.ID = a_se.AssessmentID
            join Scheduled_Events se on se.ID = a_se.ScheduledEventID
            join Courses c on c.ID = se.CourseID
        where a_se.AssessmentScheduleQueueID = @assessmentScheduleQueueID
    if (@@ROWCOUNT < 1)
    begin
        raiserror('Failed to load parameters for AssessmentScheduleQueueID %s', 16, 1, @assessmentScheduleQueueIDString)
        return;
    end

    begin tran

    --	Evaluations for Calendar Courses need a notification queued up.
    if ((@assessmentEntityType = 2600) and (@courseType = 0))
    begin
        declare @evalName nvarchar(200)
        declare @clientID uniqueidentifier
        declare @startDate datetime
        declare @endDate datetime
        select @evalName = Name, @clientID = ClientID
            from Evaluations where ID = @assessmentID

        --	Need to cursor over the ScheduledAssessments that were just created - each one needs a notification
        --	and needs to be sent to the correct Assessor (so can't bulk insert these)
        declare notificationCurs cursor for
            select ID, AssessorID, StartDate, EndDate from ScheduledAssessments sa
                where sa.AssessmentScheduledEventID = @assessmentScheduledEventID
        open notificationCurs
    
        declare @scheduledAssessmentID uniqueidentifier
        declare @assessorID uniqueidentifier
        declare @results table (ID uniqueidentifier)
        declare @notificationID uniqueidentifier

        --	These vary depending on the type of notification/assessment so can't pass in from the biz because it
        --	doesn't know what's being scheduled.
        declare @notificationMessageType int
        declare @notificationEntityType int
        select @notificationMessageType = 100	-- NotificationMessageTypeEnum.EvaluationScheduled
        select @notificationEntityType = 530	-- EntityTypeEnum.ScheduledEvaluation

        while(1=1)
        begin
            fetch next from notificationCurs into @scheduledAssessmentID, @assessorID, @startDate, @endDate
            if (@@FETCH_STATUS <> 0)
                break

            if(@endDate is null)
                continue

            insert into Notifications (ClientID, NotificationMessageType, Subject, EmailContent, PushNotificationContent, 
                                    EntityTypeID, EntityID, CreatedDate, ActiveDate, InactiveDate, LastModifyDateTime)
                output inserted.ID into @results
                values (@clientID, @notificationMessageType, 'Evaluation: ' + @evalName,
                        'You have an evaluation that needs to be completed: ' + @evalName + '<br/><br/><br/><br/><br/>Sent from ' + (select 'DB Name: ' + DB_Name() + ', Server Name: ' + @@SERVERNAME),
                        'You have an evaluation that needs to be completed: ' + @evalName,
                        @notificationEntityType, @scheduledAssessmentID, getdate(), @startDate, @endDate, getdate())
            select @notificationID = ID from @results

            insert into NotificationPeople (NotificationID, PersonID, LastModifyDateTime)
                values (@notificationID, @assessorID, getdate())

            exec Notification_Queue @notificationID
        end

        close notificationCurs
        deallocate notificationCurs
    end

    --	Unlink the AssessmentScheduleQueue record and delete it
    update Assessment_ScheduledEvent set AssessmentScheduleQueueID = null where ID = @assessmentScheduledEventID
    delete AssessmentScheduleQueue where ID = @assessmentScheduleQueueID

    commit tran
end
GO
/****** Object:  StoredProcedure [dbo].[BackgroundTask_LockTaskByTypeAndFreq]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[BackgroundTask_LockTaskByTypeAndFreq] (@taskType int, @frequency int)
as
begin
	set nocount on

	declare @lockID uniqueidentifier
	select @lockID = newid()

	--	Find and lock any unlocked tasks of the same type and frequency.  This is used to merge
	--	a new task with an existing task to prevent us from spamming the same task lots of times if
	--	a user is making similar changes.

	--	Common Table Expression makes this atomic (the leading ; is not a typo - no idea why, but that's required!)
	;with cte as
	(
		select top (1) *
			from BackgroundTasks
			where LockID is null and TaskType = @taskType and Frequency = @frequency
	)
	update cte set LockDate=GETDATE(), LockID=@lockID

	select * from BackgroundTasks where LockID = @lockID
end
GO
/****** Object:  StoredProcedure [dbo].[BackgroundTask_NextTaskToExecute]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[BackgroundTask_NextTaskToExecute]
as
begin
	set nocount on

	declare @lockID uniqueidentifier
	select @lockID = newid()

	--	Safety check - if anything has been locked for 15 minutes, something went horribly wrong.  Just unlock them so they will send.
	update BackgroundTasks set LockDate = null, LockID = null where LockDate < dateadd(minute, -15, getdate())

	--	Find the next @numItems from the queue.  They are all locked with the same lockID
	--	which is then used to fetch the details.

	--	Common Table Expression makes this atomic (the leading ; is not a typo - no idea why, but that's required!)
	;with cte as
	(
		select top (1) *
			from BackgroundTasks
			where LockID is null and NextRunDate <= getdate() and Enabled = 1
			order by NextRunDate
	)
	update cte set LockDate=GETDATE(), LockID=@lockID

	select * from BackgroundTasks where LockID = @lockID
end
GO
/****** Object:  StoredProcedure [dbo].[Course_RosterSummaryReport]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Course_RosterSummaryReport] (@courseID uniqueidentifier, @clientID uniqueidentifier, @startDate datetime, @endDate datetime, @courseCompletionStatus int, @passed bit, @page int, @pageSize int) AS
begin
	SET NOCOUNT ON
    SET ANSI_WARNINGS OFF
	declare @points CourseAssessmentPointsTableType

	insert @points
		select *
		from [dbo].[fn_Course_GradebookAssessmentPoints](@courseID)

    select	p.FirstName, 
		p.LastName, 
		l.UserName, 
		phone.Number as PhoneNumber,
		email.[Address] as EmailAddress,
		addr.[Address],
		p.DisplayID as PersonDisplayID, 
		c.[Name] as CourseName,
		cp.StatusModifiedDate as StatusAchievedDate,
		cp.CompletionStatus as CourseStatus, 
		cp.HistoricalStatus as HistoricalStatus,
		[dbo].[fn_CoursePerson_CurrentCourseScore](cp.ID, @points) as CurrentGrade,
		CASE WHEN cp.StartDate is null THEN null ELSE DATEDIFF(day, cp.StartDate, cp.StatusModifiedDate) END as NumberOfDaysToComplete,
		[dbo].[fn_CoursePerson_CalculatePercentComplete](cp.ID) as ProgressPercent,
		CASE WHEN c.AttendanceParams_Track = 1 
			 THEN CASE WHEN att.ID is null
					   THEN 1 --Absent
					   ELSE 2 --Present
					   END
			 ELSE 3 --Not Tracked
			 END as AttendanceStatus,
		stuff(( select ','+t.Name
				from CoursePerson_Tag usage
				join Tags t on usage.TagID = t.ID
				where usage.CoursePersonID = cp.ID
				order by t.Name
				for xml path ('')), 1, 1, '') as CourseUsages,
		count(*) over() as TotalCoursePeople,
		org.OrgNames as Organizations
	from Course_People cp
	join People p on cp.PersonID = p.ID
	join Courses c on cp.CourseID = c.ID
	left outer join PersonClients pc on cp.PersonID = pc.PersonID and pc.ClientID = @clientID
	left outer join PersonScores ps on cp.ID = ps.CoursePersonID and ps.GradeBookID is not null --The course score...should only ever be one of these per course
	outer apply (select top 1 ID from Attendance a where a.CoursePersonID = cp.ID) att
	outer apply (select top 1 UserName from Logins lg where lg.PersonID = cp.PersonID) l		--Just choose the first user name...may delimit list this later?
	outer apply (select top 1 Number from PhoneNumbers pn where cp.PersonID = pn.PersonID) phone
	outer apply (select top 1 ISNULL(a.Address1, '') + ' ' + ISNULL(a.Address2, '') + ' ' + ISNULL(a.City, '') + ' ' + ISNULL(a.StateID, '') + ' ' + ISNULL(a.ZipCode, '') as [Address] from Addresses a where cp.PersonID = a.PersonID) addr
	outer apply (select top 1 [Address] from Emails e where cp.PersonID = e.PersonID) email
	outer apply (SELECT  STUFF((SELECT  ',' + o.[Name]
								from People_Roles pr
								join Organizations o on pr.OrganizationID = o.ID 
								where pr.PersonID = p.ID
								order by o.Name
				 FOR XML PATH('')), 1, 1, '') AS OrgNames) org
	where cp.CourseID = @courseID
		and cp.RoleType = 2 -- student
		and p.IsDeleted = 0
		and (pc.IsDeleted is null or pc.IsDeleted = 0)
		and (@startDate is null or @endDate is null or cp.StatusModifiedDate between @startDate and DATEADD(day, 1, @endDate))
		and (@courseCompletionStatus is null or @courseCompletionStatus = cp.CompletionStatus) 
		and (@passed is null or @courseCompletionStatus != 2 or (@passed = 1 and cp.HistoricalStatus = 2) or (@passed = 0 and cp.HistoricalStatus = 5))
	order by p.LastName, p.FirstName
	offset coalesce(@pageSize, 0) * coalesce(@page, 0)  rows
	fetch next coalesce(@pageSize, 0x7ffffff) rows only
end
GO
/****** Object:  StoredProcedure [dbo].[Degree_RetrieveUpcomingRenewals]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Degree_RetrieveUpcomingRenewals] 
as
begin
    --	Should not be possible for a Degree_Person record to be linked to a ContinuingEducationHistory
    --	that already has a DateCompleted or has a RenewalDueDate that is in the past (degree should have been
    --	expired before executing this!)
    declare @today date		--	date with no time!
    select @today = getdate()
    select	a.*, 
			DegreeName = d.Name, 
			ClientID = c.ID, 
			ClientName = c.Name, 
			ClientNotificationUrl = isnull(c.NotificationUrl, c.Domain), 
            SupportEmail = oe.Address, 
			SupportPhone = op.Number, 
			SupportWebsiteUrl = o.WebsiteUrl
        from
        (
            select	dp.ID, 
					dp.DegreeID, 
					dp.PersonID, 
					dp.ExpirationDate, 
					ceh.RenewalDueDate, 
					PersonFirstName = p.FirstName, 
					PersonLastName = p.LastName, 
					PersonDisplayID = p.DisplayID,
                    DaysUntilRenewalDueOrExpired = case when ceh.RenewalDueDate is null then datediff(day, @today, dp.ExpirationDate)
                                                        else datediff(day, @today, ceh.RenewalDueDate)
                                                    end
                from Degree_People dp
					join People p on dp.PersonID = p.ID and p.IsDeleted = 0
					join PersonClients pc on dp.PersonID = pc.PersonID and pc.IsDeleted = 0
                    left outer join ContinuingEducationHistory ceh on ceh.ID = dp.NextRequiredContinuingEducationRenewalID
                where dp.CompletionStatus = 2 and ceh.RenewalDueDate < dateadd(day, 61, @today)
        ) a
            join Degrees d on a.DegreeID = d.ID
            join Clients c on c.ID = d.ClientID
            left outer join Organizations o on o.ID = (select top 1 co.OrganizationID from Client_Organization co where co.ClientID = c.ID and co.OrganizationType = 1) -- Support Organization
            --  No idea why but these joins are *MUCH* more efficient like this.  You would think joining using o.ID would be better.
            --  But no.  It's a difference of over 4k reads (using o.ID) on PhoneNumbers vs. 6 (like this)!!!
            left outer join Emails oe on oe.OrganizationID = (select top 1 co.OrganizationID from Client_Organization co where co.ClientID = c.ID and co.OrganizationType = 1) -- Support Organization
                                            and oe.EmailTypeID = 4 -- Customer Service
            left outer join PhoneNumbers op on op.OrganizationID = (select top 1 co.OrganizationID from Client_Organization co where co.ClientID = c.ID and co.OrganizationType = 1) -- Support Organization
                                            and op.PhoneType = 3 -- Customer Service
        where a.DaysUntilRenewalDueOrExpired in (7, 14, 45, 60)    --  <= 0 should not be possible, we expire degrees before calling this
            --  Filter out any rows that already have notifications created today.  This prevents spam if
            --  the job runs again on the same day.
            and not exists (select top 1 1
                                from Notifications n
                                    join NotificationPeople np on NotificationID = n.ID
                                where np.PersonID = a.PersonID
                                        and n.ClientID = d.ClientID and n.EntityTypeID = 2320 /* Degree */ and n.EntityID = d.ID
                                        and convert(date, n.CreatedDate) = convert(date, getdate())    -- 'date' so this matches on date only - not time
                                        and n.NotificationMessageType in (50, 51) --NotificationMessageTypeEnum.DegreeExpiration or DegreeRenewalDue
                            )
end
GO
/****** Object:  StoredProcedure [dbo].[Degree_UpdatePersonStatus]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Degree_UpdatePersonStatus] (@personID uniqueidentifier, @degreeID uniqueidentifier, @degreeTrackID uniqueidentifier, @includeComplete bit) AS
begin
    SET NOCOUNT ON
    SET ANSI_WARNINGS OFF

    --  Find all of the Degree_Person records that need to be calculated based on the input params
    --  Never need to process any degrees that are expired (CompletionStatus=3).
    declare @degreePeople table (ID uniqueidentifier)
    if ((@personID is not null) or (@degreeID is not null))
    begin
        insert into @degreePeople 
            select ID 
                from Degree_People dp
                where (@personID is null or dp.PersonID = @personID) and
                      (@degreeID is null or dp.DegreeID = @degreeID) and
                      (@includeComplete = 1 or dp.CompletionStatus <> 3)
    end
    else if (@degreeTrackID is not null)
    begin
        --  If only @degreeTrackID is given, we need to do a bunch of extra work to figure out the affected degrees...
        insert into @degreePeople 
            select dp.ID 
                from DegreeGroupDegreeTracks dgdt
                    join DegreeGroups dg on dg.ID = dgdt.DegreeGroupID
                    join Degree_People dp on dp.DegreeID = dg.DegreeID
                where dgdt.DegreeTrackID = @degreeTrackID and 
					(@includeComplete = 1 or dp.CompletionStatus <> 3)
    end
    else
    begin
        --  Everything is null!  This can be used to manually recalculate everything but otherwise should never happen
        insert into @degreePeople 
            select dp.ID from Degree_People dp where @includeComplete = 1 or dp.CompletionStatus <> 3
    end

    --  Need to calculate these 1 at a time because of all the extra work that needs to be done for
    --  renewals and such
    declare @degreePersonID uniqueidentifier

    declare cursDegreePeople cursor for select ID from @degreePeople
    open cursDegreePeople

    while(1=1)
    begin
        fetch next from cursDegreePeople into @degreePersonID
        if (@@FETCH_STATUS <> 0)
            break

        exec DegreePerson_UpdateCompletionStatus @degreePersonID
    end

    close cursDegreePeople
    deallocate cursDegreePeople
end
GO
/****** Object:  StoredProcedure [dbo].[DegreePerson_CalculateStatus]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[DegreePerson_CalculateStatus] (@degreePersonID uniqueidentifier, @forContinuingEd bit, @coursePeriodStartDate datetime, @coursePeriodEndDate datetime) AS
begin
    --  Calculates the Degree Completion Status based on the current courses that have been completed (and passed!).
    --  @forContinuingEd: If 1, calculates for Continuing Ed.  Otherwise, for normal degree requirements
    --  @coursePeriodStartDate and @coursePeriodEndDate: If not null, only checks courses with a StatusModifiedDate between this period.
    --      Probably only applies to Continuing Ed - so that we can find courses completed during the renewal period (and because
    --      the same course could be used for multiple renewals)

    --  Can grab everything we need to do all the grouping (to handle all of the and/or/group conditions) in 1 query.
    declare @courseUsageAccruals table
    (
        DegreeTrackCourseUsageID uniqueidentifier,
        DegreeTrackCourseUsageMinimumCredits int,
        DegreeTrackGroupID uniqueidentifier,
        DegreeTrackID uniqueidentifier,
        DegreeGroupID uniqueidentifier,
        AccruedCredits int,
        InProgressCredits int,
		CompletionDate datetime
    )

    --  Find the number of in progress & earned credits for each Degree Track Course Usage
    --  "left outer" joins used to make sure that we return SOMETHING if the CU Tag is not configured or if
    --  the student is not even in the course.  This guarantees we will have a row for every possible
    --  DegreeTrackCourseUsage record which saves us from having to re-query this entire degree/track/CU/group hierarchy
    --  in the roll-up queries that will follow.
    --  ** row_number() is used here because we want the most recent CoursePerson (and only that 1 record) within the date period.
    --  We CANNOT use cp.Retaken=0 to do this because Continuing Ed courses are retaken.
    --  This embeded select with the "row_number() over partition" stuff adds a row number field (named "rn" in this case)
    --  that is grouped/partitioned by all of the uniqueidentifier values that make each of these rows unique to us (and
    --  it counts by CoursePerson.StatusModifiedDate desc so rn=1 is the most recent record in that period).
    --  Then we can just pick off the rn=1 records and we won't have any duplicates - only the results of the most recent will be considered.
    --  https://stackoverflow.com/questions/7118170/sql-server-select-only-the-rows-with-maxdate/7118233#7118233
    insert @courseUsageAccruals 
    select DegreeTrackCourseUsageID, DegreeTrackCourseUsageMinimumCredits, DegreeTrackGroupID, DegreeTrackID,
            DegreeGroupID, AccruedCredits, InProgressCredits, CompletionDate
        from (
            select DegreeTrackCourseUsageID=dtcu.ID, DegreeTrackCourseUsageMinimumCredits=dtcu.MinimumCredits, DegreeTrackGroupID=dtg.ID,
                    dtg.DegreeTrackID, dgdt.DegreeGroupID,
                    AccruedCredits = case when cp.CompletionStatus = 2 and (cp.HistoricalStatus = 2 or cp.HistoricalStatus = 6) then co.Credits else 0 end,        --  Completed and Passed or no gradebook (ps = null)
                    InProgressCredits = case when cp.CompletionStatus = 1 then co.Credits else 0 end,
					CompletionDate = case when cp.CompletionStatus = 2 then cp.StatusModifiedDate else null end,
					row_number() over (partition by dtcu.ID, dtg.ID, dtg.DegreeTrackID, dgdt.DegreeGroupID, cp.CourseID 
                                        order by cp.StatusModifiedDate desc) as rn
                from Degree_People dp
                    join Degrees d on d.ID = dp.DegreeID
                    join DegreeGroups dg on ((@forContinuingEd = 0) and (dg.DegreeID = dp.DegreeID) and (dg.ContinuingEducationRequirementsID is null))
                                         or ((@forContinuingEd = 1) and (dg.DegreeID is null) and (dg.ContinuingEducationRequirementsID = d.ContinuingEducationRequirementsID))
                    join DegreeGroupDegreeTracks dgdt on dgdt.DegreeGroupID = dg.ID
                    join DegreeTrackGroups dtg on dtg.DegreeTrackID = dgdt.DegreeTrackID
                    join DegreeTrackCourseUsages dtcu on dtcu.DegreeTrackGroupID = dtg.ID
                    join DegreeTrackCourseUsage_Tag dtcu_t on dtcu_t.DegreeTrackCourseUsageID = dtcu.ID
                    left outer join CourseOverview_Tag co_t on co_t.TagID = dtcu_t.TagID
                    left outer join CourseOverviews co on co.ID = co_t.CourseOverviewID
                    left outer join Courses c on c.CourseOverviewID = co_t.CourseOverviewID
                    left outer join Course_People cp on cp.CourseID = c.ID and cp.PersonID = dp.PersonID and cp.RoleType = 2 -- Student; do *NOT* use cp.Retaken here - see notes above about row_number()
                                                        and ((@coursePeriodStartDate is null) or (cast(cp.StatusModifiedDate as date) >= cast(@coursePeriodStartDate as date)))
                                                        and ((@coursePeriodEndDate is null) or (cast(cp.StatusModifiedDate as date) <= cast(@coursePeriodEndDate as date)))
                where dp.ID = @degreePersonID
            ) a
        where a.rn = 1

    --A Degree Track contains a collection of groups (DegreeTrackGroups).
    --In each group, there is a collection of Course Usages that are used 
    --to determine if certain course requirements have been met. 
    --The requirements of a group are met if ANY of the course usage requirements 
    --within the group are met.
    --The requirements of a degree track are met if ALL of the degree track group
    --requirements are met. 
    --Ex.
    --Degree Track 1 - NOT MET (Because at least 1 group is not met)
    --	Degree Track Group 1 - MET (Because at least 1 course usage is met)
    --		Course Usage 1 - MET
    --		Course Usage 1a - NOT MET
    --		Course Usage 1b - NOT MET
    --	Degree Track Group 2 - NOT MET
    --		Course Usage 2 - NOT MET
    --		Course Usage 2a - NOT MET

    declare @groupByDegreeTrack table
    (
        DegreeTrackID uniqueidentifier,
        DegreeGroupID uniqueidentifier,
        InProgressOrAccruedCredits int,
        TotalUnmetGroups int
    )

    --  Groups by DegreeTrack and finds the number of Groups inside it that have not been satisfied (do not have at least 1 completed Course Usage)
    insert into @groupByDegreeTrack
    select a.DegreeTrackID, a.DegreeGroupID,
            sum(a.InProgressOrAccruedCredits),
            sum(case when a.TotalPassedCourseUsages = 0 then 1 else 0 end)
        from (
            --  Groups by the DegreeTrackGroup and finds the number of Completed/Passed CourseUsages in the group.
            --  These are OR conditions so just need one completed CourseUsage in the Group to make it satisfied.
            select cua.DegreeTrackGroupID, cua.DegreeTrackID, cua.DegreeGroupID,
                    sum(cua.InProgressCredits) + sum(cua.AccruedCredits) as InProgressOrAccruedCredits,
                    sum(case when cua.AccruedCredits >= cua.DegreeTrackCourseUsageMinimumCredits then 1 else 0 end) as TotalPassedCourseUsages
                from @courseUsageAccruals cua
                group by cua.DegreeTrackGroupID, cua.DegreeTrackID, cua.DegreeGroupID
        ) a
        group by a.DegreeTrackID, a.DegreeGroupID

    --  At this point, the records only apply to the degree (or continuing ed requirements) so just sum them.  This finds the number of
    --  Groups inside it that have not been satisfied (do not have at least 1 completed Degree Track)
    declare @inProgressOrAccruedCredits int
    declare @totalUnmetDegreeGroups int
    select @inProgressOrAccruedCredits = sum(a.InProgressOrAccruedCredits),
            @totalUnmetDegreeGroups = sum(case when a.TotalCompletedDegreeTracks = 0 then 1 else 0 end)
        from (
            --  Groups by the DegreeGroup and finds the number of Completed/Passed DegreeTracks in the group.
            --  These are OR conditions so just need one completed DegreeTrack in the Group to make it satisfied.
            select gbdt.DegreeGroupID,
                    sum(gbdt.InProgressOrAccruedCredits) as InProgressOrAccruedCredits,
                    sum(case when gbdt.TotalUnmetGroups = 0 then 1 else 0 end) as TotalCompletedDegreeTracks
                from @groupByDegreeTrack gbdt
                group by gbdt.DegreeGroupID
        ) a

    declare @newDegreeStatus int
    select @newDegreeStatus = case when @totalUnmetDegreeGroups > 0
                                then case when @inProgressOrAccruedCredits > 0
                                            then 1 -- In Progress
                                            else 0 -- Not Started
                                        end
                                else 2 -- Complete
                                end
    
	declare @completionDate datetime
	select @completionDate = null
	if (@newDegreeStatus = 2)
	begin
		select @completionDate = max(CompletionDate)
		from @courseUsageAccruals
	end

    select @newDegreeStatus as Status, @completionDate as CompletionDate
end
GO
/****** Object:  StoredProcedure [dbo].[DegreePerson_UpdateCompletionStatus]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[DegreePerson_UpdateCompletionStatus] (@degreePersonID uniqueidentifier) AS
begin
    SET NOCOUNT ON
    SET ANSI_WARNINGS OFF

    --  Calculates the DegreePerson.CompletionStatus for a single DegreePerson record.

    declare @degreeStatus int
    declare @degreeCompletedDate datetime
    declare @statusModifiedDate datetime
    declare @nextRequiredContinuingEducationRenewalID uniqueidentifier
    declare @expirationDurationPeriod int
    declare @expirationDurationAmount int
    declare @renewalDurationPeriod int
    declare @renewalDurationAmount int
	declare @expirationBuffer int
    select  @degreeStatus = dp.CompletionStatus, 
			@degreeCompletedDate = dp.CompletedDate,
            @nextRequiredContinuingEducationRenewalID = dp.NextRequiredContinuingEducationRenewalID,
            @expirationDurationPeriod = d.ExpirationDuration_Period, 
			@expirationDurationAmount = d.ExpirationDuration_Amount,
            @renewalDurationPeriod = rft.RenewalFrequency_Period, 
			@renewalDurationAmount = rft.RenewalFrequency_Amount,
			@statusModifiedDate = dp.StatusModifiedDate,
			@expirationBuffer = d.ExpirationBuffer
        from Degree_People dp
            join Degrees d on d.ID = dp.DegreeID
            left join ContinuingEducationRequirements cer on cer.ID = d.ContinuingEducationRequirementsID
            left join Configuration.RenewalFrequencyTypes rft on rft.ID = cer.RenewalFrequencyID
        where dp.ID = @degreePersonID

    --  *** Note about dates:
    --  Expiration and Renewal dates must be 23:59:59.  We only display the date (no time) to the user.  So they would have
    --  no way to know that an expiration or renewal happens at 8am (or whatever).  This gives them the entire day and still lets
    --  us do comparisons that include the entire day (mostly, within < 1 sec anyway).
    if ((@degreeStatus = 0) or (@degreeStatus = 1))
    begin
        -- When status is "NotStarted" (0) or "InProgress" (1), calculate the current status based on completed courses.
        declare @newDegreeStatus int
        select @newDegreeStatus = dbo.fn_DegreePerson_CalculateCompletionStatus(@degreePersonID, 0, @statusModifiedDate, null)
        if (@newDegreeStatus <> @degreeStatus)
        begin
            if (@newDegreeStatus = 2) 
			begin
				declare @expirationDate datetime
				select @expirationDate = case when (@newDegreeStatus = 2) and (@expirationDurationAmount > 0)
										 then convert(datetime, convert(varchar(200), dbo.fn_AddDurationToDate(getdate(), @expirationDurationPeriod, @expirationDurationAmount), 111)+' 23:59:59', 111)
										 else null
										 end

				update Degree_People
					set CompletionStatus = @newDegreeStatus, 
						ExpirationDate = @expirationDate, 
						StatusModifiedDate = getdate() ,
						CompletedDate = case when @newDegreeStatus = 2 then getdate() else null end
					from Degree_People dp
					where dp.ID = @degreePersonID
				if (@renewalDurationAmount is not null and @renewalDurationAmount > 0)
				begin
					--  There shouldn't be any records here but just to be safe.  If there were, they will be rebuilt.
					update Degree_People set NextRequiredContinuingEducationRenewalID = null where ID =  @degreePersonID
					delete ContinuingEducationHistory where DegreePersonID = @degreePersonID

					--  Need to pre-populate the ContinuingEducationHistory for any required renewals.
					declare @nextRenewalDate datetime
					select @nextRenewalDate = convert(datetime, convert(varchar(200), dbo.fn_AddDurationToDate(getdate(), @renewalDurationPeriod, @renewalDurationAmount), 111)+' 23:59:59', 111)
					while(@nextRenewalDate < @expirationDate)
					begin
						insert into ContinuingEducationHistory (DegreePersonID, RenewalDueDate, LastModifyDateTime) 
							values (@degreePersonID, @nextRenewalDate, getdate())
						select @nextRenewalDate = dbo.fn_AddDurationToDate(@nextRenewalDate, @renewalDurationPeriod, @renewalDurationAmount)
					end

					--  Setting this will then check renewals.  Shouldn't be any under normal circumstances, but just in case a course has already
					--  been completed.  This will also link the Degree_People.NextRequiredContinuingEducationRenewalID
					select @degreeStatus = 2
				end
			end
			else
			begin
				update Degree_People
					set CompletionStatus = @newDegreeStatus, 
						StatusModifiedDate = getdate()
					from Degree_People dp
					where dp.ID = @degreePersonID
			end
        end
    end

    --  
    if (@degreeStatus = 2 and @expirationDurationAmount > 0)
    begin
        --  When status is Completed (2), calculate renewal status.  Loop over any pending renewals and check to see
        --  if they have been completed.
        declare cursContEdHistory cursor for 
            select ID, DateCompleted, RenewalDueDate
            from ContinuingEducationHistory 
            where DegreePersonID = @degreePersonID
            order by RenewalDueDate
        open cursContEdHistory

        declare @periodStartDate datetime
        declare @continuingEducationHistoryID uniqueidentifier
        declare @dateCompleted datetime
        declare @renewalDateTime datetime
        declare @renewalDegreeStatus int
        declare @nextRenewalHistoryID uniqueidentifier
		declare @updatedRenewalDate datetime
        
		select	@periodStartDate = @degreeCompletedDate, 
				@nextRenewalHistoryID = null

        while(1=1)
        begin
            fetch next from cursContEdHistory into @continuingEducationHistoryID, @dateCompleted, @renewalDateTime
            if (@@FETCH_STATUS <> 0)
                break

			select @updatedRenewalDate = @renewalDateTime
            if ((@dateCompleted is null) and (@periodStartDate < getdate()))
            begin
                select @renewalDegreeStatus = dbo.fn_DegreePerson_CalculateCompletionStatus(@degreePersonID, 1, @periodStartDate, DATEADD(day, @expirationBuffer, @renewalDateTime))
                if (@renewalDegreeStatus = 2)
                begin
                    --  Renewal has been completed
                    select @dateCompleted = getdate()
					if (@dateCompleted > @renewalDateTime)
					begin
						select @updatedRenewalDate = @dateCompleted
					end

					update ContinuingEducationHistory 
					set DateCompleted = @dateCompleted,
						RenewalDueDate = @updatedRenewalDate
					where ID = @continuingEducationHistoryID
                end
            end

            --  If @dateCompleted is (still) null, then this is the next renewal
            if ((@dateCompleted is null) and (@nextRenewalHistoryID is null))
                select @nextRenewalHistoryID = @continuingEducationHistoryID

            if (@periodStartDate > getdate())
            begin
                --  We're in the future.  Note that we need to iterate into the future so that we can capture the @nextRenewalHistoryID.
                break
            end
            select @periodStartDate = cast(cast(DATEADD(day, 1, @updatedRenewalDate) as date) as datetime) 
        end

        close cursContEdHistory
        deallocate cursContEdHistory

        --  compare nullable values: https://stackoverflow.com/questions/1075142/how-to-compare-values-which-may-both-be-null-is-t-sql/19395183#19395183
        --  This handles either value being null
        if (isnull(nullif(@nextRequiredContinuingEducationRenewalID, @nextRenewalHistoryID), nullif(@nextRenewalHistoryID, @nextRequiredContinuingEducationRenewalID)) is not null)
            update Degree_People set NextRequiredContinuingEducationRenewalID = @nextRenewalHistoryID where ID = @degreePersonID
    end
end
GO
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorsXml]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ELMAH_GetErrorsXml]
    @Application [nvarchar](60),
    @PageIndex [int] = 0,
    @PageSize [int] = 15,
    @TotalCount [int] OUT
AS
BEGIN
    
    SET NOCOUNT ON
    
    DECLARE @FirstTimeUTC DATETIME
    DECLARE @FirstSequence INT
    DECLARE @StartRow INT
    DECLARE @StartRowIndex INT
    
    SELECT 
    @TotalCount = COUNT(1) 
    FROM 
    [ELMAH_Error]
    
    -- Get the ID of the first error for the requested page
    
    SET @StartRowIndex = @PageIndex * @PageSize + 1
    
    IF @StartRowIndex <= @TotalCount
    BEGIN
    
    SET ROWCOUNT @StartRowIndex
    
    SELECT  
    @FirstTimeUTC = [TimeUtc],
    @FirstSequence = [Sequence]
    FROM 
    [ELMAH_Error]
    ORDER BY 
    [TimeUtc] DESC, 
    [Sequence] DESC
    
    END
    ELSE
    BEGIN
    
    SET @PageSize = 0
    
    END
    
    -- Now set the row count to the requested page size and get
    -- all records below it for the pertaining application.
    
    SET ROWCOUNT @PageSize
    
    SELECT 
    errorId     = [ErrorId], 
    application = [Application],
    host        = [Host], 
    type        = [Type],
    source      = [Source],
    message     = [Message],
    [user]      = [User],
    statusCode  = [StatusCode], 
    time        = CONVERT(VARCHAR(50), [TimeUtc], 126) + 'Z'
    FROM 
    [ELMAH_Error] error
    WHERE
    [TimeUtc] <= @FirstTimeUTC
    AND 
    [Sequence] <= @FirstSequence
    ORDER BY
    [TimeUtc] DESC, 
    [Sequence] DESC
    FOR
    XML AUTO
END
GO
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorXml]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ELMAH_GetErrorXml]
    @Application [nvarchar](60),
    @ErrorId [uniqueidentifier]
AS
BEGIN
    
    SET NOCOUNT ON
    
    SELECT 
    [AllXml]
    FROM 
    [ELMAH_Error]
    WHERE
    [ErrorId] = @ErrorId
END
GO
/****** Object:  StoredProcedure [dbo].[ELMAH_LogError]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ELMAH_LogError]
    @ErrorId [uniqueidentifier],
    @Application [nvarchar](60),
    @Host [nvarchar](50),
    @Type [nvarchar](100),
    @Source [nvarchar](60),
    @Message [nvarchar](500),
    @User [nvarchar](50),
    @AllXml [nvarchar](max),
    @StatusCode [int],
    @TimeUtc [datetime]
AS
BEGIN
    
    SET NOCOUNT ON
    
    IF (NOT EXISTS(SELECT top 1 1 FROM [ELMAH_Error] WHERE [Message] = @Message and TimeUtc > dateadd(minute, -5, @TimeUtc)))
    BEGIN
        INSERT INTO [ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [AllXml], [StatusCode], [TimeUtc])
        VALUES (@ErrorId, @Application, @Host, @Type, @Source, @Message, @User, @AllXml, @StatusCode, @TimeUtc)
    END

    DELETE FROM [ELMAH_Error]
    WHERE TimeUtc < DATEADD(d, -90, getdate())
END
GO
/****** Object:  StoredProcedure [dbo].[EntityType_Next_DisplayID]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[EntityType_Next_DisplayID](@entityID int)
as
begin
	set nocount on

	begin transaction
		declare @tempTable TABLE (number int, entity_prefix nvarchar(10))

		update Reference.EntityTypes 
			set LastID = (LastID + 1) 
			output inserted.LastID, deleted.DisplayIDPrefix into @tempTable 
		where ID = @entityID

		select case 
			when entity_prefix is null 
				then FORMAT(number, '0000') 
				else entity_prefix + FORMAT(number, '0000') 
			end 
		from @tempTable
	commit
end
GO
/****** Object:  StoredProcedure [dbo].[MobileDevice_Register]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[MobileDevice_Register] (@personID uniqueidentifier, @deviceRegistrationID nvarchar(200), @mobilePlatform nvarchar(50), 
										@osVersion nvarchar(20), @deviceManufacturer nvarchar(100), @appVersion nvarchar(20))
as
begin
	set nocount on
	set xact_abort on

	begin tran

	--	If the @deviceRegistrationID is already registered to another @personID, delete it.  This should only happen if
	--	someone logs in to the mobile app on the same device as a different user (and somehow did not log out first).
	delete from MobileDevices where PersonID <> @personID and DeviceRegistrationID = @deviceRegistrationID

	if exists (select top 1 1 from MobileDevices where DeviceRegistrationID = @deviceRegistrationID)
	begin
		update MobileDevices set PersonID = @personID, MobilePlatform=@mobilePlatform, OSVersion = @osVersion, 
				DeviceManufacturer = @deviceManufacturer, AppVersion = @appVersion, LastModifyDateTime = getdate()
			where DeviceRegistrationID = @deviceRegistrationID
	end else begin
		insert into MobileDevices (PersonID, DeviceRegistrationID, MobilePlatform, OSVersion, DeviceManufacturer, AppVersion, LastModifyDateTime)
			values (@personID, @deviceRegistrationID, @mobilePlatform, @osVersion, @deviceManufacturer, @appVersion, getdate())
	end

	commit tran
end
GO
/****** Object:  StoredProcedure [dbo].[Notification_MoveQueueItemToHistory]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Notification_MoveQueueItemToHistory] (@notificationQueueID uniqueidentifier, @newStatus int, @error nvarchar(1000) = null)
as
begin
	set nocount on
	set xact_abort on

	begin tran

	insert into NotificationHistory (NotificationPersonID, DeliveredDate, NotificationType, Address, Status, NumAttempts, LastErrorMessage, LastModifyDateTime)
		select nq.NotificationPersonID, GETDATE(), nq.NotificationType, nq.Address, @newStatus, nq.NumAttempts+1, 
				case when @error is null then nq.LastErrorMessage else @error end, getdate()
			from NotificationQueue nq
			where ID = @notificationQueueID

	delete from NotificationQueue where ID = @notificationQueueID

	commit tran
end
GO
/****** Object:  StoredProcedure [dbo].[Notification_NextQueuedItemsToSend]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Notification_NextQueuedItemsToSend] (@numItems int)
as
begin
	set nocount on

	declare @lockID uniqueidentifier
	select @lockID = newid()

	--	Safety check - if anything has been locked for 5 minutes, something went horribly wrong.  Just unlock them so they will send.
	update NotificationQueue set LockDate = null, LockID = null where LockDate < dateadd(minute, -5, getdate())

	--	Find the next @numItems from the queue.  They are all locked with the same lockID
	--	which is then used to fetch the details.

	--	Common Table Expression makes this atomic (the leading ; is not a typo - no idea why, but that's required!)
	;with cte as
	(
		select top (@numItems) *
			from NotificationQueue
			where LockID is null and NextAttemptDate <= getdate()
			order by NextAttemptDate
	)
	update cte set LockDate=GETDATE(), LockID=@lockID, LastAttemptDate = GETDATE(), LastModifyDateTime = GETDATE()

	--	Return null if nothing available
	if (@@ROWCOUNT = 0)
		select @lockID=null

	select @lockID

end
GO
/****** Object:  StoredProcedure [dbo].[Notification_Queue]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Notification_Queue](@notificationID uniqueidentifier)
as
begin
	set nocount on

	--	Not in a ref table - only in NotificationTypeEnum
	--	Email Notification Type = 1
	--	Android Push Notification = 2
	--	iOS Push Notification = 3

	--	Not in a ref table - only in NotificationStatusEnum
	--	Queued Status = 1

	--	TODO: Need configuration for which push notifications to send - user should be able to configure this inside app
	--	TODO: Will all notifications need to be queued?  May depend on the message type...

	insert into NotificationQueue (NotificationPersonID, Address, NextAttemptDate, NotificationType, Status, NumAttempts, LastModifyDateTime)
		select np.ID, 
				case when np.EmailAddress is not null then np.EmailAddress else e.Address end, --If the email is on the notification person override getting it from the email table because we may not have a person in the system that we want to send the email to
				getdate(), 1 /* Email Notification Type */, 1 /* Queued Status */, 0, getdate()
			from NotificationPeople np
				left join Emails e on e.PersonID = np.PersonID
			where np.NotificationID = @notificationID and (np.EmailAddress is not null or e.SendNotifications = 1)
		union
		select np.ID, md.DeviceRegistrationID, getdate(), 
				case when md.MobilePlatform = 'Android' then 2 /* Android Notification Type */
					 else 3 /* iOS Notification Type */ end,
				1 /* Queued Status */, 0, getdate()
			from NotificationPeople np
				join MobileDevices md on md.PersonID = np.PersonID
			where np.NotificationID = @notificationID
end
GO
/****** Object:  StoredProcedure [dbo].[Notification_UnlockQueueItem]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Notification_UnlockQueueItem] (@notificationQueueID uniqueidentifier, @incrementAttempts bit, @nextAttemptMinutes int, @error nvarchar(1000) = null)
as
begin
	set nocount on
	set xact_abort on

	update NotificationQueue
		set NumAttempts = case when @incrementAttempts = 1 then NumAttempts+1 else NumAttempts end,
			NextAttemptDate = DATEADD(minute, @nextAttemptMinutes, GETDATE()),
			LastErrorMessage = case when @error is not null then @error else LastErrorMessage end,
			LockDate = null,
			LockID = null,
			LastModifyDateTime = getdate()
		where ID = @notificationQueueID
end
GO
/****** Object:  StoredProcedure [dbo].[Person_Merge]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Person_Merge](@mergeFromPersonID uniqueidentifier, @mergeToPersonID uniqueidentifier)
as
begin
	set nocount on
	set xact_abort on

	declare @sql nvarchar(max),
			@from varchar(max),
			@to varchar(max);

	select @from = CAST(@mergeFromPersonID as varchar(max)),
			@to = CAST(@mergeToPersonID as varchar(max))

	declare @spIDs table (
		ID uniqueidentifier
	)
	insert @spIDs
	select spFrom.ID
	from Seminar_People spFrom
	join Seminar_People spTo on spFrom.SeminarID = spTo.SeminarID and spTo.PersonID = @mergeToPersonID
	where spFrom.PersonID = @mergeFromPersonID

	select  @sql = @sql + 'update Course_People set CompletionStatus = 3, HistoricalStatus = 3 where ID = ''' +  CAST(cp.ID as varchar(max)) + ''' '
	from Course_People cp
	where cp.AddedByID in (select ID from @spIDs)

	select @sql = @sql + 'delete Seminar_People where ID = ''' +  CAST(ID as varchar(max)) + ''' '
	from @spIDs

	declare @dpIDs table (
		ID uniqueidentifier
	)
	insert @dpIDs
	select dpFrom.ID
	from Degree_People dpFrom
	join Degree_People dpTo on dpFrom.DegreeID = dpTo.DegreeID and dpTo.PersonID = @mergeToPersonID and dpTo.CompletionStatus < 2
	where dpFrom.PersonID = @mergeFromPersonID
		and dpFrom.CompletionStatus < 2

	select @sql = @sql + 'delete Degree_People where ID = ''' +  CAST(ID as varchar(max)) + ''' '
	from @dpIDs

	declare @orgIDs table (
		ID uniqueidentifier
	)
	insert @orgIDs
	select prFrom.ID
	from People_Roles prFrom
	join People_Roles prTo on (prFrom.OrganizationID = prTo.OrganizationID or (prFrom.OrganizationID is null and prTo.OrganizationID is not null)) 
						and prFrom.RoleID = prTo.RoleID and prTo.PersonID = @mergeToPersonID
	where prFrom.PersonID = @mergeFromPersonID 


	select @sql = @sql + 'delete People_Roles where ID = ''' +  CAST(ID as varchar(max)) + ''' '
	from @orgIDs

	select @sql = 'delete Logins where PersonID = ''' + @from + ''' '

	SELECT @sql = @sql + 
			STUFF((
			select ' update x set [PersonID] = ''' + @to + ''' from [' + OBJECT_SCHEMA_NAME(xsi.[object_id]) + '].[' + OBJECT_NAME(xsi.[object_id]) + '] x left outer join [' + OBJECT_SCHEMA_NAME(xsi.[object_id]) + '].[' + OBJECT_NAME(xsi.[object_id]) + '] y on' + 
				STUFF((
				SELECT ' and x.[' + c.[name] + ']=y.[' +  c.[name] + '] '
				FROM sys.indexes si
				join sys.index_columns sic on si.object_id = sic.object_id and si.index_id = sic.index_id
				join sys.columns c on sic.object_id = c.object_id and sic.column_id = c.column_id
				where c.name <> 'PersonID' and c.name <> 'ID'
					and si.[object_id] = xsi.[object_id]
					and (si.is_unique = 1 or si.is_primary_key = 1)
				FOR XML PATH('')), 1, 4, '') + ' and y.[PersonID] = ''' + @to + ''' where x.[PersonID] = ''' + @from + ''' and y.[PersonID] is null delete from [' + OBJECT_SCHEMA_NAME(xsi.[object_id]) + '].[' + OBJECT_NAME(xsi.[object_id]) + '] where [PersonID] = ''' + @from + ''''

			FROM sys.indexes xsi
			join sys.index_columns xsic on xsi.object_id = xsic.object_id and xsi.index_id = xsic.index_id
			join sys.columns xc on xsic.object_id = xc.object_id and xsic.column_id = xc.column_id
			where xc.name = 'PersonID' and (xsi.is_unique = 1 or xsi.is_primary_key = 1)
			FOR XML PATH('')), 1, 1, '')

	select @sql = @sql + 
			' update [dbo].[ScheduledAssessments] set [AssessorID] = ''' + CAST(@to as varchar(max)) + ''' where [AssessorID] = ''' + CAST(@from as varchar(max)) + ''' ' +
			STUFF((
			SELECT ' update [' + c.TABLE_SCHEMA + '].[' + c.TABLE_NAME + '] ' +	
			'set [PersonID] = ''' + CAST(@to as varchar(max)) + ''' ' + 
			'where [PersonID] = ''' + CAST(@from as varchar(max)) + ''' ' 
			from INFORMATION_SCHEMA.COLUMNS c
			where c.COLUMN_NAME = 'PersonID'
			FOR XML PATH('')), 1, 1, '') +
			'delete from [dbo].[People] where [ID] = ''' + CAST(@from as varchar(max)) + ''''

	select @sql = @sql +
		' delete from People_Roles where ID in ( select pr1.ID from people_roles pr1 join (select * from (select pr.PersonID, pr.RoleID, count(*) as total from People_Roles pr group by pr.PersonID, pr.RoleID) x where x.total > 1) y on pr1.PersonID = y.PersonID and pr1.RoleID = y.RoleID where pr1.OrganizationID is null)'

	begin transaction
	exec sp_executesql @sql
	commit transaction
end
GO
/****** Object:  StoredProcedure [dbo].[Registration_GetCourseRegistrationSettings]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Registration_GetCourseRegistrationSettings] (@personID uniqueidentifier) AS
begin
    SET NOCOUNT ON
    SET ANSI_WARNINGS OFF

	select c.ID as CourseID, case when dg.ContinuingEducationRequirementsID is null then 0 else 1 end as IsContinuingEducation 
	from courses c
	join CourseOverviews co on c.CourseOverviewID = co.ID
	join CourseOverview_Tag [cot] on co.ID = [cot].CourseOverviewID
	join DegreeTrackCourseUsage_Tag dtct on [cot].TagID = dtct.TagID
	join DegreeTrackCourseUsages dtcu on dtct.DegreeTrackCourseUsageID = dtcu.ID
	join DegreeTrackGroups dtg on dtcu.DegreeTrackGroupID = dtg.ID
	join DegreeTracks dt on dtg.DegreeTrackID = dt.ID
	join DegreeGroupDegreeTracks dgdt on dt.ID = dgdt.DegreeTrackID
	join DegreeGroups dg on dgdt.DegreeGroupID = dg.ID
	join Degrees d on dg.ContinuingEducationRequirementsID = d.ContinuingEducationRequirementsID or dg.DegreeID = d.ID
	join Degree_People dp on d.ID = dp.DegreeID 
							and dp.PersonID = @personID 
	left outer join ContinuingEducationHistory ceh on dp.NextRequiredContinuingEducationRenewalID = ceh.ID
	where c.IncludeInSelfRegistration = 1 
		and c.EntityState = 10 --Approved
		and (	(ceh.ID is null and (dp.CompletionStatus = 0 or dp.CompletionStatus = 1)) 
			or  (ceh.ID is not null and dp.CompletionStatus = 2 and ceh.RenewalDueDate > GETDATE()))
end
GO
/****** Object:  StoredProcedure [dbo].[ResourceAsset_CopyContentToNewResourceAsset]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ResourceAsset_CopyContentToNewResourceAsset](@oldResourceAssetID uniqueidentifier, @newResourceAssetID uniqueidentifier)
as
begin
    set nocount on

    --	This is called to copy the contents of one ResourceAsset to another one.
    --	Must be done this way (in a stored proc)
    --	to avoid loading the binary contents into memory - they could be huge so doing that could easily cause
    --	memory issues in the web server.

    --  Need to dynamically execute this because if the system is not configured to use FILESTREAM, the
    --  ResourceAssets.FileStreamContent column will not exist
    declare @usesFilestream bit
    select @usesFilestream = 0
    if exists (select top 1 1 from syscolumns where id=object_id('ResourceAssets') and name='FileStreamContent')
        select @usesFilestream = 1

	if (@usesFilestream = 1)
	begin
		update newRA 
		set newRA.Content = oldRA.Content, newRA.FileStreamContent = oldRA.FileStreamContent
		from ResourceAssets newRA 
		join (select ID, Content, FileStreamContent, ContentType from ResourceAssets where ID = @oldResourceAssetID) oldRA 
			on newRA.ContentType = oldRA.ContentType 
		where newRa.ID = @newResourceAssetID and newRA.FileStreamContent is null
	end
	else
	begin
		update newRA 
		set newRA.Content = oldRA.Content
		from ResourceAssets newRA 
		join (select ID, Content,ContentType from ResourceAssets where ID = @oldResourceAssetID) oldRA 
			on newRA.ContentType = oldRA.ContentType 
		where newRa.ID = @newResourceAssetID
	end
end
GO
/****** Object:  StoredProcedure [dbo].[ResourceAsset_MergeTemporaryChunks]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ResourceAsset_MergeTemporaryChunks] (@tempUploadID uniqueidentifier)
as
begin
    set nocount on

    begin tran

    declare @id uniqueidentifier
    declare @resourceAssetID uniqueidentifier
    declare @content varbinary(max)

    select @resourceAssetID = ID from ResourceAssets where TempUploadID = @tempUploadID and TempUploadChunkNum = 0

    declare curs cursor for 
        select ID, Content from ResourceAssets 
            where TempUploadID = @tempUploadID and TempUploadChunkNum > 0 
            order by TempUploadChunkNum
    open curs

    while(1=1)
    begin
        fetch next from curs into @id, @content
        if (@@FETCH_STATUS <> 0)
            break
    
        update ResourceAssets set Content.Write(@content, null, 0)
            where ID = @resourceAssetID
    end

    delete ResourceAssets where TempUploadID = @tempUploadID and TempUploadChunkNum > 0

    close curs
    deallocate curs

    commit tran

    select @resourceAssetID
end
GO
/****** Object:  StoredProcedure [dbo].[ScheduledAssessment_Fetch]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ScheduledAssessment_Fetch] (@scheduledAssessmentID uniqueidentifier, @includeFullDetails bit, @includeGradingData bit)
as
begin
    set nocount on

    --  EntityTypeEnum constants
    declare @entityTypeEvaluation int
    declare @entityTypeExamination int
    declare @entityTypeDirectObservation int
    declare @entityTypeLogRequirement int
    select @entityTypeEvaluation = 2600, @entityTypeExamination = 3150
    select @entityTypeDirectObservation = 2350, @entityTypeLogRequirement = 4350

    declare @assessmentScheduledEventID uniqueidentifier
    declare @assessmentID uniqueidentifier
    declare @scheduledEventID uniqueidentifier
    declare @assessmentScheduleParamsID uniqueidentifier
    declare @assessorID uniqueidentifier
    declare @coursePersonID uniqueidentifier
    declare @assessmentEntityType int
    declare @subjectEntityType int
    declare @subjectEntityID uniqueidentifier

    select @assessmentScheduledEventID = sa.AssessmentScheduledEventID, @assessmentID = sa.AssessmentID,
            @assessorID = sa.AssessorID, @coursePersonID = sa.CoursePersonID,
            @assessmentEntityType = a.ParentEntityType, @subjectEntityType = sa.Subject_EntityType, @subjectEntityID = sa.Subject_EntityID
        from ScheduledAssessments sa 
            join Assessments a on a.ID = sa.AssessmentID
        where sa.ID = @scheduledAssessmentID
    if (@assessmentScheduledEventID is not null)
    begin
        select @scheduledEventID = a_se.ScheduledEventID, @assessmentScheduleParamsID = a_se.AssessmentScheduleParamsID
            from Assessment_ScheduledEvent a_se
            where a_se.ID = @assessmentScheduledEventID
    end

    --  The main Assessment, Form (w/answers), and basic Scheduled Event info is always returned
    select * from ScheduledAssessments where ID = @scheduledAssessmentID
    select * from dbo.fn_AssessmentScheduledEvent_Subjects(@assessmentScheduledEventID, @assessorID, @coursePersonID, 1, 1, @subjectEntityType, @subjectEntityID)
    select * from ScheduledAssessmentProperties where ScheduledAssessmentID = @scheduledAssessmentID
    select * from Assessments where ID = @assessmentID
    select * from AssessmentForms where ID = @assessmentID
    select * from AssessmentFormSections where AssessmentFormID = @assessmentID
    select r.* from AssessmentFormSections s join AssessmentFormRows r on r.AssessmentFormSectionID = s.ID where s.AssessmentFormID = @assessmentID
    
	select distinct questions.*
	from (
		select q.*
		from AssessmentFormSections s 
		join AssessmentFormRows r on r.AssessmentFormSectionID = s.ID 
		join AssessmentFormRow_Question afr_q on afr_q.AssessmentFormRowID = r.ID 
		join Questions q on q.ID = afr_q.QuestionID
		where s.AssessmentFormID = @assessmentID
		union
		select q.*
		from Questions q
		join ScheduledAssessmentQuestions saq on q.ID = saq.QuestionID and saq.ScheduledAssessmentID = @scheduledAssessmentID
	) questions

	select distinct formRows.*
	from (
		select afr_q.AssessmentFormRowID, afr_q.QuestionID
		from AssessmentFormSections s 
		join AssessmentFormRows r on r.AssessmentFormSectionID = s.ID 
		join AssessmentFormRow_Question afr_q on afr_q.AssessmentFormRowID = r.ID 
		where s.AssessmentFormID = @assessmentID
		union
		select saq.AssessmentFormRowID, q.ID
		from Questions q
		join ScheduledAssessmentQuestions saq on q.ID = saq.QuestionID and saq.ScheduledAssessmentID = @scheduledAssessmentID
	) formRows

	select distinct possibleResponses.*
	from (
		select pr.*
		from AssessmentFormSections s 
		join AssessmentFormRows r on r.AssessmentFormSectionID = s.ID 
		join AssessmentFormRow_Question afr_q on afr_q.AssessmentFormRowID = r.ID 
		join PossibleResponses pr on pr.QuestionID = afr_q.QuestionID
		where s.AssessmentFormID = @assessmentID
		union
		select pr.*
		from ScheduledAssessmentQuestions saq 
		join PossibleResponses pr on saq.QuestionID = pr.QuestionID
		where saq.ScheduledAssessmentID = @scheduledAssessmentID
	) possibleResponses

	select distinct questionRows.*
	from (
		select qr.*
		from AssessmentFormSections s 
		join AssessmentFormRows r on r.AssessmentFormSectionID = s.ID 
		join AssessmentFormRow_Question afr_q on afr_q.AssessmentFormRowID = r.ID 
		join QuestionRows qr on qr.QuestionID = afr_q.QuestionID
		where s.AssessmentFormID = @assessmentID
		union
		select qr.*
		from ScheduledAssessmentQuestions saq 
		join QuestionRows qr on  saq.QuestionID = qr.QuestionID 
		where saq.ScheduledAssessmentID = @scheduledAssessmentID
	) questionRows

	select * from ScheduledAssessmentQuestions where ScheduledAssessmentID = @scheduledAssessmentID
    select a.* 
	from ScheduledAssessmentQuestions q 
	join ScheduledAssessmentAnswers a on a.ScheduledAssessmentQuestionID = q.ID 
	where q.ScheduledAssessmentID = @scheduledAssessmentID
    
	select * from Assessment_ScheduledEvent where ID = @assessmentScheduledEventID
    select * from Scheduled_Events where ID = @scheduledEventID
    select * from AssessmentScheduleParams where ID = @assessmentScheduleParamsID

    if (@includeFullDetails <> 0)
    begin
        --  Adds result sets for Interactive Content, the specic Assessment types, Assessor, Subjects, and the Assessor's Score
        select i.* from Assessments a join InteractiveContents i on i.ID = a.InteractiveContentID where a.ID = @assessmentID
        select * from People where ID = @assessorID

        --  Only need to select one of these depending on the actual entity type
        if (@assessmentEntityType = @entityTypeDirectObservation)
            select * from DirectObservations where ID = @assessmentID
        else if (@assessmentEntityType = @entityTypeEvaluation)
        begin
            select * from Evaluations where ID = @assessmentID
        end else if (@assessmentEntityType = @entityTypeExamination)
            select * from Examinations where ID = @assessmentID
        else if (@assessmentEntityType = @entityTypeLogRequirement)
            select * from LogRequirements where ID = @assessmentID
        else
        begin
            ;throw 50000, 'Unhandled Assessment EntityType', 1
            return;
        end
    end

    if ((@includeFullDetails <> 0) or (@includeGradingData <> 0))
    begin
        --  PersonScore records will only exist where PersonScore.PersonID == Assessor.PersonID and can only be 1 record (for the Assessor of THIS Scheduled Assessment) so this is safe - will not return scores for other people
        select * from PersonScores where ScheduledAssessmentID = @scheduledAssessmentID
    end

    if (@includeGradingData <> 0)
    begin
        declare @calendarID uniqueidentifier
        declare @courseID uniqueidentifier
        declare @gradebookID uniqueidentifier
        declare @gradingCriterionID uniqueidentifier

        select @calendarID = se.CalendarID, @courseID = c.ID, @gradebookID = c.GradeBookID, @gradingCriterionID = gb.GradingCriterionID
        from Scheduled_Events se
            join Calendars cal on cal.ID = se.CalendarID
            join Courses c on c.ID = cal.CourseID
            left outer join GradeBooks gb on gb.ID = c.GradeBookID
        where se.ID = @scheduledEventID

        select * from Calendars where ID = @calendarID
        select * from Courses where ID = @courseID
        select * from GradeBooks where ID = @gradebookID
        select * from GradeBookCategories where GradeBookID = @gradebookID
        select i.* from GradeBookCategories c join GradableItems i on i.CategoryID = c.ID where c.GradeBookID = @gradebookID
        select * from GradingCriterions where ID = @gradingCriterionID
        select * from GradingCriterionRanges where GradingCriterionID = @gradingCriterionID
    end
end
GO
/****** Object:  StoredProcedure [dbo].[ScheduledAssessment_FindRowForSaveResponse]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ScheduledAssessment_FindRowForSaveResponse] (@scheduledAssessmentID uniqueidentifier, @assessmentFormRowID uniqueidentifier, @scheduledAssessmentQuestionID uniqueidentifier = null)
as
begin
    set nocount on

    --  Returns all information needed when recording a response against a single row/question

    --  If this is for a Question Pool row, @scheduledAssessmentQuestionID will always be set.
    --  If not, we may not have created the ScheduledAssessmentQuestion record yet so the ID will be null.  In that
    --  case, we can get the question from the row (and there will be only 1)
    declare @questionID uniqueidentifier
    if (@scheduledAssessmentQuestionID is not null)
        select @questionID = QuestionID from ScheduledAssessmentQuestions where ID = @scheduledAssessmentQuestionID
    else
    begin
        --  See if there is an existing ScheduledAssessmentQuestions using the ScheduledAssessmentID & AssessmentFormRowID.
        --  This will happen when re-answering a question via TinCan api.
        select @questionID = QuestionID, @scheduledAssessmentQuestionID = ID
            from ScheduledAssessmentQuestions 
            where ScheduledAssessmentID = @scheduledAssessmentID and AssessmentFormRowID = @assessmentFormRowID

        --  If not found, we just don't have an existing ScheduledAssessmentQuestions record yet so need to find the questionID from AssessmentFormRow_Question
        if (@questionID is null)
            select top 1 @questionID = QuestionID from AssessmentFormRow_Question where AssessmentFormRowID = @assessmentFormRowID
    end

    select * from AssessmentFormRows where ID = @assessmentFormRowID
    select * from ScheduledAssessments where ID = @scheduledAssessmentID

    select * from Questions where ID = @questionID
    select AssessmentFormRowID=@assessmentFormRowID, QuestionID=@questionID
    select * from PossibleResponses where QuestionID = @questionID
    select * from QuestionRows where QuestionID = @questionID

    select * from ScheduledAssessmentQuestions where ID = @scheduledAssessmentQuestionID        --  ID may be null if not known/created yet but need to return results set anyway
    select * from ScheduledAssessmentAnswers where ScheduledAssessmentQuestionID = @scheduledAssessmentQuestionID
end
GO
/****** Object:  StoredProcedure [dbo].[ScheduledAssessment_GetInfoForActivity]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ScheduledAssessment_GetInfoForActivity] (@activityID uniqueidentifier, @personID uniqueidentifier)
as
begin
    --  Finds the status of the person (i.e. Assessor) and the Scheduled Assessment(s) for an Activity.
    --  Throws error 50000 on a configuration error.

    set xact_abort on
    set nocount on

    declare @assessmentID uniqueidentifier
    declare @activityType int
    declare @isAssessor bit
    declare @assessmentEntityType int
    declare @assessmentName nvarchar(1000)
    declare @assessmentDescription nvarchar(max)
    declare @assessmentInstructions nvarchar(max)
    declare @lastScheduledAssessmentID uniqueidentifier

    select @assessmentID = a.AssessmentID, @activityType = a.ActivityType,
           @isAssessor = case when exists (select top 1 1 from Activity_Person ap where ap.ActivityID = a.ID and ap.PersonID = @personID) then 1 else 0 end,
           @assessmentEntityType = asmnt.ParentEntityType,
           @assessmentName = a.Name, @assessmentDescription = a.Description, @assessmentInstructions = a.Instructions
        from Activities a
            join Assessments asmnt on asmnt.ID = a.AssessmentID
        where a.ID = @activityID

    --  If there are no instructions on the Activity, check to see if the assessment has any and use them if so.
    if ((@assessmentInstructions is null) or (@assessmentInstructions = ''))
    begin
        select @assessmentInstructions = a.Instructions from dbo.fn_Assessment_NameInfo(@assessmentID) a
    end

    if (@isAssessor = 1)
    begin
        --  Check to see if there is an unfinished/unsubmitted ScheduledAssessment for this Assessor/Activity.
        --  If so, we will need to return it to the client so it can be resumed.
        select @lastScheduledAssessmentID = ID
            from ScheduledAssessments
            where AssessorID = @personID and ActivityID = @activityID and Status = 0 -- ScheduledAssessmentStatusEnum.InProgress
    end

    select AssessmentID=@assessmentID,
           ActivityID=@activityID,
           ActivityType=@activityType,
           IsAssessor=@isAssessor,
           IsReviewer=@isAssessor,      --  Assessor is always review.  May also need to expand review to admins?  It will enable viewing results.
           AssessmentEntityType=@assessmentEntityType,
           AssessmentName=@assessmentName,
           AssessmentDescription=@assessmentDescription,
           AssessmentInstructions=@assessmentInstructions,
           LastScheduledAssessmentID=@lastScheduledAssessmentID

    --  This function expands the Subject info in the AssessmentScheduleParams record into the actual entities.
    --  Only needed on Evals
    --if (@assessmentEntityType = @entityTypeEvaluation)
    --begin
    --  todo: pull this from an existing ScheduledAssessment record which has Subject_EntityType & Subject_EntityID columns
    --    select * from dbo.fn_AssessmentScheduledEvent_Subjects(@assessmentScheduledEventID, @personID, @coursePersonID, @isAssessor, 1, null, null)
    --        order by Name
    --end
end
GO
/****** Object:  StoredProcedure [dbo].[ScheduledAssessment_GetInfoForScheduledEvent]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ScheduledAssessment_GetInfoForScheduledEvent] (@assessmentID uniqueidentifier, @scheduledEventID uniqueidentifier, @personID uniqueidentifier)
as
begin
    --  Finds the status of the person (i.e. Assessor vs Instructor) and the Scheduled Assessment(s) for an Assessment & Scheduled Event.
    --  Throws error 50000 on a configuration error.

    set xact_abort on
    set nocount on

    --  EntityTypeEnum constants
    declare @entityTypeEvaluation int
    declare @entityTypeExamination int
    declare @entityTypePerson int
    select @entityTypeEvaluation = 2600, @entityTypeExamination = 3150, @entityTypePerson = 5700

    --  Figure out if the person is either the Assessor (i.e. a student taking an exam or could be an instructor filling out an eval)
    --  or if the person is an Instructor in the course.  Can be both.  An Instructor may need to fill out evals and is also
    --  be able to review all of the results of those evals.
    declare @isAssessor bit
    declare @isInstructor bit
    declare @isGrader bit
    declare @isReviewer bit
    declare @assessmentScheduledEventID uniqueidentifier
    declare @assessmentEntityType int
    declare @scheduledAssessmentID uniqueidentifier
    declare @allowResubmission bit
    declare @maxNumResubmissions int
    declare @subjectEntityType int
    declare @subjectRoleType int
    declare @assessorRoleType int
    declare @assessmentName nvarchar(1000)
    declare @assessmentDescription nvarchar(max)
    declare @assessmentInstructions nvarchar(max)
    declare @assessmentIsGraded bit
    declare @startDate datetime
    declare @dueDate datetime
    declare @courseType int
    declare @coursePersonCompletionStatus int
    declare @coursePersonID uniqueidentifier

    select @isAssessor = dbo.fn_ScheduledEvent_CoursePersonIsRoleType (@scheduledEventID, asp.AssessorRoleType, cp.ID),
           @isInstructor = dbo.fn_ScheduledEvent_CoursePersonIsRoleType (@scheduledEventID, 3, cp.ID),
           @assessmentScheduledEventID = a_se.ID, 
           @allowResubmission=asp.AllowReSubmission, 
           @maxNumResubmissions=asp.MaxNumberOfResubmissions, 
           @subjectEntityType = asp.SubjectEntityType, 
           @subjectRoleType = asp.SubjectRoleType,
           @assessorRoleType = asp.AssessorRoleType,
           @startDate = se.ScheduledDate, 
           @courseType = c.[Type],
           @assessmentEntityType = a.ParentEntityType, 
           @assessmentIsGraded = a.IsGraded,
           @coursePersonCompletionStatus = cp.HistoricalStatus,
           @coursePersonID = cp.ID
        from Assessment_ScheduledEvent a_se
            join Assessments a on a.ID = a_se.AssessmentID
            join AssessmentScheduleParams asp on asp.ID = a_se.AssessmentScheduleParamsID
            join Scheduled_Events se on se.ID = a_se.ScheduledEventID
            join Courses c on c.ID = se.CourseID
            left outer join Course_People cp on c.ID = cp.CourseID and cp.PersonID = @personID      --  left outer b/c @personID may not be the student (could even be admin viewing from the Schedule)!
        where a_se.AssessmentID = @assessmentID 
			and a_se.ScheduledEventID = @scheduledEventID
            and cp.Retaken = 0       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)

    --  Find the basic info we need about the Assessment itself - to display to a user on the landing page, etc.
    --  This varies by the type of Assessment so add whatever is needed here so that we don't need to go
    --  get more stuff about it later
    select @assessmentName = a.Name, @assessmentDescription = a.Description, @assessmentInstructions = a.Instructions 
        from dbo.fn_Assessment_NameInfo(@assessmentID) a

    --  Only Evaluations in a Calendar Course have Start & Due dates
    if ((@assessmentEntityType = @entityTypeEvaluation) and (@courseType = 0))
        select @dueDate = dbo.fn_AssessmentScheduledEvent_CalcEndDate(@assessmentScheduledEventID)
    else
        select @startDate = null, @dueDate = null

    --  If person is the Assessor, need to find the current status (if any) of the most recent Scheduled Assessment.
    --  This is needed to know if we should resume an inprogress assessment, show results, or start taking a new one.
    --  TODO: This may not apply for Evaluations if the Assessor is able to evaluate multiple at once (i.e. an Instructor
    --  evaluating all Students in a Course or vice versa).
    if (@isAssessor = 1)
    begin
        select top 1 @scheduledAssessmentID=sa.ID from ScheduledAssessments sa
            where sa.AssessmentScheduledEventID = @assessmentScheduledEventID
                and CoursePersonID = @coursePersonID        --  Must filter on CoursePersonID to restrict to the correct course instance for this person
            order by sa.LastModifyDateTime desc

        --  If @maxNumResubmissions is null, retakes are unlimited so don't need to check anything else.
        --  Otherwise, need to check number of retakes and see if limit has been exceeded.
        if ((@allowResubmission = 1) and (@maxNumResubmissions is not null))
        begin
            --Check to see if they are allowed to retake the assessment or if they have taken it the max number of times
            --DO NOT use greater than or equal to because it is the number of retakes, so the first one doesn't count
            select @allowResubmission = case when count(ID) > @maxNumResubmissions then 0 else 1 end
                from ScheduledAssessments sa
                where sa.AssessmentScheduledEventID = @assessmentScheduledEventID
                    and CoursePersonID = @coursePersonID        --  Must filter on CoursePersonID to restrict to the correct course instance for this person
        end
    end

    --  Instructors are the Grader if they are not the Assessor and the Assessment actually requires grading
	--  The assessor is the grader as well when the assessment is an evaluation.
    select @isGrader = case when ((@isInstructor=1 and @isAssessor=0) or (@isAssessor=1 and @assessmentEntityType = @entityTypeEvaluation)) and @assessmentIsGraded=1 then 1 else 0 end

    --  Instructors are reviewers if they are not the Assessor except if they are the Subject of the Assessment
    --  Note: If an Instructor should be able to review assessments for OTHER Instructors (but not for themself) then
    --  we'll need to still set this to 1 and then do something else to limit this (in the UI or by excluding the
    --  subject record from being included for their PersonID in the fn_AssessmentScheduledEvent_Subjects query down below).
	
	-- We removed the subject check for the time being. See bug 2892.
	--select @isReviewer = case when (@isInstructor=1) and (@isAssessor=0) and not (@subjectEntityType = @entityTypePerson and coalesce(@subjectRoleType, 0) = 3) then 1 else 0 end

    select @isReviewer = case when (@isInstructor=1) and (@isAssessor=0) then 1 else 0 end

    select AssessmentID=@assessmentID,
           ScheduledEventID=@scheduledEventID,
           IsAssessor=@isAssessor,
           IsGrader=@isGrader,
           IsReviewer=@isReviewer,
           AssessmentEntityType=@assessmentEntityType,
           AssessmentName=@assessmentName,
           AssessmentDescription=@assessmentDescription,
           AssessmentInstructions=@assessmentInstructions,
           AssessmentIsGraded=@assessmentIsGraded,
		   AssessmentScheduledEventID = @assessmentScheduledEventID,
           AllowResubmission=@allowResubmission,
           SubjectEntityType=@subjectEntityType,
           SubjectRoleType=@subjectRoleType,
           AssessorRoleType=@assessorRoleType,
           LastScheduledAssessmentID=@scheduledAssessmentID,
           StartDate=@startDate,
           DueDate=@dueDate,
           StartByDate = dbo.fn_AssessmentScheduledEvent_CalcEndDate(@assessmentScheduledEventID),--If not started by this date it can't be started at all.  It's like a due date but for exams (currently is the same as due date for evals, maybe can eventually be expanded to give an estimated start time for evals to give the user an idea of when they'd need to start the eval to hav eit done in time?). Exams don't have a traditional due date in our system meaning they have a date that they can't be started after, but they aren't due until a designated time (the amount of time alloted to take the exam) has passed from the start.  I understand this is confusing, especially because the system doens't currently that the time limit on exams, but just go with it as a building block for the future
           CoursePersonCompletionStatus = @coursePersonCompletionStatus

    --  This function expands the Subject info in the AssessmentScheduleParams record into the actual entities.
    --  Only needed on Evals
    if (@isGrader = 1 or @isReviewer = 1)
    begin
        select * into #assessors from dbo.fn_AssessmentScheduledEvent_Assessors(@assessmentScheduledEventID, @assessorRoleType)

        select * from #assessors order by Name
        select ps.* from PersonScores ps
            join #assessors a on ps.ScheduledAssessmentID = a.LastScheduledAssessmentID

        drop table #assessors
    end
	if (@assessmentEntityType = @entityTypeEvaluation)
    begin
        select * from dbo.fn_AssessmentScheduledEvent_Subjects(@assessmentScheduledEventID, @personID, @coursePersonID, @isAssessor, 1, null, null)
            order by Name
    end 
end
GO
/****** Object:  StoredProcedure [dbo].[ScheduledAssessment_GetInfoForScheduledEventByCoursePerson]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ScheduledAssessment_GetInfoForScheduledEventByCoursePerson] (@assessmentID uniqueidentifier, @scheduledEventID uniqueidentifier, @coursePersonID uniqueidentifier)
as
begin
    --  Finds the status of the person (i.e. Assessor vs Instructor) and the Scheduled Assessment(s) for an Assessment & Scheduled Event.
    --  Throws error 50000 on a configuration error.

    set xact_abort on
    set nocount on

    --  EntityTypeEnum constants
    declare @entityTypeEvaluation int
    declare @entityTypeExamination int
    declare @entityTypePerson int
    select @entityTypeEvaluation = 2600, @entityTypeExamination = 3150, @entityTypePerson = 5700

    --  Figure out if the person is either the Assessor (i.e. a student taking an exam or could be an instructor filling out an eval)
    --  or if the person is an Instructor in the course.  Can be both.  An Instructor may need to fill out evals and is also
    --  be able to review all of the results of those evals.
    declare @isAssessor bit
    declare @isInstructor bit
    declare @isGrader bit
    declare @isReviewer bit
    declare @assessmentScheduledEventID uniqueidentifier
    declare @assessmentEntityType int
    declare @scheduledAssessmentID uniqueidentifier
    declare @allowResubmission bit
    declare @maxNumResubmissions int
    declare @subjectEntityType int
    declare @subjectRoleType int
    declare @assessorRoleType int
    declare @assessmentName nvarchar(1000)
    declare @assessmentDescription nvarchar(max)
    declare @assessmentInstructions nvarchar(max)
    declare @assessmentIsGraded bit
    declare @startDate datetime
    declare @dueDate datetime
    declare @courseType int
    declare @coursePersonCompletionStatus int
    declare @personID uniqueidentifier

    select @isAssessor = dbo.fn_ScheduledEvent_CoursePersonIsRoleType (@scheduledEventID, asp.AssessorRoleType, cp.ID),
           @isInstructor = dbo.fn_ScheduledEvent_CoursePersonIsRoleType (@scheduledEventID, 3, cp.ID),
           @assessmentScheduledEventID = a_se.ID, 
           @allowResubmission=asp.AllowReSubmission, 
           @maxNumResubmissions=asp.MaxNumberOfResubmissions, 
           @subjectEntityType = asp.SubjectEntityType, 
           @subjectRoleType = asp.SubjectRoleType,
           @assessorRoleType = asp.AssessorRoleType,
           @startDate = se.ScheduledDate, 
           @courseType = c.[Type],
           @assessmentEntityType = a.ParentEntityType, 
           @assessmentIsGraded = a.IsGraded,
           @coursePersonCompletionStatus = cp.HistoricalStatus,
           @personID = cp.PersonID
        from Assessment_ScheduledEvent a_se
            join Assessments a on a.ID = a_se.AssessmentID
            join AssessmentScheduleParams asp on asp.ID = a_se.AssessmentScheduleParamsID
            join Scheduled_Events se on se.ID = a_se.ScheduledEventID
            join Courses c on c.ID = se.CourseID
            join Course_People cp on cp.ID = @coursePersonID
        where a_se.AssessmentID = @assessmentID and a_se.ScheduledEventID = @scheduledEventID

    --  Find the basic info we need about the Assessment itself - to display to a user on the landing page, etc.
    --  This varies by the type of Assessment so add whatever is needed here so that we don't need to go
    --  get more stuff about it later
    select @assessmentName = a.Name, @assessmentDescription = a.Description, @assessmentInstructions = a.Instructions 
        from dbo.fn_Assessment_NameInfo(@assessmentID) a

    --  Only Evaluations in a Calendar Course have Start & Due dates
    if ((@assessmentEntityType = @entityTypeEvaluation) and (@courseType = 0))
        select @dueDate = dbo.fn_AssessmentScheduledEvent_CalcEndDate(@assessmentScheduledEventID)
    else
        select @startDate = null, @dueDate = null

    --  If person is the Assessor, need to find the current status (if any) of the most recent Scheduled Assessment.
    --  This is needed to know if we should resume an inprogress assessment, show results, or start taking a new one.
    --  TODO: This may not apply for Evaluations if the Assessor is able to evaluate multiple at once (i.e. an Instructor
    --  evaluating all Students in a Course or vice versa).
    if (@isAssessor = 1)
    begin
        select top 1 @scheduledAssessmentID=sa.ID from ScheduledAssessments sa
            where sa.AssessmentScheduledEventID = @assessmentScheduledEventID
                and CoursePersonID = @coursePersonID        --  Must filter on CoursePersonID to restrict to the correct course instance for this person
            order by sa.LastModifyDateTime desc

        --  If @maxNumResubmissions is null, retakes are unlimited so don't need to check anything else.
        --  Otherwise, need to check number of retakes and see if limit has been exceeded.
        if ((@allowResubmission = 1) and (@maxNumResubmissions is not null))
        begin
            --Check to see if they are allowed to retake the assessment or if they have taken it the max number of times
            --DO NOT use greater than or equal to because it is the number of retakes, so the first one doesn't count
            select @allowResubmission = case when count(ID) > @maxNumResubmissions then 0 else 1 end
                from ScheduledAssessments sa
                where sa.AssessmentScheduledEventID = @assessmentScheduledEventID
                    and CoursePersonID = @coursePersonID        --  Must filter on CoursePersonID to restrict to the correct course instance for this person
        end
    end

    --  Instructors are the Grader if they are not the Assessor and the Assessment actually requires grading
	--  The assessor is the grader as well when the assessment is an evaluation.
    select @isGrader = case when ((@isInstructor=1 and @isAssessor=0) or (@isAssessor=1 and @assessmentEntityType = @entityTypeEvaluation)) and @assessmentIsGraded=1 then 1 else 0 end

    --  Instructors are reviewers if they are not the Assessor except if they are the Subject of the Assessment
    --  Note: If an Instructor should be able to review assessments for OTHER Instructors (but not for themself) then
    --  we'll need to still set this to 1 and then do something else to limit this (in the UI or by excluding the
    --  subject record from being included for their PersonID in the fn_AssessmentScheduledEvent_Subjects query down below).
	
	-- We removed the subject check for the time being. See bug 2892.
	--select @isReviewer = case when (@isInstructor=1) and (@isAssessor=0) and not (@subjectEntityType = @entityTypePerson and coalesce(@subjectRoleType, 0) = 3) then 1 else 0 end

    select @isReviewer = case when (@isInstructor=1) and (@isAssessor=0) then 1 else 0 end

    select AssessmentID=@assessmentID,
           ScheduledEventID=@scheduledEventID,
           IsAssessor=@isAssessor,
           IsGrader=@isGrader,
           IsReviewer=@isReviewer,
           AssessmentEntityType=@assessmentEntityType,
           AssessmentName=@assessmentName,
           AssessmentDescription=@assessmentDescription,
           AssessmentInstructions=@assessmentInstructions,
           AssessmentIsGraded=@assessmentIsGraded,
		   AssessmentScheduledEventID = @assessmentScheduledEventID,
           AllowResubmission=@allowResubmission,
           SubjectEntityType=@subjectEntityType,
           SubjectRoleType=@subjectRoleType,
           AssessorRoleType=@assessorRoleType,
           LastScheduledAssessmentID=@scheduledAssessmentID,
           StartDate=@startDate,
           DueDate=@dueDate,
           StartByDate = dbo.fn_AssessmentScheduledEvent_CalcEndDate(@assessmentScheduledEventID),--If not started by this date it can't be started at all.  It's like a due date but for exams (currently is the same as due date for evals, maybe can eventually be expanded to give an estimated start time for evals to give the user an idea of when they'd need to start the eval to hav eit done in time?). Exams don't have a traditional due date in our system meaning they have a date that they can't be started after, but they aren't due until a designated time (the amount of time alloted to take the exam) has passed from the start.  I understand this is confusing, especially because the system doens't currently that the time limit on exams, but just go with it as a building block for the future
           CoursePersonCompletionStatus = @coursePersonCompletionStatus

    --  This function expands the Subject info in the AssessmentScheduleParams record into the actual entities.
    --  Only needed on Evals
	-- Stopped returning this information because is was causing serious performance problems. Switched it to a
	-- separate request that can be paged.
    --if (@isGrader = 1 or @isReviewer = 1)
    --begin
    --    select * into #assessors from dbo.fn_AssessmentScheduledEvent_Assessors(@assessmentScheduledEventID, @assessorRoleType)
    --    select * from #assessors order by Name
    --    select ps.* from PersonScores ps
    --        join #assessors a on ps.ScheduledAssessmentID = a.LastScheduledAssessmentID
    --    drop table #assessors
    --end
	if (@assessmentEntityType = @entityTypeEvaluation)
    begin
        select * from dbo.fn_AssessmentScheduledEvent_Subjects(@assessmentScheduledEventID, @personID, @coursePersonID, @isAssessor, 1, null, null)
            order by Name
    end 
end
GO
/****** Object:  StoredProcedure [dbo].[ScheduledAssessment_StartForActivity]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ScheduledAssessment_StartForActivity] (@activityID uniqueidentifier, @subjectEntityType int, @subjectEntityID uniqueidentifier, @personID uniqueidentifier)
as
begin
    --  Start a new ScheduledAssessment by creating a new ScheduledAssessment record.
    --  Throws error 50000 on a configuration error, the peson is not an Assessor,
    --  or if there is another inprogress Scheduled Assessment for this SubjectEntityID.

    set xact_abort on
    set nocount on

    --	Load info and params about the assessment we are going to schedule
    declare @scheduledAssessmentID uniqueidentifier
    declare @assessmentID uniqueidentifier

    select @assessmentID = AssessmentID from Activities where ID = @activityID

    begin tran

    --	Insert the ScheduledAssessments record
    declare @results table (ID uniqueidentifier)
    insert into ScheduledAssessments (AssessmentID, ActivityID, AssessorID, LastModifyDateTime, StartDate, Subject_EntityType, Subject_EntityID, CourseID, CoursePersonID)
        output inserted.ID into @results
        select @assessmentID, @activityID, @personID, getdate(), getdate(), @subjectEntityType, @subjectEntityID, null, null
    select @scheduledAssessmentID = ID from @results
    update ScheduledAssessments set BaseScheduledAssessmentID = @scheduledAssessmentID where ID = @scheduledAssessmentID

    commit tran

    select ScheduledAssessmentID = @scheduledAssessmentID
end
GO
/****** Object:  StoredProcedure [dbo].[ScheduledAssessment_StartForScheduledEvent]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ScheduledAssessment_StartForScheduledEvent] (@assessmentID uniqueidentifier, @scheduledEventID uniqueidentifier, @subjectEntityID uniqueidentifier, @personID uniqueidentifier)
as
begin
    --  Start a new ScheduledAssessment by creating a new ScheduledAssessment record.
    --  If there is another Scheduled Assessment for the same Assessment/ScheduledEvent/Assessor,
    --  it is linked via the BaseScheduledAssessmentID field.
    --  Throws error 50000 on a configuration error, the peson is not an Assessor,
    --  or if there is another inprogress Scheduled Assessment for this person.

    set xact_abort on
    set nocount on

    --  RoleTypesEnum constants
    declare @roleTypeStudent int
    declare @roleTypeInstructor int
    select @roleTypeStudent = 2, @roleTypeInstructor = 3

    --  CourseTypeEnum constants
    declare @courseTypeIndependentStudy int
    select @courseTypeIndependentStudy = 1

        --  EntityTypeEnum constants
    declare @entityTypeEvaluation int
    select @entityTypeEvaluation = 2600

    --	Load info and params about the assessment we are going to schedule
    declare @scheduledAssessmentID uniqueidentifier
    declare @assessmentScheduledEventID uniqueidentifier
    declare @courseID uniqueidentifier
    declare @coursePersonID uniqueidentifier
    declare @completionStatus int
    declare @courseType int
    declare @assessorRoleType int	--	Defined in RoleRypesEnum: 2 = Student, 3 = Instructor
    declare @assessmentEntityType int
    declare @allowResubmission bit
    declare @maxNumResubmissions int
    declare @totalAssessments int
    declare @baseScheduledAssessmentID uniqueidentifier
    declare @status int
    declare @subjectEntityType int

    select @assessmentScheduledEventID = a_se.ID,
            @assessorRoleType = p.AssessorRoleType,
            @assessmentEntityType = a.ParentEntityType, 
            @courseID = se.CourseID, @courseType = c.[Type],
            @allowResubmission = p.AllowResubmission,
            @maxNumResubmissions = p.MaxNumberOfResubmissions
        from Assessment_ScheduledEvent a_se
            join AssessmentScheduleParams p on a_se.AssessmentScheduleParamsID = p.ID
            join Assessments a on a.ID = a_se.AssessmentID
            join Scheduled_Events se on se.ID = a_se.ScheduledEventID
            join Courses c on c.ID = se.CourseID
        where a_se.AssessmentID = @assessmentID and a_se.ScheduledEventID = @scheduledEventID
    if (@@ROWCOUNT != 1)
    begin
        ;throw 50000, 'Failed to load parameters for Assessment_ScheduledEvent', 1
        return;
    end
    if ((@assessorRoleType != @roleTypeStudent) and (@assessorRoleType != @roleTypeInstructor))
    begin
        ;throw 50000, 'Unsupported Assessor RoleType', 1
        return
    end

    --  Find the current instance of the persons Course_People record.  Can only start an assessment against the current instance!
    select @coursePersonID = cp.ID, @completionStatus = cp.CompletionStatus
        from Course_People cp
			join Courses c on cp.CourseID = c.ID
            join People p on p.ID = cp.PersonID and p.IsDeleted = 0
			join PersonClients pc on cp.PersonID = pc.PersonID and pc.ClientID = c.ClientID and p.IsDeleted = 0
        where cp.CourseID = @courseID and cp.PersonID = @personID
		order by cp.StatusModifiedDate

    if (@completionStatus > 1)      --  CourseCompletionStatusEnum:; 0=NotStarted, 1=InProgress
    begin
        ;throw 50000, 'The course has been completed - no more assessments available', 1
        return
    end

    if (@coursePersonID is null)
    begin
        ;throw 50000, 'Person not found in course', 1
        return
    end

    --  Check to make sure @personID is @assessorRoleType within the scheduled event/calendar/course
    if (dbo.fn_ScheduledEvent_CoursePersonIsRoleType(@scheduledEventID, @assessorRoleType, @coursePersonID) = 0)
    begin
        --  Person is not an Assessor Role Type.
        ;throw 50000, 'Person is not Assessor RoleType', 1
        return
    end

    --  Check to make sure @personID is in this scheduled event and it's not locked
    if (dbo.fn_ScheduledEvent_IsAvailableForPerson(@scheduledEventID, @assessorRoleType, @coursePersonID) = 0)
    begin
        --  The Scheduled Event is locked for the person
        ;throw 50000, 'Scheduled Event is locked', 1
        return
    end

    --  SubjectEntityID/EntityType is required for an Evalation and not set otherwise
    select @subjectEntityType = null
    if (@assessmentEntityType = @entityTypeEvaluation)
    begin
        if (@subjectEntityID is null)
        begin
            ;throw 50000, 'SubjectEntityID not provided when starting an Evaluation', 1
            return
        end
    end else
        select @subjectEntityID = null

    --  Find the most recent existing ScheduledAssessment.  If the status is still in-progress, throw an error - this should not have been called.
    --  Otherwise, we need the BaseScheduledAssessmentID so that we can link this retake to the other(s).
    select @baseScheduledAssessmentID = null, @status = null
    select top 1 @baseScheduledAssessmentID = BaseScheduledAssessmentID, @status = Status, @scheduledAssessmentID = ID
    from ScheduledAssessments 
	where AssessmentScheduledEventID = @assessmentScheduledEventID
        and CoursePersonID = @coursePersonID        --  Must filter on CoursePersonID to restrict to the correct course instance for this person
        and ((@subjectEntityID is null) or (Subject_EntityID = @subjectEntityID))
    order by LastModifyDateTime desc

    if ((@status is not null) and (@status = 0))
    begin
		select ScheduledAssessmentID = @scheduledAssessmentID
        return
    end

    if (@baseScheduledAssessmentID is not null)
    begin
        --  This is a retake.  Make sure it's allowed
        if (@allowResubmission = 0)
        begin
            ;throw 50000, 'Assessment does not allow retakes', 1
            return
        end

        --  If @maxNumResubmissions is null, allows unlimited retakes.  Otherwise, need to figure out how many have been
        --  done and make sure the limit has not been exceeded.
        if (@maxNumResubmissions is not null)
        begin
            --Check to see if they are allowed to retake the assessment or if they have taken it the max number of times
            select @totalAssessments=count(ID) from ScheduledAssessments sa
                where sa.AssessmentScheduledEventID = @assessmentScheduledEventID
                    and sa.CoursePersonID = @coursePersonID        --  Must filter on CoursePersonID to restrict to the correct course instance for this person

            --DO NOT use greater than or equal to because it is the number of retakes, so the first one doesn't count
            if (@totalAssessments > @maxNumResubmissions)
            begin
                ;throw 50000, 'Assessment max number of retakes met', 1
                return
            end
        end
    end

    --  SubjectEntityID/EntityType is required for an Evalation and not set otherwise
    select @subjectEntityType = null
    if (@assessmentEntityType = @entityTypeEvaluation)
    begin
        if (@subjectEntityID is null)
        begin
            ;throw 50000, 'SubjectEntityID not provided when starting an Evaluation', 1
            return
        end

        --  Check to make sure it's valid and get the EntityType.
        select @subjectEntityType = EntityType from dbo.fn_AssessmentScheduledEvent_Subjects(@assessmentScheduledEventID, @personID, @coursePersonID, 1, 0, null, null)
            where EntityID = @subjectEntityID
        if (@subjectEntityType is null)
        begin
            ;throw 50000, 'SubjectEntityID is not valid for Evaluation', 1
            return
        end
    end else
        select @subjectEntityID = null

    --	Calculate the StartDate and End/Due Dates
    declare @startDate datetime
    declare @endDate datetime

    --  Start Date is *ALWAYS* now - we need to know when the user started it.
    --  This is also needed so that we can figure out the correct ordering if there have been multiple [re]takes.
    --  But, need to enforce that the assessment is not being started before it's allowed
    declare @configuredStartDate datetime
    select @configuredStartDate = dbo.fn_AssessmentScheduledEvent_CalcStartDate(@assessmentScheduledEventID)
    if ((@configuredStartDate is not null) and (getdate() < @configuredStartDate))
    begin
        ;throw 50001, 'The Assessment cannot be started yet', 1
        return
    end
    select @startDate = getdate()

    --  EndDate is the cutoff/due date.  Need to store this because it will allow us to find ScheduledAssessments that have
    --  been started and not finished in time.  For an Independent Study course, this will calculate as an offset from the start time
    --  (which is now).
    select @endDate = dbo.fn_AssessmentScheduledEvent_CalcEndDate(@assessmentScheduledEventID)
    if ((@endDate is not null) and (getdate() > @endDate))
    begin
        ;throw 50001, 'The Due Date of the Assessment has passed', 1
        return
    end

    begin tran

    --	Insert the ScheduledAssessments record
    declare @results table (ID uniqueidentifier)
    insert into ScheduledAssessments (AssessmentID, AssessmentScheduledEventID, CourseID, AssessorID, CoursePersonID, LastModifyDateTime, StartDate, EndDate, BaseScheduledAssessmentID, Subject_EntityID, Subject_EntityType)
        output inserted.ID into @results
        select @assessmentID, @assessmentScheduledEventID, @courseID, @personID, @coursePersonID, getdate(), @startDate, @endDate, @baseScheduledAssessmentID, @subjectEntityID, @subjectEntityType
    select @scheduledAssessmentID = ID from @results
    if (@baseScheduledAssessmentID is null)
        update ScheduledAssessments set BaseScheduledAssessmentID = @scheduledAssessmentID where ID = @scheduledAssessmentID

    commit tran

    select ScheduledAssessmentID = @scheduledAssessmentID
end
GO
/****** Object:  StoredProcedure [dbo].[ScheduledEvent_GetCourseCompleteInfo]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ScheduledEvent_GetCourseCompleteInfo] (@coursePersonID uniqueidentifier)
as
begin
    set nocount on

    declare @roleTypeStudent int,
			@roleTypeInstructor int,
			@personID uniqueidentifier,
			@courseID uniqueidentifier,
			@completionStatus int;
    select	@roleTypeStudent = 2,
			@roleTypeInstructor = 3  

	-- First, grab the most recent course person. This seems all wrong and should be more specific
	--	by sending the coursePersonID, but we may not always have it soo...most recent it is
	select top 1 @personID = PersonID, @courseID = CourseID, @completionStatus = CompletionStatus
	from Course_People
	where ID = @coursePersonID
	order by StartDate desc

    select TotalEvents=coalesce(count(*), 0), 
           NumVisibleEvents=coalesce(sum(case when [dbo].[fn_ScheduledEvent_IsAvailableForPerson](ID, @roleTypeStudent, @coursePersonID) = 1 then 1 else 0 end), 0),
           CourseCompletionStatus = coalesce(@completionStatus, 0)
        from (
            --  Scheduled Events filtered to just this person & course
            select ID
                from Scheduled_Events
                where (CourseID = @courseID) AND 
					(([dbo].[fn_ScheduledEvent_PersonIsRoleType](ID, @roleTypeStudent, @personID) = 1) OR ([dbo].[fn_ScheduledEvent_PersonIsRoleType](ID, @roleTypeInstructor, @personID) = 1))
        ) se
end
GO
/****** Object:  StoredProcedure [dbo].[ScheduledEvent_MarkItemComplete]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ScheduledEvent_MarkItemComplete] (@coursePersonID uniqueidentifier, @scheduledEventID uniqueidentifier, @entityID uniqueidentifier, @entityType int, @isUserDetermined bit, @complete bit)
as
begin
    --  Marks an entity in a Scheduled Event as Completed (in the ScheduledEventCompletedItems table) for the given person.

    set nocount on

    declare @newCompletionStatus int
    declare @oldCompletionStatus int
    declare @courseID uniqueidentifier
    declare @personID uniqueidentifier

    --  Calculate the students Course Completion Status.  If it's different, we return it so that we can process the status change
    --  in biz logic (which will then do an update on CoursePeople.Status)
    --  Note: Need to do this for a Task item too because that can trigger the status to now be In Progress (just by doing something in the course).
    select @courseID = CourseID from Scheduled_Events se where ID = @scheduledEventID

    --  Find the CoursePeopleID & current Status of the "current" instance of the Course_People record.
    select @oldCompletionStatus = CompletionStatus,
		   @personID = PersonID
        from Course_People 
        where ID = @coursePersonID

	if (@coursePersonID is not null)
	begin
		--  It looks like a convoluted way to do an "if not exists...then insert...or update" but it's much more efficient and atomic.
		--  Only do this merge if one of:
		--  1) @complete = 1: which means user has completed and we need to insert a record).  
		--  2) @isUserDetermined = 1: We will either delete or insert/update
		--  Do not do it if both are 0!  That means it has not been completed so we don't want to insert a record.  But if there is one
		--  already there, we need to keep it.
		if ((@complete = 1) or (@isUserDetermined = 1))
		begin
			-- Need to grab the root ID for assessments so that updated versions of assessments all get treated the same way
			if (@entityType = 3150) begin select @entityID = RootID	from Examinations where ID = @entityID end
			if (@entityType = 2600) begin select @entityID = RootID	from Evaluations where ID = @entityID end

			merge ScheduledEventCompletedItems as target
			using
			(
				select ScheduledEventID=@scheduledEventID, CoursePersonID=@coursePersonID, PersonID=@personID, ParentEntityID=@entityID, ParentEntityType=@entityType
			) as source (ScheduledEventID, CoursePersonID, PersonID, ParentEntityID, ParentEntityType)
			on (target.ScheduledEventID=source.ScheduledEventID and target.CoursePersonID=source.CoursePersonID and target.PersonID=source.PersonID and target.ParentEntityID=source.ParentEntityID)
			when matched and @isUserDetermined = 1 and @complete=0--If matched AND it's user deterimined AND the user is saying they haven't completed it, then delete it.  Don't delete if if it's not user determined entry because once it's been set the user has seen a resource or passed an assessment it can't be changed by failing an assessment retake
				then delete
			when matched--Already been completed so update Last modify date
				then update set LastModifyDateTime = getdate()
			when not matched by target--If it doesn't exist
				then insert (ScheduledEventID, CoursePersonID, PersonID, ParentEntityID, ParentEntityType, LastModifyDateTime, IsUserDetermined) 
							values (source.ScheduledEventID, source.CoursePersonID, source.PersonID, source.ParentEntityID, source.ParentEntityType, getdate(), @isUserDetermined);
		end

		select @newCompletionStatus = dbo.fn_Course_StudentCompletionStatus(@courseID, @coursePersonID, 1)
	end

    if (@newCompletionStatus <> @oldCompletionStatus)
        select @newCompletionStatus, @courseID
    else
        select -1, @courseID       --  this means no change
end
GO
/****** Object:  StoredProcedure [dbo].[Student_Progress_Report]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Student_Progress_Report] (@personID uniqueidentifier)
as
begin
    set nocount on

declare @totalResourcesViewed int,
        @totalRequiredResourcesViewed int,
        @totalRequiredResources int
declare @resourceTable TABLE(
    CourseID uniqueidentifier,
    TotalRequiredResources int,
    TotalCompletedResources int,
    TotalCompletedRequiredResources int
);

INSERT INTO @resourceTable
    select c.ID, SUM(CASE WHEN rse.Required = 1 THEN 1 ELSE 0 END) as TotalRequiredResources, SUM(CASE WHEN seci.IsUserDetermined = 1 or seci.IsUserDetermined is null THEN 0 ELSE 1 END) as TotalCompletedResources, SUM(CASE WHEN seci.IsUserDetermined = 1 or seci.IsUserDetermined is null or rse.Required = 0  THEN 0 ELSE 1 END) as TotalCompletedRequiredResources
    from people p
    join Course_People cp on p.ID = cp.PersonID and cp.RoleType = 2 -- Get the course where the person is a student
    join Courses c on cp.CourseID = c.ID
    join Scheduled_Events se on c.ID = se.CourseID and p.ID in (select PersonID from dbo.fn_ScheduledEvent_PeopleOfRole(se.ID, 2))
    join Resource_ScheduledEvents rse on se.ID = rse.ScheduledEventID
    left outer join ScheduledEventCompletedItems seci on se.ID = seci.ScheduledEventID and rse.ResourceID = seci.ParentEntityID and seci.CoursePersonID = cp.ID
    where p.ID = @personID and rse.ID is not null
        and cp.Retaken = 0       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)
    group by c.ID


select ISNULL(p.FirstName, '') + ' ' + ISNULL(p.MiddleName, '') + ' ' + ISNULL(p.LastName, '') as FullName,
        p.Title,
        c.ID as CourseID,
        c.DisplayID as CourseDisplayID,
        c.Name as CourseName,
        ISNULL(r.TotalCompletedResources, 0) as TotalCompletedResources,
        ISNULL(r.TotalRequiredResources, 0) as TotalRequiredResources,
        ISNULL(r.TotalCompletedRequiredResources, 0) as TotalCompletedRequiredResources,
        CASE WHEN ps.MaximumScore = 0 THEN 0 ELSE ps.Score/ps.MaximumScore END as CourseScore,
        ps.Grade as CourseGrade,
        ase.AssessmentID as AssessmentID,
        ase.Required as AssessmentRequired,
        ISNULL(exam.Name, '') + ISNULL(eval.Name, '') + ISNULL(logs.Name, '') + ISNULL(do.Name, '') as AssessmentName,
        ISNULL(assessorScore.HighestScore, subjectScore.HighestScore) as AssessmentHighScore,
        ISNULL(assessorScore.TotalAttempts, subjectScore.TotalAttempts) as AssessmentTotalAttempts,
        [dbo].[fn_ScheduledAssessment_MostCompleteStatus](se.ID, ase.AssessmentID, p.ID) as AssessmentStatus,
        CASE WHEN gradeBookAssessment.AssessmentID is null THEN 0 ELSE 1 END as InGradeBook,
        CONVERT(DECIMAL(16,4), ISNULL(se.DurationMinutes,0)/60.0) as TotalHoursScheduled
from people p
left outer join Course_People cp on p.ID = cp.PersonID and cp.RoleType = 2 -- Get the course where the person is a student
                and cp.Retaken = 0       --  when this is 0, it is the "most current" instance for the person (in case they are retaking)
left outer join Courses c on cp.CourseID = c.ID
left outer join @resourceTable r on c.ID = r.CourseID
left outer join PersonScores ps on p.ID = ps.PersonID and c.GradeBookID = ps.GradeBookID --Current Course Grade
left outer join Scheduled_Events se on c.ID = se.CourseID and p.ID in (select PersonID from dbo.fn_ScheduledEvent_PeopleOfRole(se.ID, 2))
left outer join Assessment_ScheduledEvent ase on se.ID = ase.ScheduledEventID
left outer join (
    select distinct gi.ParentEntityID as AssessmentID, gb.ID as GradeBookID
    from GradeBooks gb
    join GradeBookCategories gbc on gb.ID = gbc.GradeBookID
    join GradableItems gi on gbc.ID = gi.CategoryID 
) gradeBookAssessment on c.GradeBookID = gradeBookAssessment.GradeBookID and ase.AssessmentID = gradeBookAssessment.AssessmentID
left outer join Examinations exam on ase.AssessmentID = exam.ID
left outer join Evaluations eval on ase.AssessmentID = eval.ID
left outer join LogRequirements logs on ase.AssessmentID = logs.ID
left outer join DirectObservations do on ase.AssessmentID = do.ID
left outer join (
        select sa.AssessmentID,
               ase.ScheduledEventID,
               sa.CoursePersonID,
               MAX(CASE WHEN seps.MaximumScore = 0 THEN 0 ELSE seps.Score/seps.MaximumScore END) as HighestScore, 
               COUNT(*) as TotalAttempts
        from ScheduledAssessments sa 
            join Assessment_ScheduledEvent ase on sa.AssessmentScheduledEventID = ase.ID
            left outer join PersonScores seps on sa.ID = seps.ScheduledAssessmentID
        where sa.Status in (1, 2)
        group by ase.ScheduledEventID, sa.AssessmentID, sa.CoursePersonID
    ) as assessorScore on se.ID = assessorScore.ScheduledEventID and ase.AssessmentID = assessorScore.AssessmentID and assessorScore.CoursePersonID = cp.ID
left outer join (
        select sa.AssessmentID,
                sa.Subject_EntityID,
                ase.ScheduledEventID,
            MAX(CASE WHEN seps.MaximumScore = 0 THEN 0 ELSE seps.Score/seps.MaximumScore END) as HighestScore, 
            COUNT(*) as TotalAttempts
        from ScheduledAssessments sa 
        join Assessment_ScheduledEvent ase on sa.AssessmentScheduledEventID = ase.ID
        left outer join PersonScores seps on sa.ID = seps.ScheduledAssessmentID
        where sa.Status in (1, 2)
        group by ase.ScheduledEventID, sa.AssessmentID, sa.Subject_EntityID
    ) as subjectScore on se.ID = subjectScore.ScheduledEventID and ase.AssessmentID = subjectScore.AssessmentID and p.ID = subjectScore.Subject_EntityID
where p.ID = @personID
order by c.Name

end
GO
/****** Object:  StoredProcedure [dbo].[Update_Course_Completion_States]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Update_Course_Completion_States]
as
begin
	set nocount on

	-- When an independent study course student runs out of time to complete a course based on the 
	-- course's time limit, then the completion status needs to be set to "Expired"
	-- The only way that the EndDate is set for a CoursePerson is when they are added to an
	-- independent study course
	update Course_People
		set CompletionStatus = 4, --Expired
			HistoricalStatus = 5, --Expired
            StatusModifiedDate = getDate()
	from Course_People cp
	where cp.CompletionStatus = 1 --InProgress 
		and cp.EndDate is not null 
		and GETDATE() > cp.EndDate

	-- For a calendar course, the CompletionStatus is set to expired for people that are still
	-- in progress when the course hits its end date
	update Course_People
		set CompletionStatus = 4, --Expired
			HistoricalStatus = 5, --Expired
            StatusModifiedDate = getDate()
	from Course_People cp
	join Courses c on cp.CourseID = c.ID
	where cp.CompletionStatus = 1 --InProgress
		and cp.RoleType = 2 --Student
		and c.Type = 0 --Calendar Course
		and c.EndDate is not null
		and c.EndDate < GETDATE()

	-- Return the changes that are about to be made so that cache updates can be made by
	-- the background task
	select cp.ID, c.ClientID, 4 as CompletionStatus
	from Course_People cp
	join Courses c on cp.CourseID = c.ID
	where cp.CompletionStatus = 1 --InProgress 
		and cp.EndDate is not null 
		and GETDATE() > cp.EndDate
	union
	select cp.ID, c.ClientID, 4
	from Course_People cp
	join Courses c on cp.CourseID = c.ID
	where cp.CompletionStatus = 1 --InProgress
		and cp.RoleType = 2 --Student
		and c.Type = 0 --Calendar Course
		and c.EndDate is not null
		and c.EndDate < GETDATE()
end
GO
/****** Object:  StoredProcedure [dbo].[User_CreateOrUpdate]    Script Date: 3/14/2021 4:50:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[User_CreateOrUpdate](@clientID uniqueidentifier, @userName nvarchar(100), 
                                            @roleID uniqueidentifier, @organizationID uniqueidentifier,
                                            @hash nvarchar(100), @salt nvarchar(50),
                                            @firstName nvarchar(50), @lastName nvarchar(50))
AS
BEGIN
    set nocount on
	/*******************************

	This does not check for deleted people!!
	So if you are calling this and the person is already on the system but deleted it will 
	NOT add a new person OR make the person not deleted!!!
	
	*******************************/

    declare @userID uniqueidentifier
    declare @personID uniqueidentifier
    declare @results table (ID uniqueidentifier)

    if not exists (select top 1 1 from Users where UserName=@username)
    begin
        delete @results
        insert Users (UserName, Hash, Salt, Enabled, LastModifyDateTime) output inserted.ID into @results 
            values (@username, @hash, @salt, 1, getdate())
        select @userID = ID from @results
    end

    select @personID = ID from People where ClientID=@clientID and FirstName=@firstName and LastName=@lastName
    if (@personID is null)
    begin
        delete @results
        insert People (FirstName, LastName, ClientID, IsDeleted, LastModifyDateTime) output inserted.ID into @results 
            values (@firstName, @lastName, @clientID, 0, getdate())
        select @personID = ID from @results

		insert into PersonClients (PersonID, ClientID, LastModifyDateTime, IsDeleted) values (@personID, @clientID, getdate(), 0)
    end
	else
	begin
		if not exists (select ID from PersonClients where PersonID = @personID and ClientID = @clientID)
			insert into PersonClients (PersonID, ClientID, LastModifyDateTime, IsDeleted) values (@personID, @clientID, getdate(), 0)
	end

    if not exists (select top 1 1 from Logins where UserName=@username and PersonID=@personID)
        insert into Logins (UserName, PersonId, AuthenticationProvider, LastModifyDateTime) values (@username, @personID, 1, getdate())

    if not exists (select top 1 1 from People_Roles where PersonID=@personID and RoleID=@roleID 
                    and ((OrganizationID is null and @organizationID is null) or (OrganizationID is not null and @organizationID is not null and OrganizationID=@organizationID)))
        insert into People_Roles (PersonID, RoleID, OrganizationID) values (@personID, @roleID, @organizationID)
END
GO
USE [master]
GO
ALTER DATABASE [prod-4iq] SET  READ_WRITE 
GO

