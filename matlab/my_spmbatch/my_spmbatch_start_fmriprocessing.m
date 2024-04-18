function my_spmbatch_start_fmriprocessing(sublist,nsessions,datpath,params)

if ~params.meepi, params.echoes = [1]; end
if ~params.mruns, params.runs = [1]; end

params.use_echoes_as_sessions = false;
if params.meepi && ~contains(params.fmri_prefix,'c'), params.use_echoes_as_sessions = true; end
if params.meepi && contains(params.fmri_prefix,'c'), params.echoes = [1]; end

if ~contains(params.fmri_prefix,'s'), params.do_smoothing = true; else params.do_smoothing = false; end

if params.mruns
    switch params.use_runs
        case 'separately'
            params.oruns = params.runs; 
            params.iruns = [1];
        case 'together'
            params.oruns = [1];
            params.iruns = params.runs;
    end
else
    params.oruns = [1];
    params.iruns = [1];
end

save(fullfile(datpath,'params.mat'),'params')

datlist = zeros(numel(sublist)*numel(nsessions),3);

dpos = 1;
for i = 1:numel(sublist)
    for j = 1:numel(nsessions)
        for k = 1:numel(params.oruns)
            datlist(dpos,1) = sublist(i);
            datlist(dpos,2) = nsessions(j);
            datlist(dpos,3) = params.oruns(k);
    
            dpos = dpos+1;
        end
    end
end

numpacks = ceil(numel(datlist(:,1))/params.maxprocesses);

for k = 1:numel(params.task)
    if params.use_parallel
        for j=1:numpacks
            if (j*params.maxprocesses)<=numel(datlist(:,1))
                maxruns = params.maxprocesses;
            else
                maxruns = params.maxprocesses-((j*params.maxprocesses)-numel(datlist(:,1)));
            end
    
            for is = 1:maxruns
                i = (j-1)*params.maxprocesses+is;
    
                fprintf(['\nStart processing data for subject ' num2str(datlist(i,1)) ' session ' num2str(datlist(i,2)) ' run ' num2str(datlist(i,3)) ' task ' params.task{k} '\n'])
        
                mtlb_cmd = sprintf('"restoredefaultpath;addpath(genpath(''%s''));addpath(genpath(''%s''));my_spmbatch_run_fmriprocessing(%d,%d,%d,''%s'',''%s'',''%s'');"', ...
                                            params.spm_path,params.my_spmbatch_path,datlist(i,1),datlist(i,2),datlist(i,3),params.task{k},datpath,fullfile(datpath,'params.mat'));
                logfile{i} = fullfile(datpath,['fmri_process_logfile_' sprintf('%03d',datlist(i,1)) '_' sprintf('%02d',datlist(i,2)) '_' sprintf('%02d',datlist(i,3)) '_' params.task{k} '.txt']);
        
                if exist(logfile{i},'file'), delete(logfile{i}); end
                
                if ispc
                    export_cmd = ['set PATH=' fullfile(matlabroot,'bin')];
                    [status,result] = system(export_cmd);
                    system_cmd = sprintf(['start matlab -nodesktop -nosplash -r ' mtlb_cmd ' -logfile ' logfile{i}]);
                else
                    system_cmd = sprintf([fullfile(matlabroot,'bin') '/matlab -nosplash -r ' mtlb_cmd ' -logfile ' logfile{i} ' & ']);
                end
                [status,result]=system(system_cmd);
            end
            
            %% wait for all processing to be finnished
            isrunning = true;
            pfinnished = 0;
            while isrunning
                for is = 1:maxruns
                    i = (j-1)*params.maxprocesses+is;
    
                    if exist(logfile{i},'file')
                        FID     = fopen(logfile{i},'r');
                        txt     = textscan(FID,'%s');
                        txt     = txt{1}; 
                        test=find(cellfun('isempty',strfind(txt,'PP_Completed'))==0,1,'first');
                        errortest=find(cellfun('isempty',strfind(txt,'PP_Error'))==0,1,'first');
                        fclose(FID);
    
                        if ~isempty(errortest)
                            pfinnished = pfinnished+1;
    
                            nlogfname = fullfile(datpath,['error_fmri_process_logfile_' sprintf('%03d',datlist(i,1)) '_' sprintf('%02d',datlist(i,2)) '_' sprintf('%02d',datlist(i,3)) '_' params.task{k} '.txt']);
                            movefile(logfile{i},nlogfname);
    
                            fprintf(['\nError during processing data for subject ' num2str(datlist(i,1)) ' session ' num2str(datlist(i,2)) ' run ' num2str(datlist(i,3)) ' task ' params.task{k} '\n'])
                        elseif ~isempty(test)
                            pfinnished = pfinnished+1;
    
                            if ~params.keeplogs
                                delete(logfile{i}); 
                            else
                                nlogfname = fullfile(datpath,['done_fmri_process_logfile_' sprintf('%03d',datlist(i,1)) '_' sprintf('%02d',datlist(i,2)) '_' sprintf('%02d',datlist(i,3)) '_' params.task{k} '.txt']);
                                movefile(logfile{i},nlogfname);
                            end
    
                            fprintf(['\nDone processing data for subject ' num2str(datlist(i,1)) ' session ' num2str(datlist(i,2)) ' run ' num2str(datlist(i,3)) ' task ' params.task{k} '\n'])
                        end
                    end
                end
        
                if pfinnished==maxruns 
                    isrunning = false; 
                else
                    pause(60);
                end
            end
        end
    else            
        for i=1:numel(datlist(:,1))
            my_spmbatch_run_fmriprocessing(datlist(i,1),datlist(i,2),datlist(i,3),params.task{k},datpath,fullfile(datpath,'params.mat'));
        end
    end
end

delete(fullfile(datpath,'params.mat'),'params')