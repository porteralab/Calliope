function [ltimes] = get_lick_times(lmeta,auxd)

nbr_frames = length(lmeta);
shutter_open = find(diff(auxd(1,:)) > 2.5);
shutter_close = find(diff(-auxd(1,:)) > 2.5);

for ind=1:length(nbr_frames)
    ltimes(sum(nbr_frames(1:ind-1))+1:sum(nbr_frames(1:ind)))=lmeta(2,sum(nbr_frames(1:ind-1))+1:sum(nbr_frames(1:ind)))...
        +shutter_open(ind)-lmeta(2,sum(nbr_frames(1:ind-1))+1);
end

ltimes = round(ltimes);