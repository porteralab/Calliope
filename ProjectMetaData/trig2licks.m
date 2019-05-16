function lickmat=trig2licks(proj_meta,siteID,tp,trigs,win)


if nargin<5
    win=[-100 100];
end

% count the licks per frame
[~,frames_with_lick]=min(abs(proj_meta(siteID).rd(1,tp).lickTimes-proj_meta(siteID).rd(1,tp).frame_times'));

% distribute lick times to frame vector
licks_ft=hist(frames_with_lick,[1:length(proj_meta(siteID).rd(1,tp).frame_times)]);


trigs=trigs(:)';

% remove any trigger too close to start, finish, or stack transition
trigs(find(sum(abs(bsxfun(@minus,[0 cumsum(proj_meta(siteID).rd(1,tp).nbr_frames)]',trigs))<max(abs(win)+1))))=[];

% catch for data where aux is shorter than frames
try
    if isfield(proj_meta(siteID).rd(1,tp),'velM')
        trigs(trigs>size(proj_meta(siteID).rd(1,tp).velM,2)-win(2))=[];
    else
        trigs(trigs>size(proj_meta(siteID).rd(1,tp).frame_times,2)-win(2))=[];
    end
catch
    disp('you have issues...')
    disp('fix them')
end

lickmat=reshape(licks_ft([win(1):win(2)]'*ones(length(trigs),1)'+ones(sum(abs(win))+1,1)*trigs),[sum(abs(win))+1,length(trigs)]);


