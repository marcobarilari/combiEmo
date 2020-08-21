%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Stimulation for functional runs of fMRI design  %%%
%%%   programmer: Federica Falagiarda October 2019   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Once fully run, this script has given a txt output file per run (nReps*3) with:%


% stimuli are presented in blocks; each block contains one modality of stimuli %
% possible modalities are: visual (face), auditory (voice), bimodal (face and voice vombined) %
% there are four possible emotions portrayed by four identities %
% EMOTIONS: disgust, fear, happiness, sadness, neutral %
% identities: act27 female, act30 female, act32 lae, act33, male %

expName = 'eventrelated_combiemo';

%%% All useful variables/parameters %%%

% time stamp as the experiment starts
expStart = GetSecs;

% colors
white = 255;
black = 0;
midgrey = [127 127 127];
bgColor = black;
fixColor = black;
textColor = white;

% variables to build block / trial loops
nBlocks = 3; % num of different runs - one per modality * num of reps
nTrials = 20; % per run: 4 emotions * 4 actors * 2 within-run reps (more stable beta)
visualModality = 1;
auditoryModality = 2;
multiModality = 3;

% for the frame loop (visual stim)
nFrames = 30; % total num of frames in a whole video
stimXsize = 720;
stimYsize = 480;


% input info
subjNumber = input('Subject number:');
subjAge = input('Age:');
nReps = input('Number of repetitions:');
% if no value is supplied, do 12 reps
if isempty(nReps)
    nReps=12;
end

% this defines the modality block order within a subject
% modality orded will be fixed within participant, and randomized/balanced across %
% 1 = visual, 2 = auditory, 3 = bimodal
blockModalityVector = input('Input in square brackets - modality order:');
% if no value is supplied, choose order randomly
if isempty(blockModalityVector)
    blockModalityVector=randperm(3);
end

% add supporting functions to the path
addpath(genpath('./supporting_functions'));


%% INITIALIZE SCREEN AND START THE STIMULI PRESENTATION %%

% basic setup checking
AssertOpenGL;

% This sets a PTB preference to possibly skip some timing tests: a value
% of 0 runs these tests, and a value of 1 inhibits them. This
% should always be set to 0 for actual experiments
%Screen('Preference', 'SkipSyncTests', 2);
Screen('Preference', 'SkipSyncTests', 0);

Screen('Preference', 'ConserveVRAM', 4096);

% define default font size for all text uses (i.e. DrawFormattedText fuction)
Screen('Preference', 'DefaultFontSize', 28);

screenVector = Screen('Screens');
% OpenWindow
%[mainWindow, screenRect] = Screen('OpenWindow', max(screenVector), bgColor, [0 0 1000 700], 32, 2);
[mainWindow, screenRect] = Screen('OpenWindow', max(screenVector), bgColor, [], 32, 2);
%[mainWindow, screenRect] = Screen('OpenWindow', 0, bgColor, [], 32, 2);
%[mainWindow, screenRect] = Screen('OpenWindow', 0, bgColor);

% estimate the monitor flip interval for the onscreen window
interFrameInterval = Screen('GetFlipInterval', mainWindow); % in seconds
msInterFrameInterval = interFrameInterval*1000; %in ms

% timings in my trial sequence
ISI = 3 - interFrameInterval/3;
fixationDur = 0.5 - interFrameInterval/3;
responseDur = 4 - interFrameInterval/3;
practiceResponseDur = 5 - interFrameInterval/3;
videoFrameRate = 29.97;
frameDuration = 1/videoFrameRate - interFrameInterval/3;
audioFileDuration = 1 - 2*interFrameInterval/3;
minJitter=-0.25;
maxJitter=0.25;
% create a distribution to draw random jitters
%jitterDistribution=create_jitter(minJitter,maxJitter);

% get width and height of the screen
[widthWin, heightWin] = Screen('WindowSize', mainWindow);
widthDis = Screen('DisplaySize', max(screenVector));
Priority(MaxPriority(mainWindow));

