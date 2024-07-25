function cleanup_intermediate_files(sub,ses,datpath,delfiles,keepfiles,save_intermediate_results,subdir,save_folder)

ppparams.substring = ['sub-' num2str(sub,'%02d')];
if ~isfolder(fullfile(datpath,ppparams.substring)), ppparams.substring = ['sub-' num2str(sub,'%03d')]; end

ppparams.sesstring = ['ses-' num2str(ses,'%02d')];
if ~isfolder(fullfile(datpath,ppparams.substring,ppparams.sesstring)), ppparams.sesstring = ['ses-' num2str(ses,'%03d')]; end

subpath = fullfile(datpath,ppparams.substring,ppparams.sesstring);

subolddir = fullfile(subpath,subdir);
subnewdir = fullfile(subpath,save_folder);

if ~exist(subnewdir, 'dir')
    mkdir(subnewdir);
end

%% Delete intermediate files
if ~save_intermediate_results
    for i=1:numel(delfiles)
        if isfile(delfiles{i})
            if isfile(delfiles{i}{1}); delete(delfiles{i}{1}); end
        elseif isfolder(delfiles{i})
            rmdir(delfiles{i}{1},'s');
        end
    end
end

%% Move results
for i=1:numel(keepfiles)
    if isfile(keepfiles{i}{1})
        [opath,~,~] = fileparts(keepfiles{i}{1});
        if ~strcmp(opath,subnewdir)
            movefile(keepfiles{i}{1},subnewdir); 
        end
    end
end

end