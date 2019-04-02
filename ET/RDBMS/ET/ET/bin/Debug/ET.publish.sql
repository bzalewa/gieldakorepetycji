﻿/*
Deployment script for ETDatabase

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "ETDatabase"
:setvar DefaultFilePrefix "ETDatabase"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [master];


GO

IF (DB_ID(N'$(DatabaseName)') IS NOT NULL) 
BEGIN
    ALTER DATABASE [$(DatabaseName)]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$(DatabaseName)];
END

GO
PRINT N'Creating $(DatabaseName)...'
GO
CREATE DATABASE [$(DatabaseName)]
    ON 
    PRIMARY(NAME = [$(DatabaseName)], FILENAME = N'$(DefaultDataPath)$(DefaultFilePrefix)_Primary.mdf')
    LOG ON (NAME = [$(DatabaseName)_log], FILENAME = N'$(DefaultLogPath)$(DefaultFilePrefix)_Primary.ldf') COLLATE Polish_CI_AS
GO
USE [$(DatabaseName)];


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                NUMERIC_ROUNDABORT OFF,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT ON,
                CURSOR_DEFAULT LOCAL,
                RECOVERY FULL,
                CURSOR_CLOSE_ON_COMMIT OFF,
                AUTO_CREATE_STATISTICS ON,
                AUTO_SHRINK OFF,
                AUTO_UPDATE_STATISTICS ON,
                RECURSIVE_TRIGGERS OFF 
            WITH ROLLBACK IMMEDIATE;
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_CLOSE OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ALLOW_SNAPSHOT_ISOLATION OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET READ_COMMITTED_SNAPSHOT OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_UPDATE_STATISTICS_ASYNC OFF,
                PAGE_VERIFY NONE,
                DATE_CORRELATION_OPTIMIZATION OFF,
                DISABLE_BROKER,
                PARAMETERIZATION SIMPLE,
                SUPPLEMENTAL_LOGGING OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET TRUSTWORTHY OFF,
        DB_CHAINING OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'The database settings cannot be modified. You must be a SysAdmin to apply these settings.';
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET HONOR_BROKER_PRIORITY OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'The database settings cannot be modified. You must be a SysAdmin to apply these settings.';
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 0 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET FILESTREAM(NON_TRANSACTED_ACCESS = OFF),
                CONTAINMENT = NONE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF),
                MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = OFF,
                DELAYED_DURABILITY = DISABLED 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF fulltextserviceproperty(N'IsFulltextInstalled') = 1
    EXECUTE sp_fulltext_database 'enable';


GO
PRINT N'Creating [dbo].[tAdverts]...';


GO
CREATE TABLE [dbo].[tAdverts] (
    [AdvertID]   INT            IDENTITY (1, 1) NOT NULL,
    [Title]      NVARCHAR (50)  NOT NULL,
    [Content]    NVARCHAR (250) NOT NULL,
    [StartDate]  DATETIME2 (0)  NOT NULL,
    [DueDate]    DATETIME2 (0)  NOT NULL,
    [UserID]     INT            NOT NULL,
    [LocationID] INT            NOT NULL,
    CONSTRAINT [PK_tAdverts_AdvertID] PRIMARY KEY CLUSTERED ([AdvertID] ASC)
);


GO
PRINT N'Creating [dbo].[tAdvertsCategories]...';


GO
CREATE TABLE [dbo].[tAdvertsCategories] (
    [AdvertID]   INT NOT NULL,
    [CategoryID] INT NOT NULL,
    CONSTRAINT [PK_tAdvertsCategories_tAdverts_tCategories] PRIMARY KEY CLUSTERED ([AdvertID] ASC, [CategoryID] ASC)
);


GO
PRINT N'Creating [dbo].[tCategories]...';


GO
CREATE TABLE [dbo].[tCategories] (
    [CategoryID]   INT           IDENTITY (1, 1) NOT NULL,
    [CategoryName] NVARCHAR (50) NOT NULL,
    [ParentID]     INT           NULL,
    CONSTRAINT [PK_tCategories_CategoryID] PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);


GO
PRINT N'Creating [dbo].[tLocations]...';


GO
CREATE TABLE [dbo].[tLocations] (
    [LocationID] INT           IDENTITY (1, 1) NOT NULL,
    [Country]    NVARCHAR (50) NOT NULL,
    [Region]     NVARCHAR (50) NOT NULL,
    [County]     NVARCHAR (50) NULL,
    [City]       NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_tLocations_LocationID] PRIMARY KEY CLUSTERED ([LocationID] ASC)
);


GO
PRINT N'Creating [dbo].[tUsers]...';


GO
CREATE TABLE [dbo].[tUsers] (
    [UserID]      INT             IDENTITY (1, 1) NOT NULL,
    [Nickname]    NVARCHAR (8)    NOT NULL,
    [Pass]        NVARCHAR (12)   NOT NULL,
    [FirstName]   NVARCHAR (25)   NOT NULL,
    [LastName]    NVARCHAR (25)   NOT NULL,
    [Age]         INT             NOT NULL,
    [Email]       NVARCHAR (100)  NOT NULL,
    [PhoneNumber] NVARCHAR (11)   NULL,
    [ImageColumn] VARBINARY (MAX) NULL,
    CONSTRAINT [PK_tUsers_UserID] PRIMARY KEY CLUSTERED ([UserID] ASC),
    CONSTRAINT [AK_tUsers_Nickname] UNIQUE NONCLUSTERED ([Nickname] ASC)
);


GO
PRINT N'Creating [dbo].[FK_tAdverts_Users]...';


GO
ALTER TABLE [dbo].[tAdverts]
    ADD CONSTRAINT [FK_tAdverts_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[tUsers] ([UserID]);


GO
PRINT N'Creating [dbo].[FK_tAdverts_Locations]...';


GO
ALTER TABLE [dbo].[tAdverts]
    ADD CONSTRAINT [FK_tAdverts_Locations] FOREIGN KEY ([LocationID]) REFERENCES [dbo].[tLocations] ([LocationID]);


GO
PRINT N'Creating [dbo].[FK_tAtdvertsCategories_tAdverts]...';


GO
ALTER TABLE [dbo].[tAdvertsCategories]
    ADD CONSTRAINT [FK_tAtdvertsCategories_tAdverts] FOREIGN KEY ([AdvertID]) REFERENCES [dbo].[tAdverts] ([AdvertID]);


GO
PRINT N'Creating [dbo].[FK_tAdvertsCategories_tCategories]...';


GO
ALTER TABLE [dbo].[tAdvertsCategories]
    ADD CONSTRAINT [FK_tAdvertsCategories_tCategories] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[tCategories] ([CategoryID]);


GO
PRINT N'Creating [dbo].[tAdverts].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contains all adverts.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tAdverts';


GO
PRINT N'Creating [dbo].[tAdvertsCategories].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contains info about adverts and categories.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tAdvertsCategories';


GO
PRINT N'Creating [dbo].[tCategories].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contains all categories and subcategories.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tCategories';


GO
PRINT N'Creating [dbo].[tLocations].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contains possible locations.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tLocations';


GO
PRINT N'Creating [dbo].[tUsers].[MS_Description]...';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contains info about user.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tUsers';


GO
DECLARE @VarDecimalSupported AS BIT;

SELECT @VarDecimalSupported = 0;

IF ((ServerProperty(N'EngineEdition') = 3)
    AND (((@@microsoftversion / power(2, 24) = 9)
          AND (@@microsoftversion & 0xffff >= 3024))
         OR ((@@microsoftversion / power(2, 24) = 10)
             AND (@@microsoftversion & 0xffff >= 1600))))
    SELECT @VarDecimalSupported = 1;

IF (@VarDecimalSupported > 0)
    BEGIN
        EXECUTE sp_db_vardecimal_storage_format N'$(DatabaseName)', 'ON';
    END


GO
PRINT N'Update complete.';


GO
