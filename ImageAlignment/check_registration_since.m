function check_registration_since(pi,fromwhen,ending)
% runs (local copy of) check_registration for given PI
% default: runs check_registration since 30 days from today
% system date-format is to be considered, e.g.: 13-Apr-2018
%
% usage:
% check_registration_since('MustMaxi'); %check_registration since 4 days
% check_registration_since('MustMaxi',2); %checks since last 2 days
% check_registration_since('MustMaxi','13-Apr-2018'); %since specific date
%
% FW, 2017

if ~exist('pi','var') || isempty(pi), pi=input('Please enter your FMI username: \n','s');end
if ~exist('fromwhen','var'),fromwhen=30; warning('checking expids from %d days ago',fromwhen); end
if ~exist('ending','var'),ending=datetime;end
if isa(fromwhen,'double'), fromwhen=datetime('today')-caldays(abs(fromwhen)); end

ExpLog=getExpLog;
adata_dir=set_lab_paths;

dates={ExpLog.stackdate{:}}';
expids=[ExpLog.expid{:}]';
stacks=[ExpLog.stackid{:}]';
pis={ExpLog.pi{:}}';
comments={ExpLog.comment{:}}';
siteids=[ExpLog.siteid{:}]'; % redundant, for displaying purposes
animals={ExpLog.animalid{:}}'; % redundant, for displaying purposes

pis=ismember(pis,pi);
dates=(dates>=datetime(fromwhen) & dates<=datetime(ending) );
expids=unique(expids(find(pis&dates)));

textprogressbar(sprintf('checking %d adata files for saved registrations:\n',numel(expids)));

%check all expids
errors=[]; loadable_expids=[];
for cur_exp_ind=expids'
    textprogressbar(round(find([expids']==cur_exp_ind) / numel(expids) * 100))
    pause(0.01)
    [adata_file,mouse_id,userID] = get_adata_filename(cur_exp_ind,adata_dir,ExpLog);
    if isempty(adata_file) ||  ~ismember('dx',who('-file', [adata_dir userID '\' mouse_id '\' adata_file]))
        errors=[errors,cur_exp_ind];
    else
        loadable_expids=[loadable_expids, cur_exp_ind];
    end
end
textprogressbar('');
fprintf('\n');
warning('\nCouldn''t load registraion from ExpIDs: %s',regexprep(num2str(errors),'  ',','))
fprintf('\n');
textprogressbar(sprintf('%d stacks loadable. Displaying now:\n',numel(loadable_expids)));
cnt=1;
for cur_exp_ind=loadable_expids
    cnt=cnt+1;
    [adata_file,mouse_id,userID] = get_adata_filename(cur_exp_ind);
    adata_dir=set_lab_paths;
    adata = load([adata_dir userID '\' mouse_id '\' adata_file]);
    dx = adata.dx;
    dy = adata.dy;
    template = adata.template;
    check_registration(dx,dy,template);

    copy(handle(9876));
    set(gcf, 'name', [ ExpLog.animalid{[ExpLog.animalid{:}] == cur_exp_ind} ', ExpID=' num2str(cur_exp_ind) ', comment=' comments{find(stacks==cur_exp_ind)}]);
    textprogressbar(round(find((loadable_expids')==cur_exp_ind) / numel(loadable_expids) * 100))
    pause(0.01); %update progressbar
end
textprogressbar('');
ca(9876)
fprintf('done.\n');
end