% to overcome the well-known randomisation problem
RandStream.setGlobalStream (RandStream('mt19937ar','seed',sum(100*clock)));

% hide mouse cursor
HideCursor(mainWindow);
% Listening enabled and any output of keypresses to Matlabs windows is
% suppressed (see ref. page for ListenChar)
ListenChar(2);
KbName('UnifyKeyNames');

        % FIXATION CROSS JAZZ %
        % estimate the distance between subject and monitor, in cm
        testDistance = 60; % to be changed with real value

        %calcualte degree to pixels conversion coefficient
        deg2pixCoeff = 1/(atan(widthDis/(widthWin*(testDistance*10)))*180/pi);
        
        % define the dimension of the fixation cross in degrees and convert it to
        % pixels using the deg2pix coefficient
        fixationSizeDeg = 0.3;
        fixationSizePix = round(fixationSizeDeg * deg2pixCoeff);

        % define the dimension of the line for your fixation cross and convert it
        % to pixels
        lineSize = 0.05;
        lineSizePix = round(lineSize *deg2pixCoeff);

        % find the center of the screen and transpose to column
        centros = (screenRect(3:4)/2)';

        % fixation cross coordinates
        fixationXY = repmat(centros, 1, 4) + [0, 0, fixationSizePix, -fixationSizePix; fixationSizePix, -fixationSizePix, 0, 0];
        
        % define distance of stimulus from center of the screen and convert
        % it to pixels
        stimDegDistance = 6;
        stimPixDistance = round(stimDegDistance * deg2pixCoeff);
        

        
%% Instructions text %%

generalInstructions1 = 'Press the button when you perceive a repeated emotion.';


%% CREATING THE VISUAL STIMULI

frameNum = (1:30);
actor = {'27','30','32','33'};
emotion = {'ne','di','fe','ha','sa'};

allFrameNamesFaces = cell(30,20);
c=1;
for a = 1:length(actor)
    for e = 1:length(emotion)
        for f = 1:length(frameNum)
        allFrameNamesFaces{f,c} = {['V' actor{a} emotion{e} '_' num2str(frameNum(f))]};
        end
        c=c+1;
    end
end


% Build one structure per "video"

framePath = '/visual_stim/face_frames/'; % where to find the images

Ne27Struct = struct; Ne27Struct = buildFramesStruct(mainWindow, Ne27Struct, nFrames, frameDuration, allFrameNamesFaces(:,1), framePath);
Di27Struct = struct; Di27Struct = buildFramesStruct(mainWindow, Di27Struct, nFrames, frameDuration, allFrameNamesFaces(:,2), framePath);
Fe27Struct = struct; Fe27Struct = buildFramesStruct(mainWindow, Fe27Struct, nFrames, frameDuration, allFrameNamesFaces(:,3), framePath);
Ha27Struct = struct; Ha27Struct = buildFramesStruct(mainWindow, Ha27Struct, nFrames, frameDuration, allFrameNamesFaces(:,4), framePath);
Sa27Struct = struct; Sa27Struct = buildFramesStruct(mainWindow, Sa27Struct, nFrames, frameDuration, allFrameNamesFaces(:,5), framePath);

Ne30Struct = struct; Ne30Struct = buildFramesStruct(mainWindow, Ne30Struct, nFrames, frameDuration, allFrameNamesFaces(:,6), framePath);
Di30Struct = struct; Di30Struct = buildFramesStruct(mainWindow, Di30Struct, nFrames, frameDuration, allFrameNamesFaces(:,7), framePath);
Fe30Struct = struct; Fe30Struct = buildFramesStruct(mainWindow, Fe30Struct, nFrames, frameDuration, allFrameNamesFaces(:,8), framePath);
Ha30Struct = struct; Ha30Struct = buildFramesStruct(mainWindow, Ha30Struct, nFrames, frameDuration, allFrameNamesFaces(:,9), framePath);
Sa30Struct = struct; Sa30Struct = buildFramesStruct(mainWindow, Sa30Struct, nFrames, frameDuration, allFrameNamesFaces(:,10), framePath);

