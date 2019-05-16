function out = AdaptHistEqual(in,winsize)

in = im2uint8(in);
si = size(in);
FR = Filter_RankAK;
FR.doIrescale = 1;
FR.doIrandomise = 0;
FR.doInewimage = 0;
FR.windowsize = winsize;

INIJ = ArrayToIj(in);
FR.setup('',INIJ);
IP = INIJ.getProcessor;
disp('Processing adaptive histogram equalization in Java...please wait');
FR.run(IP);
disp('Adaptive histogram equalization complete');
pix = IP.getPixels;
out = FixSign((reshape(pix,si(2),si(1)))');