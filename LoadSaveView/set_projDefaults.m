function projDefaults=set_projDefaults(proj);

switch proj
    case 'LEC'
        projDefaults={'.ini' '.lvd' '.bin' '.run' '.eye'};
    case 'LFM'
        projDefaults={'.ini'};
    case 'DCA'
        projDefaults={'.ini'};
    case 'VML'
        projDefaults={'.ini' '.lvd'};
    case 'PRE'
        projDefaults={'.ini' '.lvd'};
    case 'M1'
        projDefaults={'.ini'};
    case 'ACX'
        projDefaults={'.ini' '.lvd'};
    case 'OMM'
        projDefaults={'.ini' '.lvd'};
    otherwise
        projDefaults={'.ini' '.lvd' '.bin'};
end