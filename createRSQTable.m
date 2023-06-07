%============== Create rsqTable ============== 

%redirecting folder to correct path. clear.
clear all; clc;

%insert local path of Tshort.csv and Tlong.csv file
Tlong = '/Users/land/Desktop/projectTrackProfiles/supportFiles/Tlong.csv';
colorProfiles = '/Users/land/Desktop/projectTrackProfiles/supportFiles/colorProfiles.csv';

%convert csv into a table.
Tlong = readtable(Tlong); 
colorProfiles = readtable(colorProfiles);

%generate column of tracts of interest ids
mask = ismember(Tlong.structureID, colorProfiles{:, 1});
tractIDs = Tlong(mask, :);
tractIDs = unique(tractIDs.structureID);
rsqTable = table(tractIDs); 

%============== Export rsqTable as a csv ==============
%local path to save table: 
mainpath = '/Users/land/Desktop/projectTrackProfiles/supportFiles';

table_path_format_rsqTAdj = fullfile(mainpath, 'rsqTableAdj.csv');
table_path_format_rsqTOrd = fullfile(mainpath, 'rsqTableOrd.csv');
table_path_format_inflecT = fullfile(mainpath, 'inflecTable.csv');

%funally, save tables
writetable(rsqTable, table_path_format_rsqTAdj);
writetable(rsqTable, table_path_format_rsqTOrd);
writetable(rsqTable, table_path_format_inflecT);