Ne32Struct = struct; Ne32Struct = buildFramesStruct(mainWindow, Ne32Struct, nFrames, frameDuration, allFrameNamesFaces(:,11), framePath);
Di32Struct = struct; Di32Struct = buildFramesStruct(mainWindow, Di32Struct, nFrames, frameDuration, allFrameNamesFaces(:,12), framePath);
Fe32Struct = struct; Fe32Struct = buildFramesStruct(mainWindow, Fe32Struct, nFrames, frameDuration, allFrameNamesFaces(:,13), framePath);
Ha32Struct = struct; Ha32Struct = buildFramesStruct(mainWindow, Ha32Struct, nFrames, frameDuration, allFrameNamesFaces(:,14), framePath);
Sa32Struct = struct; Sa32Struct = buildFramesStruct(mainWindow, Sa32Struct, nFrames, frameDuration, allFrameNamesFaces(:,15), framePath);

Ne33Struct = struct; Ne33Struct = buildFramesStruct(mainWindow, Ne33Struct, nFrames, frameDuration, allFrameNamesFaces(:,16), framePath);
Di33Struct = struct; Di33Struct = buildFramesStruct(mainWindow, Di33Struct, nFrames, frameDuration, allFrameNamesFaces(:,17), framePath);
Fe33Struct = struct; Fe33Struct = buildFramesStruct(mainWindow, Fe33Struct, nFrames, frameDuration, allFrameNamesFaces(:,18), framePath);
Ha33Struct = struct; Ha33Struct = buildFramesStruct(mainWindow, Ha33Struct, nFrames, frameDuration, allFrameNamesFaces(:,19), framePath);
Sa33Struct = struct; Sa33Struct = buildFramesStruct(mainWindow, Sa33Struct, nFrames, frameDuration, allFrameNamesFaces(:,20), framePath);

% put them all together
myFacesStructArray = {Ne27Struct,Di27Struct,Fe27Struct,Ha27Struct,Sa27Struct,Ne30Struct,Di30Struct,Fe30Struct,Ha30Struct,Sa30Struct,Ne32Struct,Di32Struct,Fe32Struct,Ha32Struct,Sa32Struct,Ne33Struct,Di33Struct,Fe33Struct,Ha33Struct,Sa33Struct};


%% AUDITORY STIMULI
%stimNameVoices = {'A27ne.wav','A27di.wav','A27fe.wav','A27ha.wav','A27sa.wav','A30ne.wav','A30di.wav','A30fe.wav','A30ha.wav','A30sa.wav','A32ne.wav','A32di.wav','A32fe.wav','A32ha.wav','A32sa.wav','A33ne.wav','A33di.wav','A33fe.wav','A33ha.wav','A33sa.wav'};
stimName = {'27ne','27di','27fe','27ha','27sa','30ne','30di','30fe','30ha','30sa','32ne','32di','32fe','32ha','32sa','33ne','33di','33fe','33ha','33sa'};

stimEmotion = repmat(1:5,1,4);
stimActor = [repmat(27,1,5),repmat(30,1,5),repmat(32,1,5),repmat(33,1,5)];

%% Read everything into a structure
% preallocate
myExpTrials = struct;
% for the experiment
for t = 1:length(stimName)
        myExpTrials(t).stimulusname = stimName{t};
        myExpTrials(t).visualstimuli = myFacesStructArray{t};
        [myExpTrials(t).audy, myExpTrials(t).audfreq] = audioread([cd '/auditory_stim/A' myExpTrials(t).stimulusname '.wav']);
        myExpTrials(t).wavedata = myExpTrials(t).audy';
        myExpTrials(t).nrchannels = size(myExpTrials(t).wavedata,1);
        myExpTrials(t).emotion = stimEmotion(t);
        myExpTrials(t).actor = stimActor(t);
end

% black image for audio-only presentation
blackImage = Screen('MakeTexture', mainWindow ,imread([cd '/visual_stim/black_img.pngblack_img.png']));

