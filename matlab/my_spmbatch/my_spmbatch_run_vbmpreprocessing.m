function out = my_spmbatch_run_vbmpreprocessing(sub,ses,datpath,paramsfile)

load(paramsfile)

try
    %% preprocess anatomical scans
    [delfiles,keepfiles] = my_spmbatch_cat12vbm(sub,ses,datpath,params);

    % Clean up unnecessary files
    cleanup_intermediate_files(sub,ses,datpath,delfiles,keepfiles,params.save_intermediate_results,'anat',params.save_folder);
catch e
    fprintf('\nPP_Error\n');
    fprintf('\nThe error was: \n%s\n',e.message)
end

fprintf('\nPP_Completed\n');

out = 1;