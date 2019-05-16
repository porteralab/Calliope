function [Power,Phase,PhaseMap,PhaseMapHor,PhaseMapVer,PhaseHor,PhaseVer]=showFourierMaps(FourierSpecs,idx,Ibv,meandat_mask)
% displayzs Fourier maps from OII data
%
% documented,edited FW 03.03.2018 (added calliope integration)

%% calliope integration: get missing parameters from calliope and saved Adatafile
if ~exist('FourierSpecs','var') && ~exist('idx','var') && ~exist('Ibv','var') && ~exist('meandat_mask','var') && ishandle(1001)
    loaded_from_calliope=1;
    fprintf('- loading maps of selected expID in calliope...');
    exp=str2double((regexp(handle(1001).Children(15).String{handle(1001).Children(15).Value},'[0-9]*(?= - )','match','once')));
    [adata_file,mouse_id,userID]=find_adata_file(exp,set_lab_paths);
    fprintf('\b\b\b (%d)\n',exp);
    
    if ~isempty(adata_file)
        load([ set_lab_paths userID '\' mouse_id '\' adata_file],'result');
        cellfun(@(x,y) assignin('caller',x,y),fieldnames(result),struct2cell(result)); %unpack result variable
        meandat_mask=0; idx=1;
    else
        error('No Adata file.');
    end
end

%%
[yRes,xRes,~]=size(FourierSpecs{1});
PowCutoff=0;
PowMultiplier = 1;
for ii = 1:4
    FourierSpecs{ii}=fliplr(squeeze(FourierSpecs{ii}(:,:,idx)));
end

%% Calculate phase and power maps
disp(' * Calculating maps');
Phase = {};
Power = zeros(yRes,xRes);
for ii = 1:4
    Phase{ii}=mod(angle(FourierSpecs{ii})+pi,2*pi)-pi;
    Power = Power + log(abs(FourierSpecs{ii}));
end

PhaseHor = mod( angle(FourierSpecs{2}./FourierSpecs{1})+pi, 2*pi ) -pi;
PhaseVer = mod( angle(FourierSpecs{4}./FourierSpecs{3})+pi, 2*pi ) -pi;
PhaseMapHor = mat2gray(PhaseHor+pi/2);
PhaseMapVer = mat2gray(PhaseVer+pi/2);

disp([' * Removed ' num2str(sum(isnan(Power(:)))) ' NaNs from the overall powermap']);
disp([' * Removed ' num2str(sum(isinf(Power(:)))) ' Infs from the overall powermap']);
Power(isinf(Power)) = NaN;
Power = ( ( (Power-nanmean(Power(:))) ./ nanstd(Power(:)) ) ./ 6 ) + 0.5;
Power(~fliplr(meandat_mask))=0; % set most saturated pixel to 0

fig = figure(1111);
fig.Name = 'Power';
subplot2(2,2,1,[0.005,0.005])
imshow(Power,'Colormap',jet(300));

AvgFilter = fspecial('average',5);
Power = imfilter( Power, AvgFilter );
Power = (Power-PowCutoff)*PowMultiplier;
Power(Power<0) = 0; Power(Power>1) = 1;
PowerCutoff = median(mat2gray(Power(:)));
PowerAlpha = mat2gray(Power);
PowerAlpha(PowerAlpha<PowerCutoff*1.25)=0;

subplot2(2,2,2,[0.005,0.005])
imshow(Power,'Colormap',jet(300));
im=repmat(ntzo(Ibv),1,1,3);
subplot2(2,2,3,[0.005,0.005])
imshow(im)
subplot2(2,2,4,[0.005,0.005])
im(:,:,2)=im(:,:,2).*imcomplement(Power .* bwareaopen(PowerAlpha>0,300));
im(:,:,3)=im(:,:,3).*imcomplement(Power .* bwareaopen(PowerAlpha>0,300));
imshow(im);
set(gcf,'Renderer','opengl');


%% Create color coded phase maps
%    C = colormap( hsv(361));
PhaseMap = {};
for ii = 1:4
    PhaseMap{ii} = mat2gray(Phase{ii}+pi/2);
end


%% Display maps
% f=[0:360];
% F=repmat(f,[20,1]);
% figure
% imshow(F,hsv(361));
% set(gca,'XTick',[0:50:361],'XTickLabel',[0:50:361],'YTick',[]);
% axis on
figure(1112);
titles = {'Moving up' , 'Moving Down', 'Moving Left','Moving Right'};
figpos = [1 2 4 5];
for ii = 1:4
    subplot2(2,3,figpos(ii),[0.05,0.005])
    %imshow(PhaseMap{ii});
    h=imshow(PhaseMap{ii},'ColorMap',hsv(360));
    set(h,'AlphaData',mat2gray(Power));
    %imwrite(Phase{ii},['PhaseMap_' num2str(ii) '.jpg']);
    title(titles{ii})
end
subplot2(2,3,3,[0.05,0.005])
h=imshow(PhaseMapHor,'ColorMap',hsv(361));
set(h,'AlphaData',mat2gray(Power));
%imwrite(PhaseMapHor,'PhaseMapHor.jpg');
title('Combined horizontal bar')
subplot2(2,3,6,[0.05,0.005])
h=imshow(PhaseMapVer,'ColorMap',hsv(361));
set(h,'AlphaData',mat2gray(Power));
%imwrite(PhaseMapVer,'PhaseMapVer.jpg');
title('Combined Vertical Bar')

figure(1113);

for ii = 1:4
    subplot2(2,3,figpos(ii),[0.05,0.005]);
    %imshow(PhaseMap{ii});
    h=imshow(PhaseMap{ii},'ColorMap',hsv(360));
    set(h,'AlphaData',mat2gray(PowerAlpha));
    %imwrite(Phase{ii},['PhaseMap_' num2str(ii) '.jpg']);
    title(titles{ii})
end


fig=figure(1114);
fig.Name = 'Phase Map combined';
subplot2(2,2,1,[0.05,0.005]);
imshow(PhaseMapHor,'ColorMap',hsv(12));
title('Hor')
%imwrite(PhaseMapHor,'ScaledPhaseMapHor.jpg');
subplot2(2,2,2,[0.05,0.005]);
imshow(PhaseMapVer,'ColorMap',hsv(12));
title('Ver')
%imwrite(PhaseMapVer,'ScaledPhaseMapVer.jpg');
subplot2(2,2,3,[0.05,0.005]);
h=imshow(PhaseMapHor,'ColorMap',hsv(12));
set(h,'AlphaData',PowerAlpha);
%imwrite(ScaledPhaseMapHorBlack,'ScaledPhaseMapHorBlack.jpg');
subplot2(2,2,4,[0.05,0.005]);
h=imshow(PhaseMapVer,'ColorMap',hsv(12));
set(h,'AlphaData',PowerAlpha);

end