function cb_plugin_trav(params,cbh,proj_meta)
% plugin for cell_browser to plot activity of cell by traversal as a
% function of position in corridor or speed
% 2015.10.22 AndersPetersen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Activity as a function of position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xpos = proj_meta(params.site_id).rd(params.zl,params.tp).VRx(1,:);

act = proj_meta(params.site_id).rd(params.zl,params.tp).act(params.cell_ind,:);
grat = proj_meta(params.site_id).rd(params.zl,params.tp).GratFlash;

%Make binning vector
binVector = linspace(0,5.02,101);

%Get indices for each bin
for i = 1:length(binVector)-1;
    binning(i).bins = find(xpos > binVector(i) & xpos <= binVector(i+1));
    binnedXPos(i) = mean(xpos(binning(i).bins));
end

%Get raw data bins for correlation calculations
maze_start = find(diff(xpos)<-.2);
maze_start = [maze_start, length(xpos)];

%Divide recordings up into traversals

for n = 1:length(maze_start)-1;
    traversal(n).act = act(maze_start(n)+1:maze_start(n+1));
    traversal(n).grat = grat(maze_start(n)+1:maze_start(n+1));
    traversal(n).pos = xpos(maze_start(n)+1:maze_start(n+1));
end


for n = 1:length(maze_start)-1;
    for j = 1:length(binVector)-1;
        temp_bin = [];
        temp_bin = find(traversal(n).pos > binVector(j) & traversal(n).pos < binVector(j+1));
        if isempty(temp_bin)
            bins(n,j) = NaN;
        else
            bins(n,j) = mean(traversal(n).act(temp_bin));
        end
        grats(n,j) = mean(traversal(n).grat(temp_bin));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Activity as a function of position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

velocity = proj_meta(params.site_id).rd(params.zl,params.tp).velM_smoothed(1,:);
velocity = -velocity;

%Make binning vector
binVectorSpeed = linspace(0,0.014,15);

%Get indices for each bin
for i = 1:length(binVectorSpeed)-1;
    binning(i).speedbins = find(velocity > binVectorSpeed(i) & velocity <= binVectorSpeed(i+1));
end

%Calculate mean activity for each bin

for j = 1:length(binVectorSpeed)-1; %Number of bins
    binActSpeed(j) = mean(act(binning(j).speedbins));
    binStdSpeed(j) = std(act(binning(j).speedbins))./sqrt(length(binning(j).speedbins));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aaa=reshape(bins',1,prod(size(bins)));

figure(169);
clf;
axes('position',[0 0.2 1 0.7]);
imagesc(bins)
set(gca,'clim',[prctile(aaa,5) prctile(aaa,99)])
axis off;
axes('position',[0 0 1 0.2]);
imagesc(grats)
axis off;
axes('position',[0 0.9 1 0.1]);
imagesc(nanmean(bins))
axis off;
set(gcf,'menubar','none')



figure(170);
subplot(121)

aaa(isnan(aaa))=0;
plot(xcorr(aaa,'unbiased'))
xlim([-200 200]+length(aaa))
xlabel('distance')
ylabel('correlation')
subplot(122)
plot(xcorr(act,'unbiased'))
xlim([-2000 2000]+length(act))
xlabel('time')

figure(171)
errorbar(binActSpeed,binStdSpeed);
ylim([1 1.2])
xlabel('Speed')
ylabel('Activity')