%% Insert the task stimuli as extra trials
% vector with block numbers
allBlocks = 1:nReps;
stimEmotion = repmat(1:5,1,4);

% randomly select a third of the blocks to have 2 1-back stimuli for the voices %
twoBackStimBlocksVoices = datasample(allBlocks,round(length(allBlocks)/3),'Replace',false);
% from the remaining blocks, select another third to have one 1-back stimulus %
remainingBlocksVoices = setdiff(allBlocks,twoBackStimBlocksVoices);
oneBackStimBlocksVoices = datasample(remainingBlocksVoices,round(length(allBlocks)/3),'Replace',false);
% the unselected blocks will have no 1-back stimuli
zeroBackStimBlocksVoices = setdiff(remainingBlocksVoices,oneBackStimBlocksVoices);

% randomly select a third of the blocks to have 2 1-back stimuli for the Faces %
twoBackStimBlocksFaces = datasample(allBlocks,round(length(allBlocks)/3),'Replace',false);
% from the remaining blocks, select another third to have one 1-back stimulus %
remainingBlocksFaces = setdiff(allBlocks,twoBackStimBlocksFaces);
oneBackStimBlocksFaces = datasample(remainingBlocksFaces,round(length(allBlocks)/3),'Replace',false);
% the unselected blocks will have no 1-back stimuli
zeroBackStimBlocksFaces = setdiff(remainingBlocksFaces,oneBackStimBlocksFaces);

% randomly select a third of the blocks to have 2 1-back stimuli for the objects%
twoBackStimBlocksPerson = datasample(allBlocks,round(length(allBlocks)/3),'Replace',false);
% from the remaining blocks, select another third to have one 1-back stimulus %
remainingBlocksPerson = setdiff(allBlocks,twoBackStimBlocksPerson);
oneBackStimBlocksPerson = datasample(remainingBlocksPerson,round(length(allBlocks)/3),'Replace',false);
% the unselected blocks will have no 1-back stimuli
zeroBackStimBlocksPerson = setdiff(remainingBlocksPerson,oneBackStimBlocksPerson);


% triggers
cfg = struct;
cfg.testingDevice = 'mri'; cfg.triggerKey = 's'; cfg.numTriggers = 1; cfg.win = mainWindow; cfg.text.color = textColor;
cfg.bids.MRI.RepetitionTime = 2.55;

%% BLOCK AND TRIAL LOOP
% for sound to be used: perform basic initialization of the sound driver
InitializePsychSound(1);
% priority
Priority(MaxPriority(mainWindow));

% Repetition loop
for rep = 1:nReps  
    
