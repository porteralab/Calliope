function [PcaFilters,PcaTraces] = runPCA(inputMatrix, numberPCs, varargin)
    % runs PCA on an input 3D matrix aiming to output number of PCs specified in input
    % Benjamin Grewe
    % updated starting: 2013.10.08
    % Written based on code by Maggie Carr , Eran Mukamel,
    % Jerome Lecoq, and Lacey Kitch,biafra ahanonu 
    % inputs
        % inputMatrix: input movie to run PCA on
        % inputID: identifier for this runs output .mat files
        % numberPCs: number of expected PCs
        % fileRegExp: regular expression to filter movies on
    %options:
        % nPCs: Initial guess as to number of principal components. Default = 1000.
        % UseNoiseFloor: Determines whether or not to use an estimate of the noise floor to determine number of PCs to keep. Default = 1.
    % outputs
        %
    % changelog
        % 2013.10.08 [12:36:53] Generalized the code so it no longer relies on a specific file or structure implementation. Removing references to days, etc.
        % 2013.11.01 [10:08:12] made movie loading into a separate function, fxn now accepts a movie as an input
        % 2013.11.18 [15:46:47] updated mean subtraction to use bsxfun, should be faster
        % 2014.01.24 - now removes NaNs from the input matrix
        % 2014.06.08 [13:06:33]
    % TODO
        %

    %========================
    options.numberPCs = 1000;
    options.npcs = 1000;
    options.usenoisefloor = 0;
    options.frameList = [];
    options.inputDatasetName = '/1';
    % get options
%     options = getOptions(options,varargin);
    options.numberPCs = numberPCs;
    % display(options)
    % unpack options into current workspace
    fn=fieldnames(options);
    for i=1:length(fn)
        eval([fn{i} '=options.' fn{i} ';']);
    end
    %========================

    % get the movie if a string input
    if strcmp(class(inputMatrix),'char')|strcmp(class(inputMatrix),'cell')
        display('loading matrix inside PCA function.')
        inputMatrix = loadMovieList(inputMatrix,'convertToDouble',0,'frameList',options.frameList,'inputDatasetName',options.inputDatasetName);
    end

    % replace any NaNs with zero
    display('removing NaNs...');drawnow
    inputMatrix(isnan(inputMatrix)) = 0;

    % get movie information
    DFOFsize = size(inputMatrix);
    Npixels = DFOFsize(1)*DFOFsize(2);
    Ntime = DFOFsize(3);

    if ~isempty(inputMatrix)

        %Perform mean subtraction for optimal PCA performance
        display('performing mean subtraction...');drawnow
        inputMean = nanmean(nanmean(inputMatrix,1),2);
        inputMean = cast(inputMean,class(inputMatrix));
        inputMatrix = bsxfun(@minus,inputMatrix,inputMean);
        % for frameInd=1:Ntime
        %     thisFrame=squeeze(inputMatrix(:,:,frameInd));
        %     meanThisFrame = mean(thisFrame(:));
        %     inputMatrix(:,:,frameInd) = inputMatrix(:,:,frameInd)-meanThisFrame;
        % end
        clear thisFrame meanThisFrame

        % TODO
            % % get 1xP matrix of mean for each frame
            % DFOFmean = mean(mean(inputMatrix));
            % % convert to MxNxP, with MxN slice containing repeat of the mean
            % DFOFmean = repmat(DFOFmean,[])
            % %
            % inputMatrix = bsxfun(@minus,inputMatrix,DFOFmean);


        % Check that the number of PCs is fewer than the number of frames
        display('checking # PCs < # frames...')
        if numberPCs>Ntime && Ntime>50
            numberPCs = Ntime-50;
        elseif numberPCs>Ntime && Ntime<=50
            error('Number of PCs must be less than number of frames in movie')
        end

        if usenoisefloor
            display('calculating noise floor...')
            %Compute a random matrix prediction (Sengupta & Mitra)
            q = max(DFOFsize(1)*DFOFsize(2),DFOFsize(3));
            p = min(DFOFsize(1)*DFOFsize(2),DFOFsize(3));
            sigma = 1;
            lmax = sigma*sqrt(p+q + 2*sqrt(p*q));
            lmin = sigma*sqrt(p+q - 2*sqrt(p*q));
            lambda = lmin: (lmax-lmin)/100.0123423421: lmax;
            rho = (1./(pi*lambda*(sigma^2))).*sqrt((lmax^2-lambda.^2).*(lambda.^2-lmin^2));
            rho(isnan(rho)) = 0;
            rhocdf = cumsum(rho)/sum(rho);
            noiseigs = interp1(rhocdf, lambda, (p:-1:1)'/p, 'linear', 'extrap').^2 ;
            clear q p sigma lmax lmin lambda rho rhocdf
        end

        nPCs = numberPCs; %Starting guess of nPCs for each day
        % display(['Running PCA calculation on day ', num2str(days(dayInd))])

        if usenoisefloor %Determine how many PCs to keep, using an estimate of the noise floor
            display('determining PCs to keep based on noise floor...')
            reachederrorfloorlimit = 0;

            while isequal(reachederrorfloorlimit,0) %Increase nPCs until noise floor is reached if using noise floor

                %Calculate PCA with current nPCs
                [CovEvals PcaTraces nPCs] = calculatePCA(inputMatrix,nPCs);

                %Normalize the PC spectrum and determine where it crosses the noisefloor
                normrank = min(DFOFsize(3)-1,length(CovEvals));
                pca_norm = CovEvals*noiseigs(normrank) / (CovEvals(normrank)*noiseigs(1));
                indices = find(pca_norm < (noiseigs(1:normrank)./noiseigs(1)),1);

                if ~isempty(indices)
                    CovEvals = CovEvals(1:indices);
                    PcaTraces = PcaTraces(:,1:indices);
                    reachederrorfloorlimit = 1;
                    nPCs = size(CovEvals,1);
                else
                    nPCs = nPCs + 100;
                    display(['Did not reach noise floor, increasing number of PCs to ' num2str(nPCs)])
                end
            end
            clear normrank pca_norm indices covmat noiseigs reachederrorfloorlimit

        else %Calculate PCA with user defined nPCs
            display('finding PCs...')
            [CovEvals PcaTraces PcaFilters nPCs] = calculatePCA(inputMatrix,nPCs);
        end

        % Adjust nPCs
        nPCs = size(CovEvals,1);

        %Reshape the filter to have a proper image inputMovie = cast(inputMovie,OldClass);
        PcaFilters = reshape(PcaFilters,DFOFsize(1),DFOFsize(2),nPCs);

    else
        success = 0;
    end
    % end