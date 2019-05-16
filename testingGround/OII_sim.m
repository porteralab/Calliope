
% t=0:0.1:(200-0.1);
% nsamples = length(t);
% mov = zeros(500,500,nsamples);
% amp = .005;
% f =.1;
% sig = amp*cos(f*2*pi*t);
% 
% s = reshape(sig,[1,1,nsamples]);
% SIG = repmat(s,[10,10,1]);
% mov(51:60,51:60,:)=SIG;
% 
% sig2 = amp*cos(f*2*pi*t+.2*pi);
% SIG2=reshape(sig2,[1,1,nsamples]);
% SIG2=repmat(SIG2,[5,5,1]);
% 
% sig3 = amp*cos(f*2*pi*t-.2*pi);
% SIG3= reshape(sig3,[1,1,nsamples]);
% SIG3 = repmat(SIG3,[5,5,1]);
% mov(51:55,61:65,:)=SIG2;
% mov(48:52,48:52,:)=SIG3;
T = 16*(4);
T_period=10*4;
Fs = 10;
dt = 1/Fs;
t = 0:dt:T_period-dt;
barpos = .5+.5*sawtooth(2*pi*0.25*t);
plot(t,barpos)
grid on;

pxIdx = ceil(barpos*256);
pxIdx_rev = 256-pxIdx;
mov = zeros(256,256,length(dt));
bar_width = 5;
pos = 200;
aux_file = zeros(1,length(mov));
for ii = 1:length(t)
    barIdx = pxIdx(ii)-bar_width:pxIdx(ii)+bar_width;
    barIdx = barIdx(barIdx>0 & barIdx<=256);
    mov(:,barIdx,pos)=200;
    aux_file(pos)=200;
    pos = pos+1;
end
pos = pos+200;
for ii = 1:length(t)
    barIdx = pxIdx_rev(ii)-bar_width:pxIdx_rev(ii)+bar_width;
    barIdx = barIdx(barIdx>0 & barIdx<=256);
    mov(:,barIdx,pos)=200;
    aux_file(pos)=200;
    pos = pos+1;
end
pos = pos+200;
for ii = 1:length(t)
    barIdx = pxIdx(ii)-bar_width:pxIdx(ii)+bar_width;
    barIdx = barIdx(barIdx>0 & barIdx<=256);
    mov(barIdx,:,pos)=200;
    aux_file(pos)=200;
    pos = pos+1;
end
pos = pos+200;
for ii = 1:length(t)
    barIdx = pxIdx_rev(ii)-bar_width:pxIdx_rev(ii)+bar_width;
    barIdx = barIdx(barIdx>0 & barIdx<=256);
    mov(barIdx,:,pos)=200;
    aux_file(pos)=200;
    pos = pos+1;
end

filt = fspecial('gaussian',256,60);

filt = filt./max(filt(:));
Z = cellfun(@(x) x.*filt,num2cell(mov,[1 2]),'UniformOutput',false);
mov = cat(3,Z{:});

%mo2=mov+.1*randn(1,1,nsamples);

view_tiff_stack(mov)

