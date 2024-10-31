%redirecting folder to correct path. clear.
clear all; clc;

%(!) % define measure (!)
measure = 'fa';

%fetching all subject's subfolders and storing them in subfolders
%insert local path to track profiles here by changing value of mainpath.
mainpath = '/Volumes/LANDLAB/projects/hbn/projectTrackProfiles/data2/proj-64aeafb13a63cf17375ff249';
topLevelFolder = dir(mainpath);

subfolders = topLevelFolder([topLevelFolder(:).isdir]); %find names of all subject's subfolders

% (!) Uncomment line 16 if running script on data for the first time(!)
% (!) Removes the unnecessary '.' and '..' files (!)
% subfolders = subfolders(arrayfun(@(x) x.name(1), subfolders) ~= '.');

% Keep only names that are subject folders.
subfolders = subfolders(arrayfun(@(x) x.name(1), subfolders) == 's');

%tables is a cell array to store each sub's table in.
tables = {}; 
Headers = {'subjectID','structureID', 'nodeID', 'fa'};
Tlong = cell2table(cell(0,4),'VariableNames', Headers);
%Tlong: Stores detailed, node-level data for each subject and tract.
%Tshort: Stores summary, subject-level data, with each tract's measure averaged across nodes.

%insert local path to csv here by changing value of mainpath.
mainpathCSV = '/Volumes/LANDLAB/projects/hbn/projectTrackProfiles/supportFiles/participants2.csv'; 
T1 = readtable(mainpathCSV);

%============== Generate Tlong ==============

for i = 1:(length(subfolders)) 
    %get subpath to each subject's folder
    subpath = fullfile(mainpath, subfolders(i).name); %pathToSubfolder
    
    %cd into subject's folder
    cd(subpath); 
    
    %find path of folder containing .csv file
    topLevelFolderCSV = dir(subpath);  
    topLevelFolderCSV = topLevelFolderCSV (arrayfun(@(x) x.name(1), topLevelFolderCSV) == 'd');
    subpathCSV = fullfile(topLevelFolderCSV.folder, topLevelFolderCSV.name); %pathToSubfolder
    
    %cd into file containing .csv file
    cd(subpathCSV);
    
    %grab .csv file and convert file path to string
    csvfile = dir("tractmeasures.csv");
    if length(csvfile) == 1
        csvFullPaths = fullfile({csvfile.folder}, {csvfile.name});
        csvFinalPath = string(csvFullPaths(1:1));
    else
        csvfile = dir("output_FiberStats.csv");
        csvFullPaths = fullfile({csvfile.folder}, {csvfile.name});
        csvFinalPath = string(csvFullPaths(1:1));
    end
    
    %read table into variable T
    T = readtable(csvFinalPath);
    T = T((T.nodeID >= 20 & T.nodeID <= 180), :);

    Tnew = table; 
    Tnew.subjectID = T.subjectID; 
    Tnew.structureID = T.structureID;
    Tnew.nodeID = T.nodeID;
    Tnew.fa = T.fa; 

    Tnew(any(ismissing(Tnew),2), :) = [];
    
    if(~isempty(Tnew.fa) && ismember(Tnew(1, 'subjectID'), cell2table(T1{:, 'subjectID'}, "VariableNames", "subjectID")))
        Tlong = vertcat(Tnew, Tlong);
    end

    %add table to cell array tables
    %tables{i} = Tnew;

    %cd out of subject's directory for next loop iteration
    cd ..
    cd ..

end

%convert Tfull from a cellarray to a table.
%Tlong = vertcat(tables{:});

%remove rows that have NAN in them; 
%Tlong = Tlong(:,~all(isnan(Tlong)));
%Tlong(all(isnan(Tlong()),2),:) = [];    %rows that are all nan

%insert local path to csv here by changing value of mainpath.
T = readtable(mainpathCSV);

%get only subject ids
subIDs = unique(Tlong.subjectID);

%create new columns in Tlong for Age, Sex, Handedness, and Bin
%Tlong.Age = repmat("NA", height(Tlong), 1);
%Tlong.Sex = repmat("NA", height(Tlong), 1);
%Tlong.Handedness = repmat("NA", height(Tlong), 1);
%Tlong.Bins = repmat("NA", height(Tlong), 1);

nrow = size(Tlong, 1);
Tlong.Age = zeros(nrow, 1);    %0
Tlong.Sex = zeros(nrow, 1);    %0
Tlong.Handedness = zeros(nrow, 1);  %0
Tlong.Bins = zeros(nrow, 1);  %0

%YourTable.OtherNewColumn = char(zeros(nrow,0));  %empty string, see note
%YourTable.ThirdColumn = repmat({''}, nrow, 1);   %cell array of empty string

[~, idx] = unique(T.subjectID, 'rows');
T4 = T(idx, :);

clear T; 
subIDsT = cell2table(subIDs);
T7 = ismember(T4{:,1}, subIDsT{:,1}, 'rows'); 
T = T4(T7, :);


%fill in Age, Sex, and Handedness data in Tlong by copying from csv. 
clear i; 
for i = 1:length(subIDs)
    idx = find(strcmp(Tlong.subjectID, char(subIDs(i))) == 1);
    idx2 = find(strcmp(T4.subjectID, char(subIDs(i))) == 1);
    Tlong.Age(idx) = repmat(T4.Age(idx2), [1 length(idx)]);
    Tlong.Sex(idx) = repmat(T4.Sex(idx2), [1 length(idx)]);
    Tlong.Handedness(idx) = repmat(T4.Handedness(idx2), [1 length(idx)]);
    clear idx; 
    clear idx2; 
end

%fill in bin assignments in Tlong
for i = 1:length(subIDs)
    idx = find(strcmp(Tlong.subjectID, char(subIDs(i))) == 1);
    Tlong.Bins(idx) = repmat(round(T4.Age(i)), [1 length(idx)]);
    T.Bins(i) = round(T4.Age(i)); 
end

%convert data types in columns from strings to doubles
%Tlong.Age = str2double(Tlong.Age);
%Tlong.Sex = str2double(Tlong.Sex);
%Tlong.Handedness = str2double(Tlong.Handedness);
%Tlong.Bins = str2double(Tlong.Bins);

%============== Generate Tshort ==============
%After Tlong is created, this for loop iterates over each unique 
%subjectID and structureID (tract ID). For each unique tract in each 
%subject, Tshort computes the mean fa and stores it.

Tshort = T; 
tractIDs = unique(Tlong.structureID);

for s = 1:length(subIDs)
    Sidx = find(strcmp(Tlong.subjectID, char(subIDs(s))) == 1);
    for t = 1:length(tractIDs)
        Tidx = find(strcmp(Tlong.structureID, char(tractIDs(t))) == 1);
        STidx = intersect(Tidx, Sidx);
        faTract = Tlong(STidx, measure);
        faTract = table2array(faTract);
        Tshort.(char(tractIDs(t)))(s) = repmat(mean(faTract, 1), [1 length(s)]); 
    end
end

%note: remove all subjects from Tshort that don't have data with them.

%============== Export Tshort and Tlong as a csv ==============
%local path to save table: 
mainpath = '/Volumes/LANDLAB/projects/hbn/projectTrackProfiles/supportFiles';

table_path_format_tshort = fullfile(mainpath, 'Tshort.csv');
table_path_format_tlong = fullfile(mainpath, 'Tlong.csv');

%funally, save tables
writetable(Tshort, table_path_format_tshort);
writetable(Tlong, table_path_format_tlong);
