%Fill ROIs
sROIs = ROIs; %Save a copy of your ROIs
tROI = {};
for layer = 1:4
    for r = 1:length(ROIs{1,layer})
        x = [];
        y = [];
        K = [];
        tempIM = zeros(400,750);
        tempIM_fill = zeros(400,750);

        [x,y] = ind2sub([400 750],ROIs{1,layer}(r).indices);
        K = convhull(x,y);
        tempIM(ROIs{1,layer}(r).indices) = 1;
        findPoints = inpolygon((repmat([1:400],1,750)),round(linspace(0.5,750.5,300000)),x(K),y(K));
        pointsInShape = find(findPoints == 1);
        tempIM_fill(pointsInShape) = 1;
        tROI{1,layer}(r).indices = pointsInShape';
%         subplot(211)
%         imshow(tempIM);
%         subplot(212)
%         imshow(tempIM_fill);
    end
end

%%
%Overwrite old ROIs with new
for layer = 1:4
    for r = 1:length(ROIs{1,layer})
         ROIs{1,layer}(r).indices = tROI{1,layer}(r).indices;
    end
end

%save A-data after this