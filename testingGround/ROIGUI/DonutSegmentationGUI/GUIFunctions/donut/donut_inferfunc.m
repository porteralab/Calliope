function donut_inferfunc(AddFlag)

global gh

if ~AddFlag
    
    switch get(gh.main.PopupMenuObjType,'value')
        case 1
            ModelTemp=load('GCaMP6_ModelMFSoma.mat','model');
        case 2
            ModelTemp=load('GCaMP6_ModelMFBouton.mat','model');
    end
    
    gh.param.model=ModelTemp.model;
    ops.Nextract=0;
    sig=[gh.param.Sig1 gh.param.Sig2];
    if get(gh.main.ChckbxInferReg,'Value')
        [elem,NormImg]=run_inference(gh.data.ImRegAvg,gh.param.model,ops,sig);
    else
        [elem,NormImg]=run_inference(gh.data.ImRawAvg,gh.param.model,ops,sig);
    end
    
    % Rotate basis
    gh.data.ix=elem.ix(elem.map==1,1);
    gh.data.iy=elem.iy(elem.map==1,1);
    gh.data.NormImg=NormImg;
    gh.param.InferFlag=1;
    
    %Mask
    gh.data.LblMask=zeros(size(gh.data.ImRawAvg));
    gh.data.LblMaskI=zeros(size(gh.data.ImRawAvg));
    gh.data.LblMaskM=zeros(size(gh.data.ImRawAvg));
    
    StartNum=1;
else
    StartNum=size(gh.data.ix);
end

FullBasis=cell(size(gh.param.model.W,3),4);
for jj=1:size(FullBasis,1)
    for kk=1:4
        FullBasis{jj,kk}=rot90(gh.param.model.W(:,:,jj),kk+3);
    end
end

BasSze=size(gh.param.model.W);
gh.param.HlfWid=floor(size(gh.param.model.W,1)/2);
ImPatch=cell(1,size(gh.data.ix,1));
ImPatch_Raw=cell(1,size(gh.data.ix,1));
ImPatch_Norm=cell(1,size(gh.data.ix,1));
ImPatch_Rec=cell(1,size(gh.data.ix,1));

