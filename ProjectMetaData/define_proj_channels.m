function [aux_chans]=define_proj_channels(projID)


switch projID
    case 'ENU'
        % 1: shutter
        % 2: frame galvo
        % 3: PS (unused)
        % 4: visual flow
        % 5: running (=4)
        % 6: laser PD - crosstalk from ch4/5
        % 7: screen PD
        % 8: dark on/off
        % 9: grating stim ID
        
        channel_ps_id=8;
        channel_air_puff=6;
        channel_screen_photo_diode=7;
        channel_stim_id=9;
        
    case 'HOM'
        % 1: shutter
        % 2: frame galvo
        % 3: PS (unused)
        % 4: visual flow
        % 5: running (=4)
        % 6: laser PD - crosstalk from ch4/5
        % 7: screen PD
        % 8: dark on/off
        % 9: grating stim ID
        
        channel_ps_id=8;
        channel_air_puff=6;
        channel_screen_photo_diode=7;
        channel_stim_id=9;
        
    case 'NPY'
        % 1: shutter
        % 2: frame galvo
        % 3: PS
        % 4: visual flow
        % 5: running
        % 6: air puff
        % 7: screen PD

        aux_chans{1,1}=3;
        aux_chans{1,2}='ps_id';
        
        aux_chans{2,1}=6;
        aux_chans{2,2}='air_puff';
        
        aux_chans{5,1}=7;
        aux_chans{5,2}='screen_pd';
        
    case 'PRE'
        % 1: shutter
        % 2: frame galvo
        % 3: PS
        % 4: visual flow
        % 5: running
        % 6: laser PD - crosstalk from ch4/5
        % 7: screen PD
        % 8: dark on/off
        % 9: grating stim ID
        % 10: air puff
        
        aux_chans{1,1}=3;
        aux_chans{1,2}='ps_id';
        
        aux_chans{2,1}=6;
        aux_chans{2,2}='air_puff';
        
        aux_chans{3,1}=7;
        aux_chans{3,2}='screen_pd';
        
        
    case 'M1'
        % 1: shutter
        % 2: frame galvo
        % 3: VR angular PS signal
        % 4: visual flow
        % 5: running linear 1st D
        % 6: air puff
        % 7: laser PD
        % 8: running rotation 2nd D
        % 9: VR position in tunnel length (x)
        % 10: VR angle facing to midline
        % 11: VR reward signal
        % 12: VR position in tunnel width (y)
        % 13: empty
        % 14: lick reporter
        
        aux_chans{1,1}=3;
        aux_chans{1,2}='ps_id';
        
        aux_chans{2,1}=6;
        aux_chans{2,2}='air_puff';
        
        aux_chans{3,1}=7;
        aux_chans{3,2}='laser_pd';
        
        aux_chans{4,1}=11;
        aux_chans{4,2}='VRrew';
        
        aux_chans{5,1}=9;
        aux_chans{5,2}='VRx';
        
        aux_chans{6,1}=12;
        aux_chans{6,2}='VRy';
        
        aux_chans{7,1}=10;
        aux_chans{7,2}='VRangle';
                
    case 'VML'
        % 1: shutter
        % 2: frame galvo
        % 3: PS (full field mismatch)
        % 4: visual flow
        % 5: running
        % 6: air_puff
        
        %         channel_ps_id=3;
        %         channel_air_puff=6;
        %         channel_screen_photo_diode=3;
        %         channel_stim_id=3;
        aux_chans{1,1}=3;
        aux_chans{1,2}='ps_id';
        
        aux_chans{2,1}=6;
        aux_chans{2,2}='airPuff';
        
    case 'LFM'
        % old VR
        % 1: shutter
        % 2: frame galvo
        % 3: PS (local and full field mismatch)
        % 4: visual flow
        % 5: running
        % 6: air puff
        % 7: laser PD - crosstalk from ch6
        % 8: dark on/off (unused)
        % 9: screen PD
        
        % new VR
        % 1: shutter
        % 2: frame galvo
        % 3: PS (local and full field mismatch)
        % 4: visual flow
        % 5: running
        % 6: air puff
        % 7: tunnel position
        % 8: screen photodiode
        
        aux_chans{1,1}=3;
        aux_chans{1,2}='ps_id';
        
        aux_chans{2,1}=6;
        aux_chans{2,2}='airPuff';
        
