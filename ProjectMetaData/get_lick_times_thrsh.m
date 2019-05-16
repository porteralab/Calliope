function licktimes=get_lick_times_thrsh(licktrace)

licktimes=find(diff(ntzo(licktrace)>0.2)==1);