%     % check on participant every 3 blocks
%     if rep > 1
%         DrawFormattedText(mainWindow, 'Ready to continue?', 'center', 'center', textColor);
%         Screen('Flip', mainWindow);
%         waitForKb('space');
%     end
    
    
    % define an index, n, that knows which kind of block/rep it is for number of one back tasks for faces %
    if ismember(rep,zeroBackStimBlocksFaces)
        n = 0;
    elseif ismember(rep,oneBackStimBlocksFaces)
        n = 1;
    elseif ismember(rep,twoBackStimBlocksFaces)
        n = 2;
    end
    % a different index for voices
    if ismember(rep,zeroBackStimBlocksVoices)
        v = 0;
    elseif ismember(rep,oneBackStimBlocksVoices)
        v = 1;
    elseif ismember(rep,twoBackStimBlocksVoices)
        v = 2;
    end
    % a different index for bimodal
    if ismember(rep,zeroBackStimBlocksPerson)
        w = 0;
    elseif ismember(rep,oneBackStimBlocksPerson)
        w = 1;
    elseif ismember(rep,twoBackStimBlocksPerson)
        w = 2;
    end
    
    % and choose randomly which trial will be repeated in this block (if any)
    backTrialsFaces = sort(randperm(20,n));
    backTrialsVoices = sort(randperm(20,v));
    backTrialsPerson = sort(randperm(20,w));
    
    
    % blocks correspond to modality, so each rep has 3 blocks %
    % blocks are also separate acquisition runs %
    for block = 1:nBlocks
    blockModality = blockModalityVector(block);
    
    if blockModality == visualModality
        r = n;
        backTrials = backTrialsFaces;
    elseif blockModality == auditoryModality
        r = v;
        backTrials = backTrialsVoices;
    elseif blockModality == multiModality
        r = w;
        backTrials = backTrialsPerson;
    end
    
    
            % Set up output file for current run (1 BLOCK = 1 ACQUISITION RUN) % 
            dataFileName = [cd '/data/subj' num2str(subjNumber) '_' expName '_' num2str(rep) '_' num2str(block) '.txt'];

            % format for the output od the data %
            formatString = '%d, %d, %d, %d, %d, %d, %1.3f, %1.3f, %1.3f \n'; 
            keypressFormatString = '%d, %s, %1.3f, \n';

            % open a file for reading AND writing
            % permission 'a' appends data without deleting potential existing content
            if exist(dataFileName, 'file') == 0
                dataFile = fopen(dataFileName, 'a');
                % header
                fprintf(dataFile, ['Experiment:\t' expName '\n']);
                fprintf(dataFile, ['date:\t' datestr(now) '\n']);
                fprintf(dataFile, ['Subject:\t' subjNumber '\n']);
                fprintf(dataFile, ['Age:\t' num2str(subjAge) '\n']);
                % data header
                fprintf(dataFile, '%s \n', 'repetition, block, modality, trial, actor, emotion, stimulus duration, ISI, timestamp'); 
                fclose(dataFile);

            end
    
        % Pseudorandomization made based on emotion vector for the faces
        [pseudoEmoVector,pseudoEmoIndex] = pseudorandptb(stimEmotion);
        for ind=1:length(stimEmotion)
            myExpTrials(pseudoEmoIndex(ind)).pseudorandindex = ind;
        end

        % turn struct into table to reorder it
        tableexptrials = struct2table(myExpTrials);
        pseudorandtabletrials = sortrows(tableexptrials,'pseudorandindex');

        % convert into structure to use in the trial/ stimui loop below
        pseudorandExpTrials = table2struct(pseudorandtabletrials);
        
        
        % add 1-back trials for current block type %
        pseudoRandExpTrialsBack = pseudorandExpTrials;
             for b=1:(length(stimEmotion)+r)
                if r == 1
                    if b <= backTrials
                    pseudoRandExpTrialsBack(b) = pseudorandExpTrials(b);

                    elseif b == backTrials+1 % this trial will have a repeated emotion but a different actor                        
                            % find where the same-emotion-different-actor rows are %
                            emotionVector = [pseudorandExpTrials.emotion]; 
                            emotionIndices = find(emotionVector == pseudorandExpTrials(backTrials).emotion);
                            emotionIndices(emotionIndices==(b-1)) = []; % get rid of current actor 
                            % and choose randomly among the others
                            pseudoRandExpTrialsBack(b) = pseudorandExpTrials(randsample(emotionIndices,1));                          

                    elseif b > backTrials+1
                    pseudoRandExpTrialsBack(b) = pseudorandExpTrials(b-1);

                    end

                elseif r == 2
                    if b <= backTrials(1)
                    pseudoRandExpTrialsBack(b) = pseudorandExpTrials(b);

                    elseif b == backTrials(1)+1 % this trial will have a repeated emotion but a different actor                        
                            % find where the same-emotion-different-actor rows are %
                            emotionVector = [pseudorandExpTrials.emotion]; 
                            emotionIndices = find(emotionVector == pseudorandExpTrials(backTrials(1)).emotion);
                            emotionIndices(emotionIndices==b-1) = []; % get rid of current actor 
                            % and choose randomly among the others
                            pseudoRandExpTrialsBack(b) = pseudorandExpTrials(randsample(emotionIndices,1));

                    elseif b == backTrials(2)+2 % this trial will have a repeated emotion but a different actor                        
                            % find where the same-emotion-different-actor rows are %
                            emotionVector = [pseudorandExpTrials.emotion]; 
                            emotionIndices = find(emotionVector == pseudorandExpTrials(backTrials(2)).emotion);
                            emotionIndices(emotionIndices==b-2) = []; % get rid of current actor 
                            % and choose randomly among the others
                            pseudoRandExpTrialsBack(b) = pseudorandExpTrials(randsample(emotionIndices,1));

                    elseif b > backTrials(1)+1 && b < backTrials(2)+2
                    pseudoRandExpTrialsBack(b) = pseudorandExpTrials(b-1);

                    elseif b > backTrials(2)+2
                    pseudoRandExpTrialsBack(b) = pseudorandExpTrials(b-2);
                    
                    end
                end
             end
        
        % Each Block is for the scanner a new run so the first 3 volumes get discarded each time %
        % trigger
        %waitForTrigger(cfg, -1);
        triggerCounter = 0;
            while triggerCounter < cfg.numTriggers

            keyCode = []; 

            [~, keyCode] = KbPressWait;

            if strcmp(KbName(keyCode), 's')

                triggerCounter = triggerCounter + 1 ;

                % msg = sprintf(' Trigger %i', triggerCounter);
                msg = ['The session will start in',...
                    num2str(cfg.numTriggers-triggerCounter),'...'];