%         aux_chans{3,1}=7;
%         aux_chans{3,2}='trackPos';
        
        aux_chans{3,1}=9;
        aux_chans{3,2}='screenPD';
        
    case 'ACC'
        % 1: shutter
        % 2: frame galvo
        % 3: pertubations
        % 4: visual flow
        % 5: running
        % 6: air puff
        % 7: laser PD - crosstalk from ch6
        % 8: (unused)
        % 9: screen PD
        aux_chans{1,1}=3;
        aux_chans{1,2}='ps_id';
        
        aux_chans{2,1}=6;
        aux_chans{2,2}='airPuff';
        
        aux_chans{3,1}=7;
        aux_chans{3,2}='trackPos';
        
        aux_chans{4,1}=9;
        aux_chans{4,2}='screenPD';
        
    case 'ACC'
        % 1: shutter
        % 2: frame galvo
        % 3: pertubations
        % 4: visual flow
        % 5: running
        % 6: air puff
        % 7: laser PD - crosstalk from ch6
        % 8: (unused)
        % 9: screen PD
        aux_chans{1,1}=3;
        aux_chans{1,2}='ps_id';
        
        aux_chans{2,1}=6;
        aux_chans{2,2}='airPuff';
        
        aux_chans{3,1}=7;
        aux_chans{3,2}='trackPos';
        
        aux_chans{4,1}=9;
        aux_chans{4,2}='screenPD';
        
    case 'SCR'
        % 1: shutter
        % 2: frame galvo
        % 3: visual flow
        % 4: running
        % 5: vrypos
        % 6: reward trig
        % 7: lick
        aux_chans{1,1}=5;
        aux_chans{1,2}='VRypos';
        
        aux_chans{2,1}=6;
        aux_chans{2,2}='RewardTrig';
        
        aux_chans{3,1}=7;
        aux_chans{3,2}='Lick';
        
    case 'ARW'  % ACC reward in 2d VRE
        % auxrec.channel0 = "Shutter"
        % auxrec.channel1 = "FrameGalvo"
        % auxrec.channel2 = "Perturbation"
        % auxrec.channel3 = "VisualFlow"
        % auxrec.channel4 = "Running"
        % auxrec.channel5 = "AirPuff"
        % auxrec.channel6 = "LaserPhotoDiode"
        % auxrec.channel7 = "RewardTrig"
        % auxrec.channel8 = "Running_Rot"
        % auxrec.channel9 = "VRypos"
        % auxrec.channel10 = "VRxpos"
        % auxrec.channel11 = "VRangle"
        % auxrec.channel12 = "Lick"
        
        aux_chans{1,1}=3;
        aux_chans{1,2}='ps_id';
        
        aux_chans{2,1}=6;
        aux_chans{2,2}='air_puff';
        
        aux_chans{3,1}=7;
        aux_chans{3,2}='laser_pd';
        
        aux_chans{4,1}=8;
        aux_chans{4,2}='VRrew';
        
        aux_chans{5,1}=11;
        aux_chans{5,2}='VRx';
        
        aux_chans{6,1}=10;
        aux_chans{6,2}='VRy';
        
        aux_chans{7,1}=12;
        aux_chans{7,2}='VRangle';
        
        aux_chans{8,1}=13;
        aux_chans{8,2}='licking';
        
    case 'ACX'
        aux_chans{1,1}=5;
        aux_chans{1,2}='screenPD';
        aux_chans{2,1}=6;
        aux_chans{2,2}='aud_trig';
        aux_chans{3,1}=7;
        aux_chans{3,2}='aud_stim';
        
    case 'DCA'
        aux_chans{1,1}=8;
        aux_chans{1,2}='airPuff';
        aux_chans{2,1}=4;
        aux_chans{2,2}='screenPD';
        aux_chans{3,1}=6;
        aux_chans{3,2}='darkOnOff';
        aux_chans{4,1}=7;
        aux_chans{4,2}='stimulusID';
    case 'OMM'
        aux_chans{1,1}=4;
        aux_chans{1,2}='airPuff';
        aux_chans{2,1}=5;
        aux_chans{2,2}='Flip';
        aux_chans{3,1}=6;
        aux_chans{3,2}='GratFlash';
        aux_chans{4,1}=7;
        aux_chans{4,2}='screenPD';
        aux_chans{5,1}=8;
        aux_chans{5,2}='VRx';
        aux_chans{6,1}=9;
        aux_chans{6,2}='Licking';
        aux_chans{7,1}=10;
        aux_chans{7,2}='VROnOff';
        aux_chans{8,1}=11;
        aux_chans{8,2}='Reward';
        aux_chans{9,1} = 12;
        aux_chans{9,2} = 'Dark';    
        
    case 'AD'
        aux_chans{1,1}=8;
        aux_chans{1,2}='airPuff';
        aux_chans{2,1}=4;
        aux_chans{2,2}='screenPD';
        aux_chans{3,1}=6;
        aux_chans{3,2}='darkOnOff';
        aux_chans{4,1}=7;
        aux_chans{4,2}='stimulusID';
end