UseFullBasis=~get(gh.disp.ChckbxRegularizeMask,'Value');
for ii=StartNum:size(gh.data.ix,1)
        % Crop out the cell
        [xL,xR,yL,yR]=donut_retrbound(ii);
        
        ImPatch_Raw{1,ii}=gh.data.ImRawAvg(xL:xR,yL:yR);
        ImPatch_Norm{1,ii}=gh.data.NormImg(xL:xR,yL:yR);
        ImPatch{1,ii}=ImPatch_Norm{1,ii};
        
        if (gh.data.ix(ii,1)-gh.param.HlfWid>=1) && (gh.data.ix(ii,1)+gh.param.HlfWid<=gh.data.sze(1)) && (gh.data.iy(ii,1)-gh.param.HlfWid>=1) && (gh.data.iy(ii,1)+gh.param.HlfWid<=gh.data.sze(2))
            % Reconstruct
            if UseFullBasis
                M=[ones(BasSze(1)*BasSze(2),1) FullBasis{1,1}(:) FullBasis{1,2}(:) FullBasis{1,3}(:) FullBasis{1,4}(:)...
                    FullBasis{2,1}(:) FullBasis{2,2}(:) FullBasis{2,3}(:) FullBasis{2,4}(:)...
                    FullBasis{3,1}(:) FullBasis{3,2}(:) FullBasis{3,3}(:) FullBasis{3,4}(:)];
            else
                M=[ones(BasSze(1)*BasSze(2),1) FullBasis{1,1}(:) FullBasis{2,1}(:) FullBasis{3,1}(:) FullBasis{4,1}(:) FullBasis{5,1}(:)];
            end
            c=M\ImPatch{1,ii}(:);
            ImPatch_Rec{1,ii}=reshape(M*c,BasSze(1),BasSze(2));
        else
            % Find size reduction
            SzePad=zeros(2,2);
            SzePad(1,1)=max(1-(gh.data.ix(ii,1)-gh.param.HlfWid),0);
            SzePad(1,2)=max((gh.data.ix(ii,1)+gh.param.HlfWid)-gh.data.sze(1),0);
            SzePad(2,1)=max(1-(gh.data.iy(ii,1)-gh.param.HlfWid),0);
            SzePad(2,2)=max((gh.data.iy(ii,1)+gh.param.HlfWid)-gh.data.sze(2),0);
            
            % Use smaller bases
            for jj=1:size(gh.param.model.W,3)
                for kk=1:4
                    PartBasis{jj,kk}=rot90(gh.param.model.W(SzePad(1,1)+1:end-SzePad(1,2),SzePad(2,1)+1:end-SzePad(2,2),jj),kk);
                end
            end
            PartBasis{1,1}=gh.param.model.W(SzePad(1,1)+1:end-SzePad(1,2),SzePad(2,1)+1:end-SzePad(2,2),1);
            PartBasis{1,2}=gh.param.model.W(SzePad(1,1)+1:end-SzePad(1,2),SzePad(2,1)+1:end-SzePad(2,2),2);
            PartBasis{1,3}=gh.param.model.W(SzePad(1,1)+1:end-SzePad(1,2),SzePad(2,1)+1:end-SzePad(2,2),3);
            PartBasis{1,4}=gh.param.model.W(SzePad(1,1)+1:end-SzePad(1,2),SzePad(2,1)+1:end-SzePad(2,2),4);
            PartBasis{1,5}=gh.param.model.W(SzePad(1,1)+1:end-SzePad(1,2),SzePad(2,1)+1:end-SzePad(2,2),5);
            PartBasSze=size(PartBasis{1,1});
            
            % Reconstruct
            if UseFullBasis
                M=[ones(PartBasSze(1)*PartBasSze(2),1) PartBasis{1,1}(:) PartBasis{1,2}(:) PartBasis{1,3}(:) PartBasis{1,4}(:)...
                    PartBasis{2,1}(:) PartBasis{2,2}(:) PartBasis{2,3}(:) PartBasis{2,4}(:)...
                    PartBasis{3,1}(:) PartBasis{3,2}(:) PartBasis{3,3}(:) PartBasis{3,4}(:)];
            else
                M=[ones(PartBasSze(1)*PartBasSze(2),1) PartBasis{1,1}(:) PartBasis{2,1}(:) PartBasis{3,1}(:) PartBasis{4,1}(:) PartBasis{5,1}(:)];
            end
            c=M\ImPatch{1,ii}(:);
            ImPatch_Rec{1,ii}=reshape(M*c,PartBasSze(1),PartBasSze(2));
        end
end

Threshold=0.6;
[rr cc]=meshgrid(1:2*gh.param.HlfWid+1);
R=sqrt((rr-gh.param.HlfWid-1).^2+(cc-gh.param.HlfWid-1).^2)<=gh.param.HlfWid;
se=strel('disk',1);

for ii=StartNum:size(gh.data.ix,1)

    Mask=NormIm(ImPatch_Rec{1,ii})>Threshold;
    Mask=bwmorph(Mask,'bridge');
    Mask=bwmorph(Mask,'fill');
    while sum((Mask(:)>Threshold))<(gh.param.HlfWid*gh.param.HlfWid)
        Mask=imdilate(Mask,se);
    end
    
    if get(gh.main.PopupMenuObjType,'value')==1
        Mask=bwareaopen(Mask,round(gh.param.HlfWid^2/3),4);
        Mask=bwmorph(Mask,'diag');
        Mask=bwmorph(Mask,'spur');
        if (size(Mask,1)==gh.param.HlfWid) && (size(Mask,2)==gh.param.HlfWid)
            Mask=Mask.*R;
        end
    end
    
    [xL,xR,yL,yR]=donut_retrbound(ii);
    gh.data.LblMask(xL:xR,yL:yR)=max(gh.data.LblMask(xL:xR,yL:yR),ii*Mask);
end

donut_dispdrawfunc;