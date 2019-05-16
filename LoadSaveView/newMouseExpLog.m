function []=newMouseExpLog()
% adds a new Mouse to the ExpLog database
%
%follow the on screen intructions.
%
%
%documented by GK - 13.04.2014

disp('*******************************************************')
disp('This function will add a mouse to the ExpLog database.')
disp('Note that you can cancel at any point by pressing Ctr-C,')
disp('or responding with "no" to the final confirmation.')
disp('Keep to standard formats with all data entered.');
disp('*******************************************************')

adata_dir=set_lab_paths;

AnimalID=input('Name your mouse: ','s');

Gender=input('Gender (F/M): ','s');

while sum(strcmp(Gender,{'M','F'}))==0
    disp('Wanna try again...?')
    Gender=input('Gender (F/M): ','s');
end

Strain=input('is it a C57Bl/6J (y/n): ','s');

if strcmp(Strain,'y');
    Strain='C57Bl/6J';
else
    Strain=input('What strain is it: ','s');
end

DoB=input('Date of birth (dd.mm.yyyy): ','s');

% stupid AE SQL...
DoB_tmp=DoB;
DoB_tmp(1:2)=DoB(4:5);
DoB_tmp(4:5)=DoB(1:2);
DoB=DoB_tmp;

Source=input('Where is the mouse from (CR or FMI): ','s');

VivariumID=input('Vivarium ID: ','s');

PI=input('What is your username (e.g. kellgeor): ','s');

go_on=input('Is all the information correct, do you want to create your mouse in ExpLog (y/n): ','s');

if strcmp(go_on,'y')
    
    disp('Now creating Animal folder on M:Adata');
    
    if ~isdir([adata_dir '_AnimalData\' PI])
        mkdir([adata_dir '_AnimalData\'],PI);
    end
    
    if ~isdir([adata_dir '_AnimalData\' PI '\' AnimalID])
        mkdir([adata_dir '_AnimalData\' PI '\'],AnimalID);
        mkdir([adata_dir '_AnimalData\' PI '\' AnimalID '\'],'OII');
        mkdir([adata_dir '_AnimalData\' PI '\' AnimalID '\'],'POIs');
        mkdir([adata_dir '_AnimalData\' PI '\' AnimalID '\'],'Histology');
    else
        disp('WARNING! Mouse folder already exists - please check and delete manually first if obsolete');
        return
    end
    
    DB=connectToExpLog;
    sql = ['INSERT INTO Animals (AnimalID,Gender,Strain,DoB,Source,VivariumID,PI) '...
        'VALUES (''' AnimalID ''', ''' Gender ''', ''' Strain ''', ''' DoB ''', ''' Source ''', ''' VivariumID ''', ''' PI ''')' ];
    ExpLog = adodb_query(DB, sql);
    DB.release;
end
