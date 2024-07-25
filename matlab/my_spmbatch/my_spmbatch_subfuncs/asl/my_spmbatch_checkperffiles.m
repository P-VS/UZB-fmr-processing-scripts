function ppparams = my_spmbatch_checkperffiles(ppparams,params)

namefilters(1).name = ppparams.substring;
namefilters(1).required = true;

namefilters(2).name = ppparams.sesstring;
namefilters(2).required = false;

namefilters(3).name = ['run-' num2str(ppparams.run)];
if params.func.mruns, namefilters(3).required = true; else namefilters(3).required = false; end

namefilters(4).name = ['task-' ppparams.task];
namefilters(4).required = true;

namefilters(5).name = '_echo-1';
namefilters(5).required = true;

% asl data

namefilters(6).name = '_asl';
namefilters(6).required = true;

aslniilist = my_spmbatch_dirfilelist(ppparams.subperfdir,'nii',namefilters,false);

if isempty(aslniilist)
    fprintf(['No asl nifti file found for ' ppparams.substring ' ' ppparams.sesstring ' task-' ppparams.task '\n'])
    fprintf('\nPP_Error\n');
    return
end

prefixlist = split({aslniilist.name},'sub-');
if numel(aslniilist)==1, prefixlist=prefixlist{1}; else prefixlist = prefixlist(:,:,1); end

studyprefix = ppparams.func(1).prefix;

perfcheck = true;
while perfcheck
    tmp = find(strcmp(prefixlist,studyprefix));
    if ~isempty(tmp)
        ppparams.perf(1).aslprefix = studyprefix; 
        perfcheck = false;
    else 
        studyprefix = studyprefix(2:end); 
        if length(studyprefix) == 0 
            perfcheck = false; 
        end
    end
end

if ~isempty(tmp)
    ffile = aslniilist(tmp).name;
    fsplit = split(ffile,ppparams.perf(1).aslprefix);
    ppparams.perf(1).aslfile = fsplit{2};
end

% m0scan data

namefilters(6).name = '_m0scan';
namefilters(6).required = true;

m0scanniilist = my_spmbatch_dirfilelist(ppparams.subperfdir,'nii',namefilters,false);

if isempty(m0scanniilist)
    fprintf(['No m0scan nifti file found for ' ppparams.substring ' ' ppparams.sesstring ' task-' ppparams.task '\n'])
    fprintf('\nPP_Error\n');
    return
end

prefixlist = split({m0scanniilist.name},'sub-');
if numel(m0scanniilist)==1, prefixlist=prefixlist{1}; else prefixlist = prefixlist(:,:,1); end

studyprefix = ppparams.func(1).prefix;

perfcheck = true;
while perfcheck
    tmp = find(strcmp(prefixlist,studyprefix));
    if ~isempty(tmp)
        ppparams.perf(1).m0scanprefix = studyprefix; 
        perfcheck = false;
    else 
        studyprefix = studyprefix(2:end); 
        if length(studyprefix) == 0 
            perfcheck = false; 
        end
    end
end

if ~isempty(tmp)
    ffile = m0scanniilist(tmp).name;
    fsplit = split(ffile,ppparams.perf(1).m0scanprefix);
    ppparams.perf(1).m0scanfile = fsplit{2};
end

tmp=find(contains(prefixlist,'c1'));
if ~isempty(tmp), ppparams.perf(1).c1m0scanfile = m0scanniilist(tmp).name; end

tmp=find(contains(prefixlist,'c2'));
if ~isempty(tmp), ppparams.perf(1).c2m0scanfile = m0scanniilist(tmp).name; end

tmp=find(contains(prefixlist,'c3'));
if ~isempty(tmp), ppparams.perf(1).c3m0scanfile = m0scanniilist(tmp).name; end

% deltam data

namefilters(6).name = '_deltam';
namefilters(6).required = true;

deltamniilist = my_spmbatch_dirfilelist(ppparams.subperfdir,'nii',namefilters,false);

if ~isempty(deltamniilist)
    prefixlist = split({deltamniilist.name},'sub-');
    if numel(deltamniilist)==1, prefixlist=prefixlist{1}; else prefixlist = prefixlist(:,:,1); end
    
    studyprefix = ppparams.func(1).prefix;
    
    perfcheck = true;
    while perfcheck
        tmp = find(strcmp(prefixlist,studyprefix));
        if ~isempty(tmp)
            ppparams.perf(1).deltamprefix = studyprefix; 
            perfcheck = false;
        else 
            studyprefix = studyprefix(2:end); 
            if length(studyprefix) == 0 
                perfcheck = false; 
            end
        end
    end
    
    if ~isempty(tmp)
        ffile = deltamniilist(tmp).name;
        fsplit = split(ffile,ppparams.perf(1).deltamprefix);
        ppparams.perf(1).deltamfile = fsplit{2};
    end
end

% CBF data

namefilters(5).name = '_cbf';
namefilters(5).required = true;

cbfniilist = my_spmbatch_dirfilelist(ppparams.subperfdir,'nii',namefilters,false);

if ~isempty(cbfniilist)
    prefixlist = split({cbfniilist.name},'sub-');
    if numel(cbfniilist)==1, prefixlist=prefixlist{1}; else prefixlist = prefixlist(:,:,1); end
    
    studyprefix = ppparams.func(1).prefix;
    
    perfcheck = true;
    while perfcheck
        tmp = find(strcmp(prefixlist,studyprefix));
        if ~isempty(tmp)
            ppparams.perf(1).cbfprefix = studyprefix; 
            perfcheck = false;
        else 
            studyprefix = studyprefix(2:end); 
            if length(studyprefix) == 0 
                perfcheck = false; 
            end
        end
    end
    
    if ~isempty(tmp)
        ffile = cbfniilist(tmp).name;
        fsplit = split(ffile,ppparams.perf(1).cbfprefix);
        ppparams.perf(1).cbffile = fsplit{2};
    end
end