%                 talkToMe(cfg, msg);

%                 % we only wait if this is not the last trigger
%                 if triggerCounter < cfg.numTriggers
%                     pauseBetweenTriggers(cfg);
%                 end

            end
            end

        for trial = 1:(nTrials+r)
            
            % start queuing for triggers and subject's keypresses (flush previous queue) %
            KbQueue('flush');
            KbQueue('start', {'s', 'd'});
    
            % which kind of block is it? Stimulus presentation changes based on modality %
            
            %% visual
            if blockModality == visualModality
                
                if trial == 1
                    DrawFormattedText(mainWindow, 'Pay attention to the faces', 'center', 'center', textColor);
                    [~, ~, lastEventTime] = Screen('Flip', mainWindow);
                    WaitSecs(0.5);
                end

                    % frames presentation loop
                    for f = 1:nFrames   

                       Screen('DrawTexture', mainWindow, pseudoRandExpTrialsBack(trial).visualstimuli(f).imageTexture, [], [], 0);
                       [vlb, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);

                       % time stamp to measure stimulus duration on screen
                       if f == 1
                          stimStart = GetSecs;
                       end

                    end
                    
                % clear last frame                
                Screen('FillRect', mainWindow, bgColor);
                [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);
                
                stimEnd = GetSecs;
                Screen('Flip', mainWindow, stimEnd+ISI);
                [~, ~, ISIend] = Screen('Flip', mainWindow, stimEnd+ISI);

            %% auditory    
            elseif blockModality == auditoryModality
                
                
               if trial == 1
                    DrawFormattedText(mainWindow, 'Pay attention to the voices', 'center', 'center', textColor);
                    Screen('Flip', mainWindow);
                    WaitSecs(0.5);
                    % clear instructions from screen
                    Screen('FillRect', mainWindow, bgColor);
                    [~, ~, lastEventTime] = Screen('Flip', mainWindow);
               end
    
                
            if pseudoRandExpTrialsBack(trial).nrchannels < 2
            wavedata = [pseudoRandExpTrialsBack(trial).wavedata ; pseudoRandExpTrialsBack(trial).wavedata];
            nrchannels = 2;
            end
            
            try
            % Try with the 'freq'uency we wanted:
            pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
            catch
                % Failed. Retry with default frequency as suggested by device:
    
            psychlasterror('reset');
            pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
            end
        
            % Fill the audio playback buffer with the audio data 'wavedata':
            PsychPortAudio('FillBuffer', pahandle, wavedata);

            % Start audio playback for 'repetitions' repetitions of the sound data,
            % start it immediately (0) and wait for the playback to start, return onset
            % timestamp.
            stimStart = GetSecs;
            PsychPortAudio('Start', pahandle, 1, 0, 1);
        

            % Stay in a little loop for the file duration:     
            % use frames presentation loop to get the same duration as in the bimodal condition%
            for f = 1:nFrames   

            Screen('DrawTexture', mainWindow, blackImage, [], [], 0);
            [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);

               % time stamp to measure stimulus duration on screen
