-- Doctor Agreement: time-window support. NULL = legacy agreement (always valid).
IF COL_LENGTH('dbo.Doctor_Agreement', 'Start_Time') IS NULL
    ALTER TABLE dbo.Doctor_Agreement ADD Start_Time time(0) NULL;
IF COL_LENGTH('dbo.Doctor_Agreement', 'End_Time') IS NULL
    ALTER TABLE dbo.Doctor_Agreement ADD End_Time time(0) NULL;