%                if f == 1
%                   stimStart = GetSecs;
%                end

            end   

        
            % Stop playback:
            PsychPortAudio('Stop', pahandle);

            % Close the audio device:
            PsychPortAudio('Close', pahandle);
            
            % clear stimulus from screen
            [~, ~, stimEnd] = Screen('Flip', mainWindow);
            [~, ~, ISIend] = Screen('Flip', mainWindow, stimEnd+ISI);

        
            %% bimodal
            elseif blockModality == multiModality      
                
               if trial == 1
                    DrawFormattedText(mainWindow, 'Pay attention to the persons', 'center', 'center', textColor);
                    [~, ~, lastEventTime] = Screen('Flip', mainWindow);
                    WaitSecs(0.5);
               end
                
            % play audio first %
            if pseudoRandExpTrialsBack(trial).nrchannels < 2
            wavedata = [pseudoRandExpTrialsBack(trial).wavedata ; pseudoRandExpTrialsBack(trial).wavedata];
            nrchannels = 2;
            end
            
            try
            % Try with the 'freq'uency we wanted:
            pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
            catch
                % Failed. Retry with default frequency as suggested by device:
    
            psychlasterror('reset');
            pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
            end
        
            % Fill the audio playback buffer with the audio data 'wavedata':
            PsychPortAudio('FillBuffer', pahandle, wavedata);

            % Start audio playback for 'repetitions' repetitions of the sound data,
            % start it immediately (0) and wait for the playback to start, return onset
            % timestamp.
            
            PsychPortAudio('Start', pahandle, 1, 0, 1);
            stimStart = GetSecs;
            
            % frames presentation loop
            for f = 1:nFrames   

            Screen('DrawTexture', mainWindow, pseudoRandExpTrialsBack(trial).visualstimuli(f).imageTexture, [], [], 0);
            [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);

               % time stamp to measure stimulus duration on screen
%                if f == 1
%                   stimStart = GetSecs;
%                end

            end
             
            % Stop playback:
            PsychPortAudio('Stop', pahandle);

            % Close the audio device:
            PsychPortAudio('Close', pahandle);
            
            % end of stimulus timestamp to calculate stim duration
            % flip screen and ISI
            % clear stimulus from screen
            [~, ~, stimEnd] = Screen('Flip', mainWindow);
            [~, ~, ISIend] = Screen('Flip', mainWindow, stimEnd+ISI);
                    
            end
            
                    % SAVE DATA TO THE OUTPUT FILE % header 'rep, block, modality, trial, actor, emotion, stimlus duration'    
                    %save timestamps to output file
                    % write keypresses and timestamps on its file   
                    pressCodeTime = KbQueue('stop', expStart);
                    howManyKeyInputs = size(pressCodeTime);                    
                    dataFile = fopen(dataFileName, 'a');
                    for p = 1:howManyKeyInputs(2)
                    fprintf(dataFile, keypressFormatString, pressCodeTime(1,p), KbName(pressCodeTime(1,p)), pressCodeTime(2,p));
                    end
                    fprintf(dataFile, formatString, rep, block, blockModality, trial,  pseudoRandExpTrialsBack(trial).actor, pseudoRandExpTrialsBack(trial).emotion, stimEnd-stimStart, ISIend-stimEnd, GetSecs);
                    fclose(dataFile);
                

        end

    end
    
    waitForKb('space');
    
end

DrawFormattedText(mainWindow, 'end of experiment :)', 'center', 'center', textColor);
Screen('Flip', mainWindow);
expEnd = GetSecs;
disp('Exp duration:')
disp((expEnd-expStart)/60);
waitForKb('space');
ListenChar(0);
ShowCursor;
sca;